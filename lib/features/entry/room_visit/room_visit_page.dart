import 'package:flutter/material.dart';

import '../models/photo_item.dart';
import '../models/room_inspection.dart';
import '../photos/photo_gallery.dart';
import '../photos/photo_picker_service.dart';

class RoomVisitPage extends StatefulWidget {
  const RoomVisitPage({required this.inspection, super.key});

  final RoomInspection inspection;

  @override
  State<RoomVisitPage> createState() => _RoomVisitPageState();
}

class _RoomVisitPageState extends State<RoomVisitPage> {
  final PhotoPickerService _photoService = PhotoPickerService();
  late final Map<String, TextEditingController> _controllers;
  bool _isLoadingPhotos = false;

  RoomInspection get inspection => widget.inspection;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      'Sol': TextEditingController(text: inspection.floor),
      'Murs': TextEditingController(text: inspection.walls),
      'Plafond': TextEditingController(text: inspection.ceiling),
      'Menuiseries': TextEditingController(text: inspection.woodwork),
      'Portes': TextEditingController(text: inspection.doors),
      'Châssis': TextEditingController(text: inspection.windows),
      'Chauffage': TextEditingController(text: inspection.heating),
      'Sanitaires': TextEditingController(text: inspection.sanitary),
      'Observations': TextEditingController(
        text: inspection.generalObservations,
      ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    inspection.floor = _controllers['Sol']!.text.trim();
    inspection.walls = _controllers['Murs']!.text.trim();
    inspection.ceiling = _controllers['Plafond']!.text.trim();
    inspection.woodwork = _controllers['Menuiseries']!.text.trim();
    inspection.doors = _controllers['Portes']!.text.trim();
    inspection.windows = _controllers['Châssis']!.text.trim();
    inspection.heating = _controllers['Chauffage']!.text.trim();
    inspection.sanitary = _controllers['Sanitaires']!.text.trim();
    inspection.generalObservations = _controllers['Observations']!.text.trim();
    Navigator.of(context).pop(true);
  }

