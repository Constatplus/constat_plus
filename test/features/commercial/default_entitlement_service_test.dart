import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/domain/models/entitlement_snapshot.dart';
import 'package:flutter_app/features/commercial/domain/models/subscription_plan.dart';
import 'package:flutter_app/features/commercial/domain/models/usage_period.dart';
import 'package:flutter_app/features/commercial/domain/models/user_subscription.dart';
import 'package:flutter_app/features/commercial/domain/services/default_entitlement_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = DefaultEntitlementService();
  final now = DateTime.utc(2026, 7, 20, 12);

  group('DefaultEntitlementService', () {
    test('refuse un utilisateur non connecté', () {
      final decision = service.evaluate(
        action: CommercialAction.createMissionDraft,
        snapshot: _snapshot(now, authenticated: false),
        now: now,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, EntitlementReason.notAuthenticated);
    });

    test('autorise la lecture d’une ancienne mission après expiration', () {
      final decision = service.evaluate(
        action: CommercialAction.readExistingMission,
        snapshot: _snapshot(
          now,
          accountStatus: AccountStatus.suspended,
          existingMissionIds: const {'mission-1'},
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isTrue);
      expect(decision.readOnly, isTrue);
    });

    test('autorise un brouillon sans consommer de mission', () {
      final decision = service.evaluate(
        action: CommercialAction.createMissionDraft,
        snapshot: _snapshot(now),
        now: now,
      );

      expect(decision.allowed, isTrue);
      expect(decision.requiresOnlineConfirmation, isFalse);
    });

    test('autorise la finalisation avec un quota disponible', () {
      final decision = service.evaluate(
        action: CommercialAction.finalizeMission,
        snapshot: _snapshot(
          now,
          plan: _plan(now, missionQuota: 5),
          subscription: _subscription(now),
          usagePeriod: _usage(now, missionsUsed: 4),
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isTrue);
      expect(decision.requiresOnlineConfirmation, isTrue);
    });

    test('refuse la finalisation lorsque le quota est atteint', () {
      final decision = service.evaluate(
        action: CommercialAction.finalizeMission,
        snapshot: _snapshot(
          now,
          plan: _plan(now, missionQuota: 5),
          subscription: _subscription(now),
          usagePeriod: _usage(now, missionsUsed: 5),
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, EntitlementReason.missionQuotaReached);
    });

    test('une mission déjà couverte ne consomme pas un second quota', () {
      final decision = service.evaluate(
        action: CommercialAction.generateFinalReport,
        snapshot: _snapshot(
          now,
          missionEntitlements: {
            'mission-1': MissionEntitlement(
              missionId: 'mission-1',
              sourceId: 'purchase-1',
              includesAiAnalysis: false,
              grantedAt: now,
            ),
          },
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isTrue);
      expect(decision.requiresOnlineConfirmation, isTrue);
    });

    test('refuse une analyse IA lorsque son quota est atteint', () {
      final decision = service.evaluate(
        action: CommercialAction.useAiAnalysis,
        snapshot: _snapshot(
          now,
          plan: _plan(now, aiQuota: 10),
          subscription: _subscription(now),
          usagePeriod: _usage(now, aiUsed: 10),
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, EntitlementReason.aiQuotaReached);
    });

    test('un abonnement en retard conserve seulement la lecture', () {
      final decision = service.evaluate(
        action: CommercialAction.generateFinalReport,
        snapshot: _snapshot(
          now,
          plan: _plan(now),
          subscription: _subscription(now, status: SubscriptionStatus.pastDue),
          usagePeriod: _usage(now),
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, EntitlementReason.subscriptionRequired);
    });

    test('un abonnement expiré ne donne plus de droit d’écriture', () {
      final decision = service.evaluate(
        action: CommercialAction.finalizeMission,
        snapshot: _snapshot(
          now,
          plan: _plan(now),
          subscription: _subscription(now, status: SubscriptionStatus.expired),
          usagePeriod: _usage(now),
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, EntitlementReason.subscriptionRequired);
    });

    test('un achat unitaire peut inclure explicitement une analyse IA', () {
      final decision = service.evaluate(
        action: CommercialAction.useAiAnalysis,
        snapshot: _snapshot(
          now,
          missionEntitlements: {
            'mission-1': MissionEntitlement(
              missionId: 'mission-1',
              sourceId: 'purchase-1',
              includesAiAnalysis: true,
              grantedAt: now,
            ),
          },
        ),
        now: now,
        missionId: 'mission-1',
      );

      expect(decision.allowed, isTrue);
      expect(decision.requiresOnlineConfirmation, isTrue);
    });

    test('respecte le nombre maximal de collaborateurs du plan', () {
      final decision = service.evaluate(
        action: CommercialAction.manageCollaborators,
        snapshot: _snapshot(
          now,
          plan: _plan(now),
          subscription: _subscription(now),
          usagePeriod: _usage(now),
          activeOrganizationUsers: 1,
        ),
        now: now,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, EntitlementReason.maximumUsersReached);
    });
  });
}

EntitlementSnapshot _snapshot(
  DateTime now, {
  bool authenticated = true,
  AccountStatus accountStatus = AccountStatus.active,
  SubscriptionPlan? plan,
  UserSubscription? subscription,
  UsagePeriod? usagePeriod,
  Map<String, MissionEntitlement> missionEntitlements = const {},
  Set<String> existingMissionIds = const {},
  int activeOrganizationUsers = 1,
}) {
  return EntitlementSnapshot(
    authenticated: authenticated,
    accountStatus: accountStatus,
    plan: plan,
    subscription: subscription,
    usagePeriod: usagePeriod,
    missionEntitlements: missionEntitlements,
    existingMissionIds: existingMissionIds,
    activeOrganizationUsers: activeOrganizationUsers,
    verifiedAt: now,
    validUntil: now.add(const Duration(hours: 24)),
  );
}

SubscriptionPlan _plan(DateTime now, {int missionQuota = 5, int aiQuota = 10}) {
  return SubscriptionPlan(
    id: 'plan-solo',
    code: 'solo',
    name: 'Solo',
    description: 'Offre Solo',
    billingPeriod: BillingPeriod.monthly,
    priceMinor: 9900,
    currency: 'EUR',
    missionQuota: missionQuota,
    aiAnalysisQuota: aiQuota,
    maximumUsers: 1,
    platformAvailability: CommercialPlatform.values.toSet(),
    active: true,
    createdAt: now,
    updatedAt: now,
  );
}

UserSubscription _subscription(
  DateTime now, {
  SubscriptionStatus status = SubscriptionStatus.active,
}) {
  return UserSubscription(
    id: 'subscription-1',
    userId: 'user-1',
    planCode: 'solo',
    provider: PaymentProviderKind.googlePlay,
    providerSubscriptionId: 'provider-subscription-1',
    providerProductId: 'constat_solo_monthly',
    status: status,
    startedAt: now.subtract(const Duration(days: 10)),
    currentPeriodStart: now.subtract(const Duration(days: 10)),
    currentPeriodEnd: now.add(const Duration(days: 20)),
    lastVerifiedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

UsagePeriod _usage(DateTime now, {int missionsUsed = 0, int aiUsed = 0}) {
  return UsagePeriod(
    id: 'usage-1',
    userId: 'user-1',
    periodStart: now.subtract(const Duration(days: 10)),
    periodEnd: now.add(const Duration(days: 20)),
    missionsUsed: missionsUsed,
    aiAnalysesUsed: aiUsed,
    createdAt: now,
    updatedAt: now,
  );
}
