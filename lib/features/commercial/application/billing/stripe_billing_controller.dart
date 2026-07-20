import '../../../../core/auth/auth_service.dart';
import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../../infrastructure/payments/stripe_payment_provider.dart';
import '../../infrastructure/repositories/supabase_provider_product_repository.dart';
import '../../presentation/commercial_formatters.dart';

class StripeBillingController {
  StripeBillingController({
    StripePaymentProvider? provider,
    SupabaseProviderProductRepository? productRepository,
  }) : _provider = provider ?? StripePaymentProvider.instance,
       _productRepository =
           productRepository ?? SupabaseProviderProductRepository();

  final StripePaymentProvider _provider;
  final SupabaseProviderProductRepository _productRepository;

  Future<BillingProduct> loadProduct(SubscriptionPlan plan) async {
    final mapping = await _productRepository.findStripeProduct(plan.code);
    if (mapping == null) {
      throw StateError('Aucun prix Stripe actif n’est associé à ${plan.name}.');
    }
    return BillingProduct(
      id: mapping.providerProductId,
      planCode: plan.code,
      kind: plan.billingPeriod == BillingPeriod.monthly
          ? ProductKind.subscription
          : ProductKind.oneTimeMission,
      title: plan.name,
      description: plan.description,
      displayPrice: CommercialFormatters.money(plan.priceMinor, plan.currency),
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
        provider: PaymentProviderKind.stripe,
        message: 'Connectez-vous avant de lancer un paiement.',
      );
    }
    final request = PurchaseRequest(
      product: product,
      userId: user.id,
      missionId: missionId,
      idempotencyKey:
          'stripe:${user.id}:${DateTime.now().microsecondsSinceEpoch}',
    );
    return product.kind == ProductKind.subscription
        ? _provider.purchaseSubscription(request)
        : _provider.purchaseOneTimeProduct(request);
  }

  Future<String> checkoutStatus(String sessionId) =>
      _provider.checkoutStatus(sessionId);

  Future<void> manageSubscription() => _provider.openSubscriptionManagement();
}
