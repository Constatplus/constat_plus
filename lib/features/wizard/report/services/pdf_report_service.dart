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
              _text(
                'APERCU - NON DEFINITIF',
                style: pw.TextStyle(
                  color: PdfColors.red700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            _text('Constat+ - ${settings.reportType.label}'),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _text(
            '${preview ? 'APERCU NON EXPORTABLE - ' : ''}Page ${context.pageNumber} / ${context.pagesCount}',
          ),
        ),
        build: (context) => <pw.Widget>[
          pw.SizedBox(height: 40),
          if (preview) ...<pw.Widget>[
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              color: PdfColors.red50,
              child: _text(
                'APERCU DU MODE DECOUVERTE - CE DOCUMENT N\'EST PAS UN RAPPORT DEFINITIF.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: PdfColors.red800,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 18),
          ],
          _text(
            settings.reportTitle,
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          _text(settings.propertyAddress),
          if (settings.visitDate.isNotEmpty)
            _text('Date : ${settings.visitDate}'),
          pw.SizedBox(height: 24),
          ...settings.preliminaryNotes.map(
            (note) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: _text(note),
            ),
          ),
          if (beforeWorksData != null) ..._beforeWorks(beforeWorksData, rooms),
          if (referenceReport != null)
            ..._afterWorks(referenceReport, comparisonRemarks),
          pw.SizedBox(height: 24),
          _text('Signatures', style: _heading()),
          pw.SizedBox(height: 30),
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(child: _text('Expert : ${settings.expertName}')),
              pw.Expanded(child: _text('Partie : ____________________')),
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
      _text('Ordre de mission', style: _heading()),
      _text('Mandant : ${data.principal}'),
      _text('Proprietaire / occupant : ${data.ownerOrOccupant}'),
      _text('Maitre d\'ouvrage : ${data.projectOwner}'),
      _text('Entrepreneur : ${data.contractor}'),
      _text('Architecte : ${data.architect}'),
      _text('Nature des travaux : ${data.worksNature}'),
      _text('Observations : ${data.generalObservations}'),
      pw.SizedBox(height: 18),
      _text('Composition du constat', style: _heading()),
      if (data.areas.isEmpty)
        ...rooms.map((room) => _text('- ${room.name} - ${room.level}'))
      else
        for (final root in data.areas.where((area) => area.parentId == null)) ...<pw.Widget>[
          _text(
            root.name,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          for (final child in data.areas.where((area) => area.parentId == root.id))
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12),
              child: _text('- ${child.type.label} : ${child.name}'),
            ),
        ],
      pw.SizedBox(height: 18),
      _text('Constats techniques', style: _heading()),
      if (data.areas.isNotEmpty)
        for (final area in data.areas)
          if (data.findings.any((finding) => finding.areaId == area.id)) ...<pw.Widget>[
            _text(
              data.areaPath(area),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            for (final finding in data.findings.where((item) => item.areaId == area.id))
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
      _text(
        finding.post.isEmpty ? finding.zone : finding.post,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      _text('${finding.classification.label} - ${finding.disorderType.label}'),
      if (finding.description.isNotEmpty) _text(finding.description),
      if (finding.disorderType.isCrack)
        _text(
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
      _text('Rapport avant travaux de reference', style: _heading()),
      _text(reference.title),
      if (reference.findings.isNotEmpty) ...<pw.Widget>[
        pw.SizedBox(height: 10),
        for (final finding in reference.findings) ...<pw.Widget>[
          _text(
            '${finding.zone} - ${finding.post}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          _text('${finding.classification.label} - ${finding.disorderType.label}'),
          _text(finding.description),
          if (finding.photoPaths.isNotEmpty) _photos(finding.photoPaths),
          pw.SizedBox(height: 8),
        ],
      ],
      pw.SizedBox(height: 18),
      _text('Comparaison apres travaux', style: _heading()),
      for (final remark in remarks) ...<pw.Widget>[
        _text(
          '${remark.zone} - ${remark.post}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        _text('Statut : ${remark.status.label}'),
        _text('Apres travaux : ${remark.afterDescription}'),
        _text('Conclusion : ${remark.conclusion.label}'),
        if (remark.recommendation.isNotEmpty)
          _text('Recommandation : ${remark.recommendation}'),
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
        images.add(_text('Photographie non disponible : $path'));
      }
    }
    return pw.Wrap(spacing: 8, runSpacing: 8, children: images);
  }

  pw.Text _text(
    String value, {
    pw.TextStyle? style,
    pw.TextAlign? textAlign,
  }) {
    return pw.Text(
      _safePdfText(value),
      style: style,
      textAlign: textAlign,
    );
  }

  String _safePdfText(String value) {
    return value
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2022', '-')
        .replaceAll('\u2026', '...')
        .replaceAll('\u00A0', ' ');
  }

  pw.TextStyle _heading() => pw.TextStyle(
    fontSize: 17,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
  );
}
