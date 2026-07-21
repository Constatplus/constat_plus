import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../core/access/access_service.dart';
import '../../core/responsive/responsive.dart';
import '../commercial/application/commercial_access_controller.dart';
import '../commercial/presentation/commercial_access_messages.dart';
import '../pricing/pricing_page.dart';
import 'before_works/models/before_works_data.dart';
import 'before_works/models/technical_finding.dart';
import 'comparison/models/comparison_remark.dart';
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
  final String missionId;
  final String missionType;
  final VisitReportSnapshot snapshot;
  final InspectionReportType initialReportType;
  final List<RoomItem> rooms;
  final BeforeWorksData? beforeWorksData;
  final ReferenceReport? referenceReport;
  final List<ComparisonRemark> comparisonRemarks;

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
    _loadSavedPreferences();
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
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(dialogContext).width < 600 ? 16 : 40,
            vertical: 24,
          ),
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
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(dialogContext).width < 600 ? 16 : 40,
          vertical: 24,
        ),
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
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(dialogContext).width < 600 ? 16 : 40,
          vertical: 24,
        ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Responsive.mobileBreakpoint;
        final isTablet = constraints.maxWidth < Responsive.tabletBreakpoint;
        final contentWidth = constraints.maxWidth > 1180
            ? 1180.0
            : constraints.maxWidth;
        final fieldWidth = isMobile
            ? constraints.maxWidth
            : isTablet
            ? (constraints.maxWidth - 16) / 2
            : 360.0;
        final largeFieldWidth = isMobile
            ? constraints.maxWidth
            : isTablet
            ? constraints.maxWidth
            : 460.0;

        return ListView(
          padding: EdgeInsets.only(
            bottom: Responsive.value(
              context: context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isMobile),
                    SizedBox(height: Responsive.spacingLg(context)),
                    _sectionCard(
                      context,
                      title: 'Informations du rapport',
                      icon: Icons.description_outlined,
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child:
                                DropdownButtonFormField<InspectionReportType>(
                                  initialValue: _reportType,
                                  isExpanded: true,
                                  decoration: _decoration('Type de rapport'),
                                  items: InspectionReportType.values
                                      .map(
                                        (type) =>
                                            DropdownMenuItem<
                                              InspectionReportType
                                            >(
                                              value: type,
                                              child: Text(type.label),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: standardReport
                                      ? _changeReportType
                                      : null,
                                ),
                          ),
                          _field(
                            _titleController,
                            'Titre du rapport',
                            isMobile ? constraints.maxWidth : largeFieldWidth,
                          ),
                          _field(
                            _addressController,
                            'Adresse du bien',
                            isMobile ? constraints.maxWidth : largeFieldWidth,
                          ),
                          _field(
                            _dateController,
                            'Date de la visite',
                            fieldWidth,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacingMd(context)),
                    _sectionCard(
                      context,
                      title: 'Parties et intervenants',
                      icon: Icons.groups_outlined,
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _field(_companyController, 'Entreprise', fieldWidth),
                          _field(_ownerController, 'Propriétaire', fieldWidth),
                          _field(_tenantController, 'Locataire', fieldWidth),
                          _field(
                            _expertController,
                            'Nom de l’expert',
                            fieldWidth,
                          ),
                          _field(
                            _registrationController,
                            'Matricule',
                            fieldWidth,
                          ),
                          _field(_emailController, 'E-mail', fieldWidth),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacingMd(context)),
                    _sectionCard(
                      context,
                      title: 'Présentation du document',
                      icon: Icons.draw_outlined,
                      child: Material(
                        color: Colors.transparent,
                        child: SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _includeExpertSignature,
                          title: const Text(
                            'Afficher la signature de l’expert',
                          ),
                          subtitle: const Text(
                            'La signature configurée sera ajoutée au rapport final.',
                          ),
                          onChanged: (value) {
                            setState(() => _includeExpertSignature = value);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacingMd(context)),
                    _sectionCard(
                      context,
                      title: 'Clés, entretiens, manuels et documents',
                      icon: Icons.inventory_2_outlined,
                      subtitle: 'Saisissez un élément par ligne.',
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _multiLineField(
                            _keysController,
                            'Clés / badges / télécommandes',
                            isMobile ? constraints.maxWidth : largeFieldWidth,
                          ),
                          _multiLineField(
                            _maintenanceController,
                            'Entretiens',
                            isMobile ? constraints.maxWidth : largeFieldWidth,
                          ),
                          _multiLineField(
                            _manualsController,
                            'Manuels / modes d’emploi',
                            isMobile ? constraints.maxWidth : largeFieldWidth,
                          ),
                          _multiLineField(
                            _documentsController,
                            'Documents remis',
                            isMobile ? constraints.maxWidth : largeFieldWidth,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacingMd(context)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        Responsive.value(
                          context: context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Le document comprend : page de garde, table des matières limitée aux pièces, notes liminaires, parties, clés, entretiens, manuels, documents, généralités, pièces avec photos, conclusion et signatures.',
                              style: TextStyle(
                                height: 1.45,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacingLg(context)),
                    _buildActions(
                      context,
                      isMobile: isMobile,
                      standardReport: standardReport,
                      previewEnabled: previewEnabled,
                    ),
                    if (_lastExportPath != null || _lastPdfPath != null) ...[
                      SizedBox(height: Responsive.spacingMd(context)),
                      _sectionCard(
                        context,
                        title: 'Derniers fichiers générés',
                        icon: Icons.folder_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_lastExportPath != null)
                              SelectableText('Word : $_lastExportPath'),
                            if (_lastExportPath != null && _lastPdfPath != null)
                              const SizedBox(height: 8),
                            if (_lastPdfPath != null)
                              SelectableText('PDF : $_lastPdfPath'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        Responsive.value(context: context, mobile: 18, tablet: 22, desktop: 26),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF115E59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Rapports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.snapshot.rooms.length} pièce(s) prête(s) à être exportée(s).',
                  style: const TextStyle(
                    color: Color(0xFFD1FAE5),
                    height: 1.35,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rapports',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.snapshot.rooms.length} pièce(s) prête(s) à être exportée(s).',
                        style: const TextStyle(color: Color(0xFFD1FAE5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        Responsive.value(context: context, mobile: 16, tablet: 20, desktop: 22),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF0F766E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context, {
    required bool isMobile,
    required bool standardReport,
    required bool previewEnabled,
  }) {
    final buttons = <Widget>[
      if (previewEnabled)
        OutlinedButton.icon(
          onPressed: _isExporting ? null : _previewPdf,
          icon: const Icon(Icons.preview_outlined),
          label: const Text('Consulter l’aperçu'),
        ),
      if (standardReport)
        FilledButton.icon(
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
      FilledButton.icon(
        onPressed: _isExporting ? null : _exportPdf,
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Exporter en PDF'),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < buttons.length; index++) ...[
            SizedBox(height: 50, child: buttons[index]),
            if (index != buttons.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: buttons);
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, double width) {
    return SizedBox(
      width: width,
      child: TextField(controller: controller, decoration: _decoration(label)),
    );
  }

  Widget _multiLineField(
    TextEditingController controller,
    String label,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 8,
        decoration: _decoration(label),
      ),
    );
  }
}
