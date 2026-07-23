import 'commercial_enums.dart';
import 'subscription_plan.dart';

enum PricingAudience { individual, professional }

enum PricingPeriod { monthly, annual }

class PricingOffer {
  const PricingOffer({
    required this.code,
    required this.name,
    required this.audience,
    required this.description,
    required this.targetAudience,
    required this.monthlyPriceMinor,
    required this.taxDisplay,
    required this.features,
    required this.exclusions,
    required this.aiDetails,
    required this.archiveDetails,
    required this.supportDetails,
    required this.changeDetails,
    required this.actionLabel,
    this.missionQuota = 1,
    this.aiQuota = 0,
    this.maximumUsers = 1,
    this.badge,
    this.disclaimer,
    this.oneTime = false,
    this.free = false,
    this.customQuote = false,
  });

  final String code;
  final String name;
  final PricingAudience audience;
  final String description;
  final String targetAudience;
  final int monthlyPriceMinor;
  final PriceTaxDisplay taxDisplay;
  final List<String> features;
  final List<String> exclusions;
  final String aiDetails;
  final String archiveDetails;
  final String supportDetails;
  final String changeDetails;
  final String actionLabel;
  final int missionQuota;
  final int aiQuota;
  final int maximumUsers;
  final String? badge;
  final String? disclaimer;
  final bool oneTime;
  final bool free;
  final bool customQuote;

  int priceMinor(PricingPeriod period) {
    if (audience == PricingAudience.professional &&
        period == PricingPeriod.annual &&
        !customQuote) {
      return monthlyPriceMinor * 10;
    }
    return monthlyPriceMinor;
  }

  String checkoutCode(PricingPeriod period) {
    if (period == PricingPeriod.annual &&
        audience == PricingAudience.professional) {
      return '${code}_annual';
    }
    return code;
  }

  SubscriptionPlan toSubscriptionPlan(PricingPeriod period) {
    final now = DateTime(2026, 1, 1);
    return SubscriptionPlan(
      id: checkoutCode(period),
      code: checkoutCode(period),
      name: name,
      description: description,
      billingPeriod: oneTime ? BillingPeriod.none : BillingPeriod.monthly,
      priceMinor: priceMinor(period),
      currency: 'EUR',
      missionQuota: missionQuota,
      aiAnalysisQuota: aiQuota,
      maximumUsers: maximumUsers,
      taxDisplay: taxDisplay,
      additionalMissionPriceMinor: audience == PricingAudience.professional
          ? 700
          : null,
      featureLabels: features,
      platformAvailability: CommercialPlatform.values.toSet(),
      active: !free && !customQuote,
      createdAt: now,
      updatedAt: now,
    );
  }
}

abstract final class OfficialPricingCatalog {
  static const launchOfferEnabled = true;

