import '../models/billing_models.dart';
import '../models/commercial_enums.dart';

abstract interface class BillingProvider {
  PaymentProviderKind get kind;

  Stream<PurchaseUpdate> get purchaseUpdates;

  Future<bool> isAvailable();

  Future<List<BillingProduct>> loadProducts(Set<String> productIds);
}

abstract interface class PaymentProvider implements BillingProvider {
  Future<PurchaseResult> purchaseSubscription(PurchaseRequest request);

  Future<PurchaseResult> purchaseOneTimeProduct(PurchaseRequest request);

  Future<void> restorePurchases();

  Future<void> openSubscriptionManagement();
}

abstract interface class PaymentProviderFactory {
  PaymentProvider forPlatform(CommercialPlatform platform);
}

abstract interface class SubscriptionStatusMapper {
  SubscriptionStatus fromProviderStatus(String providerStatus);
}
