
## Version 0.8.0 - Authentification et contrôle d'accès

- Écran de connexion premium.
- Compte administrateur de vérification.
- Comptes de démonstration Occasionnel, Solo et Pro.
- Contrôle d'accès selon la formule.
- Mode Occasionnel limité aux trois premières pièces.
- Fenêtre de paiement à l'ouverture de la quatrième pièce.
- Déverrouillage de test de la mission occasionnelle à 69 EUR.
- Badge « Admin vérifié » dans l'en-tête.

> Le bouton de paiement de cette version est une simulation locale. La connexion Stripe/Bancontact sera ajoutée dans le sprint Paiements.


## Version 0.9.0

Comptes de vérification locaux :

- Administrateur : `info@gaudiumimmo.be` / `Constat2026!`
- Contrôleur : `controleur@constatplus.be` / `Controle2026!`
- Démonstration : mot de passe `Demo2026!`

Fonctions ajoutées : missions d'entrée, de sortie et avant travaux, réglages persistants du rapport, espace de contrôle et ordre des murs modifiable.

## Sprint 6.1 - Studio de rapport (implémenté)

- Identité professionnelle configurable.
- Couleurs principale, secondaire, titres et texte via valeurs hexadécimales.
- Police, tailles et marges configurables.
- Notes liminaires séparées pour l'entrée, la sortie et l'avant travaux.
- Sections du rapport activables et réordonnables.
- Aperçu A4 en direct.
- Persistance locale des réglages.
- L'export Word reprend désormais l'identité de société et les notes liminaires enregistrées pour les rapports d'entrée et de sortie.

À poursuivre : appliquer la palette, la typographie, les marges et l'ordre des sections au moteur OOXML.

## Sprint 6.2a - Studio de rapport PRO

L’onglet Apparence comprend désormais un aperçu A4 permanent et réactif. Les modifications de palette, typographie, tailles, marges, logo et numéros de page sont visibles immédiatement. L’utilisateur peut afficher cinq pages d’exemple : couverture, notes liminaires, pièce, calculs et annexes. Le zoom varie de 50 % à 150 %. L’ancien onglet Aperçu séparé a été supprimé afin de conserver les réglages et le rendu côte à côte.

Fichiers principaux :
- `lib/features/settings/report_settings_page.dart`
- `lib/features/settings/widgets/report_live_preview.dart`

## Mise a jour 0.9.5 - Avant travaux
Le parcours Avant travaux suit maintenant cet ordre : donneur d'ordre et description de mission, notes liminaires, personnes presentes, pieces/exterieurs/voirie, description detaillee, conclusion, apercu du rapport. Une voirie peut etre ajoutee comme zone specifique avec des champs adaptes aux constats routiers. Sur l'accueil, les trois cartes de mission sont l'unique point de creation afin d'eviter les doubles emplois.
