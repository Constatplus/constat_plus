import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/infrastructure/payments/payment_provider_factory.dart';
import 'package:flutter_app/features/commercial/infrastructure/payments/stripe_subscription_status_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mapper = StripeSubscriptionStatusMapper();

  test('normalise les principaux états Stripe', () {
    expect(mapper.fromProviderStatus('active'), SubscriptionStatus.active);
    expect(
      mapper.fromProviderStatus('future_status'),
      SubscriptionStatus.failed,
    );
    expect(mapper.fromProviderStatus('past_due'), SubscriptionStatus.pastDue);
    expect(mapper.fromProviderStatus('unpaid'), SubscriptionStatus.suspended);
    expect(mapper.fromProviderStatus('paused'), SubscriptionStatus.suspended);
    expect(mapper.fromProviderStatus('canceled'), SubscriptionStatus.canceled);
    expect(
      mapper.fromProviderStatus('incomplete_expired'),
      SubscriptionStatus.expired,
    );
  });

  test('un état Stripe inconnu ne donne jamais accès', () {
    final status = mapper.fromProviderStatus('future_status');
    expect(status, SubscriptionStatus.failed);
    expect(status.grantsAccess, isFalse);
  });

  test('la factory sélectionne Stripe pour Windows', () {
    const factory = DefaultPaymentProviderFactory();
    expect(
      factory.forPlatform(CommercialPlatform.windows).kind,
      PaymentProviderKind.stripe,
    );
  });
}
