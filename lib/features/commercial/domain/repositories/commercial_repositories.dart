import '../models/entitlement_snapshot.dart';
import '../models/consumption_result.dart';
import '../models/one_time_purchase.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_overview.dart';
import '../models/usage_period.dart';
import '../models/user_profile.dart';
import '../models/user_subscription.dart';

abstract interface class ProductCatalogRepository {
  Future<List<SubscriptionPlan>> getActivePlans();

  Future<SubscriptionPlan?> getPlan(String code);
}

abstract interface class ProfileRepository {
  Future<UserProfile?> getCurrentProfile();

  Future<UserProfile> saveProfile(UserProfile profile);
}

abstract interface class SubscriptionRepository {
  Future<UserSubscription?> getCurrentSubscription();

  Future<List<UserSubscription>> getSubscriptionHistory();
}

abstract interface class PurchaseRepository {
  Future<List<OneTimePurchase>> getPurchases();

  Future<List<OneTimePurchase>> getAssignablePurchases();
}

abstract interface class UsageRepository {
  Future<UsagePeriod?> getCurrentPeriod();

  Future<ConsumptionResult> consumeMission({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
  });

  Future<ConsumptionResult> consumeAiAnalysis({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
  });
}

abstract interface class EntitlementRepository {
  Future<EntitlementSnapshot> getSnapshot({bool forceRefresh = false});
}

abstract interface class SubscriptionOverviewRepository {
  Future<SubscriptionOverview> loadOverview();
}
