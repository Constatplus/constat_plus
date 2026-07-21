import '../../domain/models/commercial_enums.dart';
import '../../domain/models/one_time_purchase.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/models/usage_period.dart';
import '../../domain/models/user_subscription.dart';

class CommercialSupabaseMappers {
  const CommercialSupabaseMappers._();

  static SubscriptionPlan plan(Map<String, dynamic> map) {
    final platforms = (map['platform_availability'] as List? ?? const [])
        .map((value) => _platform(value))
        .whereType<CommercialPlatform>()
        .toSet();
    return SubscriptionPlan(
      id: map['id'].toString(),
      code: map['code'].toString(),
      name: map['name'].toString(),
      description: map['description']?.toString() ?? '',
      billingPeriod: map['billing_period'] == 'monthly'
          ? BillingPeriod.monthly
          : BillingPeriod.none,
      priceMinor: _integer(map['price_minor']),
      currency: map['currency']?.toString() ?? 'EUR',
      missionQuota: _integer(map['mission_quota']),
      aiAnalysisQuota: _integer(map['ai_analysis_quota']),
      maximumUsers: _integer(map['maximum_users']),
      taxDisplay: map['tax_display'] == 'tvac'
          ? PriceTaxDisplay.tvac
          : PriceTaxDisplay.htva,
      additionalMissionPriceMinor: _optionalInteger(
        map['additional_mission_price_minor'],
      ),
      featureLabels: (map['feature_labels'] as List? ?? const <dynamic>[])
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .toList(growable: false),
      platformAvailability: platforms,
      active: map['active'] == true,
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
    );
  }

  static UserSubscription subscription(Map<String, dynamic> map) {
    return UserSubscription(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      organizationId: map['organization_id']?.toString(),
      planCode: map['plan_code'].toString(),
      provider: _provider(map['provider']),
      providerCustomerId: map['provider_customer_id']?.toString(),
      providerSubscriptionId: map['provider_subscription_id'].toString(),
      providerProductId: map['provider_product_id'].toString(),
      providerPurchaseToken: map['provider_purchase_token']?.toString(),
      status: _subscriptionStatus(map['status']),
      startedAt: _date(map['started_at']),
      currentPeriodStart: _date(map['current_period_start']),
      currentPeriodEnd: _date(map['current_period_end']),
      cancelAtPeriodEnd: map['cancel_at_period_end'] == true,
      canceledAt: _optionalDate(map['canceled_at']),
      gracePeriodEnd: _optionalDate(map['grace_period_end']),
      lastVerifiedAt: _date(map['last_verified_at']),
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
    );
  }

  static UsagePeriod usagePeriod(Map<String, dynamic> map) {
    return UsagePeriod(
      id: map['id'].toString(),
      userId: map['user_id']?.toString(),
      organizationId: map['organization_id']?.toString(),
      periodStart: _date(map['period_start']),
      periodEnd: _date(map['period_end']),
      missionsUsed: _integer(map['missions_used']),
      aiAnalysesUsed: _integer(map['ai_analyses_used']),
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
    );
  }

  static OneTimePurchase purchase(Map<String, dynamic> map) {
    return OneTimePurchase(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      missionId: map['mission_id']?.toString(),
      provider: _provider(map['provider']),
      providerTransactionId: map['provider_transaction_id'].toString(),
      providerProductId: map['provider_product_id'].toString(),
      amountMinor: _integer(map['amount_minor']),
      currency: map['currency']?.toString() ?? 'EUR',
      status: _purchaseStatus(map['status']),
      purchasedAt: _date(map['purchased_at']),
      verifiedAt: _optionalDate(map['verified_at']),
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
    );
  }

  static int _integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };

  static int? _optionalInteger(Object? value) =>
      value == null ? null : _integer(value);

  static DateTime _date(Object? value) =>
      DateTime.parse(value.toString()).toUtc();

  static DateTime? _optionalDate(Object? value) =>
      value == null ? null : _date(value);

  static CommercialPlatform? _platform(Object? value) {
    return switch (value?.toString()) {
      'android' => CommercialPlatform.android,
      'windows' => CommercialPlatform.windows,
      'ios' => CommercialPlatform.ios,
      _ => null,
    };
  }

  static PaymentProviderKind _provider(Object? value) {
    return switch (value?.toString()) {
      'google_play' => PaymentProviderKind.googlePlay,
      'stripe' => PaymentProviderKind.stripe,
      'apple' => PaymentProviderKind.apple,
      _ => PaymentProviderKind.demo,
    };
  }

  static SubscriptionStatus _subscriptionStatus(Object? value) {
    return switch (value?.toString()) {
      'pending' => SubscriptionStatus.pending,
      'active' => SubscriptionStatus.active,
      'grace_period' => SubscriptionStatus.gracePeriod,
      'past_due' => SubscriptionStatus.pastDue,
      'suspended' => SubscriptionStatus.suspended,
      'canceled' => SubscriptionStatus.canceled,
      'expired' => SubscriptionStatus.expired,
      'incomplete' => SubscriptionStatus.incomplete,
      _ => SubscriptionStatus.failed,
    };
  }

  static PurchaseStatus _purchaseStatus(Object? value) {
    return switch (value?.toString()) {
      'pending' => PurchaseStatus.pending,
      'verified' => PurchaseStatus.verified,
      'assigned' => PurchaseStatus.assigned,
      'refunded' => PurchaseStatus.refunded,
      'canceled' => PurchaseStatus.canceled,
      _ => PurchaseStatus.failed,
    };
  }
}
