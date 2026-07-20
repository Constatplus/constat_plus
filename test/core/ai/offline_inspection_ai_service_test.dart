import 'package:flutter_app/core/ai/inspection_ai_service.dart';
import 'package:flutter_app/core/ai/local_technical_knowledge.dart';
import 'package:flutter_app/core/ai/offline_inspection_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OfflineInspectionAiService service;

  setUp(() {
    service = OfflineInspectionAiService(
      knowledge: LocalTechnicalKnowledge(loader: () async => _knowledgeJson),
    );
  });

  test('retrouve le terme technique depuis un synonyme courant', () async {
    final suggestions = await service.suggestVocabulary(
      query: 'coin cassé',
      missionType: 'entry',
      element: 'Mur',
    );

    expect(suggestions, hasLength(1));
    expect(suggestions.single.label, 'Épaufrure');
    expect(suggestions.single.confidence, InspectionConfidence.high);
    expect(suggestions.single.proposedSentence, contains('mur'));
  });

  test('filtre strictement les termes selon le type de mission', () async {
    final suggestions = await service.suggestVocabulary(
      query: 'témoin',
      missionType: 'entry',
    );

    expect(suggestions, isEmpty);
  });

  test(
    'reformule localement sans inventer si aucun terme ne correspond',
    () async {
      final result = await service.improveDescription(
        description: '  peinture usée près de la porte  ',
        missionType: 'entry',
      );

      expect(result, 'Peinture usée près de la porte.');
    },
  );
}

const _knowledgeJson = '''
{
  "terms": [
    {
      "id": "epaufrure",
      "label": "Épaufrure",
      "definition": "Éclat avec perte de matière sur une arête.",
      "category": "maçonnerie",
      "synonyms": ["coin cassé"],
      "elements": ["mur"],
      "sentenceTemplates": ["Observation de type « épaufrure » sur {élément}, {localisation}."],
      "missionTypes": ["entry", "before_works"],
      "corpusOccurrences": 4
    },
    {
      "id": "temoin",
      "label": "Témoin de fissure",
      "definition": "Repère posé sur une fissure.",
      "category": "fissuration",
      "synonyms": ["témoin"],
      "elements": ["façade"],
      "sentenceTemplates": ["Un témoin est visible sur {élément}, {localisation}."],
      "missionTypes": ["before_works"],
      "corpusOccurrences": 1
    }
  ]
}
''';
