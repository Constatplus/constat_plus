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

  /// Identifie l'offre mise en avant sans modifier la structure Supabase.
  bool get isRecommended => code.trim().toLowerCase() == 'pro';

  /// Prévoit l'affichage d'une formule Entreprise si elle est ajoutée au
  /// catalogue plus tard, sans imposer de migration immédiate.
  bool get isEnterprise {
    final normalizedCode = code.trim().toLowerCase();
    final normalizedName = name.trim().toLowerCase();

    return normalizedCode == 'enterprise' ||
        normalizedCode == 'entreprise' ||
        normalizedName.contains('entreprise');
  }

  /// Une formule sans prix fixe ou explicitement définie comme Entreprise est
  /// présentée comme une offre sur devis.
  bool get isCustomQuote => isEnterprise || priceMinor == 0;

  bool get isOneOff => billingPeriod == BillingPeriod.none;

  bool get isMonthly => billingPeriod == BillingPeriod.monthly;

  bool get hasUnlimitedMissions => missionQuota == 0 && !isOneOff;

  bool get hasUnlimitedAiAnalyses => aiAnalysisQuota == 0 && !isOneOff;

  String get missionQuotaLabel {
    if (isEnterprise) return 'Volume personnalisé';
    if (hasUnlimitedMissions) return 'Illimité';
    if (isOneOff) return '1 mission';
    return '$missionQuota / mois';
  }

  String get aiQuotaLabel {
    if (isEnterprise) return 'Crédits mutualisés';
    if (hasUnlimitedAiAnalyses) return 'Illimité';
    if (isOneOff) return '$aiAnalysisQuota incluses';
    return '$aiAnalysisQuota / mois';
  }

  String get userQuotaLabel {
    if (isEnterprise) return 'Équipe sur mesure';
    if (maximumUsers == 1) return '1 utilisateur';
    return '$maximumUsers utilisateurs';
  }
}
