/// Ordre canonique des rubriques d'une pièce dans tous les rapports Constat+.
///
/// Les libellés inconnus sont conservés et placés avant les observations afin
/// d'éviter toute perte de données lorsqu'une nouvelle rubrique est ajoutée au
/// mode visite.
abstract final class RoomReportSectionOrder {
  static const List<String> canonicalLabels = <String>[
    'Général',
    'Sol',
    'Mur',
    'Mur avant',
    'Mur droit',
    'Mur arrière',
    'Mur gauche',
    'Plafond',
    'Menuiserie intérieure',
    'Menuiserie extérieure',
    'Électricité',
    'Chauffage',
    'Mobilier',
    'Observations',
  ];

  static const Map<String, String> _aliases = <String, String>{
    'general': 'Général',
    'général': 'Général',
    'sols': 'Sol',
    'murs': 'Mur',
    'plafonds': 'Plafond',
    'menuiseries intérieures': 'Menuiserie intérieure',
    'menuiseries extérieures': 'Menuiserie extérieure',
    'electricite': 'Électricité',
    'électricite': 'Électricité',
    'electricité': 'Électricité',
    'chauffages': 'Chauffage',
    'mobiliers': 'Mobilier',
    'observation': 'Observations',
  };

  static List<MapEntry<String, String>> orderedEntries(
    Map<String, String> sections,
  ) {
    final nonEmpty = sections.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList(growable: false);

    final indexed = <String, MapEntry<String, String>>{};
    for (final entry in nonEmpty) {
      indexed[_canonicalKey(entry.key)] = entry;
    }

    final result = <MapEntry<String, String>>[];
    final consumedKeys = <String>{};

    for (final label in canonicalLabels) {
      final key = _canonicalKey(label);
      final entry = indexed[key];
      if (entry == null) continue;
      result.add(MapEntry<String, String>(label, entry.value.trim()));
      consumedKeys.add(key);
    }

    final observationsIndex = result.indexWhere(
      (entry) => _canonicalKey(entry.key) == _canonicalKey('Observations'),
    );
    final insertionIndex = observationsIndex < 0
        ? result.length
        : observationsIndex;

    final customEntries = nonEmpty
        .where((entry) => !consumedKeys.contains(_canonicalKey(entry.key)))
        .map(
          (entry) => MapEntry<String, String>(
            entry.key.trim(),
            entry.value.trim(),
          ),
        )
        .toList(growable: false);

    result.insertAll(insertionIndex, customEntries);
    return List<MapEntry<String, String>>.unmodifiable(result);
  }

  static String canonicalLabel(String value) {
    final normalized = _normalize(value);
    return _aliases[normalized] ?? value.trim();
  }

  static bool isElectrical(String value) =>
      _canonicalKey(value) == _canonicalKey('Électricité');

  static bool isFurniture(String value) =>
      _canonicalKey(value) == _canonicalKey('Mobilier');

  static String _canonicalKey(String value) {
    return _normalize(canonicalLabel(value));
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
