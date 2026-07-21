import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../../core/storage/local_json_store.dart';
import '../before_works/models/before_works_data.dart';
import '../before_works/models/technical_finding.dart';
import '../property_composition/models/room_item.dart';
import '../property_composition/models/property_element.dart';
import '../report/models/visit_report_snapshot.dart';
import 'models/reference_report.dart';

class ReferenceReportRepository {
  ReferenceReportRepository._();

  static final ReferenceReportRepository instance =
      ReferenceReportRepository._();
  static const String _storageKey = 'before_works_reference_reports';

  final List<ReferenceReport> _reports = <ReferenceReport>[];
  final LocalJsonStore _store = const LocalJsonStore();
  bool _loaded = false;

  List<ReferenceReport> get reports =>
      List<ReferenceReport>.unmodifiable(_reports.reversed);

  Future<void> load() async {
    if (_loaded) return;
    final values = await _store.readList(_storageKey);
    _reports
      ..clear()
      ..addAll(values.map(_fromJson).whereType<ReferenceReport>());
    _loaded = true;
  }

  Future<ReferenceReport> save(
    ReferenceReport report,
    Uint8List pdfBytes,
  ) async {
    await load();
    final directory = await getApplicationDocumentsDirectory();
    final reportsDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}constat_plus${Platform.pathSeparator}references',
    );
    await reportsDirectory.create(recursive: true);
    final path =
        '${reportsDirectory.path}${Platform.pathSeparator}${report.id}.pdf';
    await File(path).writeAsBytes(pdfBytes, flush: true);

    final stored = ReferenceReport(
      id: report.id,
      title: report.title,
      createdAt: report.createdAt,
      zones: report.zones,
      snapshot: report.snapshot,
      findings: report.findings,
      missionType: report.missionType,
      areas: report.areas,
      pdfPath: path,
      source: report.source,
    );
    _reports.removeWhere((item) => item.id == stored.id);
    _reports.add(stored);
    await _store.writeList(
      _storageKey,
      _reports.map(_toJson).toList(growable: false),
    );
    return stored;
  }

  Map<String, dynamic> _toJson(ReferenceReport report) => <String, dynamic>{
    'id': report.id,
    'title': report.title,
    'createdAt': report.createdAt.toIso8601String(),
    'pdfPath': report.pdfPath,
    'source': report.source.name,
    'missionType': report.missionType,
    'zones': report.zones
        .map(
          (room) => <String, String>{
            'type': room.type,
            'name': room.name,
            'level': room.level,
            'propertyElementId': room.propertyElementId,
          },
        )
        .toList(growable: false),
    'findings': report.findings
        .map((finding) => finding.toJson())
        .toList(growable: false),
    'areas': report.areas.map((area) => area.toJson()).toList(growable: false),
    'snapshot': _snapshotToJson(report.snapshot),
  };

  ReferenceReport? _fromJson(Map<String, dynamic> json) {
    final path = json['pdfPath'] as String?;
    if (path == null || !File(path).existsSync()) return null;
    return ReferenceReport(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Rapport avant travaux',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      zones: (json['zones'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) => RoomItem(
              type: value['type'] as String? ?? '',
              name: value['name'] as String? ?? '',
              level: value['level'] as String? ?? '',
              propertyElementId: value['propertyElementId'] as String? ?? '',
            ),
          )
          .toList(),
      snapshot: _snapshotFromJson(json['snapshot']),
      findings: (json['findings'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) =>
                TechnicalFinding.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(),
      areas: (json['areas'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) =>
                BeforeWorksArea.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(),
      pdfPath: path,
      missionType: json['missionType'] as String? ?? 'before_works',
      source: ReferenceReportSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => ReferenceReportSource.constatPlus,
      ),
    );
  }

  Map<String, dynamic> _snapshotToJson(VisitReportSnapshot snapshot) {
    return <String, dynamic>{
      'propertyElements': snapshot.propertyElements
          .map(
            (element) => <String, String>{
              'id': element.id,
              'type': element.type.name,
              'name': element.name,
            },
          )
          .toList(growable: false),
      'rooms': snapshot.rooms
          .map(
            (room) => <String, dynamic>{
              'name': room.name,
              'type': room.type,
              'level': room.level,
              'propertyElementId': room.propertyElementId,
              'sections': room.sections,
              'electricalByWall': room.electricalByWall,
              'furnitureDescriptions': room.furnitureDescriptions,
              'photoPaths': room.photoPaths,
              'kitchen': room.kitchen == null
                  ? null
                  : <String, dynamic>{
                      'generalDescription': room.kitchen!.generalDescription,
                      'worktopDescription': room.kitchen!.worktopDescription,
                      'worktopEquipment': room.kitchen!.worktopEquipment,
                      'upperUnits': room.kitchen!.upperUnits
                          .map(
                            (unit) => <String, String>{
                              'type': unit.type,
                              'comment': unit.comment,
                            },
                          )
                          .toList(growable: false),
                      'lowerUnits': room.kitchen!.lowerUnits
                          .map(
                            (unit) => <String, String>{
                              'type': unit.type,
                              'comment': unit.comment,
                            },
                          )
                          .toList(growable: false),
                    },
            },
          )
          .toList(growable: false),
    };
  }

  VisitReportSnapshot _snapshotFromJson(Object? value) {
    if (value is! Map) {
      return const VisitReportSnapshot(rooms: <VisitRoomReport>[]);
    }
    final rooms = (value['rooms'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((room) {
          final kitchenValue = room['kitchen'];
          KitchenReport? kitchen;
          if (kitchenValue is Map) {
            kitchen = KitchenReport(
              generalDescription:
                  kitchenValue['generalDescription'] as String? ?? '',
              worktopDescription:
                  kitchenValue['worktopDescription'] as String? ?? '',
              worktopEquipment: _stringMap(kitchenValue['worktopEquipment']),
              upperUnits: _kitchenUnits(kitchenValue['upperUnits']),
              lowerUnits: _kitchenUnits(kitchenValue['lowerUnits']),
            );
          }
          final electrical = <String, Map<String, int>>{};
          final electricalValue = room['electricalByWall'];
          if (electricalValue is Map) {
            for (final entry in electricalValue.entries) {
              electrical[entry.key.toString()] = _intMap(entry.value);
            }
          }
          return VisitRoomReport(
            name: room['name'] as String? ?? '',
            type: room['type'] as String? ?? '',
            level: room['level'] as String? ?? '',
            propertyElementId: room['propertyElementId'] as String? ?? '',
            sections: _stringMap(room['sections']),
            electricalByWall: electrical,
            furnitureDescriptions: _stringMap(room['furnitureDescriptions']),
            kitchen: kitchen,
            photoPaths:
                (room['photoPaths'] as List<dynamic>? ?? const <dynamic>[])
                    .whereType<String>()
                    .toList(growable: false),
          );
        })
        .toList(growable: false);
    final propertyElements =
        (value['propertyElements'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (element) => PropertyElement(
                id: element['id'] as String? ?? '',
                type: PropertyElementType.values.firstWhere(
                  (type) => type.name == element['type'],
                  orElse: () => PropertyElementType.custom,
                ),
                name: element['name'] as String? ?? 'Zone personnalisée',
              ),
            )
            .where((element) => element.id.isNotEmpty)
            .toList(growable: false);
    return VisitReportSnapshot(
      rooms: rooms,
      propertyElements: propertyElements,
    );
  }

  Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return <String, String>{};
    return <String, String>{
      for (final entry in value.entries)
        entry.key.toString(): entry.value.toString(),
    };
  }

  Map<String, int> _intMap(Object? value) {
    if (value is! Map) return <String, int>{};
    return <String, int>{
      for (final entry in value.entries)
        entry.key.toString(): int.tryParse(entry.value.toString()) ?? 0,
    };
  }

  List<KitchenUnitReport> _kitchenUnits(Object? value) {
    return (value as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map(
          (unit) => KitchenUnitReport(
            type: unit['type'] as String? ?? '',
            comment: unit['comment'] as String? ?? '',
          ),
        )
        .toList(growable: false);
  }
}
