import 'package:flutter/material.dart';

import '../widgets/photo_picker_section.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab>
    with AutomaticKeepAliveClientMixin {
  final List<_DocumentItem> documents = [
    _DocumentItem('Chaudière'),
    _DocumentItem('Thermostat'),
    _DocumentItem('Boiler'),
    _DocumentItem('Pompe à chaleur'),
    _DocumentItem('Adoucisseur'),
    _DocumentItem('VMC'),
    _DocumentItem('Ventilation'),
    _DocumentItem('Hotte'),
    _DocumentItem('Four'),
    _DocumentItem('Plaque de cuisson'),
    _DocumentItem('Lave-vaisselle'),
    _DocumentItem('Réfrigérateur'),
    _DocumentItem('Congélateur'),
    _DocumentItem('Machine à laver'),
    _DocumentItem('Sèche-linge'),
    _DocumentItem('Alarme'),
    _DocumentItem('Portail'),
    _DocumentItem('Porte de garage'),
    _DocumentItem('Panneaux photovoltaïques'),
    _DocumentItem('Batterie domestique'),
    _DocumentItem('Certificat PEB'),
    _DocumentItem('Contrôle électrique'),
    _DocumentItem('Contrôle gaz'),
    _DocumentItem('Autre'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.separated(
      itemCount: documents.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final item = documents[index];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: item.selected
                  ? Colors.blue
                  : Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                CheckboxListTile(
                  value: item.selected,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.blue,
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Manuel ou document remis avec le bien',
                  ),
                  onChanged: (value) {
                    setState(() {
                      item.selected = value ?? false;
                    });
                  },
                ),
                if (item.selected) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: item.observation,
                    maxLines: 2,
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
                    key: ValueKey(
                      'document-photo-${item.id}',
                    ),
                    title: 'Photos du document',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentItem {
  final String id;
  final String name;

  bool selected;
  String observation;

  _DocumentItem(this.name)
      : selected = false,
        observation = '',
        id = '${DateTime.now().microsecondsSinceEpoch}-$name';
}
