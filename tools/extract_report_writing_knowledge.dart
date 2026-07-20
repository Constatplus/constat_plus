import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:pdfrx_engine/pdfrx_engine.dart';

const _outputPath = 'assets/knowledge/report_writing_knowledge.json';

const _categories = <String>[
  'fissuration',
  'peinture et enduits',
  'maçonnerie',
  'pierres naturelles',
  'carrelage',
  'parquet',
  'menuiseries',
  'vitrages',
  'quincaillerie',
  'toiture',
  'étanchéité',
  'humidité',
  'sanitaires',
  'électricité',
  'chauffage',
  'mobilier',
  'voirie',
  'trottoirs',
  'bordures',
  'égouttage',
  'clôtures',
  'murs de soutènement',
  'propreté',
  'usure',
  'défauts de finition',
];

const _styleMarkers = <String, String>{
  'presence_de': 'présence de',
  'est_realise': 'est réalisé',
  'est_constitue': 'est constitué',
  'sous_peinture': 'sous peinture',
  'en_partie_basse': 'en partie basse',
  'au_droit_de': 'au droit de',
  'localise': 'localisé',
  'sans_remarque': 'sans remarque',
  'etat_usage': "état d'usage",
  'bon_etat': 'bon état',
};

const _termSeeds = <Map<String, Object>>[
  {
    'id': 'fissure-verticale',
    'label': 'Fissure verticale',
    'definition':
        'Ouverture visible suivant une direction principalement verticale.',
    'category': 'fissuration',
    'synonyms': ['fente verticale'],
    'elements': ['mur', 'façade', 'maçonnerie'],
  },
  {
    'id': 'fissure-horizontale',
    'label': 'Fissure horizontale',
    'definition':
        'Ouverture visible suivant une direction principalement horizontale.',
    'category': 'fissuration',
    'synonyms': ['fente horizontale'],
    'elements': ['mur', 'façade', 'maçonnerie'],
  },
  {
    'id': 'fissure-oblique',
    'label': 'Fissure oblique',
    'definition': 'Ouverture visible suivant une direction inclinée.',
    'category': 'fissuration',
    'synonyms': ['fente en biais'],
    'elements': ['mur', 'façade', 'maçonnerie'],
  },
  {
    'id': 'fissure-escalier',
    'label': 'Fissure en escalier',
    'definition':
        'Fissure suivant successivement les joints horizontaux et verticaux d’une maçonnerie.',
    'category': 'fissuration',
    'synonyms': ['fissure en marches'],
    'elements': ['brique', 'bloc', 'façade'],
  },
  {
    'id': 'fissure-traversante',
    'label': 'Fissure traversante',
    'definition':
        'Fissure visible sur toute l’épaisseur observable ou sur deux faces correspondantes.',
    'category': 'fissuration',
    'synonyms': ['fissure de part en part'],
    'elements': ['mur', 'dalle'],
  },
  {
    'id': 'microfissure',
    'label': 'Microfissure',
    'definition':
        'Fissure très fine dont l’ouverture paraît faible à l’observation.',
    'category': 'fissuration',
    'synonyms': ['cheveu', 'fissure fine'],
    'elements': ['enduit', 'peinture', 'mur'],
  },
  {
    'id': 'fendille',
    'label': 'Fendille',
    'definition': 'Petite fente superficielle et localisée.',
    'category': 'fissuration',
    'synonyms': ['petite fente'],
    'elements': ['bois', 'enduit', 'maçonnerie'],
  },
  {
    'id': 'faiencage',
    'label': 'Faïençage',
    'definition': 'Réseau de fines fissures formant un maillage en surface.',
    'category': 'fissuration',
    'synonyms': ['fissures en toile', 'craquelures'],
    'elements': ['enduit', 'peinture', 'enrobé'],
  },
  {
    'id': 'ouverture-joint',
    'label': 'Ouverture de joint',
    'definition':
        'Séparation visible au niveau d’un joint entre deux éléments.',
    'category': 'fissuration',
    'synonyms': ['joint ouvert'],
    'elements': ['maçonnerie', 'carrelage', 'menuiserie'],
  },
  {
    'id': 'fissure-baie',
    'label': 'Fissure au droit d’une baie',
    'definition':
        'Fissure localisée à proximité d’une porte, d’une fenêtre ou de son appui.',
    'category': 'fissuration',
    'synonyms': ['fissure près de la fenêtre'],
    'elements': ['façade', 'mur', 'linteau'],
  },
  {
    'id': 'impact',
    'label': 'Impact',
    'definition':
        'Marque ponctuelle résultant visiblement d’un contact ou d’un choc, sans en attribuer la cause.',
    'category': 'usure',
    'synonyms': ['coup', 'marque de choc'],
    'elements': ['mur', 'porte', 'mobilier'],
  },
  {
    'id': 'epaufrure',
    'label': 'Épaufrure',
    'definition': 'Éclat avec perte de matière sur l’arête d’un matériau dur.',
    'category': 'maçonnerie',
    'synonyms': ['coin cassé', 'arête cassée', 'éclat'],
    'elements': ['béton', 'pierre', 'carrelage', 'appui'],
  },
  {
    'id': 'percement',
    'label': 'Percement',
    'definition': 'Ouverture ou trou réalisé dans un support.',
    'category': 'défauts de finition',
    'synonyms': ['trou', 'trou de vis'],
    'elements': ['mur', 'plafond', 'menuiserie'],
  },
  {
    'id': 'trou-fixation',
    'label': 'Trou de fixation',
    'definition':
        'Petit percement subsistant après la pose ou la dépose d’une fixation.',
    'category': 'défauts de finition',
    'synonyms': ['trou de vis', 'ancienne fixation'],
    'elements': ['mur', 'plafond', 'menuiserie'],
  },
  {
    'id': 'arrachement',
    'label': 'Arrachement',
    'definition':
        'Zone où une partie du matériau ou du revêtement a été retirée avec perte de matière.',
    'category': 'défauts de finition',
    'synonyms': ['matière arrachée'],
    'elements': ['enduit', 'peinture', 'sol'],
  },
  {
    'id': 'rayure',
    'label': 'Rayure',
    'definition': 'Marque linéaire superficielle affectant une finition.',
    'category': 'usure',
    'synonyms': ['griffe', 'griffure'],
    'elements': ['vitrage', 'parquet', 'menuiserie', 'mobilier'],
  },
  {
    'id': 'enfoncement',
    'label': 'Enfoncement',
    'definition': 'Déformation ponctuelle vers l’intérieur d’une surface.',
    'category': 'usure',
    'synonyms': ['creux', 'coup enfoncé'],
    'elements': ['porte', 'tôle', 'parquet'],
  },
  {
    'id': 'desaffleurement',
    'label': 'Désaffleurement',
    'definition':
        'Différence de niveau entre deux surfaces normalement voisines.',
    'category': 'défauts de finition',
    'synonyms': ['décalage de niveau', 'marche'],
    'elements': ['carrelage', 'pavé', 'bordure', 'joint'],
  },
  {
    'id': 'decollement',
    'label': 'Décollement',
    'definition':
        'Séparation partielle d’un revêtement par rapport à son support.',
    'category': 'peinture et enduits',
    'synonyms': ['revêtement décollé'],
    'elements': ['peinture', 'enduit', 'carrelage'],
  },
  {
    'id': 'cloquage',
    'label': 'Cloquage',
    'definition':
        'Formation de boursouflures ou de petites poches sous un revêtement.',
    'category': 'peinture et enduits',
    'synonyms': ['bulles', 'peinture gonflée'],
    'elements': ['peinture', 'enduit'],
  },
  {
    'id': 'ecaillage',
    'label': 'Écaillage',
    'definition':
        'Départ du revêtement sous forme de petites plaques ou écailles.',
    'category': 'peinture et enduits',
    'synonyms': ['peinture qui pèle'],
    'elements': ['peinture', 'vernis'],
  },
  {
    'id': 'souillure',
    'label': 'Souillure',
    'definition': 'Salissure localisée visible sur une surface.',
    'category': 'propreté',
    'synonyms': ['saleté', 'trace sale'],
    'elements': ['mur', 'sol', 'plafond', 'équipement'],
  },
  {
    'id': 'aureole',
    'label': 'Auréole',
    'definition':
        'Trace diffuse présentant un contour plus ou moins circulaire.',
    'category': 'humidité',
    'synonyms': ['cerne', 'tache ronde'],
    'elements': ['plafond', 'mur', 'enduit'],
  },
  {
    'id': 'coulure',
    'label': 'Coulure',
    'definition':
        'Trace allongée suivant le cheminement apparent d’un liquide.',
    'category': 'humidité',
    'synonyms': ['trace qui coule'],
    'elements': ['mur', 'façade', 'menuiserie'],
  },
  {
    'id': 'joint-evide',
    'label': 'Joint évidé',
    'definition':
        'Joint de maçonnerie dont la matière est en retrait ou partiellement manquante.',
    'category': 'maçonnerie',
    'synonyms': ['joint creusé'],
    'elements': ['brique', 'pierre', 'bloc'],
  },
  {
    'id': 'brique-fissuree',
    'label': 'Brique fissurée',
    'definition': 'Brique présentant une fissure visible dans sa matière.',
    'category': 'maçonnerie',
    'synonyms': ['brique fendue'],
    'elements': ['façade', 'mur'],
  },
  {
    'id': 'brique-descel',
    'label': 'Brique descellée',
    'definition':
        'Brique ne paraissant plus correctement liée à la maçonnerie environnante.',
    'category': 'maçonnerie',
    'synonyms': ['brique mobile'],
    'elements': ['façade', 'mur'],
  },
  {
    'id': 'defaut-aplomb',
    'label': 'Défaut d’aplomb',
    'definition': 'Écart apparent par rapport à la verticale.',
    'category': 'maçonnerie',
    'synonyms': ['mur penché', 'pas droit'],
    'elements': ['mur', 'clôture', 'poteau'],
  },
  {
    'id': 'bombement',
    'label': 'Bombement',
    'definition': 'Déformation d’une surface formant une saillie arrondie.',
    'category': 'maçonnerie',
    'synonyms': ['mur gonflé', 'surface bombée'],
    'elements': ['mur', 'façade', 'revêtement'],
  },
  {
    'id': 'reprise-maconnerie',
    'label': 'Reprise de maçonnerie',
    'definition':
        'Zone réparée ou reconstruite se distinguant de la maçonnerie voisine.',
    'category': 'maçonnerie',
    'synonyms': ['réparation de briques'],
    'elements': ['mur', 'façade'],
  },
  {
    'id': 'eclat-pierre',
    'label': 'Éclat de pierre',
    'definition': 'Perte ponctuelle de matière sur un élément en pierre.',
    'category': 'pierres naturelles',
    'synonyms': ['pierre cassée'],
    'elements': ['seuil', 'appui', 'façade'],
  },
  {
    'id': 'carreau-descel',
    'label': 'Carreau descellé',
    'definition': 'Carreau dont l’adhérence au support paraît insuffisante.',
    'category': 'carrelage',
    'synonyms': ['carrelage qui sonne creux', 'carreau mobile'],
    'elements': ['sol', 'mur'],
  },
  {
    'id': 'parquet-use',
    'label': 'Parquet usé',
    'definition': 'Parquet présentant une altération visible liée à l’usage.',
    'category': 'parquet',
    'synonyms': ['parquet marqué', 'vernis usé'],
    'elements': ['sol'],
  },
  {
    'id': 'menuiserie-deformee',
    'label': 'Menuiserie déformée',
    'definition':
        'Élément de menuiserie présentant une modification visible de sa forme.',
    'category': 'menuiseries',
    'synonyms': ['porte voilée', 'châssis déformé'],
    'elements': ['porte', 'châssis'],
  },
  {
    'id': 'vitrage-raye',
    'label': 'Vitrage rayé',
    'definition':
        'Vitrage présentant une ou plusieurs rayures visibles selon l’éclairage.',
    'category': 'vitrages',
    'synonyms': ['vitre griffée'],
    'elements': ['fenêtre', 'porte vitrée'],
  },
  {
    'id': 'quincaillerie-jeu',
    'label': 'Jeu dans la quincaillerie',
    'definition':
        'Mouvement apparent anormalement important dans une pièce de manœuvre.',
    'category': 'quincaillerie',
    'synonyms': ['poignée qui bouge', 'charnière lâche'],
    'elements': ['poignée', 'charnière', 'serrure'],
  },
  {
    'id': 'tuile-deplacee',
    'label': 'Élément de couverture déplacé',
    'definition':
        'Tuile ou ardoise dont la position diffère visiblement des éléments voisins.',
    'category': 'toiture',
    'synonyms': ['tuile bougée', 'ardoise déplacée'],
    'elements': ['toiture'],
  },
  {
    'id': 'joint-etancheite-degrade',
    'label': 'Joint d’étanchéité dégradé',
    'definition':
        'Joint souple présentant une rupture, un retrait ou une adhérence altérée.',
    'category': 'étanchéité',
    'synonyms': ['silicone abîmé', 'joint fendu'],
    'elements': ['sanitaire', 'menuiserie', 'façade'],
  },
  {
    'id': 'trace-humidite',
    'label': 'Trace d’humidité',
    'definition':
        'Modification visible de teinte ou d’aspect pouvant correspondre à une présence passée ou actuelle d’humidité.',
    'category': 'humidité',
    'synonyms': ['tache humide', 'mur humide'],
    'elements': ['mur', 'plafond', 'sol'],
  },
  {
    'id': 'sanitaire-eclat',
    'label': 'Éclat sur appareil sanitaire',
    'definition':
        'Perte ponctuelle de matière ou d’émail sur un appareil sanitaire.',
    'category': 'sanitaires',
    'synonyms': ['lavabo ébréché'],
    'elements': ['lavabo', 'baignoire', 'WC'],
  },
  {
    'id': 'prise-descelee',
    'label': 'Prise descellée',
    'definition':
        'Prise électrique dont la fixation au support paraît insuffisante.',
    'category': 'électricité',
    'synonyms': ['prise qui bouge'],
    'elements': ['prise', 'mur'],
  },
  {
    'id': 'radiateur-peinture-usee',
    'label': 'Peinture de radiateur usée',
    'definition':
        'Finition peinte du radiateur présentant des marques d’usage ou des pertes ponctuelles.',
    'category': 'chauffage',
    'synonyms': ['radiateur écaillé'],
    'elements': ['radiateur'],
  },
  {
    'id': 'mobilier-rayure',
    'label': 'Mobilier rayé',
    'definition':
        'Élément de mobilier présentant une marque linéaire superficielle.',
    'category': 'mobilier',
    'synonyms': ['meuble griffé'],
    'elements': ['meuble', 'plan de travail'],
  },
  {
    'id': 'fissuration-longitudinale',
    'label': 'Fissuration longitudinale',
    'definition': 'Fissuration orientée dans le sens principal de la voirie.',
    'category': 'voirie',
    'synonyms': ['fissure dans le sens de la route'],
    'elements': ['chaussée', 'enrobé'],
  },
  {
    'id': 'fissuration-transversale',
    'label': 'Fissuration transversale',
    'definition':
        'Fissuration orientée en travers du sens principal de la voirie.',
    'category': 'voirie',
    'synonyms': ['fissure en travers de la route'],
    'elements': ['chaussée', 'enrobé'],
  },
  {
    'id': 'ornierage',
    'label': 'Orniérage',
    'definition':
        'Déformation longitudinale en creux dans les zones de passage des roues.',
    'category': 'voirie',
    'synonyms': ['traces de roues creusées'],
    'elements': ['chaussée', 'enrobé'],
  },
  {
    'id': 'nid-poule',
    'label': 'Nid-de-poule',
    'definition': 'Cavité localisée dans le revêtement d’une chaussée.',
    'category': 'voirie',
    'synonyms': ['trou dans la route'],
    'elements': ['chaussée', 'enrobé'],
  },
  {
    'id': 'pave-affaisse',
    'label': 'Pavé affaissé',
    'definition':
        'Pavé situé en contrebas du niveau apparent des pavés voisins.',
    'category': 'trottoirs',
    'synonyms': ['pavé enfoncé'],
    'elements': ['trottoir', 'accotement'],
  },
  {
    'id': 'bordure-descelee',
    'label': 'Bordure descellée',
    'definition':
        'Bordure dont la fixation ou la liaison avec les éléments voisins paraît altérée.',
    'category': 'bordures',
    'synonyms': ['bordure qui bouge'],
    'elements': ['bordure', 'trottoir'],
  },
  {
    'id': 'avaloir-encrasse',
    'label': 'Avaloir encrassé',
    'definition':
        'Avaloir présentant une accumulation visible de dépôts ou de déchets.',
    'category': 'égouttage',
    'synonyms': ['grille bouchée'],
    'elements': ['avaloir', 'voirie'],
  },
  {
    'id': 'tampon-descel',
    'label': 'Tampon descellé',
    'definition':
        'Tampon ou couvercle dont l’assise paraît instable ou désolidarisée.',
    'category': 'égouttage',
    'synonyms': ['plaque d’égout qui bouge'],
    'elements': ['chambre de visite', 'regard'],
  },
  {
    'id': 'cloture-deformee',
    'label': 'Clôture déformée',
    'definition':
        'Clôture présentant une déformation ou un défaut d’alignement visible.',
    'category': 'clôtures',
    'synonyms': ['grillage plié'],
    'elements': ['clôture', 'portillon'],
  },
  {
    'id': 'soutenement-fissure',
    'label': 'Mur de soutènement fissuré',
    'definition':
        'Mur retenant des terres et présentant une fissure visible, sans préjuger de sa cause.',
    'category': 'murs de soutènement',
    'synonyms': ['mur de retenue fissuré'],
    'elements': ['mur de soutènement'],
  },
  {
    'id': 'aspect-irregulier',
    'label': 'Aspect irrégulier',
    'definition':
        'Finition présentant des différences visibles de texture, de planéité ou d’application.',
    'category': 'défauts de finition',
    'synonyms': ['finition pas uniforme'],
    'elements': ['peinture', 'enduit', 'joint'],
  },
  {
    'id': 'difference-teinte',
    'label': 'Différence de teinte',
    'definition':
        'Variation ponctuelle de couleur par rapport à la surface voisine.',
    'category': 'peinture et enduits',
    'synonyms': ['couleur différente', 'retouche visible'],
    'elements': ['peinture', 'enduit', 'maçonnerie'],
  },
];

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/extract_report_writing_knowledge.dart <pdf>...',
    );
    exitCode = 64;
    return;
  }

  final files = arguments.map(File.new).toList(growable: false);
  final missing = files.where((file) => !file.existsSync()).toList();
  if (missing.isNotEmpty) {
    throw StateError('${missing.length} rapport(s) PDF introuvable(s).');
  }

  var pageCount = 0;
  var extractedCharacters = 0;
  var entryReportCount = 0;
  var beforeWorksReportCount = 0;
  final corpus = StringBuffer();

  for (final file in files) {
    final normalizedName = file.uri.pathSegments.last.toLowerCase();
    if (normalizedName.contains('avant travaux')) {
      beforeWorksReportCount++;
    } else {
      entryReportCount++;
    }
    final document = await PdfDocument.openFile(file.path);
    try {
      pageCount += document.pages.length;
      for (final page in document.pages) {
        final rawText = await page.loadText();
        final text = rawText?.fullText ?? '';
        extractedCharacters += text.length;
        corpus.writeln(text.toLowerCase());
      }
    } finally {
      await document.dispose();
    }
  }

  if (extractedCharacters < 1000) {
    throw StateError(
      'Texte extractible insuffisant. Un OCR local serait nécessaire.',
    );
  }

  final corpusText = corpus.toString();
  final terms = _termSeeds.map((seed) => _buildTerm(seed, corpusText)).toList();
  final knowledge = <String, Object>{
    'schemaVersion': 1,
    'language': 'fr-BE',
    'corpus': <String, Object>{
      'documentCount': files.length,
      'entryReportCount': entryReportCount,
      'beforeWorksReportCount': beforeWorksReportCount,
      'pageCount': pageCount,
      'extractedCharacterCount': extractedCharacters,
      'containsSourceText': false,
      'containsPersonalData': false,
    },
    'categories': _categories,
    'writingStructure': const <String>[
      'nature',
      'matériau ou support',
      'finition',
      'teinte',
      'état général',
      'défaut visible',
      'localisation',
      'dimension approximative si renseignée',
      'limite d’observation',
    ],
    'writingRules': const <String>[
      'Rester factuel, professionnel, prudent et non accusatoire.',
      'Décrire uniquement les parties visibles et accessibles.',
      'Ne jamais inventer un matériau, une dimension, un défaut ou un fonctionnement.',
      'Ne jamais attribuer une responsabilité ou affirmer une cause structurelle sur photographie.',
      'Conserver les observations encodées par l’utilisateur.',
      'Employer une approximation uniquement lorsque l’utilisateur a fourni une mesure.',
    ],
    'cautiousPhrases': const <String>[
      'pouvant correspondre à',
      'semblant résulter de',
      'd’origine non déterminée lors du constat',
      'visible sur les parties accessibles',
      'sans préjuger de l’origine du désordre',
      'L’élément n’a pas pu être observé dans son intégralité.',
      'L’observation complète est rendue difficile par la présence de mobilier.',
    ],
    'missionGuidance': const <String, Object>{
      'entry': <String>[
        'Décrire la propreté, l’entretien, les matériaux, les finitions et l’état locatif.',
        'Qualifier le fonctionnement comme apparent uniquement lorsqu’un essai est renseigné.',
      ],
      'before_works': <String>[
        'Privilégier l’état constructif visible des façades, maçonneries, voiries et abords.',
        'Localiser la géométrie des fissures et leurs dimensions seulement si elles sont renseignées.',
        'Éviter les observations purement locatives sans intérêt pour le constat avant travaux.',
      ],
      'after_works': <String>[
        'Comparer l’état initial et l’état observé sans déduire automatiquement une causalité.',
        'Distinguer absence de modification, aggravation, nouveau désordre, réparation et comparaison impossible.',
      ],
    },
    'observedStyleMarkers': _styleMarkers.map(
      (id, marker) => MapEntry(id, <String, Object>{
        'label': marker,
        'occurrences': _countOccurrences(corpusText, marker),
      }),
    ),
    'terms': terms,
  };

  final encoded = const JsonEncoder.withIndent('  ').convert(knowledge);
  _assertNoSensitiveData(encoded);
  final output = File(_outputPath);
  await output.parent.create(recursive: true);
  await output.writeAsString('$encoded\n', flush: true);
  stdout.writeln(
    'Synthèse créée: ${terms.length} termes, ${files.length} rapports, '
    '$pageCount pages. Aucun texte source conservé.',
  );
}

