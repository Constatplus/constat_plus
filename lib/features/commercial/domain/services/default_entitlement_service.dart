import '../models/commercial_enums.dart';
import '../models/entitlement_snapshot.dart';
import 'commercial_services.dart';

class DefaultEntitlementService implements EntitlementService {
  const DefaultEntitlementService();

  @override
  EntitlementDecision evaluate({
    required CommercialAction action,
    required EntitlementSnapshot snapshot,
    required DateTime now,
    String? missionId,
  }) {
    if (!snapshot.authenticated) {
      return const EntitlementDecision.deny(EntitlementReason.notAuthenticated);
    }

    if (action == CommercialAction.readExistingMission) {
      if (missionId == null ||
          !snapshot.existingMissionIds.contains(missionId)) {
        return const EntitlementDecision.deny(
          EntitlementReason.missionNotFound,
        );
      }
      return const EntitlementDecision.allow(readOnly: true);
    }

    if (snapshot.accountStatus != AccountStatus.active) {
      return const EntitlementDecision.deny(
        EntitlementReason.accountInactive,
        readOnly: true,
      );
    }

    if (action == CommercialAction.createMissionDraft) {
      return const EntitlementDecision.allow();
    }

    final subscriptionIsEffective =
        snapshot.subscription?.isEffectiveAt(now) ?? false;
    final plan = snapshot.plan;
    final usage = snapshot.usagePeriod;

    if (action == CommercialAction.manageCollaborators) {
      if (!subscriptionIsEffective || plan == null) {
        return const EntitlementDecision.deny(
          EntitlementReason.subscriptionRequired,
        );
      }
      if (snapshot.activeOrganizationUsers >= plan.maximumUsers) {
        return const EntitlementDecision.deny(
          EntitlementReason.maximumUsersReached,
        );
      }
      return const EntitlementDecision.allow(requiresOnlineConfirmation: true);
    }

    if (action == CommercialAction.useAiAnalysis) {
      final missionAccess = snapshot.hasMissionEntitlement(missionId);
      if (missionAccess) {
        final missionEntitlement = snapshot.missionEntitlements[missionId];
        if (missionEntitlement!.includesAiAnalysis) {
          return const EntitlementDecision.allow(
            requiresOnlineConfirmation: true,
          );
        }
      }
      if (!subscriptionIsEffective || plan == null || usage == null) {
        return const EntitlementDecision.deny(
          EntitlementReason.subscriptionRequired,
        );
      }
      if (usage.remainingAiAnalyses(plan.aiAnalysisQuota) == 0) {
        return const EntitlementDecision.deny(EntitlementReason.aiQuotaReached);
      }
      return const EntitlementDecision.allow(requiresOnlineConfirmation: true);
    }

    if (snapshot.hasMissionEntitlement(missionId)) {
      return const EntitlementDecision.allow(requiresOnlineConfirmation: true);
    }

    if (!subscriptionIsEffective || plan == null || usage == null) {
      return EntitlementDecision.deny(
        snapshot.hasAssignablePurchase
            ? EntitlementReason.missionPaymentRequired
            : EntitlementReason.subscriptionRequired,
      );
    }

    if (usage.remainingMissions(plan.missionQuota) == 0) {
      return const EntitlementDecision.deny(
        EntitlementReason.missionQuotaReached,
      );
    }

    return const EntitlementDecision.allow(requiresOnlineConfirmation: true);
  }
}
