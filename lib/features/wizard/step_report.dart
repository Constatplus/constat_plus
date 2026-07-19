import 'package:flutter/material.dart';

import '../settings/models/report_preferences.dart';
import '../settings/services/report_preferences_service.dart';
import 'report/models/report_settings.dart';
import 'report/models/visit_report_snapshot.dart';
import 'report/services/word_report_service.dart';

class StepReport extends StatefulWidget {
  final VisitReportSnapshot snapshot;
  final InspectionReportType initialReportType;

  const StepReport({
    super.key,
    required this.snapshot,
    this.initialReportType = InspectionReportType.entry,
  });

  @override
  State<StepReport> createState() => _StepReportState();
}

class _StepReportState extends State<StepReport> {
  final WordReportService _wordService = WordReportService();
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
    };
    return text
        .split(RegExp(r'\n\s*\n|\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
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
      final defaults = ReportSettings.defaults(_reportType);
      final settings = ReportSettings(
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
            ? 'Adresse du bien'
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'Export Word',
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
                onChanged: _changeReportType,
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
        if (_lastExportPath != null) ...[
          const SizedBox(height: 16),
          SelectableText('Dernier fichier : $_lastExportPath'),
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

  Widget _field(
    TextEditingController controller,
    String label,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: _decoration(label),
      ),
    );
  }

  Widget _multiLineField(
    TextEditingController controller,
    String label,
  ) {
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
