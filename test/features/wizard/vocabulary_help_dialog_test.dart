import 'package:flutter/material.dart';
import 'package:flutter_app/core/ai/local_technical_knowledge.dart';
import 'package:flutter_app/features/wizard/visit/widgets/vocabulary_help_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('permet de rechercher, modifier puis insérer une formulation', (
    tester,
  ) async {
    String? inserted;
    final knowledge = LocalTechnicalKnowledge(
      loader: () async => _knowledgeJson,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                inserted = await VocabularyHelpDialog.show(
                  context,
                  missionType: 'entry',
                  element: 'Mur',
                  knowledge: knowledge,
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('vocabulary-search')),
      'coin cassé',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Épaufrure'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('vocabulary-sentence')),
      'Épaufrure visible sur le mur gauche.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('insert-vocabulary')));
    await tester.pumpAndSettle();

    expect(inserted, 'Épaufrure visible sur le mur gauche.');
  });
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
      "missionTypes": ["entry"],
      "corpusOccurrences": 4
    }
  ]
}
''';
