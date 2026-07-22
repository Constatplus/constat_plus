import 'package:flutter/material.dart';

import '../models/mission_handover_data.dart';
import '../widgets/photo_picker_section.dart';

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key, required this.data});

  final MissionHandoverData data;

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab>
    with AutomaticKeepAliveClientMixin {
  static const List<String> _defaultDocuments = <String>[
    'Chaudière',
    'Thermostat',
    'Boiler',
    'Pompe à chaleur',
    'Adoucisseur',
    'VMC',
    'Ventilation',
    'Hotte',
    'Four',
    'Plaque de cuisson',
    'Lave-vaisselle',
    'Réfrigérateur',
    'Congélateur',
    'Machine à laver',
    'Sèche-linge',
    'Alarme',
    'Portail',
    'Porte de garage',
    'Panneaux photovoltaïques',
    'Batterie domestique',
    'Certificat PEB',
    'Contrôle électrique',
    'Contrôle gaz',
    'Autre',
  ];

  List<DocumentHandoverItem> get documents => widget.data.documents;

  @override
  void initState() {
    super.initState();
    if (documents.isEmpty) {
      documents.addAll(
        _defaultDocuments.map(DocumentHandoverItem.new),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.separated(
      itemCount: documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = documents[index];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: item.selected ? Colors.blue : Colors.grey.shade300,
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Manuel ou document remis avec le bien'),
                  onChanged: (value) {
                    setState(() {
                      item.selected = value ?? false;
                    });
                  },
                ),
                if (item.selected) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey('document-observation-${item.id}'),
                    initialValue: item.observation,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Observation',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    onChanged: (value) => item.observation = value,
                  ),
                  const SizedBox(height: 14),
                  PhotoPickerSection(
                    key: ValueKey('document-photo-${item.id}'),
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
