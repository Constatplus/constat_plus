import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/infrastructure/payments/apple_subscription_status_mapper.dart';
import 'package:flutter_app/features/commercial/infrastructure/payments/payment_provider_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mapper = AppleSubscriptionStatusMapper();

  test('normalise les principaux états Apple', () {
    expect(mapper.fromProviderStatus('active'), SubscriptionStatus.active);
    expect(
      mapper.fromProviderStatus('grace_period'),
      SubscriptionStatus.gracePeriod,
    );
    expect(mapper.fromProviderStatus('past_due'), SubscriptionStatus.pastDue);
    expect(mapper.fromProviderStatus('expired'), SubscriptionStatus.expired);
    expect(mapper.fromProviderStatus('refunded'), SubscriptionStatus.canceled);
  });

  test('un état Apple inconnu ne donne jamais accès', () {
    final status = mapper.fromProviderStatus('future_status');
    expect(status, SubscriptionStatus.failed);
    expect(status.grantsAccess, isFalse);
  });

  test('la factory sélectionne Apple pour iOS', () {
    const factory = DefaultPaymentProviderFactory();
    expect(
      factory.forPlatform(CommercialPlatform.ios).kind,
      PaymentProviderKind.apple,
    );
  });
}