  static const offers = <PricingOffer>[
    PricingOffer(
      code: 'discovery',
      name: 'Découverte',
      audience: PricingAudience.individual,
      description: 'Découvrez Constat+ et préparez un premier brouillon.',
      targetAudience:
          'Particuliers souhaitant tester Constat+ sans engagement.',
      monthlyPriceMinor: 0,
      taxDisplay: PriceTaxDisplay.tvac,
      features: [
        'Création d’un brouillon d’état des lieux',
        'Aperçu limité',
        'Découverte de l’application',
        'Aucun rapport final signé',
      ],
      exclusions: ['Rapport PDF définitif', 'Signature finale'],
      aiDetails: 'Fonctions IA limitées selon le quota Découverte.',
      archiveDetails: 'Le brouillon reste associé au compte.',
      supportDetails: 'Aide en ligne.',
      changeDetails: 'Passage à une offre payante à tout moment.',
      actionLabel: 'Essayer gratuitement',
      free: true,
    ),
    PricingOffer(
      code: 'mission_unit',
      name: 'État des lieux',
      audience: PricingAudience.individual,
      description: 'Un état des lieux complet, sans abonnement.',
      targetAudience: 'Particuliers réalisant un état des lieux ponctuel.',
      monthlyPriceMinor: 3900,
      taxDisplay: PriceTaxDisplay.tvac,
      features: [
        '1 état des lieux complet',
        'Rapport professionnel PDF',
        'Ajout des photographies',
        'Relevé des clés et des compteurs',
        'Signature des parties',
        'Archivage pendant 12 mois',
      ],
      exclusions: ['Analyse intelligente des photographies', 'Contrôle humain'],
      aiDetails: 'Aucune analyse IA incluse.',
      archiveDetails: 'Archivage sécurisé pendant 12 mois.',
      supportDetails: 'Assistance standard.',
      changeDetails: 'Paiement unique, sans renouvellement ni résiliation.',
      actionLabel: 'Acheter cet état des lieux',
      oneTime: true,
    ),
    PricingOffer(
      code: 'mission_ai',
      name: 'État des lieux IA',
      audience: PricingAudience.individual,
      description: 'Accélérez la rédaction avec l’assistant intelligent.',
      targetAudience: 'Particuliers souhaitant gagner du temps avec l’IA.',
      monthlyPriceMinor: 5900,
      taxDisplay: PriceTaxDisplay.tvac,
      features: [
        'Tout ce qui est inclus dans l’offre État des lieux',
        'Analyse intelligente des photographies',
        'Préremplissage des pièces et des équipements',
        'Aide à la rédaction des descriptions',
        'Détection et signalement des dégradations',
        'Rapport modifiable avant finalisation',
      ],
      exclusions: ['Contrôle humain de cohérence'],
      aiDetails:
          'Analyses IA incluses pour la mission ; le rapport reste modifiable.',
      archiveDetails: 'Archivage sécurisé pendant 12 mois.',
      supportDetails: 'Assistance standard.',
      changeDetails: 'Paiement unique, sans renouvellement ni résiliation.',
      actionLabel: 'Choisir l’analyse IA',
      aiQuota: 1,
      badge: 'Recommandé',
      oneTime: true,
    ),
    PricingOffer(
      code: 'mission_secure',
      name: 'État des lieux sécurisé',
      audience: PricingAudience.individual,
      description: 'Une assistance humaine à distance avant finalisation.',
      targetAudience:
          'Particuliers souhaitant une vérification complémentaire.',
      monthlyPriceMinor: 9900,
      taxDisplay: PriceTaxDisplay.tvac,
      features: [
        'Tout ce qui est inclus dans l’offre IA',
        'Contrôle humain de la cohérence du rapport',
        'Vérification des descriptions',
        'Signalement des éléments incomplets',
        'Corrections simples avant finalisation',
        'Intervention réalisée à distance, sans déplacement',
      ],
      exclusions: ['Mission contradictoire sur place par un expert'],
      aiDetails: 'Analyse IA et contrôle humain à distance inclus.',
      archiveDetails: 'Archivage sécurisé pendant 12 mois.',
      supportDetails: 'Assistance avec relecture humaine.',
      changeDetails: 'Paiement unique, sans renouvellement ni résiliation.',
      actionLabel: 'Sécuriser mon rapport',
      aiQuota: 1,
      disclaimer:
          'Ce service constitue une assistance à la rédaction et ne remplace pas une mission contradictoire réalisée sur place par un expert.',
      oneTime: true,
    ),
    PricingOffer(
      code: 'solo',
      name: 'Solo',
      audience: PricingAudience.professional,
      description: 'L’essentiel pour exercer seul avec un volume régulier.',
      targetAudience: 'Indépendants et experts travaillant seuls.',
      monthlyPriceMinor: 6900,
      taxDisplay: PriceTaxDisplay.htva,
      missionQuota: 5,
      aiQuota: 5,
      features: [
        'Jusqu’à 5 états des lieux par mois',
        '1 utilisateur',
        '5 analyses IA par mois',
        'Rapports PDF professionnels',
        'Photos et signatures',
        'Comparaison entrée-sortie',
        'Gestion des clés et des compteurs',
        'Archivage sécurisé',
        'Assistance standard',
      ],
      exclusions: ['Personnalisation avec logo', 'Tableau de bord d’équipe'],
      aiDetails: '5 analyses IA incluses par mois.',
      archiveDetails: 'Archivage sécurisé selon les conditions du service.',
      supportDetails: 'Assistance standard.',
      changeDetails:
          'Changement de formule possible ; résiliation selon les CGV.',
      actionLabel: 'Souscrire à Solo',
    ),
    PricingOffer(
      code: 'pro',
      name: 'Pro',
      audience: PricingAudience.professional,
      description: 'Collaborez et supervisez une activité soutenue.',
      targetAudience: 'Petites équipes et cabinets en croissance.',
      monthlyPriceMinor: 14900,
      taxDisplay: PriceTaxDisplay.htva,
      missionQuota: 15,
      aiQuota: 15,
      maximumUsers: 3,
      badge: 'Le plus choisi',
      features: [
        'Jusqu’à 15 états des lieux par mois',
        'Jusqu’à 3 utilisateurs',
        '15 analyses IA par mois',
        'Toutes les fonctionnalités de Solo',
        'Rapports personnalisés avec logo',
        'Inventaire détaillé des biens meublés',
        'Récolement entrée-sortie',
        'Tableau de bord d’équipe',
        'Suivi et contrôle des dossiers',
        'Assistance prioritaire',
      ],
      exclusions: ['Rôle contrôleur avancé'],
      aiDetails: '15 analyses IA incluses par mois.',
      archiveDetails: 'Archivage sécurisé selon les conditions du service.',
      supportDetails: 'Assistance prioritaire.',
      changeDetails:
          'Changement de formule possible ; résiliation selon les CGV.',
      actionLabel: 'Souscrire à Pro',
    ),
    PricingOffer(
      code: 'agency',
      name: 'Agence',
      audience: PricingAudience.professional,
      description: 'Centralisez la production de toute votre agence.',
      targetAudience: 'Agences et cabinets comptant plusieurs collaborateurs.',
      monthlyPriceMinor: 24900,
      taxDisplay: PriceTaxDisplay.htva,
      missionQuota: 35,
      aiQuota: 35,
      maximumUsers: 10,
      features: [
        'Jusqu’à 35 états des lieux par mois',
        'Jusqu’à 10 utilisateurs',
        '35 analyses IA par mois',
        'Toutes les fonctionnalités de Pro',
        'Gestion de plusieurs collaborateurs',
        'Rôles administrateur et contrôleur',
        'Supervision centralisée des dossiers',
        'Personnalisation avancée des rapports',
        'Statistiques d’activité',
        'Assistance prioritaire',
      ],
      exclusions: ['Intégrations et API sur mesure'],
      aiDetails: '35 analyses IA incluses par mois.',
      archiveDetails: 'Archivage sécurisé selon les conditions du service.',
      supportDetails: 'Assistance prioritaire.',
      changeDetails:
          'Changement de formule possible ; résiliation selon les CGV.',
      actionLabel: 'Souscrire à Agence',
    ),
    PricingOffer(
      code: 'enterprise',
      name: 'Entreprise',
      audience: PricingAudience.professional,
      description: 'Une solution configurée selon votre organisation.',
      targetAudience: 'Réseaux, grands cabinets et organisations complexes.',
      monthlyPriceMinor: 0,
      taxDisplay: PriceTaxDisplay.htva,
      missionQuota: 0,
      aiQuota: 0,
      maximumUsers: 1,
      features: [
        'Volume d’états des lieux personnalisé',
        'Utilisateurs selon les besoins',
        'Personnalisation avancée',
        'Accompagnement au déploiement',
        'Import ou migration des données',
        'Intégrations et API sur demande',
        'Support dédié',
      ],
      exclusions: ['Aucune limite standard : conditions définies sur devis'],
      aiDetails: 'Quota défini selon les besoins.',
      archiveDetails: 'Durée définie contractuellement.',
      supportDetails: 'Support dédié.',
      changeDetails: 'Conditions contractuelles personnalisées.',
      actionLabel: 'Demander une offre',
      customQuote: true,
    ),
  ];

  static List<PricingOffer> forAudience(PricingAudience audience) => offers
      .where((offer) => offer.audience == audience)
      .toList(growable: false);
}
