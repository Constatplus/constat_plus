# Installation - Sprint 6 Word V3

1. Faites une copie de sauvegarde du projet.
2. Décompressez le ZIP à la racine de `flutter_app`.
3. Acceptez la fusion des dossiers et le remplacement des fichiers présents.
4. Dans PowerShell, à la racine du projet :

```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d windows --dart-define=OPENAI_API_KEY=VOTRE_CLE
```

## Fichiers remplacés

- `pubspec.yaml`
- `lib/features/wizard/wizard_page.dart`
- `lib/features/wizard/step_visit.dart`
- `lib/features/wizard/step_report.dart`

## Fichiers ajoutés

- `lib/features/wizard/report/models/report_settings.dart`
- `lib/features/wizard/report/models/visit_report_snapshot.dart`
- `lib/features/wizard/report/services/word_report_service.dart`
- `lib/features/wizard/report/services/word_ooxml_styler.dart`

## Test

1. Créez au moins une pièce et complétez quelques postes.
2. Ajoutez des photos.
3. Passez à l'étape Rapport.
4. Choisissez Entrée ou Sortie.
5. Complétez les parties et les listes.
6. Cliquez sur `Exporter en Word`.
7. Ouvrez le DOCX dans Word et actualisez la table des matières si Word le demande.
