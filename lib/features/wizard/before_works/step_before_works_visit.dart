import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../property_composition/models/room_item.dart';
import 'models/technical_finding.dart';

class StepBeforeWorksVisit extends StatefulWidget {
  const StepBeforeWorksVisit({
    super.key,
    required this.rooms,
    required this.findings,
    required this.onChanged,
  });

  final List<RoomItem> rooms;
  final List<TechnicalFinding> findings;
  final VoidCallback onChanged;

  @override
  State<StepBeforeWorksVisit> createState() => _StepBeforeWorksVisitState();
}

class _StepBeforeWorksVisitState extends State<StepBeforeWorksVisit> {
  static const List<String> _posts = <String>[
    'Sol',
    'Murs',
    'Plafond',
    'Menuiseries',
    'Portes',
    'Châssis',
    'Électricité',
    'Sanitaires',
    'Équipements',
    'Observations',
  ];

  final ImagePicker _picker = ImagePicker();

  void _addFinding() {
    setState(() {
      widget.findings.add(
        TechnicalFinding(id: DateTime.now().microsecondsSinceEpoch.toString()),
      );
    });
    widget.onChanged();
  }

  Future<void> _addPhotos(TechnicalFinding finding) async {
    final files = await _picker.pickMultiImage(imageQuality: 88);
    if (files.isEmpty || !mounted) return;
    setState(() => finding.photoPaths.addAll(files.map((file) => file.path)));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final zones = widget.rooms.map((room) => room.name).toList();
    return ListView(
      children: <Widget>[
        const Text(
          'Visite avant travaux',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Documentez l’état apparent de chaque zone et rattachez chaque photographie au constat concerné.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        if (zones.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Ajoutez d’abord une zone dans la composition du constat.',
              ),
            ),
          ),
        for (
          var index = 0;
          index < widget.findings.length;
          index++
        ) ...<Widget>[_findingCard(index, zones), const SizedBox(height: 14)],
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: zones.isEmpty ? null : _addFinding,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un constat'),
          ),
        ),
      ],
    );
  }

  Widget _findingCard(int index, List<String> zones) {
    final finding = widget.findings[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Constat ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() => widget.findings.removeAt(index));
                    widget.onChanged();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _stringDropdown(
                  'Zone',
                  finding.zone,
                  zones,
                  (value) => finding.zone = value,
                ),
                _stringDropdown(
                  'Poste',
                  finding.post,
                  _posts,
                  (value) => finding.post = value,
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<FindingClassification>(
                    initialValue: finding.classification,
                    decoration: _input('Classification'),
                    items: FindingClassification.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(
                        () => finding.classification =
                            value ?? FindingClassification.normal,
                      );
                      widget.onChanged();
                    },
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<TechnicalDisorderType>(
                    initialValue: finding.disorderType,
                    decoration: _input('Constat technique'),
                    items: TechnicalDisorderType.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(
                        () => finding.disorderType =
                            value ?? TechnicalDisorderType.other,
                      );
                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: finding.description,
              minLines: 3,
              maxLines: 7,
              decoration: _input('Description du constat'),
              onChanged: (value) {
                finding.description = value;
                widget.onChanged();
              },
            ),
            if (finding.disorderType.isCrack) ...<Widget>[
              const SizedBox(height: 14),
              const Text(
                'Caractéristiques de la fissure',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _crackField(
                    'Emplacement',
                    finding.crack.location,
                    (value) => finding.crack.location = value,
                  ),
                  _crackField(
                    'Orientation',
                    finding.crack.orientation,
                    (value) => finding.crack.orientation = value,
                  ),
                  _crackField(
                    'Longueur',
                    finding.crack.length,
                    (value) => finding.crack.length = value,
                  ),
                  _crackField(
                    'Largeur approximative',
                    finding.crack.approximateWidth,
                    (value) => finding.crack.approximateWidth = value,
                  ),
                  _crackField(
                    'Ouverture (mm)',
                    finding.crack.openingMillimeters,
                    (value) => finding.crack.openingMillimeters = value,
                  ),
                  _boolDropdown(
                    'Traversante',
                    finding.crack.through,
                    (value) => finding.crack.through = value,
                  ),
                  _boolDropdown(
                    'Active ou évolutive',
                    finding.crack.active,
                    (value) => finding.crack.active = value,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: finding.crack.observation,
                decoration: _input('Observation libre sur la fissure'),
                onChanged: (value) {
                  finding.crack.observation = value;
                  widget.onChanged();
                },
              ),
            ],
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _addPhotos(finding),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text('Ajouter des photos (${finding.photoPaths.length})'),
            ),
            if (finding.photoPaths.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: finding.photoPaths
                    .asMap()
                    .entries
                    .map(
                      (entry) => Stack(
                        children: <Widget>[
                          Image.file(
                            File(entry.value),
                            width: 120,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton.filledTonal(
                              onPressed: () {
                                setState(
                                  () => finding.photoPaths.removeAt(entry.key),
                                );
                                widget.onChanged();
                              },
                              icon: const Icon(Icons.close),
                              iconSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stringDropdown(
    String label,
    String current,
    List<String> values,
    ValueChanged<String> changed,
  ) => SizedBox(
    width: 280,
    child: DropdownButtonFormField<String>(
      initialValue: values.contains(current) ? current : null,
      decoration: _input(label),
      items: values
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) {
        changed(value ?? '');
        widget.onChanged();
      },
    ),
  );

  Widget _crackField(
    String label,
    String value,
    ValueChanged<String> changed,
  ) => SizedBox(
    width: 230,
    child: TextFormField(
      initialValue: value,
      decoration: _input(label),
      onChanged: (text) {
        changed(text);
        widget.onChanged();
      },
    ),
  );

  Widget _boolDropdown(
    String label,
    bool? value,
    ValueChanged<bool?> changed,
  ) => SizedBox(
    width: 230,
    child: DropdownButtonFormField<String>(
      initialValue: value == null
          ? 'unknown'
          : value
          ? 'yes'
          : 'no',
      decoration: _input(label),
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(
          value: 'unknown',
          child: Text('Non déterminé'),
        ),
        DropdownMenuItem<String>(value: 'yes', child: Text('Oui')),
        DropdownMenuItem<String>(value: 'no', child: Text('Non')),
      ],
      onChanged: (selected) {
        changed(selected == 'unknown' ? null : selected == 'yes');
        widget.onChanged();
      },
    ),
  );

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}
