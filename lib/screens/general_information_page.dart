import 'package:flutter/material.dart';
import 'presence_page.dart';

class GeneralInformationPage extends StatelessWidget {
  final String propertyType;

  const GeneralInformationPage({super.key, required this.propertyType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations générales')),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Text(
            propertyType,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "État des lieux d'entrée",
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
          const SizedBox(height: 28),

          const _SectionTitle('Adresse du bien'),
          const _GeoField(label: 'Rue'),
          const _GeoField(label: 'Numéro'),
          const _GeoField(label: 'Boîte'),
          const _GeoField(label: 'Code postal'),
          const _GeoField(label: 'Commune'),

          const SizedBox(height: 22),
          const _SectionTitle('Dossier'),
          const _GeoField(label: 'Référence dossier'),
          const _GeoField(label: 'Date de l’état des lieux'),
          const _GeoField(label: 'Heure'),

          const SizedBox(height: 22),
          const _SectionTitle('Bailleur'),
          const _GeoField(label: 'Nom et prénom'),
          const _GeoField(label: 'Téléphone'),
          const _GeoField(label: 'Email'),

          const SizedBox(height: 22),
          const _SectionTitle('Locataire'),
          const _GeoField(label: 'Nom et prénom'),
          const _GeoField(label: 'Téléphone'),
          const _GeoField(label: 'Email'),

          const SizedBox(height: 32),
          SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PresencePage()),
                );
              },
              child: const Text('Continuer', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GeoField extends StatelessWidget {
  final String label;

  const _GeoField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
