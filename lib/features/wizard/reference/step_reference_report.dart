import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../report/models/visit_report_snapshot.dart';
import '../before_works/models/technical_finding.dart';
import '../property_composition/models/room_item.dart';
import 'models/reference_report.dart';
import 'reference_pdf_viewer_page.dart';
import 'reference_report_repository.dart';

class StepReferenceReport extends StatefulWidget {
  const StepReferenceReport({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ReferenceReport? selected;
  final ValueChanged<ReferenceReport> onSelected;

  @override
  State<StepReferenceReport> createState() => _StepReferenceReportState();
}

class _StepReferenceReportState extends State<StepReferenceReport> {
  bool _importing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    await ReferenceReportRepository.instance.load();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _importPdf() async {
    setState(() => _importing = true);
    try {
      const group = XTypeGroup(
        label: 'Rapport avant travaux (PDF)',
        extensions: <String>['pdf'],
        mimeTypes: <String>['application/pdf'],
      );
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[group],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final report = ReferenceReport(
        id: 'external-${DateTime.now().microsecondsSinceEpoch}',
        title: file.name,
        createdAt: DateTime.now(),
        zones: <RoomItem>[],
        snapshot: const VisitReportSnapshot(rooms: <VisitRoomReport>[]),
        findings: <TechnicalFinding>[],
        pdfBytes: bytes,
        external: true,
      );
      widget.onSelected(report);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _open(ReferenceReport report) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReferencePdfViewerPage(
          title: report.title,
          backLabel: 'Retour au récolement',
          pdfBytes: report.pdfBytes,
          pdfPath: report.pdfPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = ReferenceReportRepository.instance.reports;
    return ListView(
      children: <Widget>[
        const Text(
          'Rapport avant travaux de référence',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sélectionnez un rapport créé dans Constat+ ou importez un PDF externe.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (reports.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Aucun rapport avant travaux interne disponible.'),
            ),
          )
        else
          ...reports.map((report) {
            final selected = widget.selected?.id == report.id;
            return Card(
              color: selected ? const Color(0xFFEFF6FF) : null,
              child: ListTile(
                onTap: () => widget.onSelected(report),
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? const Color(0xFF1D4ED8) : null,
                ),
                title: Text(report.title),
                subtitle: Text(
                  '${report.createdAt.day.toString().padLeft(2, '0')}/'
                  '${report.createdAt.month.toString().padLeft(2, '0')}/'
                  '${report.createdAt.year}',
                ),
                trailing: IconButton(
                  tooltip: 'Consulter',
                  onPressed: () => _open(report),
                  icon: const Icon(Icons.visibility_outlined),
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _importing ? null : _importPdf,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              _importing ? 'Import en cours...' : 'Importer un PDF externe',
            ),
          ),
        ),
        if (widget.selected != null) ...<Widget>[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _open(widget.selected!),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Consulter le rapport avant travaux'),
          ),
        ],
      ],
    );
  }
}
