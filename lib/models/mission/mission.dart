import '../person/person.dart';
import '../property/property.dart';
import '../room/room.dart';
import '../shared/enums.dart';

class Mission {
  final String id;

  final Property property;

  final Person owner;

  final Person tenant;

  final MissionType type;

  final MissionStatus status;

  final DateTime createdAt;

  final DateTime updatedAt;

  final List<Room> rooms;

  const Mission({
    required this.id,
    required this.property,
    required this.owner,
    required this.tenant,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.rooms,
  });
}
