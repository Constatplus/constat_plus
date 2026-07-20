# Rapports de référence locaux

Ce dossier ne doit contenir aucun rapport personnel versionné. Les PDF restent
hors du dépôt et servent uniquement d’entrée au script local :

```powershell
dart run tools/extract_report_writing_knowledge.dart '<rapport-1.pdf>' '<rapport-2.pdf>'
```

Le script extrait le texte en mémoire, compte uniquement des termes et patrons
prédéfinis, puis génère `assets/knowledge/report_writing_knowledge.json`. Il ne
conserve ni texte brut, ni nom de fichier, ni adresse, ni identité issue des PDF.

Le fichier JSON produit doit être relu avant toute diffusion. Les rapports PDF
et les éventuels fichiers d’extraction temporaires ne doivent jamais être
ajoutés au dépôt ou au build Flutter.
