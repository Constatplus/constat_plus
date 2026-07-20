import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';
import '../repositories/apple_verification_repository.dart';

class ApplePaymentProvider implements PaymentProvider {
  ApplePaymentProvider._();

  static final ApplePaymentProvider instance = ApplePaymentProvider._();

  iap.InAppPurchase get _store => iap.InAppPurchase.instance;
  final StreamController<PurchaseUpdate> _updates =
      StreamController<PurchaseUpdate>.broadcast();
  final Map<String, iap.ProductDetails> _products = {};
  final Map<String, PurchaseRequest> _pendingRequests = {};
  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;
  bool _initialized = false;

  @override
  PaymentProviderKind get kind => PaymentProviderKind.apple;

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => _updates.stream;

  void initialize() {
    if (_initialized || !Platform.isIOS) return;
    _initialized = true;
    _subscription = _store.purchaseStream.listen(
      _handlePurchases,
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
    if (!Platform.isIOS) return false;
    initialize();
    return _store.isAvailable();
  }

  @override
  Future<List<BillingProduct>> loadProducts(Set<String> productIds) async {
    if (!await isAvailable()) return const [];
    final response = await _store.queryProductDetails(productIds);
    if (response.error != null) throw StateError(response.error!.message);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
    return productIds
        .map((id) => _products[id])
        .whereType<iap.ProductDetails>()
        .map(
          (product) => BillingProduct(
            id: product.id,
            planCode: product.id,
            kind: _inferProductKind(product.id),
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
      return const PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: PaymentProviderKind.apple,
        message: 'Les achats intégrés Apple ne sont pas disponibles.',
      );
    }
    final details = _products[request.product.id];
    if (details == null) {
      return const PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: PaymentProviderKind.apple,
        message: 'Le produit Apple est indisponible.',
      );
    }
    _pendingRequests[request.product.id] = request;
    final purchaseParam = iap.PurchaseParam(
      productDetails: details,
      applicationUserName: request.userId,
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
          ? 'Paiement Apple en attente de confirmation.'
          : 'L’App Store n’a pas pu ouvrir le paiement.',
    );
  }

  Future<void> _handlePurchases(List<iap.PurchaseDetails> purchases) async {
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
    final transactionId = purchase.purchaseID;
    if (transactionId == null || transactionId.isEmpty) {
      _emit(
        purchase,
        PurchaseOutcome.failed,
        'Identifiant de transaction Apple absent.',
      );
      return;
    }
    final request = _pendingRequests[purchase.productID];
    final productKind =
        request?.product.kind ?? _inferProductKind(purchase.productID);
    try {
      final result = await AppleVerificationRepository().verify(
        productId: purchase.productID,
        transactionId: transactionId,
        signedTransaction: purchase.verificationData.serverVerificationData,
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
          // Le serveur a déjà enregistré cette transaction de façon idempotente.
        }
      }
      _pendingRequests.remove(purchase.productID);
      _updates.add(
        PurchaseUpdate(
          provider: kind,
          productId: purchase.productID,
          providerTransactionId: result.transactionId ?? transactionId,
          outcome: PurchaseOutcome.succeeded,
          message: result.message,
        ),
      );
    } catch (error) {
      _emit(
        purchase,
        PurchaseOutcome.failed,
        'Validation serveur Apple impossible : $error',
      );
    }
  }

  ProductKind _inferProductKind(String productId) =>
      productId.toLowerCase().contains('mission')
      ? ProductKind.oneTimeMission
      : ProductKind.subscription;

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
      throw StateError('Les achats intégrés Apple ne sont pas disponibles.');
    }
    await _store.restorePurchases();
  }

  @override
  Future<void> openSubscriptionManagement() async {
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Impossible d’ouvrir la gestion des abonnements Apple.');
    }
  }

  Future<void> disposeForTesting() async {
    await _subscription?.cancel();
    await _updates.close();
  }
}
