import 'commercial_enums.dart';

enum PriceTaxDisplay { htva, tvac }

extension PriceTaxDisplayLabel on PriceTaxDisplay {
  String get label => switch (this) {
    PriceTaxDisplay.htva => 'HTVA',
    PriceTaxDisplay.tvac => 'TVAC',
  };
}

class SubscriptionPlan {
  final String id;
  final String code;
  final String name;
  final String description;
  final BillingPeriod billingPeriod;
  final int priceMinor;
  final String currency;
  final int missionQuota;
  final int aiAnalysisQuota;
  final int maximumUsers;
  final PriceTaxDisplay taxDisplay;
  final int? additionalMissionPriceMinor;
  final List<String> featureLabels;
  final Set<CommercialPlatform> platformAvailability;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.billingPeriod,
    required this.priceMinor,
    required this.currency,
    required this.missionQuota,
    required this.aiAnalysisQuota,
    required this.maximumUsers,
    this.taxDisplay = PriceTaxDisplay.htva,
    this.additionalMissionPriceMinor,
    this.featureLabels = const <String>[],
    required this.platformAvailability,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(priceMinor >= 0),
       assert(missionQuota >= 0),
       assert(aiAnalysisQuota >= 0),
       assert(maximumUsers >= 1),
       assert(
         additionalMissionPriceMinor == null ||
             additionalMissionPriceMinor >= 0,
       ),
       assert(currency.length == 3);

  bool supports(CommercialPlatform platform) =>
      active && platformAvailability.contains(platform);
}
