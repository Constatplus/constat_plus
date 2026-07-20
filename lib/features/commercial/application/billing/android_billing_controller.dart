import 'dart:async';

import '../../../../core/auth/auth_service.dart';
import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../../infrastructure/payments/google_play_payment_provider.dart';
import '../../infrastructure/repositories/supabase_provider_product_repository.dart';

class AndroidBillingController {
  AndroidBillingController({
    GooglePlayPaymentProvider? provider,
    SupabaseProviderProductRepository? productRepository,
  }) : _provider = provider ?? GooglePlayPaymentProvider.instance,
       _productRepository =
           productRepository ?? SupabaseProviderProductRepository();

  final GooglePlayPaymentProvider _provider;
  final SupabaseProviderProductRepository _productRepository;

  Stream<PurchaseUpdate> get updates => _provider.purchaseUpdates;

  Future<BillingProduct> loadProduct(SubscriptionPlan plan) async {
    final mapping = await _productRepository.findGooglePlayProduct(plan.code);
    if (mapping == null) {
      throw StateError(
        'Aucun produit Google Play actif n’est associé à ${plan.name}.',
      );
    }
    final products = await _provider.loadProducts({mapping.providerProductId});
    if (products.isEmpty) {
      throw StateError(
        'Le produit ${mapping.providerProductId} est introuvable dans Google Play.',
      );
    }
    final storeProduct = products.single;
    return BillingProduct(
      id: storeProduct.id,
      planCode: plan.code,
      kind: plan.billingPeriod == BillingPeriod.monthly
          ? ProductKind.subscription
          : ProductKind.oneTimeMission,
      title: storeProduct.title,
      description: storeProduct.description,
      displayPrice: storeProduct.displayPrice,
    );
  }

  Future<PurchaseResult> purchase(
    BillingProduct product, {
    String? missionId,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) {
      return const PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: PaymentProviderKind.googlePlay,
        message: 'Connectez-vous avant de lancer un paiement.',
      );
    }
    final request = PurchaseRequest(
      product: product,
      userId: user.id,
      missionId: missionId,
      idempotencyKey:
          'google-play:${user.id}:${DateTime.now().microsecondsSinceEpoch}',
    );
    return product.kind == ProductKind.subscription
        ? _provider.purchaseSubscription(request)
        : _provider.purchaseOneTimeProduct(request);
  }

  Future<void> restorePurchases() => _provider.restorePurchases();

  Future<void> manageSubscription() => _provider.openSubscriptionManagement();
}