Map<String, Object> _buildTerm(Map<String, Object> seed, String corpus) {
  final label = seed['label']! as String;
  final category = seed['category']! as String;
  final applicableMissionTypes = <String>[
    'entry',
    if (category != 'propreté' && category != 'mobilier') 'before_works',
    'after_works',
  ];
  return <String, Object>{
    ...seed,
    'sentenceTemplates': <String>[
      'Observation de type « ${label.toLowerCase()} » localisée sur {élément}, {localisation}.',
      'Sur {élément}, un désordre pouvant être décrit comme « ${label.toLowerCase()} » est visible sur les parties accessibles.',
    ],
    'missionTypes': applicableMissionTypes,
    'corpusOccurrences': _countOccurrences(corpus, label.toLowerCase()),
    'sourceTrace': 'corpus_interne_anonymisé',
  };
}

int _countOccurrences(String text, String pattern) {
  if (pattern.isEmpty) return 0;
  var count = 0;
  var start = 0;
  while (true) {
    final index = text.indexOf(pattern, start);
    if (index < 0) return count;
    count++;
    start = index + pattern.length;
  }
}

void _assertNoSensitiveData(String json) {
  final forbidden = <RegExp>[
    RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
    RegExp(r'\bBE\s?\d{2}(?:\s?\d{4}){3}\b', caseSensitive: false),
    RegExp(r'\b(?:\+32|0)\s?\d(?:[ .-]?\d{2}){4}\b'),
    RegExp(r'\b\d{4}\s+[A-ZÀ-Ÿ][A-Za-zÀ-ÿ-]+\b'),
  ];
  if (forbidden.any((pattern) => pattern.hasMatch(json))) {
    throw StateError('La synthèse contient un motif potentiellement sensible.');
  }
}
