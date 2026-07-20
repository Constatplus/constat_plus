import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';

class StripeSubscriptionStatusMapper implements SubscriptionStatusMapper {
  const StripeSubscriptionStatusMapper();

  @override
  SubscriptionStatus fromProviderStatus(String providerStatus) {
    return switch (providerStatus.toLowerCase()) {
      'active' => SubscriptionStatus.active,
      'past_due' => SubscriptionStatus.pastDue,
      'unpaid' || 'paused' => SubscriptionStatus.suspended,
      'canceled' => SubscriptionStatus.canceled,
      'incomplete' => SubscriptionStatus.incomplete,
      'incomplete_expired' => SubscriptionStatus.expired,
      _ => SubscriptionStatus.failed,
    };
  }
}
