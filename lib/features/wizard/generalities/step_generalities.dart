import 'package:flutter/material.dart';

class StepGeneralities extends StatefulWidget {
  const StepGeneralities({
    super.key,
    Map<String, String>? values,
    required this.onChanged,
    this.includeFurniture = true,
    this.technicalMode = false,
  }) : values = values ?? sharedValues;

  static final Map<String, String> sharedValues = <String, String>{};

  final Map<String, String> values;
  final VoidCallback onChanged;
  final bool includeFurniture;
  final bool technicalMode;

  @override
  State<StepGeneralities> createState() => _StepGeneralitiesState();
}

class _StepGeneralitiesState extends State<StepGeneralities> {
  static const List<String> _baseSections = <String>[
    'Plafond',
    'Murs',
    'Menuiserie intérieure',
    'Menuiserie extérieure',
    'Électricité',
    'Chauffage',
    'Sol',
  ];

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  List<String> get _sections => <String>[
    ..._baseSections,
    if (widget.includeFurniture) 'Mobilier',
  ];

  @override
  void initState() {
    super.initState();
    for (final section in _sections) {
      _controllers[section] = TextEditingController(
        text: widget.values[section] ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant StepGeneralities oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final section in _sections) {
      _controllers.putIfAbsent(
        section,
        () => TextEditingController(text: widget.values[section] ?? ''),
      );
    }
  }

  void _update(String section, String value) {
    final text = value.trim();
    if (text.isEmpty) {
      widget.values.remove(section);
    } else {
      widget.values[section] = text;
    }
    widget.onChanged();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Text(
          widget.technicalMode
              ? 'Généralités du constat avant travaux'
              : "Généralités de l’état des lieux",
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Décrivez ici les caractéristiques communes du bien. Dans la visite, '
          'la case « Conforme aux généralités » permettra de renvoyer clairement '
          'à ces descriptions sans devoir les répéter dans chaque pièce.',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 22),
        for (final section in _sections) ...<Widget>[
          _sectionCard(section),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _sectionCard(String section) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              section,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controllers[section],
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _hintFor(section),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) => _update(section, value),
            ),
          ],
        ),
      ),
    );
  }

  String _hintFor(String section) => switch (section) {
    'Plafond' =>
      'Ex. : plafonds enduits et recouverts d’une peinture blanche mate...',
    'Murs' =>
      'Ex. : murs enduits, peints, propres et exempts de dégradation apparente...',
    'Menuiserie intérieure' =>
      'Ex. : portes planes peintes, quincailleries métalliques...',
    'Menuiserie extérieure' =>
      'Ex. : châssis en PVC double vitrage, tablettes et joints...',
    'Électricité' =>
      'Ex. : appareillage encastré, prises et interrupteurs de teinte blanche...',
    'Chauffage' =>
      'Ex. : radiateurs métalliques peints, vannes thermostatiques...',
    'Sol' => 'Ex. : revêtement carrelé, parquet, plinthes assorties...',
    'Mobilier' =>
      'Ex. : mobilier présent, état général et mode de description commun...',
    _ => 'Décrivez les caractéristiques générales de ce poste.',
  };
}
