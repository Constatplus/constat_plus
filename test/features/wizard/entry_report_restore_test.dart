import 'package:flutter/material.dart';
import 'package:flutter_app/features/wizard/property_composition/models/room_item.dart';
import 'package:flutter_app/features/wizard/property_composition/models/property_element.dart';
import 'package:flutter_app/features/wizard/report/models/visit_report_snapshot.dart';
import 'package:flutter_app/features/wizard/step_visit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('restaure un rapport d’entrée dans une visite modifiable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = StepVisitController();
    final building = PropertyElement(
      id: 'building-main',
      type: PropertyElementType.housing,
      name: 'Habitation principale',
    );
    final snapshot = VisitReportSnapshot(
      propertyElements: <PropertyElement>[building.copy()],
      rooms: <VisitRoomReport>[
        VisitRoomReport(
          name: 'Cuisine',
          type: 'Cuisine',
          level: 'Rez-de-chaussée',
          sections: const <String, String>{
            'Sol': 'Carrelage en bon état.',
            'Mur avant': 'Trace ponctuelle en partie basse.',
          },
          electricalByWall: const <String, Map<String, int>>{
            'Mur avant': <String, int>{'Prise': 2},
          },
          furnitureDescriptions: const <String, String>{
            'Placard': 'Placard sous peinture blanche.',
          },
          kitchen: null,
          photoPaths: const <String>[],
          propertyElementId: building.id,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepVisit(
            missionId: 'mission-importée',
            missionType: 'entry',
            rooms: <RoomItem>[
              RoomItem(
                type: 'Cuisine',
                name: 'Cuisine',
                level: 'Rez-de-chaussée',
                propertyElementId: building.id,
              ),
            ],
            propertyElements: <PropertyElement>[building],
            controller: controller,
            initialSnapshot: snapshot,
          ),
        ),
      ),
    );
    await tester.pump();

    final restored = controller.read().rooms.single;
    expect(restored.sections['Sol'], 'Carrelage en bon état.');
    expect(restored.sections['Mur avant'], 'Trace ponctuelle en partie basse.');
    expect(restored.electricalByWall['Mur avant']?['Prise'], 2);
    expect(
      restored.furnitureDescriptions['Placard'],
      'Placard sous peinture blanche.',
    );
    expect(restored.propertyElementId, building.id);
    expect(
      controller.read().propertyElements.single.name,
      'Habitation principale',
    );
  });

  testWidgets('guide la visite par bâtiment', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final main = PropertyElement(
      id: 'main',
      type: PropertyElementType.housing,
      name: 'Habitation principale',
    );
    final garage = PropertyElement(
      id: 'garage',
      type: PropertyElementType.garage,
      name: 'Garage indépendant',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepVisit(
            missionId: 'mission-multiple',
            missionType: 'entry',
            rooms: <RoomItem>[
              RoomItem(
                type: 'Cuisine',
                name: 'Cuisine principale',
                level: 'Rez-de-chaussée',
                propertyElementId: main.id,
              ),
              RoomItem(
                type: 'Garage',
                name: 'Zone du garage',
                level: 'Rez-de-chaussée',
                propertyElementId: garage.id,
              ),
            ],
            propertyElements: <PropertyElement>[main, garage],
            controller: StepVisitController(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bâtiments et zones de la mission'), findsOneWidget);
    await tester.tap(find.text('Garage indépendant'));
    await tester.pump();

    expect(find.text('Zone du garage'), findsWidgets);
    expect(find.text('Cuisine principale'), findsNothing);
  });
}
