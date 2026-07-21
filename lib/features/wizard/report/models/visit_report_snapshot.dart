import '../../property_composition/models/property_element.dart';

class VisitReportSnapshot {
  final List<VisitRoomReport> rooms;
  final List<PropertyElement> propertyElements;

  const VisitReportSnapshot({
    required this.rooms,
    this.propertyElements = const <PropertyElement>[],
  });

  bool get isEmpty => rooms.isEmpty;
}

class VisitRoomReport {
  final String name;
  final String type;
  final String level;
  final Map<String, String> sections;
  final Map<String, Map<String, int>> electricalByWall;
  final Map<String, String> furnitureDescriptions;
  final KitchenReport? kitchen;
  final List<String> photoPaths;
  final String propertyElementId;
  final List<String> wallNames;

  const VisitRoomReport({
    required this.name,
    required this.type,
    required this.level,
    required this.sections,
    required this.electricalByWall,
    required this.furnitureDescriptions,
    required this.kitchen,
    required this.photoPaths,
    this.propertyElementId = '',
    this.wallNames = const <String>[],
  });
}

class KitchenReport {
  final String generalDescription;
  final String worktopDescription;
  final Map<String, String> worktopEquipment;
  final List<KitchenUnitReport> upperUnits;
  final List<KitchenUnitReport> lowerUnits;

  const KitchenReport({
    required this.generalDescription,
    required this.worktopDescription,
    required this.worktopEquipment,
    required this.upperUnits,
    required this.lowerUnits,
  });

  bool get hasContent =>
      generalDescription.trim().isNotEmpty ||
      worktopDescription.trim().isNotEmpty ||
      worktopEquipment.isNotEmpty ||
      upperUnits.isNotEmpty ||
      lowerUnits.isNotEmpty;
}

class KitchenUnitReport {
  final String type;
  final String comment;

  const KitchenUnitReport({required this.type, required this.comment});
}

class StepVisitController {
  VisitReportSnapshot Function()? _reader;

  void attach(VisitReportSnapshot Function() reader) {
    _reader = reader;
  }

  void detach() {
    _reader = null;
  }

  VisitReportSnapshot read() {
    final reader = _reader;
    if (reader == null) {
      return const VisitReportSnapshot(rooms: []);
    }
    return reader();
  }
}
