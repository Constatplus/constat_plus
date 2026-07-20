import 'technical_finding.dart';

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

  static String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}
