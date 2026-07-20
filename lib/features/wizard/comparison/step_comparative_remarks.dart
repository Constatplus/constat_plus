import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../before_works/models/technical_finding.dart';
import '../property_composition/models/room_item.dart';
import 'models/comparison_remark.dart';

class StepComparativeRemarks extends StatefulWidget {
  const StepComparativeRemarks({
    super.key,
    required this.rooms,
    required this.remarks,
    required this.referenceFindings,
    required this.afterWorks,
    this.onOpenReference,
  });

  final List<RoomItem> rooms;
  final List<ComparisonRemark> remarks;
  final List<TechnicalFinding> referenceFindings;
  final bool afterWorks;
  final VoidCallback? onOpenReference;

  @override
  State<StepComparativeRemarks> createState() => _StepComparativeRemarksState();
}

class _StepComparativeRemarksState extends State<StepComparativeRemarks> {
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

  @override
  void initState() {
    super.initState();
    if (widget.remarks.isEmpty) {
      widget.remarks.add(
        ComparisonRemark(id: DateTime.now().microsecondsSinceEpoch.toString()),
      );
    }
  }

  void _add() {
    setState(() {
      widget.remarks.add(
        ComparisonRemark(id: DateTime.now().microsecondsSinceEpoch.toString()),
      );
    });
  }

  Future<void> _addPhotos(ComparisonRemark remark) async {
    final files = await _picker.pickMultiImage(imageQuality: 88);
    if (files.isEmpty || !mounted) return;
    setState(
      () => remark.afterPhotoPaths.addAll(files.map((file) => file.path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomNames = widget.rooms.map((room) => room.name).toList();
    return ListView(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.afterWorks
                    ? 'Remarques comparatives de récolement'
                    : 'Remarques comparatives de sortie',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (widget.onOpenReference != null)
              FilledButton.icon(
                onPressed: widget.onOpenReference,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Consulter le rapport avant travaux'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < widget.remarks.length; index++) ...<Widget>[
          _remarkCard(index, roomNames),
          const SizedBox(height: 14),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une remarque'),
          ),
        ),
      ],
    );
  }

  Widget _remarkCard(int index, List<String> roomNames) {
    final remark = widget.remarks[index];
    final findings = widget.referenceFindings
        .where((finding) => remark.zone.isEmpty || finding.zone == remark.zone)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Remarque ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.remarks.length == 1
                      ? null
                      : () => setState(() => widget.remarks.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _dropdown<String>(
                  280,
                  'Zone',
                  roomNames.contains(remark.zone) ? remark.zone : null,
                  roomNames,
                  (value) => setState(() {
                    remark.zone = value ?? '';
                    remark.referenceFindingId = '';
                  }),
                ),
                _dropdown<String>(
                  260,
                  'Poste',
                  _posts.contains(remark.post) ? remark.post : null,
                  _posts,
                  (value) => setState(() => remark.post = value ?? ''),
                ),
                if (widget.afterWorks)
                  SizedBox(
                    width: 360,
                    child: DropdownButtonFormField<String>(
                      initialValue:
                          findings.any(
                            (item) => item.id == remark.referenceFindingId,
                          )
                          ? remark.referenceFindingId
                          : null,
                      decoration: _input('Constat de référence'),
                      items: findings
                          .map(
                            (finding) => DropdownMenuItem<String>(
                              value: finding.id,
                              child: Text(
                                finding.description.isEmpty
                                    ? finding.disorderType.label
                                    : finding.description,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => remark.referenceFindingId = value ?? '',
                      ),
                    ),
                  ),
                if (widget.afterWorks)
                  SizedBox(
                    width: 340,
                    child: DropdownButtonFormField<ComparisonStatus>(
                      initialValue: remark.status,
                      decoration: _input('Statut comparatif'),
                      items: ComparisonStatus.values
                          .map(
                            (status) => DropdownMenuItem<ComparisonStatus>(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () =>
                            remark.status = value ?? ComparisonStatus.unchanged,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: remark.afterDescription,
              minLines: 3,
              maxLines: 7,
              decoration: _input(
                widget.afterWorks
                    ? 'Description du constat après travaux'
                    : 'Remarque constatée à la sortie',
              ),
              onChanged: (value) => remark.afterDescription = value,
            ),
            if (widget.afterWorks) ...<Widget>[
              const SizedBox(height: 12),
              DropdownButtonFormField<TechnicalConclusion>(
                initialValue: remark.conclusion,
                decoration: _input('Conclusion technique'),
                items: TechnicalConclusion.values
                    .map(
                      (value) => DropdownMenuItem<TechnicalConclusion>(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(
                  () => remark.conclusion =
                      value ?? TechnicalConclusion.noApparentChange,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: remark.recommendation,
                decoration: _input('Recommandation éventuelle'),
                onChanged: (value) => remark.recommendation = value,
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _addPhotos(remark),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Photos après travaux (${remark.afterPhotoPaths.length})',
              ),
            ),
            if (remark.afterPhotoPaths.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: remark.afterPhotoPaths
                    .map(
                      (path) => Image.file(
                        File(path),
                        width: 110,
                        height: 82,
                        fit: BoxFit.cover,
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

  Widget _dropdown<T>(
    double width,
    String label,
    T? value,
    List<T> values,
    ValueChanged<T?> changed,
  ) => SizedBox(
    width: width,
    child: DropdownButtonFormField<T>(
      initialValue: value,
      decoration: _input(label),
      items: values
          .map((item) => DropdownMenuItem<T>(value: item, child: Text('$item')))
          .toList(),
      onChanged: changed,
    ),
  );

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}
