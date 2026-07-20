import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';

class AppleSubscriptionStatusMapper implements SubscriptionStatusMapper {
  const AppleSubscriptionStatusMapper();

  @override
  SubscriptionStatus fromProviderStatus(String providerStatus) {
    return switch (providerStatus.toUpperCase()) {
      'ACTIVE' => SubscriptionStatus.active,
      'GRACE_PERIOD' => SubscriptionStatus.gracePeriod,
      'PAST_DUE' => SubscriptionStatus.pastDue,
      'CANCELED' => SubscriptionStatus.canceled,
      'EXPIRED' => SubscriptionStatus.expired,
      'PENDING' => SubscriptionStatus.pending,
      'REFUNDED' || 'REVOKED' => SubscriptionStatus.canceled,
      _ => SubscriptionStatus.failed,
    };
  }
}
