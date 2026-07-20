import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../property_composition/models/room_item.dart';
import 'models/before_works_data.dart';
import 'models/technical_finding.dart';

class StepBeforeWorksVisit extends StatefulWidget {
  const StepBeforeWorksVisit({
    super.key,
    required this.rooms,
    required this.data,
    required this.onChanged,
  });

  final List<RoomItem> rooms;
  final BeforeWorksData data;
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

  List<TechnicalFinding> get _findings => widget.data.findings;

  @override
  void initState() {
    super.initState();
    widget.data.ensureInitialStructure(widget.rooms.map((room) => room.name));
  }

  void _addFinding() {
    final areas = widget.data.areas;
    setState(() {
      final finding = TechnicalFinding(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
      );
      if (areas.isNotEmpty) {
        final preferred = areas.firstWhere(
          (area) => !area.type.isContainer,
          orElse: () => areas.first,
        );
        finding
          ..areaId = preferred.id
          ..zone = widget.data.areaPath(preferred);
      }
      _findings.add(finding);
    });
    widget.onChanged();
  }

  Future<void> _addArea(
    BeforeWorksAreaType type, {
    String? parentId,
    String? suggestedName,
  }) async {
    final controller = TextEditingController(text: suggestedName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter : ${type.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.isEmpty) return;
    setState(() {
      widget.data.areas.add(
        BeforeWorksArea(
          id: '${type.name}-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          type: type,
          parentId: parentId,
        ),
      );
    });
    widget.onChanged();
  }

  Future<void> _renameArea(BeforeWorksArea area) async {
    final controller = TextEditingController(text: area.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${area.type.label.toLowerCase()}'),
        content: TextField(controller: controller, autofocus: true),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.isEmpty) return;
    setState(() {
      area.name = name;
      for (final finding in _findings) {
        final matches = widget.data.areas.where(
          (item) => item.id == finding.areaId,
        );
        if (matches.isNotEmpty) {
          finding.zone = widget.data.areaPath(matches.first);
        }
      }
    });
    widget.onChanged();
  }

  Future<void> _deleteArea(BeforeWorksArea area) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer « ${area.name} » ?'),
        content: const Text(
          'Ses sous-éléments et les constats qui y sont rattachés seront également supprimés.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final ids = <String>{area.id};
    var added = true;
    while (added) {
      final before = ids.length;
      ids.addAll(
        widget.data.areas
            .where((item) => ids.contains(item.parentId))
            .map((item) => item.id),
      );
      added = ids.length != before;
    }
    setState(() {
      widget.data.areas.removeWhere((item) => ids.contains(item.id));
      _findings.removeWhere((item) => ids.contains(item.areaId));
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
    final areas = widget.data.areas;
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
        _compositionCard(),
        const SizedBox(height: 22),
        for (var index = 0; index < _findings.length; index++) ...<Widget>[
          _findingCard(index, areas),
          const SizedBox(height: 14),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: areas.isEmpty ? null : _addFinding,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un constat'),
          ),
        ),
      ],
    );
  }

  Widget _compositionCard() {
    final roots = widget.data.areas
        .where((area) => area.parentId == null)
        .toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Structure du constat',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final root in roots) _areaTile(root),
            Wrap(
              spacing: 10,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () => _addArea(
                    BeforeWorksAreaType.building,
                    suggestedName:
                        'Maison ou bâtiment n° ${roots.where((item) => item.type == BeforeWorksAreaType.building).length + 1}',
                  ),
                  icon: const Icon(Icons.apartment),
                  label: const Text('Ajouter un bâtiment'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      roots.any((item) => item.type == BeforeWorksAreaType.road)
                      ? null
                      : () => _addArea(
                          BeforeWorksAreaType.road,
                          suggestedName: 'Voirie',
                        ),
                  icon: const Icon(Icons.add_road),
                  label: const Text('Ajouter la voirie'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaTile(BeforeWorksArea area) {
    final children = widget.data.areas
        .where((item) => item.parentId == area.id)
        .toList(growable: false);
    return ExpansionTile(
      initiallyExpanded: true,
      leading: Icon(
        area.type == BeforeWorksAreaType.building
            ? Icons.apartment
            : Icons.add_road,
      ),
      title: Text(area.name),
      subtitle: Text(area.type.label),
      trailing: Wrap(
        children: <Widget>[
          IconButton(
            tooltip: 'Modifier',
            onPressed: () => _renameArea(area),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Supprimer',
            onPressed: () => _deleteArea(area),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      children: <Widget>[
        for (final child in children)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 40, right: 8),
            title: Text(child.name),
            subtitle: Text(child.type.label),
            trailing: Wrap(
              children: <Widget>[
                IconButton(
                  tooltip: 'Modifier',
                  onPressed: () => _renameArea(child),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  onPressed: () => _deleteArea(child),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 4, 8, 12),
          child: Wrap(
            spacing: 8,
            children: area.type == BeforeWorksAreaType.building
                ? <Widget>[
                    _addChildButton(area, BeforeWorksAreaType.facade),
                    _addChildButton(area, BeforeWorksAreaType.room),
                    _addChildButton(area, BeforeWorksAreaType.surroundings),
                  ]
                : <Widget>[_roadZoneButton(area)],
          ),
        ),
      ],
    );
  }

  Widget _addChildButton(
    BeforeWorksArea parent,
    BeforeWorksAreaType type, {
    String? suggestedName,
  }) {
    return TextButton.icon(
      onPressed: () =>
          _addArea(type, parentId: parent.id, suggestedName: suggestedName),
      icon: const Icon(Icons.add, size: 18),
      label: Text(type.label),
    );
  }

  Widget _roadZoneButton(BeforeWorksArea road) {
    const standardZones = <String>[
      'Chaussée',
      'Trottoir',
      'Bordures',
      'Accotements',
      'Avaloirs',
      'Chambres de visite',
      'Murs de soutènement',
      'Zone personnalisée',
    ];
    return PopupMenuButton<String>(
      onSelected: (name) => _addArea(
        BeforeWorksAreaType.roadZone,
        parentId: road.id,
        suggestedName: name == 'Zone personnalisée' ? '' : name,
      ),
      itemBuilder: (context) => standardZones
          .map((name) => PopupMenuItem(value: name, child: Text(name)))
          .toList(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text('Zone de voirie'),
          ],
        ),
      ),
    );
  }

  Widget _findingCard(int index, List<BeforeWorksArea> areas) {
    final finding = _findings[index];
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
                    setState(() => _findings.removeAt(index));
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
                _areaDropdown(finding, areas),
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

  Widget _areaDropdown(TechnicalFinding finding, List<BeforeWorksArea> areas) =>
      SizedBox(
        width: 340,
        child: DropdownButtonFormField<String>(
          initialValue: areas.any((area) => area.id == finding.areaId)
              ? finding.areaId
              : null,
          decoration: _input('Élément du constat'),
          items: areas
              .map(
                (area) => DropdownMenuItem<String>(
                  value: area.id,
                  child: Text(
                    widget.data.areaPath(area),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            final selected = areas.where((area) => area.id == value);
            if (selected.isEmpty) return;
            finding
              ..areaId = selected.first.id
              ..zone = widget.data.areaPath(selected.first);
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
