import 'package:flutter/material.dart';
import 'package:flutter_app/features/wizard/before_works/models/before_works_data.dart';
import 'package:flutter_app/features/wizard/comparison/step_comparative_remarks.dart';
import 'package:flutter_app/features/wizard/property_composition/models/property_element.dart';
import 'package:flutter_app/features/wizard/property_composition/widgets/building_workflow_shell.dart';
import 'package:flutter_app/features/wizard/step_before_works_info.dart';
import 'package:flutter_app/features/wizard/step_exit_calculations.dart';
import 'package:flutter_app/features/wizard/step_exit_comparison.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[360, 600, 1200]) {
    testWidgets('les écrans sensibles restent visibles à $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final element = PropertyElement.create(
        PropertyElementType.house,
        name: 'Maison principale',
      );
      final screens = <Widget>[
        StepBeforeWorksInfo(data: BeforeWorksData(), onChanged: () {}),
        const StepComparativeRemarks(
          rooms: [],
          remarks: [],
          referenceFindings: [],
          afterWorks: false,
        ),
        const StepExitComparison(rooms: [], remarks: []),
        const StepExitCalculations(
          rooms: [],
          remarks: [],
          lines: [],
          dismissedSourceIds: {},
        ),
        BuildingWorkflowShell(
          elements: <PropertyElement>[element],
          rooms: const [],
          selectedElementId: element.id,
          completedElementIds: const {},
          onSelected: (_) {},
          onCompletionChanged: (_, _) {},
          child: const SizedBox.expand(),
        ),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} à $width px',
        );
      }
    });
  }
}
