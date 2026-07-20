import 'commercial_enums.dart';
import 'one_time_purchase.dart';
import 'subscription_plan.dart';
import 'usage_period.dart';
import 'user_subscription.dart';

class MissionEntitlement {
  final String missionId;
  final String sourceId;
  final bool includesAiAnalysis;
  final DateTime grantedAt;

  const MissionEntitlement({
    required this.missionId,
    required this.sourceId,
    required this.includesAiAnalysis,
    required this.grantedAt,
  });
}

class EntitlementSnapshot {
  final bool authenticated;
  final AccountStatus accountStatus;
  final SubscriptionPlan? plan;
  final UserSubscription? subscription;
  final UsagePeriod? usagePeriod;
  final List<OneTimePurchase> oneTimePurchases;
  final Map<String, MissionEntitlement> missionEntitlements;
  final Set<String> existingMissionIds;
  final int activeOrganizationUsers;
  final DateTime verifiedAt;
  final DateTime validUntil;

  const EntitlementSnapshot({
    required this.authenticated,
    required this.accountStatus,
    this.plan,
    this.subscription,
    this.usagePeriod,
    this.oneTimePurchases = const [],
    this.missionEntitlements = const {},
    this.existingMissionIds = const {},
    this.activeOrganizationUsers = 1,
    required this.verifiedAt,
    required this.validUntil,
  }) : assert(activeOrganizationUsers >= 0);

  bool isFreshAt(DateTime instant) => !instant.isAfter(validUntil);

  bool hasMissionEntitlement(String? missionId) =>
      missionId != null && missionEntitlements.containsKey(missionId);

  bool get hasAssignablePurchase =>
      oneTimePurchases.any((purchase) => purchase.canBeAssigned);
}

class EntitlementDecision {
  final bool allowed;
  final EntitlementReason reason;
  final bool readOnly;
  final bool requiresOnlineConfirmation;

  const EntitlementDecision._({
    required this.allowed,
    required this.reason,
    this.readOnly = false,
    this.requiresOnlineConfirmation = false,
  });

  const EntitlementDecision.allow({
    bool readOnly = false,
    bool requiresOnlineConfirmation = false,
  }) : this._(
         allowed: true,
         reason: EntitlementReason.allowed,
         readOnly: readOnly,
         requiresOnlineConfirmation: requiresOnlineConfirmation,
       );

  const EntitlementDecision.deny(
    EntitlementReason reason, {
    bool readOnly = false,
  }) : this._(allowed: false, reason: reason, readOnly: readOnly);
}
