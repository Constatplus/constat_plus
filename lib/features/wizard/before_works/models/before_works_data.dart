import 'technical_finding.dart';
import '../../property_composition/models/property_element.dart';
import '../../property_composition/models/room_item.dart';

enum BeforeWorksAreaType {
  building,
  facade,
  room,
  surroundings,
  road,
  roadZone,
}

extension BeforeWorksAreaTypeLabel on BeforeWorksAreaType {
  String get label => switch (this) {
    BeforeWorksAreaType.building => 'Bâtiment',
    BeforeWorksAreaType.facade => 'Façade',
    BeforeWorksAreaType.room => 'Pièce intérieure',
    BeforeWorksAreaType.surroundings => 'Abords',
    BeforeWorksAreaType.road => 'Voirie',
    BeforeWorksAreaType.roadZone => 'Zone de voirie',
  };

  bool get isContainer =>
      this == BeforeWorksAreaType.building || this == BeforeWorksAreaType.road;
}

class BeforeWorksArea {
  BeforeWorksArea({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
  });

  final String id;
  String name;
  final BeforeWorksAreaType type;
  final String? parentId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'type': type.name,
    'parentId': parentId,
  };

  factory BeforeWorksArea.fromJson(Map<String, dynamic> json) {
    return BeforeWorksArea(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: BeforeWorksAreaType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => BeforeWorksAreaType.room,
      ),
      parentId: json['parentId'] as String?,
    );
  }
}

class PresentParty {
  PresentParty({this.name = '', this.quality = '', this.represents = ''});

  String name;
  String quality;
  String represents;
}

class BeforeWorksData {
  DateTime missionDate = DateTime.now();
  DateTime? plannedWorksStartDate;
  String address = '';
  String principal = '';
  String ownerOrOccupant = '';
  String projectOwner = '';
  String contractor = '';
  String architect = '';
  String worksNature = '';
  String generalObservations = '';
  final List<PresentParty> presentParties = <PresentParty>[PresentParty()];
  final List<BeforeWorksArea> areas = <BeforeWorksArea>[];
  final List<TechnicalFinding> findings = <TechnicalFinding>[];
  final Map<String, String> propertyElementAreaIds = <String, String>{};

  int _idSequence = 0;

  String areaPath(BeforeWorksArea area) {
    final parents = areas.where((item) => item.id == area.parentId);
    return parents.isEmpty ? area.name : '${parents.first.name} › ${area.name}';
  }

  void ensureInitialStructure(Iterable<String> roomNames) {
    if (areas.isNotEmpty) {
      _attachLegacyFindings();
      return;
    }
    final building = BeforeWorksArea(
      id: _newId('building'),
      name: 'Maison ou bâtiment n° 1',
      type: BeforeWorksAreaType.building,
    );
    areas.add(building);
    for (final roomName in roomNames.where((name) => name.trim().isNotEmpty)) {
      areas.add(
        BeforeWorksArea(
          id: _newId('room'),
          name: roomName.trim(),
          type: BeforeWorksAreaType.room,
          parentId: building.id,
        ),
      );
    }
    _attachLegacyFindings();
  }

  void syncPropertyStructure(
    List<PropertyElement> elements,
    List<RoomItem> rooms,
  ) {
    for (final element in elements) {
      final mappedId = propertyElementAreaIds[element.id];
      final mapped = areas.where((area) => area.id == mappedId);
      final namedRoots = areas.where(
        (area) => area.parentId == null && area.name == element.name,
      );
      BeforeWorksArea root;
      if (mapped.isNotEmpty) {
        root = mapped.first;
      } else if (namedRoots.isNotEmpty) {
        root = namedRoots.first;
      } else {
        root = BeforeWorksArea(
          id: 'property-${element.id}',
          name: element.name,
          type: element.type == PropertyElementType.road
              ? BeforeWorksAreaType.road
              : BeforeWorksAreaType.building,
        );
        areas.add(root);
      }
      root.name = element.name;
      propertyElementAreaIds[element.id] = root.id;

      final elementRooms = rooms.where(
        (room) => room.propertyElementId == element.id,
      );
      for (final room in elementRooms) {
        final exists = areas.any(
          (area) => area.parentId == root.id && area.name == room.name,
        );
        if (!exists) {
          areas.add(
            BeforeWorksArea(
              id: _newId('room'),
              name: room.name,
              type: root.type == BeforeWorksAreaType.road
                  ? BeforeWorksAreaType.roadZone
                  : BeforeWorksAreaType.room,
              parentId: root.id,
            ),
          );
        }
      }
    }
    _attachLegacyFindings();
  }

  List<BeforeWorksArea> areasForPropertyElement(String elementId) {
    final rootId = propertyElementAreaIds[elementId];
    if (rootId == null) return const <BeforeWorksArea>[];
    final ids = <String>{rootId};
    var changed = true;
    while (changed) {
      final before = ids.length;
      ids.addAll(
        areas
            .where((area) => ids.contains(area.parentId))
            .map((area) => area.id),
      );
      changed = ids.length != before;
    }

    // A legacy draft may already contain duplicate IDs. DropdownButton requires
    // exactly one item for its selected value, so keep only the first area for
    // each ID while preserving the original display order.
    final uniqueAreas = <String, BeforeWorksArea>{};
    for (final area in areas) {
      if (ids.contains(area.id)) {
        uniqueAreas.putIfAbsent(area.id, () => area);
      }
    }
    return uniqueAreas.values.toList(growable: false);
  }

  void _attachLegacyFindings() {
    for (final finding in findings.where((item) => item.areaId.isEmpty)) {
      final normalizedZone = finding.zone.trim().toLowerCase();
      if (normalizedZone.isEmpty) continue;
      final matches = areas.where(
        (area) => area.name.trim().toLowerCase() == normalizedZone,
      );
      if (matches.isNotEmpty) finding.areaId = matches.first.id;
    }
  }

  String _newId(String prefix) {
    String candidate;
    do {
      _idSequence++;
      candidate =
          '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_idSequence';
    } while (areas.any((area) => area.id == candidate));
    return candidate;
  }
}
