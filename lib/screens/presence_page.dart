import 'package:flutter/material.dart';

class PresencePage extends StatelessWidget {
  const PresencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final persons = [
      'Bailleur',
      'Locataire',
      'Géomètre-Expert',
      'Agent immobilier',
      'Témoin',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnes présentes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Text(
            'Qui est présent lors de l’état des lieux ?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          for (final person in persons)
            CheckboxListTile(
              value: person == 'Géomètre-Expert',
              onChanged: (_) {},
              title: Text(person),
            ),
          const SizedBox(height: 30),
          SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: () {},
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}