enum BillingPeriod { none, monthly }

enum CommercialPlatform { android, windows, ios }

enum PaymentProviderKind { googlePlay, stripe, apple, demo }

enum ProductKind { subscription, oneTimeMission }

enum AccountStatus { pending, active, suspended, closed }

enum SubscriptionStatus {
  pending,
  active,
  gracePeriod,
  pastDue,
  suspended,
  canceled,
  expired,
  incomplete,
  failed,
}

extension SubscriptionStatusAccess on SubscriptionStatus {
  bool get grantsAccess => this == SubscriptionStatus.active;
}

enum PurchaseStatus { pending, verified, assigned, refunded, canceled, failed }

enum CommercialAction {
  createMissionDraft,
  finalizeMission,
  generateFinalReport,
  useAiAnalysis,
  readExistingMission,
  manageCollaborators,
}

enum EntitlementReason {
  allowed,
  notAuthenticated,
  accountInactive,
  missionNotFound,
  missionPaymentRequired,
  missionQuotaReached,
  aiQuotaReached,
  subscriptionRequired,
  maximumUsersReached,
}

enum PurchaseOutcome { pending, succeeded, canceled, failed }
