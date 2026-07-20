import '../domain/models/commercial_enums.dart';

String commercialAccessMessage(EntitlementReason reason) => switch (reason) {
  EntitlementReason.notAuthenticated =>
    'Connectez-vous pour générer un rapport définitif.',
  EntitlementReason.accountInactive =>
    'Votre compte ne permet pas encore de générer un rapport définitif.',
  EntitlementReason.missionQuotaReached =>
    'Votre quota de missions est épuisé. Choisissez une offre ou achetez une mission à l’unité.',
  EntitlementReason.subscriptionRequired ||
  EntitlementReason.missionPaymentRequired =>
    'Cette mission nécessite un abonnement actif ou un achat à l’unité vérifié.',
  _ => 'Le rapport définitif ne peut pas être généré pour le moment.',
};
