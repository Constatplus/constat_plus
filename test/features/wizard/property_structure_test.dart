import 'package:flutter/material.dart';
import 'package:flutter_app/features/wizard/property_composition/models/property_element.dart';
import 'package:flutter_app/features/wizard/property_composition/models/room_item.dart';
import 'package:flutter_app/features/wizard/step_property_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('associe chaque pièce à un élément principal stable', () {
    final mainHouse = PropertyElement.create(
      PropertyElementType.housing,
      name: 'Habitation principale',
    );
    final rearHouse = PropertyElement.create(
      PropertyElementType.housing,
      name: 'Maison arrière',
    );
    final rooms = <RoomItem>[
      RoomItem(
        type: 'Cuisine',
        name: 'Cuisine',
        level: 'Rez-de-chaussée',
        propertyElementId: mainHouse.id,
      ),
      RoomItem(
        type: 'Chambre',
        name: 'Chambre 1',
        level: '1er étage',
        propertyElementId: rearHouse.id,
      ),
    ];

    expect(mainHouse.id, isNot(rearHouse.id));
    expect(
      rooms.where((room) => room.propertyElementId == mainHouse.id),
      hasLength(1),
    );
    expect(
      rooms.where((room) => room.propertyElementId == rearHouse.id),
      hasLength(1),
    );
  });

  test('conserve la compatibilité des anciennes pièces sans parent', () {
    final legacyRoom = RoomItem(
      type: 'Salon',
      name: 'Salon',
      level: 'Rez-de-chaussée',
    );

    expect(legacyRoom.propertyElementId, isEmpty);
  });

  testWidgets('permet d’ajouter plusieurs maisons et de les sélectionner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final elements = <PropertyElement>[];
    String? selectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => StepPropertyType(
              elements: elements,
              selectedElementId: selectedId,
              onSelected: (id) => setState(() => selectedId = id),
              onChanged: () => setState(() {}),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Maison').first);
    await tester.pump();
    await tester.tap(find.text('Maison').first);
    await tester.pump();

    expect(elements, hasLength(2));
    expect(elements.first.name, 'Maison');
    expect(elements.last.name, 'Maison 2');
    expect(selectedId, elements.last.id);
  });
}
