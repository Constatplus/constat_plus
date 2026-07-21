import 'package:flutter_app/features/wizard/property_composition/services/room_reorder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('déplace une pièce vers le bas avec l’index de destination Flutter', () {
    final rooms = <String>['Cuisine', 'Salon', 'Hall'];

    reorderRooms(rooms, 0, 3);

    expect(rooms, <String>['Salon', 'Hall', 'Cuisine']);
  });

  test('déplace une pièce vers le haut', () {
    final rooms = <String>['Cuisine', 'Salon', 'Hall'];

    reorderRooms(rooms, 2, 0);

    expect(rooms, <String>['Hall', 'Cuisine', 'Salon']);
  });

  test('la clé et toutes les données associées suivent la pièce', () {
    final kitchen = _RoomBundle(
      name: 'Cuisine',
      observations: 'Mur marqué',
      photos: <String>['cuisine.jpg'],
      furniture: 'Meubles blancs',
      equipment: 'Four',
      comment: 'À revoir',
      calculation: 125,
    );
    final salon = _RoomBundle(name: 'Salon');
    final rooms = <_RoomBundle>[kitchen, salon];
    final dataByRoom = <String, _RoomBundle>{
      roomIdentityKey(kitchen): kitchen,
      roomIdentityKey(salon): salon,
    };

    reorderRooms(rooms, 0, 2);

    final moved = dataByRoom[roomIdentityKey(rooms.last)]!;
    expect(moved, same(kitchen));
    expect(moved.observations, 'Mur marqué');
    expect(moved.photos, <String>['cuisine.jpg']);
    expect(moved.furniture, 'Meubles blancs');
    expect(moved.equipment, 'Four');
    expect(moved.comment, 'À revoir');
    expect(moved.calculation, 125);
  });
}

class _RoomBundle {
  _RoomBundle({
    required this.name,
    this.observations = '',
    this.photos = const <String>[],
    this.furniture = '',
    this.equipment = '',
    this.comment = '',
    this.calculation = 0,
  });

  final String name;
  final String observations;
  final List<String> photos;
  final String furniture;
  final String equipment;
  final String comment;
  final double calculation;
}
