import 'dart:convert';

import 'package:flutter/services.dart';

typedef TechnicalKnowledgeLoader = Future<String> Function();

class TechnicalKnowledgeTerm {
  const TechnicalKnowledgeTerm({
    required this.id,
    required this.label,
    required this.definition,
    required this.category,
    required this.synonyms,
    required this.elements,
    required this.sentenceTemplates,
    required this.missionTypes,
    required this.corpusOccurrences,
  });

  factory TechnicalKnowledgeTerm.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List<dynamic>? ?? const []).cast<String>();

    return TechnicalKnowledgeTerm(
      id: json['id'] as String,
      label: json['label'] as String,
      definition: json['definition'] as String,
      category: json['category'] as String,
      synonyms: strings('synonyms'),
      elements: strings('elements'),
      sentenceTemplates: strings('sentenceTemplates'),
      missionTypes: strings('missionTypes'),
      corpusOccurrences: json['corpusOccurrences'] as int? ?? 0,
    );
  }

  final String id;
  final String label;
  final String definition;
  final String category;
  final List<String> synonyms;
  final List<String> elements;
  final List<String> sentenceTemplates;
  final List<String> missionTypes;
  final int corpusOccurrences;
}

class LocalTechnicalKnowledge {
  LocalTechnicalKnowledge({TechnicalKnowledgeLoader? loader})
    : _loader =
          loader ??
          (() => rootBundle.loadString(
            'assets/knowledge/report_writing_knowledge.json',
          ));

  final TechnicalKnowledgeLoader _loader;
  Future<List<TechnicalKnowledgeTerm>>? _terms;

  Future<List<TechnicalKnowledgeTerm>> load() => _terms ??= _loadFromAsset();

  Future<List<String>> categories({required String missionType}) async {
    final terms = await load();
    final values =
        terms
            .where((term) => term.missionTypes.contains(missionType))
            .map((term) => term.category)
            .toSet()
            .toList()
          ..sort();
    return values;
  }

  Future<List<TechnicalKnowledgeTerm>> search(
    String query, {
    required String missionType,
    String? category,
    String? element,
  }) async {
    final terms = await load();
    final normalizedQuery = _normalize(query);
    final normalizedElement = _normalize(element ?? '');

    final scored = <({TechnicalKnowledgeTerm term, int score})>[];
    for (final term in terms) {
      if (!term.missionTypes.contains(missionType)) continue;
      if (category != null &&
          category.isNotEmpty &&
          term.category != category) {
        continue;
      }

      var score = normalizedQuery.isEmpty
          ? 1
          : _matchScore(term, normalizedQuery);
      if (score == 0) continue;

      if (normalizedElement.isNotEmpty &&
          term.elements.any(
            (candidate) =>
                normalizedElement.contains(_normalize(candidate)) ||
                _normalize(candidate).contains(normalizedElement),
          )) {
        score += 15;
      }
      scored.add((term: term, score: score));
    }

    scored.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) return byScore;
      final byCorpus = right.term.corpusOccurrences.compareTo(
        left.term.corpusOccurrences,
      );
      if (byCorpus != 0) return byCorpus;
      return left.term.label.compareTo(right.term.label);
    });
    return scored.map((match) => match.term).toList(growable: false);
  }

  Future<List<TechnicalKnowledgeTerm>> _loadFromAsset() async {
    final decoded = jsonDecode(await _loader()) as Map<String, dynamic>;
    return (decoded['terms'] as List<dynamic>? ?? const [])
        .map(
          (value) =>
              TechnicalKnowledgeTerm.fromJson(value as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  static int _matchScore(TechnicalKnowledgeTerm term, String normalizedQuery) {
    final label = _normalize(term.label);
    final synonyms = term.synonyms.map(_normalize);
    if (label == normalizedQuery || synonyms.contains(normalizedQuery)) {
      return 100;
    }
    if (label.contains(normalizedQuery) ||
        normalizedQuery.contains(label) ||
        synonyms.any(
          (value) =>
              value.contains(normalizedQuery) ||
              normalizedQuery.contains(value),
        )) {
      return 75;
    }

    final searchable = <String>[
      term.definition,
      term.category,
      ...term.elements,
    ].map(_normalize).join(' ');
    final words = normalizedQuery
        .split(' ')
        .where((word) => word.length > 2)
        .toList(growable: false);
    if (words.isNotEmpty && words.every(searchable.contains)) return 45;
    return 0;
  }

  static String normalize(String value) => _normalize(value);

  static String _normalize(String value) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ô': 'o',
      'ö': 'o',
      'ó': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'œ': 'oe',
    };
    final lower = value.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final character = String.fromCharCode(rune);
      buffer.write(accents[character] ?? character);
    }
    return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
