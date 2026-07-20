import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../before_works/models/before_works_data.dart';
import '../../before_works/models/technical_finding.dart';
import '../../comparison/models/comparison_remark.dart';
import '../../property_composition/models/room_item.dart';
import '../../reference/models/reference_report.dart';
import '../models/report_settings.dart';

class PdfReportService {
  Future<Uint8List> generate({
    required ReportSettings settings,
    required List<RoomItem> rooms,
    BeforeWorksData? beforeWorksData,
    ReferenceReport? referenceReport,
    List<ComparisonRemark> comparisonRemarks = const <ComparisonRemark>[],
    bool preview = false,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            if (preview)
              pw.Text(
                'APERÇU — NON DÉFINITIF',
                style: pw.TextStyle(
                  color: PdfColors.red700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            pw.Text('Constat+ • ${settings.reportType.label}'),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${preview ? 'APERÇU NON EXPORTABLE • ' : ''}Page ${context.pageNumber} / ${context.pagesCount}',
          ),
        ),
        build: (context) => <pw.Widget>[
          pw.SizedBox(height: 40),
          if (preview) ...<pw.Widget>[
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              color: PdfColors.red50,
              child: pw.Text(
                'APERÇU DU MODE DÉCOUVERTE — CE DOCUMENT N’EST PAS UN RAPPORT DÉFINITIF.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: PdfColors.red800,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 18),
          ],
          pw.Text(
            settings.reportTitle,
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(settings.propertyAddress),
          if (settings.visitDate.isNotEmpty)
            pw.Text('Date : ${settings.visitDate}'),
          pw.SizedBox(height: 24),
          ...settings.preliminaryNotes.map(
            (note) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(note),
            ),
          ),
          if (beforeWorksData != null) ..._beforeWorks(beforeWorksData, rooms),
          if (referenceReport != null)
            ..._afterWorks(referenceReport, comparisonRemarks),
          pw.SizedBox(height: 24),
          pw.Text('Signatures', style: _heading()),
          pw.SizedBox(height: 30),
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(child: pw.Text('Expert : ${settings.expertName}')),
              pw.Expanded(child: pw.Text('Partie : ____________________')),
            ],
          ),
        ],
      ),
    );
    return document.save();
  }

  List<pw.Widget> _beforeWorks(BeforeWorksData data, List<RoomItem> rooms) {
    return <pw.Widget>[
      pw.SizedBox(height: 22),
      pw.Text('Ordre de mission', style: _heading()),
      pw.Text('Mandant : ${data.principal}'),
      pw.Text('Propriétaire / occupant : ${data.ownerOrOccupant}'),
      pw.Text('Maître d’ouvrage : ${data.projectOwner}'),
      pw.Text('Entrepreneur : ${data.contractor}'),
      pw.Text('Architecte : ${data.architect}'),
      pw.Text('Nature des travaux : ${data.worksNature}'),
      pw.Text('Observations : ${data.generalObservations}'),
      pw.SizedBox(height: 18),
      pw.Text('Composition du constat', style: _heading()),
      if (data.areas.isEmpty)
        ...rooms.map((room) => pw.Text('• ${room.name} — ${room.level}'))
      else
        for (final root in data.areas.where(
          (area) => area.parentId == null,
        )) ...<pw.Widget>[
          pw.Text(
            root.name,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          for (final child in data.areas.where(
            (area) => area.parentId == root.id,
          ))
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12),
              child: pw.Text('• ${child.type.label} : ${child.name}'),
            ),
        ],
      pw.SizedBox(height: 18),
      pw.Text('Constats techniques', style: _heading()),
      if (data.areas.isNotEmpty)
        for (final area in data.areas)
          if (data.findings.any(
            (finding) => finding.areaId == area.id,
          )) ...<pw.Widget>[
            pw.Text(
              data.areaPath(area),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            for (final finding in data.findings.where(
              (item) => item.areaId == area.id,
            ))
              ..._beforeWorksFinding(finding),
          ],
      for (final finding in data.findings.where(
        (item) =>
            item.areaId.isEmpty ||
            !data.areas.any((area) => area.id == item.areaId),
      ))
        ..._beforeWorksFinding(finding),
    ];
  }

  List<pw.Widget> _beforeWorksFinding(TechnicalFinding finding) {
    return <pw.Widget>[
      pw.Text(
        finding.post.isEmpty ? finding.zone : finding.post,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        '${finding.classification.label} — ${finding.disorderType.label}',
      ),
      if (finding.description.isNotEmpty) pw.Text(finding.description),
      if (finding.disorderType.isCrack)
        pw.Text(
          'Fissure : ${finding.crack.location}, ${finding.crack.orientation}, longueur ${finding.crack.length}, ouverture ${finding.crack.openingMillimeters} mm.',
        ),
      if (finding.photoPaths.isNotEmpty) _photos(finding.photoPaths),
      pw.SizedBox(height: 12),
    ];
  }

  List<pw.Widget> _afterWorks(
    ReferenceReport reference,
    List<ComparisonRemark> remarks,
  ) {
    return <pw.Widget>[
      pw.SizedBox(height: 22),
      pw.Text('Rapport avant travaux de référence', style: _heading()),
      pw.Text(reference.title),
      if (reference.findings.isNotEmpty) ...<pw.Widget>[
        pw.SizedBox(height: 10),
        for (final finding in reference.findings) ...<pw.Widget>[
          pw.Text(
            '${finding.zone} • ${finding.post}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${finding.classification.label} — ${finding.disorderType.label}',
          ),
          pw.Text(finding.description),
          if (finding.photoPaths.isNotEmpty) _photos(finding.photoPaths),
          pw.SizedBox(height: 8),
        ],
      ],
      pw.SizedBox(height: 18),
      pw.Text('Comparaison après travaux', style: _heading()),
      for (final remark in remarks) ...<pw.Widget>[
        pw.Text(
          '${remark.zone} • ${remark.post}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Statut : ${remark.status.label}'),
        pw.Text('Après travaux : ${remark.afterDescription}'),
        pw.Text('Conclusion : ${remark.conclusion.label}'),
        if (remark.recommendation.isNotEmpty)
          pw.Text('Recommandation : ${remark.recommendation}'),
        if (remark.afterPhotoPaths.isNotEmpty) _photos(remark.afterPhotoPaths),
        pw.SizedBox(height: 12),
      ],
    ];
  }

  pw.Widget _photos(List<String> paths) {
    final images = <pw.Widget>[];
    for (final path in paths) {
      try {
        final bytes = File(path).readAsBytesSync();
        images.add(
          pw.Image(
            pw.MemoryImage(bytes),
            width: 150,
            height: 110,
            fit: pw.BoxFit.cover,
          ),
        );
      } catch (_) {
        images.add(pw.Text('Photographie non disponible : $path'));
      }
    }
    return pw.Wrap(spacing: 8, runSpacing: 8, children: images);
  }

  pw.TextStyle _heading() => pw.TextStyle(
    fontSize: 17,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
  );
}
