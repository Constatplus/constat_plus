import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../core/access/access_service.dart';
import '../commercial/application/commercial_access_controller.dart';
import '../commercial/presentation/commercial_access_messages.dart';
import '../pricing/pricing_page.dart';
import 'before_works/models/before_works_data.dart';
import 'before_works/models/technical_finding.dart';
import 'comparison/models/comparison_remark.dart';
import 'keys_meters/models/mission_handover_data.dart';
import 'property_composition/models/room_item.dart';
import 'reference/models/reference_report.dart';
import 'reference/reference_pdf_viewer_page.dart';
import 'reference/reference_report_repository.dart';
import '../settings/models/report_preferences.dart';
import '../settings/services/report_preferences_service.dart';
import 'report/models/report_settings.dart';
import 'report/models/visit_report_snapshot.dart';
import 'report/services/word_report_service.dart';
import 'report/services/pdf_report_service.dart';

class StepReport extends StatefulWidget {
  final Map<String, String> generalities;
  final String missionId;
  final String missionType;
  final VisitReportSnapshot snapshot;
  final InspectionReportType initialReportType;
  final List<RoomItem> rooms;
  final BeforeWorksData? beforeWorksData;
  final ReferenceReport? referenceReport;
  final List<ComparisonRemark> comparisonRemarks;
  final MissionHandoverData? handover;

  const StepReport({
    super.key,
    required this.missionId,
    required this.missionType,
    required this.snapshot,
    this.initialReportType = InspectionReportType.entry,
    this.rooms = const <RoomItem>[],
    this.beforeWorksData,
    this.referenceReport,
    this.comparisonRemarks = const <ComparisonRemark>[],
    this.handover,
    this.generalities = const <String, String>{},
  });

  @override
  State<StepReport> createState() => _StepReportState();
}

class _StepReportState extends State<StepReport> {
  final CommercialAccessController _accessController =
      CommercialAccessController();
  final WordReportService _wordService = WordReportService();
  final PdfReportService _pdfService = PdfReportService();
  final ReportPreferencesService _preferencesService =
      ReportPreferencesService();
  ReportPreferences? _savedPreferences;

  late InspectionReportType _reportType;
  late final TextEditingController _titleController;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _companyController = TextEditingController(
    text: 'Constat+',
  );
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _tenantController = TextEditingController();
  final TextEditingController _expertController = TextEditingController(
    text: 'Di Pasquale Gianni',
  );
  final TextEditingController _registrationController = TextEditingController(
    text: 'GEO20/1523',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'info@capital-immo.expert',
  );
  final TextEditingController _keysController = TextEditingController();
  final TextEditingController _maintenanceController = TextEditingController();
  final TextEditingController _manualsController = TextEditingController();
  final TextEditingController _documentsController = TextEditingController();

  bool _includeExpertSignature = true;
  bool _isExporting = false;
  String? _lastExportPath;
  String? _lastPdfPath;

  @override
  void initState() {
    super.initState();
    _reportType = widget.initialReportType;
    _titleController = TextEditingController(text: _reportType.label);
    _prefillHandoverData();
    _loadSavedPreferences();
  }

  void _prefillHandoverData() {
    final handover = widget.handover;
    if (handover == null) return;

    _keysController.text = handover.keyReportLines.join('\n');
    _maintenanceController.text = handover.maintenanceReportLines.join('\n');
    _manualsController.text = handover.manualReportLines.join('\n');
    _documentsController.text = handover.documentReportLines.join('\n');
  }

