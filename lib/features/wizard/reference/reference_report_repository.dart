import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../../core/storage/local_json_store.dart';
import '../before_works/models/technical_finding.dart';
import '../property_composition/models/room_item.dart';
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
      pdfPath: path,
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
    'zones': report.zones
        .map(
          (room) => <String, String>{
            'type': room.type,
            'name': room.name,
            'level': room.level,
          },
        )
        .toList(growable: false),
    'findings': report.findings
        .map((finding) => finding.toJson())
        .toList(growable: false),
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
            ),
          )
          .toList(),
      snapshot: const VisitReportSnapshot(rooms: <VisitRoomReport>[]),
      findings: (json['findings'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) =>
                TechnicalFinding.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(),
      pdfPath: path,
    );
  }
}
