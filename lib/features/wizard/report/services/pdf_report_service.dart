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
    final accent = PdfColor.fromHex('#173F5F');
    final light = PdfColor.fromHex('#EAF2F7');
    final muted = PdfColor.fromHex('#5F6B76');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 46, 42, 44),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: accent, width: 0.7),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text(
                settings.companyName.isEmpty ? 'Constat+' : settings.companyName,
                style: pw.TextStyle(
                  color: accent,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                settings.reportType.label,
                style: pw.TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text(
                preview ? 'Aperçu du rapport' : settings.email,
                style: pw.TextStyle(color: muted, fontSize: 8),
              ),
              pw.Text(
                'Page ${context.pageNumber} / ${context.pagesCount}',
                style: pw.TextStyle(color: muted, fontSize: 8),
              ),
            ],
          ),
        ),
        build: (context) => <pw.Widget>[
          pw.SizedBox(height: 28),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: pw.BoxDecoration(
              color: light,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  settings.reportTitle,
                  style: pw.TextStyle(
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                    color: accent,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  settings.propertyAddress,
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (settings.visitDate.isNotEmpty) ...<pw.Widget>[
                  pw.SizedBox(height: 5),
                  pw.Text('Visite du ${settings.visitDate}'),
                ],
                if (preview) ...<pw.Widget>[
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'APERÇU — DOCUMENT NON DÉFINITIF',
                    style: pw.TextStyle(
                      color: PdfColors.red700,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          ..._identityBlock(settings, accent),
          if (settings.preliminaryNotes.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 18),
            _sectionTitle('Notes liminaires', accent),
            ...settings.preliminaryNotes.map(
              (note) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 7),
                child: pw.Text(
                  note,
                  textAlign: pw.TextAlign.justify,
                  style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 2),
                ),
              ),
            ),
          ],
          if (_hasDeliveredItems(settings)) ...<pw.Widget>[
            pw.SizedBox(height: 18),
            _sectionTitle('Éléments remis', accent),
            _deliveredItems(settings, light),
          ],
          if (settings.generalities.values.any((value) => value.trim().isNotEmpty)) ...<pw.Widget>[
            pw.SizedBox(height: 18),
            _sectionTitle('Généralités', accent),
            for (final entry in settings.generalities.entries)
              if (entry.value.trim().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 9),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(
                        entry.key,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(entry.value, textAlign: pw.TextAlign.justify),
                    ],
                  ),
                ),
          ],
          if (rooms.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 18),
            _sectionTitle('Composition du bien', accent),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const <int, pw.TableColumnWidth>{
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(1.5),
                2: pw.FlexColumnWidth(1.2),
              },
              children: <pw.TableRow>[
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: light),
                  children: <pw.Widget>[
                    _tableCell('Pièce', bold: true),
                    _tableCell('Type', bold: true),
                    _tableCell('Niveau', bold: true),
                  ],
                ),
                for (final room in rooms)
                  pw.TableRow(
                    children: <pw.Widget>[
                      _tableCell(room.name),
                      _tableCell(room.type),
                      _tableCell(room.level),
                    ],
                  ),
              ],
            ),
          ],
          if (beforeWorksData != null) ..._beforeWorks(beforeWorksData, rooms, accent),
          if (referenceReport != null)
            ..._afterWorks(referenceReport, comparisonRemarks, accent),
          pw.SizedBox(height: 26),
          _sectionTitle('Conclusion et signatures', accent),
          pw.Text(
            'Le présent rapport reprend les constatations et informations communiquées lors de la visite.',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 34),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Expanded(
                child: _signatureBox(
                  settings.includeExpertSignature
                      ? 'L’expert\n${settings.expertName}${settings.expertRegistration.isEmpty ? '' : '\n${settings.expertRegistration}'}'
                      : 'L’expert',
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(child: _signatureBox('Le propriétaire / mandant')),
              pw.SizedBox(width: 16),
              pw.Expanded(child: _signatureBox('Le locataire / occupant')),
            ],
          ),
        ],
      ),
    );
    return document.save();
  }

  List<pw.Widget> _identityBlock(ReportSettings settings, PdfColor accent) {
    final rows = <List<String>>[
      if (settings.ownerName.isNotEmpty) <String>['Propriétaire', settings.ownerName],
      if (settings.tenantName.isNotEmpty) <String>['Locataire', settings.tenantName],
      if (settings.expertName.isNotEmpty) <String>['Expert', settings.expertName],
      if (settings.expertRegistration.isNotEmpty)
        <String>['Matricule', settings.expertRegistration],
      if (settings.email.isNotEmpty) <String>['E-mail', settings.email],
    ];
    if (rows.isEmpty) return <pw.Widget>[];
    return <pw.Widget>[
      _sectionTitle('Identification des parties', accent),
      pw.Table(
        columnWidths: const <int, pw.TableColumnWidth>{
          0: pw.FixedColumnWidth(120),
          1: pw.FlexColumnWidth(),
        },
        children: rows
            .map(
              (row) => pw.TableRow(
                children: <pw.Widget>[
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(
                      row[0],
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(row[1]),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ];
  }

  bool _hasDeliveredItems(ReportSettings settings) =>
      settings.keys.isNotEmpty ||
      settings.maintenance.isNotEmpty ||
      settings.manuals.isNotEmpty ||
      settings.documents.isNotEmpty;

  pw.Widget _deliveredItems(ReportSettings settings, PdfColor background) {
    final groups = <MapEntry<String, List<String>>>[
      MapEntry<String, List<String>>('Clés, badges et télécommandes', settings.keys),
      MapEntry<String, List<String>>('Entretiens', settings.maintenance),
      MapEntry<String, List<String>>('Manuels et modes d’emploi', settings.manuals),
      MapEntry<String, List<String>>('Documents remis', settings.documents),
    ].where((entry) => entry.value.isNotEmpty);

    return pw.Column(
      children: groups
          .map(
            (entry) => pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(11),
              decoration: pw.BoxDecoration(
                color: background,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    entry.key,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  ...entry.value.map((item) => pw.Text('• $item')),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  List<pw.Widget> _beforeWorks(
    BeforeWorksData data,
    List<RoomItem> rooms,
    PdfColor accent,
  ) {
    return <pw.Widget>[
      pw.SizedBox(height: 22),
      _sectionTitle('Ordre de mission', accent),
      pw.Text('Mandant : ${data.principal}'),
      pw.Text('Propriétaire / occupant : ${data.ownerOrOccupant}'),
      pw.Text('Maître d’ouvrage : ${data.projectOwner}'),
      pw.Text('Entrepreneur : ${data.contractor}'),
      pw.Text('Architecte : ${data.architect}'),
      pw.Text('Nature des travaux : ${data.worksNature}'),
      if (data.generalObservations.isNotEmpty)
        pw.Text('Observations : ${data.generalObservations}'),
      pw.SizedBox(height: 18),
      _sectionTitle('Constats techniques', accent),
      if (data.areas.isNotEmpty)
        for (final area in data.areas)
          if (data.findings.any((finding) => finding.areaId == area.id)) ...<pw.Widget>[
            pw.Text(
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
      pw.Text(
        finding.post.isEmpty ? finding.zone : finding.post,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.Text('${finding.classification.label} — ${finding.disorderType.label}'),
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
    PdfColor accent,
  ) {
    return <pw.Widget>[
      pw.SizedBox(height: 22),
      _sectionTitle('Rapport avant travaux de référence', accent),
      pw.Text(reference.title),
      if (reference.findings.isNotEmpty) ...<pw.Widget>[
        pw.SizedBox(height: 10),
        for (final finding in reference.findings) ...<pw.Widget>[
          pw.Text(
            '${finding.zone} • ${finding.post}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('${finding.classification.label} — ${finding.disorderType.label}'),
          pw.Text(finding.description),
          if (finding.photoPaths.isNotEmpty) _photos(finding.photoPaths),
          pw.SizedBox(height: 8),
        ],
      ],
      pw.SizedBox(height: 18),
      _sectionTitle('Comparaison après travaux', accent),
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

  pw.Widget _sectionTitle(String title, PdfColor accent) => pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.only(bottom: 5),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: accent, width: 1.2),
      ),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: accent,
      ),
    ),
  );

  pw.Widget _tableCell(String value, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 9.5,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );

  pw.Widget _signatureBox(String title) => pw.Container(
    height: 90,
    padding: const pw.EdgeInsets.all(9),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(title, style: const pw.TextStyle(fontSize: 9)),
  );
}
