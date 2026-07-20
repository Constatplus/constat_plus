import '../models/billing_models.dart';
import '../models/consumption_result.dart';
import '../models/commercial_enums.dart';
import '../models/entitlement_snapshot.dart';
import '../models/subscription_plan.dart';
import '../models/user_profile.dart';
import '../models/user_subscription.dart';

abstract interface class ProfileService {
  Future<UserProfile?> loadProfile();

  Future<UserProfile> updateProfile(UserProfile profile);
}

abstract interface class ProductCatalogService {
  Future<List<SubscriptionPlan>> loadPlans();
}

abstract interface class SubscriptionService {
  Future<UserSubscription?> loadCurrentSubscription();

  Future<PurchaseResult> subscribe({
    required BillingProduct product,
    required String idempotencyKey,
  });

  Future<void> manageSubscription();

  Future<void> restorePurchases();
}

abstract interface class PurchaseService {
  Future<PurchaseResult> purchaseMission({
    required String missionId,
    required BillingProduct product,
    required String idempotencyKey,
  });
}

abstract interface class UsageService {
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

abstract interface class EntitlementService {
  EntitlementDecision evaluate({
    required CommercialAction action,
    required EntitlementSnapshot snapshot,
    required DateTime now,
    String? missionId,
  });
}
