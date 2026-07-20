# Intégration Constat+ — paiement et conditions générales

## Fichiers

- `lib/features/commercial/presentation/secure_checkout_page.dart`
- `lib/features/legal/legal_documents_page.dart`

## Exemple d’ouverture

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => SecureCheckoutPage(
      planName: plan.name,
      priceLabel: plan.formattedPrice,
      billingLabel: plan.billingPeriod == 'monthly' ? '/ mois' : '',
      features: const [
        '5 états des lieux par mois',
        '50 analyses Gianni IA',
        'Rapports Word et PDF',
        'Sauvegarde Cloud',
      ],
      onCheckout: () async {
        // Appeler ici le service Stripe / Google Play / Apple existant.
      },
    ),
  ),
);
```

## Test

1. Ouvrir une offre.
2. Vérifier l’affichage sur fenêtre large et étroite.
3. Cliquer sur les liens CGU et CGV.
4. Vérifier que le bouton refuse le paiement sans acceptation.
5. Cocher les conditions et vérifier que `onCheckout` est appelé.
6. Exécuter `flutter analyze`.

## Important

Les textes juridiques sont une base de travail à faire relire par un avocat belge avant mise en production.
