import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';
import '../repositories/google_play_verification_repository.dart';

class GooglePlayPaymentProvider implements PaymentProvider {
  GooglePlayPaymentProvider._();

  static final GooglePlayPaymentProvider instance =
      GooglePlayPaymentProvider._();

  iap.InAppPurchase get _store => iap.InAppPurchase.instance;
  final StreamController<PurchaseUpdate> _updates =
      StreamController<PurchaseUpdate>.broadcast();
  final Map<String, iap.ProductDetails> _products = {};
  final Map<String, PurchaseRequest> _pendingRequests = {};
  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;

  bool _initialized = false;

  @override
  PaymentProviderKind get kind => PaymentProviderKind.googlePlay;

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => _updates.stream;

  void initialize() {
    if (_initialized || !Platform.isAndroid) return;
    _initialized = true;
    _subscription = _store.purchaseStream.listen(
      _handlePurchaseDetails,
      onError: (Object error, StackTrace stackTrace) {
        _updates.add(
          PurchaseUpdate(
            provider: kind,
            productId: '',
            providerTransactionId: '',
            outcome: PurchaseOutcome.failed,
            message: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    initialize();
    return _store.isAvailable();
  }

  @override
  Future<List<BillingProduct>> loadProducts(Set<String> productIds) async {
    if (!await isAvailable()) return const [];
    final response = await _store.queryProductDetails(productIds);
    if (response.error != null) {
      throw StateError(response.error!.message);
    }
    for (final product in response.productDetails) {
      _products.putIfAbsent(product.id, () => product);
    }
    return productIds
        .map((id) => _products[id])
        .whereType<iap.ProductDetails>()
        .map(
          (product) => BillingProduct(
            id: product.id,
            planCode: product.id,
            kind: ProductKind.oneTimeMission,
            title: product.title,
            description: product.description,
            displayPrice: product.price,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<PurchaseResult> purchaseSubscription(PurchaseRequest request) =>
      _startPurchase(request, consumable: false);

  @override
  Future<PurchaseResult> purchaseOneTimeProduct(PurchaseRequest request) =>
      _startPurchase(request, consumable: true);

  Future<PurchaseResult> _startPurchase(
    PurchaseRequest request, {
    required bool consumable,
  }) async {
    if (!await isAvailable()) {
      return PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: kind,
        message: 'Google Play Billing n’est pas disponible sur cet appareil.',
      );
    }
    final details = _products[request.product.id];
    if (details == null) {
      return PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: kind,
        message: 'Le produit Google Play est indisponible.',
      );
    }

    _pendingRequests[request.product.id] = request;
    final purchaseParam = GooglePlayPurchaseParam(
      productDetails: details,
      applicationUserName: request.userId,
      offerToken: consumable || details is! GooglePlayProductDetails
          ? null
          : details.offerToken,
    );
    final launched = consumable
        ? await _store.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: false,
          )
        : await _store.buyNonConsumable(purchaseParam: purchaseParam);
    return PurchaseResult(
      outcome: launched ? PurchaseOutcome.pending : PurchaseOutcome.failed,
      provider: kind,
      message: launched
          ? 'Paiement Google Play en attente de confirmation.'
          : 'Google Play n’a pas pu ouvrir le paiement.',
    );
  }

  Future<void> _handlePurchaseDetails(
    List<iap.PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case iap.PurchaseStatus.pending:
          _emit(purchase, PurchaseOutcome.pending);
        case iap.PurchaseStatus.canceled:
          _pendingRequests.remove(purchase.productID);
          _emit(purchase, PurchaseOutcome.canceled);
        case iap.PurchaseStatus.error:
          _pendingRequests.remove(purchase.productID);
          _emit(purchase, PurchaseOutcome.failed, purchase.error?.message);
        case iap.PurchaseStatus.purchased:
        case iap.PurchaseStatus.restored:
          await _verifyAndComplete(purchase);
      }
    }
  }

  Future<void> _verifyAndComplete(iap.PurchaseDetails purchase) async {
    final request = _pendingRequests[purchase.productID];
    final productKind =
        request?.product.kind ?? _inferProductKind(purchase.productID);
    try {
      final result = await GooglePlayVerificationRepository().verify(
        productId: purchase.productID,
        purchaseToken: purchase.verificationData.serverVerificationData,
        productKind: productKind,
        missionId: request?.missionId,
      );
      if (!result.verified) {
        _emit(purchase, result.outcome, result.message);
        return;
      }
      if (purchase.pendingCompletePurchase) {
        try {
          await _store.completePurchase(purchase);
        } catch (_) {
          // Le backend a déjà reconnu et finalisé l’achat Google Play.
        }
      }
      _pendingRequests.remove(purchase.productID);
      _updates.add(
        PurchaseUpdate(
          provider: kind,
          productId: purchase.productID,
          providerTransactionId:
              result.transactionId ?? purchase.purchaseID ?? '',
          outcome: PurchaseOutcome.succeeded,
          message: result.message,
        ),
      );
    } catch (error) {
      _emit(
        purchase,
        PurchaseOutcome.failed,
        'Validation serveur impossible : $error',
      );
    }
  }

  ProductKind _inferProductKind(String productId) {
    return productId.toLowerCase().contains('mission')
        ? ProductKind.oneTimeMission
        : ProductKind.subscription;
  }

  void _emit(
    iap.PurchaseDetails purchase,
    PurchaseOutcome outcome, [
    String? message,
  ]) {
    _updates.add(
      PurchaseUpdate(
        provider: kind,
        productId: purchase.productID,
        providerTransactionId: purchase.purchaseID ?? '',
        outcome: outcome,
        message: message,
      ),
    );
  }

  @override
  Future<void> restorePurchases() async {
    if (!await isAvailable()) {
      throw StateError('Google Play Billing n’est pas disponible.');
    }
    await _store.restorePurchases();
  }

  @override
  Future<void> openSubscriptionManagement() async {
    const packageName = String.fromEnvironment(
      'GOOGLE_PLAY_PACKAGE_NAME',
      defaultValue: 'com.example.flutter_app',
    );
    final uri = Uri.https(
      'play.google.com',
      '/store/account/subscriptions',
      <String, String>{'package': packageName},
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Impossible d’ouvrir la gestion Google Play.');
    }
  }

  Future<void> disposeForTesting() async {
    await _subscription?.cancel();
    await _updates.close();
  }
}
