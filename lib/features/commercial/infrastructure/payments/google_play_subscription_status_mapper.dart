import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';

class GooglePlaySubscriptionStatusMapper implements SubscriptionStatusMapper {
  const GooglePlaySubscriptionStatusMapper();

  @override
  SubscriptionStatus fromProviderStatus(String providerStatus) {
    return switch (providerStatus.toUpperCase()) {
      'SUBSCRIPTION_STATE_PENDING' => SubscriptionStatus.pending,
      'SUBSCRIPTION_STATE_ACTIVE' => SubscriptionStatus.active,
      'SUBSCRIPTION_STATE_IN_GRACE_PERIOD' => SubscriptionStatus.gracePeriod,
      'SUBSCRIPTION_STATE_ON_HOLD' => SubscriptionStatus.pastDue,
      'SUBSCRIPTION_STATE_PAUSED' => SubscriptionStatus.suspended,
      'SUBSCRIPTION_STATE_CANCELED' => SubscriptionStatus.canceled,
      'SUBSCRIPTION_STATE_EXPIRED' => SubscriptionStatus.expired,
      _ => SubscriptionStatus.failed,
    };
  }
}
