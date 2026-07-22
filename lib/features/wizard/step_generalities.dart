import 'package:flutter/material.dart';

class StepGeneralities extends StatefulWidget {
  const StepGeneralities({
    super.key,
    required this.generalities,
    required this.onChanged,
    this.includeFurniture = true,
  });

  final Map<String, String> generalities;
  final VoidCallback onChanged;
  final bool includeFurniture;

  @override
  State<StepGeneralities> createState() => _StepGeneralitiesState();
}

class _StepGeneralitiesState extends State<StepGeneralities> {
  static const List<String> _allPosts = <String>[
    'Plafond',
    'Mur',
    'Menuiserie intérieure',
    'Menuiserie extérieure',
    'Électricité',
    'Chauffage',
    'Sol',
    'Mobilier',
  ];

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  List<String> get _posts => widget.includeFurniture
      ? _allPosts
      : _allPosts.where((post) => post != 'Mobilier').toList(growable: false);

  @override
  void initState() {
    super.initState();
    for (final post in _posts) {
      _controllers[post] = TextEditingController(
        text: widget.generalities[post] ?? '',
      );
    }
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
        const Text(
          'Généralités descriptives',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Décrivez ici les caractéristiques communes du bien. Dans la visite pièce par pièce, la case « Conforme aux généralités » renverra vers ces textes.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 22),
        for (final post in _posts) ...<Widget>[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controllers[post],
                minLines: 3,
                maxLines: 7,
                decoration: InputDecoration(
                  labelText: post,
                  hintText: 'Description générale applicable à plusieurs pièces',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (value) {
                  widget.generalities[post] = value.trim();
                  widget.onChanged();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
