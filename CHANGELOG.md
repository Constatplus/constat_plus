# 1.0.1

- Ajout d’un écran Plan cadastral immédiatement après la mission.
- Écran disponible pour les parcours Entrée, Sortie et Avant travaux.
- Import d’une image et dessin libre avec couleur, épaisseur, annulation et effacement.
- Ajout des observations du plan et affichage du plan annoté dans l’aperçu du rapport.

# Changelog

## 0.9.2 - Studio de rapport

- Refonte complète de la page Réglages du rapport.
- Ajout des informations d’identité professionnelle.
- Choix de quatre couleurs avec saisie hexadécimale et aperçu.
- Choix de la police, des tailles de texte et des marges.
- Notes liminaires distinctes pour entrée, sortie et avant travaux.
- Activation et réorganisation des sections du rapport.
- Prévisualisation en direct du modèle.
- Sauvegarde locale complète via SharedPreferences.

## 0.6.3 - Export Word V3

### Ajouts
- Export Word entrée/sortie
- Table des matières limitée aux pièces
- Insertion des photos existantes
- Page des parties
- Clés, entretiens, manuels et documents
- Conclusion et signatures configurables
- Titres bleus et verts, texte descriptif noir
- Police Aptos

### Corrections
- Arborescence complète des modèles de rapport
- Dépendances ajoutées au `pubspec.yaml`
- Suppression des imports manquants du premier essai


## Version 0.9.0 - Stabilisation des accès et missions

- Ajout du compte contrôleur de vérification.
- Ajout des missions Entrée, Sortie et Avant travaux.
- Ajout d'un espace Administration / Contrôleur.
- Activation des réglages persistants du rapport.
- Ajout du réordonnancement des murs par glisser-déposer.
- Correction de la hauteur infinie sur la page de connexion Web.

## 0.9.3 - Studio de rapport PRO (aperçu temps réel)

- Intégration de l’aperçu A4 directement dans l’onglet Apparence.
- Mise à jour instantanée des couleurs, polices, tailles, marges, logo et pagination.
- Ajout des vues Couverture, Notes liminaires, Pièce, Calculs et Annexes.
- Ajout du zoom de 50 % à 150 % et d’un bouton d’adaptation.
- Mise en page responsive : deux colonnes sur grand écran, empilement sur écran étroit.
- Suppression de l’ancien onglet Aperçu séparé.

## 0.9.5 - Constat avant travaux et accueil simplifie
- Parcours avant travaux reorganise autour de la mission, des notes liminaires, des personnes presentes, des descriptions par zone et de la conclusion.
- Ajout d'une description detaillee de la mission et d'une conclusion dediee au modele de donnees.
- Ajout d'un type de zone Voirie avec des rubriques adaptees : chaussee, bordures, niveaux, ouvrages, reseaux, drainage, mobilier urbain et regards.
- Apercu du rapport avant travaux enrichi avec le donneur d'ordre, la description de mission, les notes liminaires et la conclusion.
- Page d'accueil simplifiee : la creation de mission reste uniquement dans les trois cartes dediees ; suppression des actions de creation redondantes et de la colonne droite du bandeau.