  Future<void> _pickPhotos() async {
    setState(() => _isLoadingPhotos = true);
    try {
      final photos = await _photoService.pickFromGallery();
      if (!mounted || photos.isEmpty) {
        return;
      }
      setState(() => inspection.photos.addAll(photos));
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('Impossible d’ajouter les photos : $error');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPhotos = false);
      }
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoadingPhotos = true);
    try {
      final photo = await _photoService.takePhoto();
      if (!mounted || photo == null) {
        return;
      }
      setState(() => inspection.photos.add(photo));
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(
        'La caméra n’est pas disponible sur cet appareil. Utilisez « Choisir des photos » sur Windows.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingPhotos = false);
      }
    }
  }

  void _deletePhoto(PhotoItem photo) {
    setState(() => inspection.photos.remove(photo));
  }

  Future<void> _openPhoto(PhotoItem photo) async {
    final noteController = TextEditingController(text: photo.note);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 760),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(photo.bytes, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Légende facultative',
                    hintText: 'Ex. Vue générale du mur arrière',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fermer'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        setState(() => photo.note = noteController.text.trim());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    noteController.dispose();
  }

  void _preFillFromPhotos() {
    if (inspection.photos.isEmpty) {
      _showMessage('Ajoutez d’abord au moins une photo.');
      return;
    }

    var changed = false;
    void fill(String key, String value) {
      final controller = _controllers[key]!;
      if (controller.text.trim().isEmpty) {
        controller.text = value;
        changed = true;
      }
    }

    fill('Sol', 'Revêtement de sol à décrire sur la base des vues générales.');
    fill(
      'Murs',
      'Murs visibles sur les photographies, état à confirmer lors de la visite.',
    );
    fill('Plafond', 'Plafond visible, état à contrôler et compléter.');
    fill(
      'Observations',
      '${inspection.photos.length} photo(s) générale(s) ajoutée(s) pour documenter la pièce.',
    );

    _showMessage(
      changed
          ? 'Préremplissage local effectué. Vérifiez et corrigez chaque proposition.'
          : 'Les champs principaux contiennent déjà une description.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(inspection.roomName),
        actions: [
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Enregistrer'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  title: 'Photos et préremplissage',
                  subtitle:
                      'Ajoutez des vues générales. Elles ne sont pas liées à un élément précis.',
                  icon: Icons.photo_camera_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PhotoGallery(
                        photos: inspection.photos,
                        onDelete: _deletePhoto,
                        onOpen: _openPhoto,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isLoadingPhotos ? null : _takePhoto,
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Prendre une photo'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isLoadingPhotos ? null : _pickPhotos,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Choisir des photos'),
                          ),
                          FilledButton.icon(
                            onPressed: _isLoadingPhotos
                                ? null
                                : _preFillFromPhotos,
                            icon: const Icon(Icons.auto_awesome_outlined),
                            label: const Text('Préremplir les postes'),
                          ),
                        ],
                      ),
                      if (_isLoadingPhotos) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Le préremplissage proposé dans ce sprint est local et doit toujours être vérifié par l’expert.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Description de la pièce',
                  subtitle:
                      'Complétez uniquement les postes présents ou utiles.',
                  icon: Icons.description_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth = constraints.maxWidth >= 760
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final label in <String>[
                            'Sol',
                            'Murs',
                            'Plafond',
                            'Menuiseries',
                            'Portes',
                            'Châssis',
                            'Chauffage',
                            'Sanitaires',
                          ])
                            SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                controller: _controllers[label],
                                minLines: 3,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  labelText: label,
                                  alignLabelWithHint: true,
                                  hintText:
                                      'Décrivez l’état, la matière, la teinte et les défauts.',
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Électricité',
                  subtitle:
                      'Cochez les équipements présents et indiquez leur quantité.',
                  icon: Icons.electrical_services_outlined,
                  child: Column(
                    children: [
                      for (final item in inspection.electricalItems)
                        _ElectricalRow(
                          item: item,
                          onChanged: () => setState(() {}),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Mobilier et équipements',
                  subtitle:
                      'Sélectionnez un élément puis décrivez-le sous son titre.',
                  icon: Icons.chair_outlined,
                  child: Column(
                    children: [
                      for (final item in inspection.furnitureItems)
                        _FurnitureEditor(
                          item: item,
                          onChanged: () => setState(() {}),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Observations complémentaires',
                  subtitle:
                      'Ajoutez toute information non reprise dans les postes précédents.',
                  icon: Icons.notes_outlined,
                  child: TextField(
                    controller: _controllers['Observations'],
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Observations générales de la pièce…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Enregistrer la pièce'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _ElectricalRow extends StatelessWidget {
  const _ElectricalRow({required this.item, required this.onChanged});

  final QuantityItem item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: item.selected,
              onChanged: (value) {
                item.selected = value ?? false;
                onChanged();
              },
            ),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: item.selected && item.quantity > 1
                  ? () {
                      item.quantity--;
                      onChanged();
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 34,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: item.selected
                  ? () {
                      item.quantity++;
                      onChanged();
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _FurnitureEditor extends StatefulWidget {
  const _FurnitureEditor({required this.item, required this.onChanged});

  final FurnitureItem item;
  final VoidCallback onChanged;

  @override
  State<_FurnitureEditor> createState() => _FurnitureEditorState();
}

class _FurnitureEditorState extends State<_FurnitureEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: widget.item.selected,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                widget.item.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onChanged: (value) {
                widget.item.selected = value ?? false;
                widget.onChanged();
              },
            ),
            if (widget.item.selected) ...[
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: widget.item.label,
                  hintText: 'Matière, teinte, état, fonctionnement et défauts…',
                  alignLabelWithHint: true,
                ),
                onChanged: (value) => widget.item.description = value,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
