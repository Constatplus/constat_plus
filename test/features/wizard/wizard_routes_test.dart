import 'package:flutter/material.dart';
import 'package:flutter_app/core/models/mission_type.dart';
import 'package:flutter_app/features/wizard/wizard_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('le récolement démarre sans étape financière', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: WizardPage(missionType: MissionType.afterWorks)),
    );

    expect(find.text('Récolement après travaux'), findsOneWidget);
    expect(find.text('Ordre de mission et parties présentes'), findsWidgets);
    expect(find.textContaining('indemnit'), findsNothing);
    expect(find.textContaining('vétusté'), findsNothing);
  });

  testWidgets(
    'le constat avant travaux utilise un ordre de mission technique',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: WizardPage(missionType: MissionType.beforeWorks),
        ),
      );

      expect(find.text('Ordre de mission avant travaux'), findsOneWidget);
      expect(find.text('Mandant'), findsOneWidget);
      expect(find.text('Maître d’ouvrage'), findsOneWidget);
      expect(find.text('Entrepreneur'), findsOneWidget);
    },
  );
}