  Future<void> _loadSavedPreferences() async {
    final saved = await _preferencesService.load();
    if (!mounted) return;
    setState(() {
      _savedPreferences = saved;
      _companyController.text = saved.companyName;
      _registrationController.text = saved.professionalNumber;
      _emailController.text = saved.companyEmail;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _companyController.dispose();
    _ownerController.dispose();
    _tenantController.dispose();
    _expertController.dispose();
    _registrationController.dispose();
    _emailController.dispose();
    _keysController.dispose();
    _maintenanceController.dispose();
    _manualsController.dispose();
    _documentsController.dispose();
    super.dispose();
  }

  void _changeReportType(InspectionReportType? value) {
    if (value == null) return;
    setState(() {
      _reportType = value;
      _titleController.text = value.label;
    });
  }

  List<String> _lines(TextEditingController controller) {
    return controller.text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> _notesForType(
    ReportPreferences preferences,
    InspectionReportType type,
  ) {
    final text = switch (type) {
      InspectionReportType.entry => preferences.entryPreliminaryNotes,
      InspectionReportType.exit => preferences.exitPreliminaryNotes,
      InspectionReportType.beforeWorks =>
        preferences.beforeWorksPreliminaryNotes,
      InspectionReportType.afterWorks =>
        preferences.beforeWorksPreliminaryNotes,
    };
    return text
        .split(RegExp(r'\n\s*\n|\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  ReportSettings _settings() {
    final defaults = ReportSettings.defaults(_reportType);
    return ReportSettings(
      reportType: _reportType,
      companyName: _companyController.text.trim(),
      expertName: _expertController.text.trim(),
      expertRegistration: _registrationController.text.trim(),
      email: _emailController.text.trim(),
      includeExpertSignature: _includeExpertSignature,
      reportTitle: _titleController.text.trim().isEmpty
          ? _reportType.label
          : _titleController.text.trim(),
      propertyAddress: _addressController.text.trim().isEmpty
          ? widget.beforeWorksData?.address ?? 'Adresse du bien'
          : _addressController.text.trim(),
      visitDate: _dateController.text.trim(),
      ownerName: _ownerController.text.trim(),
      tenantName: _tenantController.text.trim(),
      preliminaryNotes: _savedPreferences == null
          ? defaults.preliminaryNotes
          : _notesForType(_savedPreferences!, _reportType),
      keys: _lines(_keysController),
      maintenance: _lines(_maintenanceController),
      manuals: _lines(_manualsController),
      documents: _lines(_documentsController),
      generalities: defaults.generalities,
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final settings = _settings();
      final location = await getSaveLocation(
        suggestedName:
            '${settings.reportTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')}.pdf',
        acceptedTypeGroups: const <XTypeGroup>[
          XTypeGroup(label: 'Document PDF', extensions: <String>['pdf']),
        ],
      );
      if (location == null) return;
      if (!await _authorizeExport()) return;
      final bytes = await _pdfService.generate(
        settings: settings,
        rooms: widget.rooms,
        beforeWorksData: widget.beforeWorksData,
        referenceReport: widget.referenceReport,
        comparisonRemarks: widget.comparisonRemarks,
      );
      if (_reportType == InspectionReportType.entry ||
          (_reportType == InspectionReportType.beforeWorks &&
              widget.beforeWorksData != null)) {
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        final beforeWorks = widget.beforeWorksData;
        await ReferenceReportRepository.instance.save(
          ReferenceReport(
            id: id,
            title: settings.reportTitle,
            createdAt: DateTime.now(),
            zones: widget.rooms
                .map(
                  (room) => RoomItem(
                    type: room.type,
                    name: room.name,
                    level: room.level,
                  ),
                )
                .toList(),
            snapshot: widget.snapshot,
            findings: beforeWorks?.findings ?? <TechnicalFinding>[],
            areas: (beforeWorks?.areas ?? <BeforeWorksArea>[])
                .map(
                  (area) => BeforeWorksArea(
                    id: area.id,
                    name: area.name,
                    type: area.type,
                    parentId: area.parentId,
                  ),
                )
                .toList(growable: false),
            source: ReferenceReportSource.constatPlus,
            missionType: _reportType == InspectionReportType.entry
                ? 'entry'
                : 'before_works',
          ),
          bytes,
        );
      }
      final file = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: location.path.split(RegExp(r'[/\\]')).last,
      );
      await file.saveTo(location.path);
      if (!mounted) return;
      setState(() => _lastPdfPath = location.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le rapport PDF a été généré.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export PDF impossible : $error')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportWord() async {
    if (widget.snapshot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune donnée de visite à exporter.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      if (!await _authorizeWordExport()) return;
      final settings = _settings();

      final path = await _wordService.export(
        snapshot: widget.snapshot,
        settings: settings,
      );

      if (!mounted || path == null) return;
      setState(() => _lastExportPath = path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le rapport Word a été généré.')),
      );
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Export impossible'),
          content: SelectableText(error.toString()),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _previewPdf() async {
    setState(() => _isExporting = true);
    try {
      final settings = _settings();
      final bytes = await _pdfService.generate(
        settings: settings,
        rooms: widget.rooms,
        beforeWorksData: widget.beforeWorksData,
        referenceReport: widget.referenceReport,
        comparisonRemarks: widget.comparisonRemarks,
        preview: true,
      );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ReferencePdfViewerPage(
            title: 'Aperçu — ${settings.reportTitle}',
            backLabel: 'Retour au brouillon',
            pdfBytes: bytes,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aperçu indisponible : $error')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<bool> _authorizeExport() async {
    final result = await _accessController.authorizeFinalReport(
      missionId: widget.missionId,
      missionType: widget.missionType,
    );
    if (result.allowed || !mounted) return result.allowed;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rapport définitif indisponible'),
        content: Text(commercialAccessMessage(result.reason)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const PricingPage()),
              );
            },
            child: const Text('Voir les offres'),
          ),
        ],
      ),
    );
    return false;
  }

  Future<bool> _authorizeWordExport() async {
    final result = await _accessController.authorizeWordExport(
      missionId: widget.missionId,
    );
    if (result.allowed || !mounted) return result.allowed;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export Word indisponible'),
        content: const Text(
          'Le Mode Découverte permet uniquement de consulter un aperçu. Choisissez une mission ou un abonnement pour obtenir un export exploitable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const PricingPage()),
              );
            },
            child: const Text('Voir les offres'),
          ),
        ],
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final standardReport =
        _reportType == InspectionReportType.entry ||
        _reportType == InspectionReportType.exit;
    final commercialAccess = AccessService.instance;
    final previewEnabled =
        commercialAccess.hasPaidAccessFor(widget.missionId) ||
        (commercialAccess.discoveryAccess?.policy.previewEnabled ?? false);
    return ListView(
      children: [
        const Text(
          'Rapports',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.snapshot.rooms.length} pièce(s) prête(s) à être exportée(s).',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<InspectionReportType>(
                initialValue: _reportType,
                decoration: _decoration('Type de rapport'),
                items: InspectionReportType.values
                    .map(
                      (type) => DropdownMenuItem<InspectionReportType>(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: standardReport ? _changeReportType : null,
              ),
            ),
            _field(_titleController, 'Titre du rapport', 360),
            _field(_addressController, 'Adresse du bien', 460),
            _field(_dateController, 'Date de la visite', 240),
            _field(_companyController, 'Entreprise', 300),
            _field(_ownerController, 'Propriétaire', 340),
            _field(_tenantController, 'Locataire', 340),
            _field(_expertController, 'Nom de l’expert', 300),
            _field(_registrationController, 'Matricule', 220),
            _field(_emailController, 'E-mail', 320),
          ],
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _includeExpertSignature,
          title: const Text('Afficher la signature de l’expert'),
          onChanged: (value) {
            setState(() => _includeExpertSignature = value);
          },
        ),
        const SizedBox(height: 18),
        const Text(
          'Clés, entretiens, manuels et documents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _multiLineField(_keysController, 'Clés / badges / télécommandes'),
            _multiLineField(_maintenanceController, 'Entretiens'),
            _multiLineField(_manualsController, 'Manuels / modes d’emploi'),
            _multiLineField(_documentsController, 'Documents remis'),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Text(
            'Le document comprend : page de garde, table des matières limitée aux pièces, notes liminaires, parties, clés/entretiens/manuels/documents, généralités, pièces avec photos, conclusion et signatures.',
          ),
        ),
        const SizedBox(height: 24),
        if (previewEnabled)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isExporting ? null : _previewPdf,
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Consulter l’aperçu du rapport'),
            ),
          ),
        const SizedBox(height: 12),
        if (standardReport)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _isExporting ? null : _exportWord,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.description_outlined),
              label: Text(
                _isExporting ? 'Génération en cours...' : 'Exporter en Word',
              ),
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _isExporting ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Exporter en PDF'),
          ),
        ),
        if (_lastExportPath != null) ...[
          const SizedBox(height: 16),
          SelectableText('Dernier fichier : $_lastExportPath'),
        ],
        if (_lastPdfPath != null) ...<Widget>[
          const SizedBox(height: 8),
          SelectableText('Dernier PDF : $_lastPdfPath'),
        ],
      ],
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _field(TextEditingController controller, String label, double width) {
    return SizedBox(
      width: width,
      child: TextField(controller: controller, decoration: _decoration(label)),
    );
  }

  Widget _multiLineField(TextEditingController controller, String label) {
    return SizedBox(
      width: 420,
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 8,
        decoration: _decoration('$label - une ligne par élément'),
      ),
    );
  }
}
