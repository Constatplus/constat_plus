import 'package:flutter/material.dart';

import 'models/report_preferences.dart';
import 'services/report_preferences_service.dart';
import 'widgets/report_live_preview.dart';

class ReportSettingsPage extends StatefulWidget {
  const ReportSettingsPage({super.key});

  @override
  State<ReportSettingsPage> createState() => _ReportSettingsPageState();
}

class _ReportSettingsPageState extends State<ReportSettingsPage>
    with SingleTickerProviderStateMixin {
  final _service = ReportPreferencesService();
  late final TabController _tabs;

  ReportPreferences? _preferences;
  bool _loading = true;
  bool _saving = false;
  ReportPreviewPage _previewPage = ReportPreviewPage.cover;
  double _previewZoom = .75;

  final _templateName = TextEditingController();
  final _logoPath = TextEditingController();
  final _companyName = TextEditingController();
  final _companyAddress = TextEditingController();
  final _companyPhone = TextEditingController();
  final _companyEmail = TextEditingController();
  final _companyWebsite = TextEditingController();
  final _professionalNumber = TextEditingController();
  final _vatNumber = TextEditingController();
  final _footerText = TextEditingController();
  final _entryNotes = TextEditingController();
  final _exitNotes = TextEditingController();
  final _beforeWorksNotes = TextEditingController();
  final _primaryColor = TextEditingController();
  final _secondaryColor = TextEditingController();
  final _headingColor = TextEditingController();
  final _bodyColor = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final value = await _service.load();
    _applyToControllers(value);
    if (!mounted) return;
    setState(() {
      _preferences = value;
      _loading = false;
    });
  }

  void _applyToControllers(ReportPreferences value) {
    _templateName.text = value.templateName;
    _logoPath.text = value.logoPath;
    _companyName.text = value.companyName;
    _companyAddress.text = value.companyAddress;
    _companyPhone.text = value.companyPhone;
    _companyEmail.text = value.companyEmail;
    _companyWebsite.text = value.companyWebsite;
    _professionalNumber.text = value.professionalNumber;
    _vatNumber.text = value.vatNumber;
    _footerText.text = value.footerText;
    _entryNotes.text = value.entryPreliminaryNotes;
    _exitNotes.text = value.exitPreliminaryNotes;
    _beforeWorksNotes.text = value.beforeWorksPreliminaryNotes;
    _primaryColor.text = value.primaryColorHex;
    _secondaryColor.text = value.secondaryColorHex;
    _headingColor.text = value.headingColorHex;
    _bodyColor.text = value.bodyColorHex;
  }

  ReportPreferences _collect() {
    final current = _preferences ?? ReportPreferences.defaults();
    return current.copyWith(
      templateName: _templateName.text.trim(),
      logoPath: _logoPath.text.trim(),
      companyName: _companyName.text.trim(),
      companyAddress: _companyAddress.text.trim(),
      companyPhone: _companyPhone.text.trim(),
      companyEmail: _companyEmail.text.trim(),
      companyWebsite: _companyWebsite.text.trim(),
      professionalNumber: _professionalNumber.text.trim(),
      vatNumber: _vatNumber.text.trim(),
      footerText: _footerText.text.trim(),
      entryPreliminaryNotes: _entryNotes.text.trim(),
      exitPreliminaryNotes: _exitNotes.text.trim(),
      beforeWorksPreliminaryNotes: _beforeWorksNotes.text.trim(),
      primaryColorHex: _cleanHex(_primaryColor.text, current.primaryColorHex),
      secondaryColorHex: _cleanHex(_secondaryColor.text, current.secondaryColorHex),
      headingColorHex: _cleanHex(_headingColor.text, current.headingColorHex),
      bodyColorHex: _cleanHex(_bodyColor.text, current.bodyColorHex),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final value = _collect();
    await _service.save(value);
    if (!mounted) return;
    setState(() {
      _preferences = value;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modèle de rapport enregistré.')),
    );
  }

  Future<void> _restoreDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rétablir le modèle par défaut ?'),
        content: const Text(
          'Les couleurs, polices, notes liminaires et informations de société seront réinitialisées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rétablir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final defaults = ReportPreferences.defaults();
    _applyToControllers(defaults);
    await _service.save(defaults);
    if (!mounted) return;
    setState(() => _preferences = defaults);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final controller in <TextEditingController>[
      _templateName,
      _logoPath,
      _companyName,
      _companyAddress,
      _companyPhone,
      _companyEmail,
      _companyWebsite,
      _professionalNumber,
      _vatNumber,
      _footerText,
      _entryNotes,
      _exitNotes,
      _beforeWorksNotes,
      _primaryColor,
      _secondaryColor,
      _headingColor,
      _bodyColor,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Studio de rapport'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _restoreDefaults,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Valeurs par défaut'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: _loading || _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.business_outlined), text: 'Identité'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'Apparence'),
            Tab(icon: Icon(Icons.notes_outlined), text: 'Notes liminaires'),
            Tab(icon: Icon(Icons.view_agenda_outlined), text: 'Structure'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _identityTab(),
                _appearanceTab(),
                _notesTab(),
                _structureTab(),
              ],
            ),
    );
  }

  Widget _identityTab() {
    return _scroll(
      children: [
        _section(
          title: 'Modèle',
          subtitle: 'Nommez ce modèle pour l’identifier facilement.',
          children: [
            _field(_templateName, 'Nom du modèle', icon: Icons.bookmark_outline),
          ],
        ),
        _section(
          title: 'Identité professionnelle',
          subtitle: 'Ces informations apparaîtront sur la page de garde et dans le pied de page.',
          children: [
            _twoColumns(
              _field(_companyName, 'Nom de la société', icon: Icons.business),
              _field(_professionalNumber, 'Numéro professionnel', icon: Icons.badge_outlined),
            ),
            _field(_companyAddress, 'Adresse', icon: Icons.location_on_outlined),
            _twoColumns(
              _field(_companyPhone, 'Téléphone', icon: Icons.phone_outlined),
              _field(_companyEmail, 'E-mail', icon: Icons.email_outlined),
            ),
            _twoColumns(
              _field(_companyWebsite, 'Site internet', icon: Icons.language),
              _field(_vatNumber, 'Numéro de TVA', icon: Icons.receipt_long_outlined),
            ),
            _field(_logoPath, 'Chemin ou URL du logo', icon: Icons.image_outlined),
            _field(
              _footerText,
              'Texte du pied de page',
              icon: Icons.vertical_align_bottom,
              maxLines: 2,
            ),
          ],
        ),
        _section(
          title: 'Éléments affichés',
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _preferences!.showLogo,
              title: const Text('Afficher le logo'),
              subtitle: const Text('Sur la page de garde et, selon le modèle, dans l’en-tête.'),
              onChanged: (value) => setState(
                () => _preferences = _preferences!.copyWith(showLogo: value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _preferences!.showPageNumbers,
              title: const Text('Afficher les numéros de page'),
              onChanged: (value) => setState(
                () => _preferences = _preferences!.copyWith(showPageNumbers: value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _appearanceTab() {
    final value = _preferences!;
    final live = _collect();

    final settingsPanel = ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _section(
          title: 'Palette du rapport',
          subtitle: 'Chaque changement est visible immédiatement dans l’aperçu.',
          children: [
            _colorField('Couleur principale', _primaryColor),
            _colorField('Couleur secondaire', _secondaryColor),
            _colorField('Titres et sous-titres', _headingColor),
            _colorField('Texte courant', _bodyColor),
          ],
        ),
        _section(
          title: 'Typographie',
          children: [
            DropdownButtonFormField<String>(
              initialValue: value.fontFamily,
              decoration: const InputDecoration(
                labelText: 'Police principale',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Sylfaen',
                'Arial',
                'Calibri',
                'Georgia',
                'Times New Roman',
                'Verdana',
              ]
                  .map((font) => DropdownMenuItem(value: font, child: Text(font)))
                  .toList(),
              onChanged: (font) {
                if (font == null) return;
                setState(() => _preferences = _preferences!.copyWith(fontFamily: font));
              },
            ),
            const SizedBox(height: 20),
            _slider(
              'Titre principal',
              value.titleFontSize,
              16,
              32,
              (size) => setState(
                () => _preferences = _preferences!.copyWith(titleFontSize: size),
              ),
            ),
            _slider(
              'Titres de section',
              value.headingFontSize,
              11,
              22,
              (size) => setState(
                () => _preferences = _preferences!.copyWith(headingFontSize: size),
              ),
            ),
            _slider(
              'Texte courant',
              value.bodyFontSize,
              8,
              16,
              (size) => setState(
                () => _preferences = _preferences!.copyWith(bodyFontSize: size),
              ),
            ),
          ],
        ),
        _section(
          title: 'Mise en page',
          children: [
            _slider(
              'Marges de page',
              value.pageMarginMm,
              10,
              35,
              (size) => setState(
                () => _preferences = _preferences!.copyWith(pageMarginMm: size),
              ),
              suffix: 'mm',
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: value.showLogo,
              title: const Text('Afficher le logo'),
              onChanged: (enabled) => setState(
                () => _preferences = _preferences!.copyWith(showLogo: enabled),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: value.showPageNumbers,
              title: const Text('Afficher les numéros de page'),
              onChanged: (enabled) => setState(
                () => _preferences = _preferences!.copyWith(showPageNumbers: enabled),
              ),
            ),
          ],
        ),
      ],
    );

    final preview = ReportLivePreview(
      preferences: live,
      page: _previewPage,
      zoom: _previewZoom,
      onPageChanged: (page) => setState(() => _previewPage = page),
      onZoomChanged: (zoom) => setState(() => _previewZoom = zoom),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1050) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(height: 760, child: settingsPanel),
              const SizedBox(height: 16),
              SizedBox(height: 980, child: preview),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 430, child: settingsPanel),
              const SizedBox(width: 18),
              Expanded(child: preview),
            ],
          ),
        );
      },
    );
  }

  Widget _notesTab() {
    return _scroll(
      children: [
        _section(
          title: 'État des lieux d’entrée',
          subtitle: 'Texte placé au début du rapport d’entrée.',
          children: [_field(_entryNotes, 'Notes liminaires', maxLines: 9)],
        ),
        _section(
          title: 'État des lieux de sortie',
          subtitle: 'Ce texte doit rappeler la comparaison avec l’état des lieux d’entrée.',
          children: [_field(_exitNotes, 'Notes liminaires', maxLines: 9)],
        ),
        _section(
          title: 'État des lieux avant travaux',
          subtitle: 'Texte spécifique à la preuve des désordres préexistants.',
          children: [_field(_beforeWorksNotes, 'Notes liminaires', maxLines: 9)],
        ),
      ],
    );
  }

  Widget _structureTab() {
    return _scroll(
      children: [
        _section(
          title: 'Ordre et contenu du rapport',
          subtitle: 'Glissez les sections pour les réordonner et désactivez celles qui ne doivent pas apparaître.',
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _preferences!.sections.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final sections = [..._preferences!.sections];
                  if (newIndex > oldIndex) newIndex--;
                  final item = sections.removeAt(oldIndex);
                  sections.insert(newIndex, item);
                  _preferences = _preferences!.copyWith(sections: sections);
                });
              },
              itemBuilder: (context, index) {
                final section = _preferences!.sections[index];
                return Card(
                  key: ValueKey(section.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    title: Text(section.label),
                    trailing: Switch.adaptive(
                      value: section.enabled,
                      onChanged: (enabled) {
                        final sections = [..._preferences!.sections];
                        sections[index] = section.copyWith(enabled: enabled);
                        setState(() => _preferences = _preferences!.copyWith(sections: sections));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _scroll({required List<Widget> children}) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey)),
            ],
            const SizedBox(height: 20),
            ...children.expand((child) => [child, const SizedBox(height: 14)]),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _twoColumns(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(children: [left, const SizedBox(height: 14), right]);
        }
        return Row(children: [Expanded(child: left), const SizedBox(width: 14), Expanded(child: right)]);
      },
    );
  }

  Widget _colorField(String label, TextEditingController controller) {
    final color = _hexColor(_cleanHex(controller.text, '1E5AA8'));
    const presets = ['1E5AA8', '0F766E', '7C3AED', 'B45309', '9F1239', '111827'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLength: 7,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: label,
            counterText: '',
            prefixText: '#',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: presets.map((hex) {
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                controller.text = hex;
                setState(() {});
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _hexColor(hex),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String suffix = 'pt',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('${value.toStringAsFixed(0)} $suffix'),
          ],
        ),
        Slider(value: value.clamp(min, max).toDouble(), min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
      ],
    );
  }

  static String _cleanHex(String value, String fallback) {
    final clean = value.replaceAll('#', '').trim().toUpperCase();
    return RegExp(r'^[0-9A-F]{6}$').hasMatch(clean) ? clean : fallback;
  }

  static Color _hexColor(String value) {
    final clean = _cleanHex(value, '1E5AA8');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
