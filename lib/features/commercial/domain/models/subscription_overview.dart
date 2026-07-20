import 'one_time_purchase.dart';
import 'subscription_plan.dart';
import 'usage_period.dart';
import 'user_subscription.dart';

class SubscriptionOverview {
  final SubscriptionPlan? plan;
  final UserSubscription? subscription;
  final UsagePeriod? usagePeriod;
  final List<OneTimePurchase> purchases;
  final DateTime loadedAt;

  const SubscriptionOverview({
    this.plan,
    this.subscription,
    this.usagePeriod,
    this.purchases = const [],
    required this.loadedAt,
  });

  bool get hasSubscription => plan != null && subscription != null;

  int get remainingMissions => plan == null || usagePeriod == null
      ? 0
      : usagePeriod!.remainingMissions(plan!.missionQuota);

  int get remainingAiAnalyses => plan == null || usagePeriod == null
      ? 0
      : usagePeriod!.remainingAiAnalyses(plan!.aiAnalysisQuota);

  int get availableOneTimeMissions =>
      purchases.where((purchase) => purchase.canBeAssigned).length;
}
