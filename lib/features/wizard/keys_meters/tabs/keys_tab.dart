import 'package:flutter/material.dart';

import '../widgets/photo_picker_section.dart';

class KeysTab extends StatefulWidget {
  const KeysTab({super.key});

  @override
  State<KeysTab> createState() => _KeysTabState();
}

class _KeysTabState extends State<KeysTab> with AutomaticKeepAliveClientMixin {
  final List<String> keyTemplates = const [
    'Porte d’entrée',
    'Porte arrière',
    'Porte jardin',
    'Portail',
    'Garage',
    'Remise',
    'Cave',
    'Boîte aux lettres',
    'Local technique',
    'Badge',
    'Télécommande portail',
    'Télécommande garage',
    'Clé de sécurité',
    'Autre',
  ];

  final List<_KeyItem> selectedKeys = [];

  @override
  bool get wantKeepAlive => true;

  void _addKey(String name) {
    setState(() {
      selectedKeys.add(
        _KeyItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          quantity: 1,
        ),
      );
    });
  }

  void _removeKey(int index) {
    setState(() {
      selectedKeys.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 310,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter une clé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: keyTemplates.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final name = keyTemplates[index];

                    return Material(
                      color: const Color(0xFFF4F8FA),
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        leading: const Icon(
                          Icons.key_rounded,
                          color: Colors.blue,
                        ),
                        title: Text(name),
                        trailing: const Icon(Icons.add_circle_outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onTap: () => _addKey(name),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clés ajoutées (${selectedKeys.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: selectedKeys.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune clé ajoutée.',
                          style: TextStyle(fontSize: 17, color: Colors.black45),
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedKeys.length,
                        itemBuilder: (context, index) {
                          final item = selectedKeys[index];

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.key_rounded,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item.name,
                                          decoration: const InputDecoration(
                                            labelText: 'Nom',
                                          ),
                                          onChanged: (value) {
                                            item.name = value;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        child: DropdownButtonFormField<int>(
                                          initialValue: item.quantity,
                                          decoration: const InputDecoration(
                                            labelText: 'Quantité',
                                          ),
                                          items: List.generate(10, (
                                            quantityIndex,
                                          ) {
                                            final value = quantityIndex + 1;

                                            return DropdownMenuItem(
                                              value: value,
                                              child: Text('$value'),
                                            );
                                          }),
                                          onChanged: (value) {
                                            if (value == null) return;

                                            item.quantity = value;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: 'Supprimer',
                                        onPressed: () => _removeKey(index),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    initialValue: item.observation,
                                    decoration: const InputDecoration(
                                      labelText: 'Observation',
                                      prefixIcon: Icon(Icons.notes_rounded),
                                    ),
                                    onChanged: (value) {
                                      item.observation = value;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  PhotoPickerSection(
                                    key: ValueKey('key-photo-${item.id}'),
                                    title: 'Photos de la clé',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeyItem {
  final String id;

  String name;
  int quantity;
  String observation;

  _KeyItem({required this.id, required this.name, required this.quantity})
    : observation = '';
}
