import 'package:image_picker/image_picker.dart';

import 'inspection_ai_service.dart';
import 'local_technical_knowledge.dart';

abstract interface class OfflineVisionAnalyzer {
  bool get isInstalled;
  int? get modelSizeBytes;

  Future<InspectionAnalysis> analyzePhotos({
    required String missionType,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  });
}

class OfflineVisionUnavailableException implements Exception {
  const OfflineVisionUnavailableException();

  @override
  String toString() =>
      'Aucun modèle de vision hors ligne n’est installé. La visite reste disponible sans analyse photo.';
}

class UnavailableOfflineVisionAnalyzer implements OfflineVisionAnalyzer {
  const UnavailableOfflineVisionAnalyzer();

  @override
  bool get isInstalled => false;

  @override
  int? get modelSizeBytes => null;

  @override
  Future<InspectionAnalysis> analyzePhotos({
    required String missionType,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  }) async {
    throw const OfflineVisionUnavailableException();
  }
}

class OfflineInspectionAiService implements InspectionAiService {
  OfflineInspectionAiService({
    OfflineVisionAnalyzer? visionAnalyzer,
    LocalTechnicalKnowledge? knowledge,
  }) : _visionAnalyzer =
           visionAnalyzer ?? const UnavailableOfflineVisionAnalyzer(),
       _knowledge = knowledge ?? LocalTechnicalKnowledge();

  final OfflineVisionAnalyzer _visionAnalyzer;
  final LocalTechnicalKnowledge _knowledge;

  @override
  InspectionAiEngine get engine => InspectionAiEngine.offline;

  @override
  Future<InspectionAnalysis> analyzePhotos({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  }) {
    return _visionAnalyzer.analyzePhotos(
      missionType: missionType,
      roomName: roomName,
      roomType: roomType,
      photos: photos,
    );
  }

  @override
  Future<String> improveDescription({
    required String description,
    required String missionType,
  }) async {
    final trimmed = description.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return '';

    final terms = await _knowledge.search(trimmed, missionType: missionType);
    if (terms.isNotEmpty && terms.first.sentenceTemplates.isNotEmpty) {
      return buildSentence(terms.first.sentenceTemplates.first);
    }

    final capitalized = '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
    return RegExp(r'[.!?]$').hasMatch(capitalized)
        ? capitalized
        : '$capitalized.';
  }

  @override
  Future<List<TechnicalSuggestion>> suggestVocabulary({
    required String query,
    required String missionType,
    String? element,
  }) async {
    final terms = await _knowledge.search(
      query,
      missionType: missionType,
      element: element,
    );
    final normalizedQuery = LocalTechnicalKnowledge.normalize(query);
    return terms
        .take(12)
        .map((term) {
          final exact = <String>[
            term.label,
            ...term.synonyms,
          ].map(LocalTechnicalKnowledge.normalize).contains(normalizedQuery);
          return TechnicalSuggestion(
            termId: term.id,
            label: term.label,
            simpleDefinition: term.definition,
            proposedSentence: term.sentenceTemplates.isEmpty
                ? term.label
                : buildSentence(term.sentenceTemplates.first, element: element),
            confidence: exact
                ? InspectionConfidence.high
                : InspectionConfidence.medium,
          );
        })
        .toList(growable: false);
  }

  static String buildSentence(String template, {String? element}) {
    final target = element?.trim().isNotEmpty == true
        ? element!.trim().toLowerCase()
        : 'l’élément observé';
    return template
        .replaceAll('{élément}', target)
        .replaceAll(
          '{localisation}',
          'sur les parties visibles et accessibles',
        );
  }
}
