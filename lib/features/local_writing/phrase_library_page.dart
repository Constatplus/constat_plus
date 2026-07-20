import 'package:flutter/material.dart';

class PhraseLibraryPage extends StatefulWidget {
  const PhraseLibraryPage({super.key});
  @override
  State<PhraseLibraryPage> createState() => _PhraseLibraryPageState();
}

class _PhraseLibraryPageState extends State<PhraseLibraryPage> {
  String element = 'Mur gauche';
  String covering = 'peinture blanche';
  String condition = 'bon état général';
  String defect = 'traces de frottement';
  String location = 'en partie basse';

  String get sentence =>
      '$element revêtu de $covering, en $condition. Présence de $defect $location.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque locale de rédaction')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Générateur hors ligne',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les phrases sont construites localement, sans crédit IA et sans connexion.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _field('Élément', element, [
                'Mur gauche',
                'Mur droit',
                'Sol',
                'Plafond',
                'Porte',
                'Châssis',
              ], (v) => setState(() => element = v)),
              _field('Revêtement', covering, [
                'peinture blanche',
                'papier peint',
                'carrelage',
                'parquet stratifié',
                'PVC',
              ], (v) => setState(() => covering = v)),
              _field('État', condition, [
                'bon état général',
                'état d’usage',
                'état moyen',
                'mauvais état',
              ], (v) => setState(() => condition = v)),
              _field('Défaut', defect, [
                'traces de frottement',
                'griffures superficielles',
                'éclat',
                'fissure millimétrique',
                'souillures',
              ], (v) => setState(() => defect = v)),
              _field('Localisation', location, [
                'en partie basse',
                'en partie centrale',
                'à proximité de la porte',
                'ponctuellement',
                'sur l’ensemble',
              ], (v) => setState(() => location = v)),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phrase générée',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    sentence,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      width: 280,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: values
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
