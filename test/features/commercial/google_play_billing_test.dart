import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/infrastructure/payments/google_play_subscription_status_mapper.dart';
import 'package:flutter_app/features/commercial/infrastructure/payments/payment_provider_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mapper = GooglePlaySubscriptionStatusMapper();

  test('normalise les principaux états Google Play', () {
    expect(
      mapper.fromProviderStatus('SUBSCRIPTION_STATE_ACTIVE'),
      SubscriptionStatus.active,
    );
    expect(
      mapper.fromProviderStatus('SUBSCRIPTION_STATE_IN_GRACE_PERIOD'),
      SubscriptionStatus.gracePeriod,
    );
    expect(
      mapper.fromProviderStatus('SUBSCRIPTION_STATE_ON_HOLD'),
      SubscriptionStatus.pastDue,
    );
    expect(
      mapper.fromProviderStatus('SUBSCRIPTION_STATE_EXPIRED'),
      SubscriptionStatus.expired,
    );
  });

  test('un état Google inconnu ne donne jamais accès', () {
    expect(
      mapper.fromProviderStatus('SUBSCRIPTION_STATE_FUTURE'),
      SubscriptionStatus.failed,
    );
  });

  test('la factory sélectionne le fournisseur natif de chaque mobile', () {
    const factory = DefaultPaymentProviderFactory();
    expect(
      factory.forPlatform(CommercialPlatform.android).kind,
      PaymentProviderKind.googlePlay,
    );
    expect(
      factory.forPlatform(CommercialPlatform.ios).kind,
      PaymentProviderKind.apple,
    );
  });
}
