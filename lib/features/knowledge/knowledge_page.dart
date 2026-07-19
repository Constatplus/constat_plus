import 'package:flutter/material.dart';

import '../../engine/inspection/repository/inspection_repository.dart';
import '../../engine/inspection/models/element_definition.dart';

class KnowledgePage extends StatelessWidget {
  const KnowledgePage({super.key});

  @override
  Widget build(BuildContext context) {
    const repository = InspectionRepository();

    final List<ElementDefinition> definitions =
        repository.getAllDefinitions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Engine'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: definitions.length,
        itemBuilder: (context, index) {
          final definition = definitions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.element.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Matériaux",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ...definition.materials.map(
                    (m) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.square),
                      title: Text(m.name),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Revêtements",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ...definition.coverings.map(
                    (c) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.layers),
                      title: Text(c.name),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Défauts",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ...definition.defects.map(
                    (d) => ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                      ),
                      title: Text(d.name),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}