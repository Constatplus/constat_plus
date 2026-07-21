import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'comparison/models/comparison_remark.dart';
import 'comparison/step_comparative_remarks.dart';
import 'property_composition/models/room_item.dart';
import 'reference/models/reference_report.dart';
import 'reference/reference_pdf_viewer_page.dart';
import 'report/models/visit_report_snapshot.dart';

class StepExitComparison extends StatefulWidget {
  const StepExitComparison({
    super.key,
    required this.rooms,
    required this.remarks,
  });

  final List<RoomItem> rooms;
  final List<ComparisonRemark> remarks;

  @override
  State<StepExitComparison> createState() => _StepExitComparisonState();
}

class _StepExitComparisonState extends State<StepExitComparison> {
  ReferenceReport? _reference;

  Future<void> _pickEntryPdf() async {
    const group = XTypeGroup(
      label: "État des lieux d'entrée (PDF)",
      extensions: <String>['pdf'],
      mimeTypes: <String>['application/pdf'],
    );
    final file = await openFile(acceptedTypeGroups: const <XTypeGroup>[group]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _reference = ReferenceReport(
        id: 'entry-${DateTime.now().microsecondsSinceEpoch}',
        title: file.name,
        createdAt: DateTime.now(),
        zones: const <RoomItem>[],
        snapshot: const VisitReportSnapshot(rooms: <VisitRoomReport>[]),
        findings: const [],
        pdfBytes: bytes,
        external: true,
      );
    });
  }

  void _openReference() {
    final reference = _reference;
    if (reference == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReferencePdfViewerPage(
          title: reference.title,
          backLabel: 'Retour au rapport de sortie',
          pdfBytes: reference.pdfBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final selectButton = OutlinedButton.icon(
          onPressed: _pickEntryPdf,
          icon: const Icon(Icons.upload_file_outlined),
          label: Text(
            _reference == null
                ? "Sélectionner le PDF d'entrée"
                : 'Remplacer ${_reference!.title}',
          ),
        );
        final consultButton = FilledButton.icon(
          onPressed: _reference == null ? null : _openReference,
          icon: const Icon(Icons.visibility_outlined),
          label: const Text("Consulter l'état des lieux d'entrée"),
        );
        return Column(
          children: <Widget>[
            if (compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  selectButton,
                  const SizedBox(height: 8),
                  consultButton,
                ],
              )
            else
              Row(
                children: <Widget>[
                  Flexible(child: selectButton),
                  const SizedBox(width: 12),
                  Flexible(child: consultButton),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: StepComparativeRemarks(
                rooms: widget.rooms,
                remarks: widget.remarks,
                referenceFindings: const [],
                afterWorks: false,
              ),
            ),
          ],
        );
      },
    );
  }
}
