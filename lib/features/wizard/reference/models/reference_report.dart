import 'dart:typed_data';

import '../../before_works/models/before_works_data.dart';
import '../../before_works/models/technical_finding.dart';
import '../../property_composition/models/room_item.dart';
import '../../report/models/visit_report_snapshot.dart';

enum ReferenceReportSource { constatPlus, externalPdf }

enum RecollectionReferenceMode { constatPlus, externalPdf, none }

class ReferenceReport {
  ReferenceReport({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.zones,
    required this.snapshot,
    required this.findings,
    this.missionType = 'before_works',
    this.areas = const <BeforeWorksArea>[],
    this.pdfPath,
    this.pdfBytes,
    ReferenceReportSource? source,
    bool external = false,
  }) : source =
           source ??
           (external
               ? ReferenceReportSource.externalPdf
               : ReferenceReportSource.constatPlus);

  final String id;
  final String title;
  final DateTime createdAt;
  final List<RoomItem> zones;
  final VisitReportSnapshot snapshot;
  final List<TechnicalFinding> findings;
  final String missionType;
  final List<BeforeWorksArea> areas;
  final String? pdfPath;
  final Uint8List? pdfBytes;
  final ReferenceReportSource source;

  bool get external => source == ReferenceReportSource.externalPdf;
}
