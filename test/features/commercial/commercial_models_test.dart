import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/domain/models/one_time_purchase.dart';
import 'package:flutter_app/features/commercial/domain/models/usage_period.dart';
import 'package:flutter_app/features/commercial/domain/models/user_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 7, 20);

  test('les compteurs restants ne deviennent jamais négatifs', () {
    final usage = UsagePeriod(
      id: 'usage-1',
      userId: 'user-1',
      periodStart: now,
      periodEnd: now.add(const Duration(days: 30)),
      missionsUsed: 8,
      aiAnalysesUsed: 12,
      createdAt: now,
      updatedAt: now,
    );

    expect(usage.remainingMissions(5), 0);
    expect(usage.remainingAiAnalyses(10), 0);
  });

  test('seuls les statuts prévus accordent un abonnement', () {
    expect(SubscriptionStatus.active.grantsAccess, isTrue);
    expect(SubscriptionStatus.gracePeriod.grantsAccess, isFalse);
    expect(SubscriptionStatus.pastDue.grantsAccess, isFalse);
    expect(SubscriptionStatus.canceled.grantsAccess, isFalse);
  });

  test('un achat vérifié non associé peut être affecté à une mission', () {
    final purchase = OneTimePurchase(
      id: 'purchase-1',
      userId: 'user-1',
      provider: PaymentProviderKind.googlePlay,
      providerTransactionId: 'transaction-1',
      providerProductId: 'constat_mission_1',
      amountMinor: 6900,
      currency: 'EUR',
      status: PurchaseStatus.verified,
      purchasedAt: now,
      verifiedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    expect(purchase.canBeAssigned, isTrue);
  });

  test(
    'une période de grâce conserve la lecture mais bloque les droits actifs',
    () {
      final subscription = UserSubscription(
        id: 'subscription-1',
        userId: 'user-1',
        planCode: 'solo',
        provider: PaymentProviderKind.stripe,
        providerSubscriptionId: 'sub-1',
        providerProductId: 'price-1',
        status: SubscriptionStatus.gracePeriod,
        startedAt: now.subtract(const Duration(days: 30)),
        currentPeriodStart: now.subtract(const Duration(days: 30)),
        currentPeriodEnd: now,
        gracePeriodEnd: now.add(const Duration(days: 2)),
        lastVerifiedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        subscription.isEffectiveAt(now.add(const Duration(days: 1))),
        isFalse,
      );
      expect(
        subscription.isEffectiveAt(now.add(const Duration(days: 3))),
        isFalse,
      );
    },
  );

  test('la période d’usage est bornée et change au renouvellement', () {
    final usage = UsagePeriod(
      id: 'usage-1',
      userId: 'user-1',
      periodStart: now,
      periodEnd: now.add(const Duration(days: 30)),
      missionsUsed: 0,
      aiAnalysesUsed: 0,
      createdAt: now,
      updatedAt: now,
    );

    expect(usage.contains(now), isTrue);
    expect(usage.contains(now.add(const Duration(days: 29))), isTrue);
    expect(usage.contains(now.add(const Duration(days: 30))), isFalse);
  });
}
