import 'dart:typed_data';

import '../../before_works/models/technical_finding.dart';
import '../../property_composition/models/room_item.dart';
import '../../report/models/visit_report_snapshot.dart';

class ReferenceReport {
  ReferenceReport({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.zones,
    required this.snapshot,
    required this.findings,
    this.pdfPath,
    this.pdfBytes,
    this.external = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<RoomItem> zones;
  final VisitReportSnapshot snapshot;
  final List<TechnicalFinding> findings;
  final String? pdfPath;
  final Uint8List? pdfBytes;
  final bool external;
}
