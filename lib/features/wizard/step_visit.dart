import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/ai/vision_service.dart';
import '../../core/access/access_service.dart';
import '../paywall/occasional_paywall_dialog.dart';
import 'property_composition/models/room_item.dart';
import 'visit/widgets/electrical_panel.dart';
import 'report/models/visit_report_snapshot.dart';


class _KitchenUnit {
  String type;
  final TextEditingController commentController;

  _KitchenUnit({
    required this.type,
    String comment = '',
  }) : commentController = TextEditingController(text: comment);

  void dispose() {
    commentController.dispose();
  }
}

class StepVisit extends StatefulWidget {
  final List<RoomItem> rooms;
  final StepVisitController controller;

  const StepVisit({
    super.key,
    required this.rooms,
    required this.controller,
  });

  @override
  State<StepVisit> createState() => _StepVisitState();
}

class _StepVisitState extends State<StepVisit> {
  final ImagePicker _imagePicker = ImagePicker();
  final VisionService _visionService = VisionService();
  bool _isAnalyzingRoom = false;

  final List<String> _sections = [
    'Plafond',
    'Mur',
    'Mur avant',
    'Mur droit',
    'Mur arrière',
    'Mur gauche',
    'Menuiserie intérieure',
    'Menuiserie extérieure',
    'Électricité',
    'Chauffage',
    'Sol',
    'Mobilier',
  ];

  final List<String> _walls = [
    'Mur avant',
    'Mur droit',
    'Mur arrière',
    'Mur gauche',
  ];

  final List<String> _furnitureTemplates = const [
    'Cuisine équipée',
    'Placard',
    'Dressing',
    'Étagère',
    'Meuble haut',
    'Meuble bas',
    'Plan de travail',
    'Évier',
    'Robinetterie',
    'Douche',
    'Baignoire',
    'Meuble lavabo',
    'Lavabo',
    'WC',
    'Miroir',
    'Paroi de douche',
    'Électroménager',
    'Autre mobilier',
  ];


  final List<String> _kitchenWorktopEquipment = const [
    'Évier',
    'Égouttoir',
    'Robinetterie',
    'Taque vitrocéramique',
    'Taque à induction',
    'Taque au gaz',
    'Hotte',
    'Crédence',
    'Prises',
    'Éclairage du plan de travail',
    'Autre équipement',
  ];

  final List<String> _kitchenUpperUnitTypes = const [
    'Meuble simple porte',
    'Meuble double porte',
    'Meuble d’angle',
    'Meuble vitré',
    'Étagère ouverte',
    'Meuble hotte',
    'Hotte apparente',
    'Micro-ondes encastré',
    'Four encastré',
    'Colonne',
    'Réfrigérateur',
    'Congélateur',
    'Autre',
  ];

  final List<String> _kitchenLowerUnitTypes = const [
    'Meuble simple porte',
    'Meuble double porte',
    'Meuble sous-évier',
    'Meuble d’angle',
    'Bloc tiroirs',
    'Casserolier',
    'Four encastré',
    'Lave-vaisselle',
    'Machine à laver',
    'Sèche-linge',
    'Réfrigérateur',
    'Congélateur',
    'Cave à vin',
    'Colonne',
    'Autre',
  ];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, List<XFile>> _photos = {};
  final Map<String, bool> _conformToGeneralities = {};

  final Map<String, Map<String, int>> _electricalQuantities = {};
  final Map<String, int> _electricalBlockQuantities = {};
  final Map<String, Set<String>> _electricalBlockComponents = {};

  final Map<String, Set<String>> _furnitureEquipment = {};
  final Map<String, TextEditingController> _furnitureControllers = {};
  final Map<String, Set<String>> _kitchenSelectedWorktopEquipment = {};
  final Map<String, List<_KitchenUnit>> _kitchenUpperUnits = {};
  final Map<String, List<_KitchenUnit>> _kitchenLowerUnits = {};

  final Map<String, List<XFile>> _roomPrefillPhotos = {};
  final Set<String> _completedRooms = {};

  int _selectedRoomIndex = 0;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();

    for (var index = 0; index < widget.rooms.length; index++) {
      final room = widget.rooms[index];
      final roomLabel = '${room.type} ${room.name}'.toLowerCase();

      if (roomLabel.contains('cuisine')) {
        _furnitureItemsFor(index).add('Cuisine équipée');
      }
    }

    widget.controller.attach(_buildReportSnapshot);
  }

  RoomItem get _currentRoom => widget.rooms[_selectedRoomIndex];
  String get _currentSection => _sections[_selectedSectionIndex];


  Future<void> _reorderWalls() async {
    final workingOrder = List<String>.from(_walls);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ordre des murs'),
          content: SizedBox(
            width: 430,
            height: 340,
            child: ReorderableListView.builder(
              itemCount: workingOrder.length,
              onReorderItem: (oldIndex, newIndex) {
                setDialogState(() {
                  final wall = workingOrder.removeAt(oldIndex);
                  workingOrder.insert(newIndex, wall);
                });
              },
              itemBuilder: (context, index) {
                final wall = workingOrder[index];
                return Card(
                  key: ValueKey(wall),
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(wall),
                    trailing: const Icon(Icons.drag_handle_rounded),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );

    if (accepted != true || !mounted) return;
    setState(() {
      final selectedSection = _currentSection;
      _walls
        ..clear()
        ..addAll(workingOrder);
      _sections.removeWhere(_wallsSetContains);
      final insertAt = _sections.indexOf('Mur') + 1;
      _sections.insertAll(insertAt, _walls);
      _selectedSectionIndex = _sections.indexOf(selectedSection);
      if (_selectedSectionIndex < 0) _selectedSectionIndex = 0;
    });
  }

  bool _wallsSetContains(String value) => const {
        'Mur avant',
        'Mur droit',
        'Mur arrière',
        'Mur gauche',
      }.contains(value);

  String _roomKey(int roomIndex) {
    final room = widget.rooms[roomIndex];
    return '$roomIndex-${room.type}-${room.level}-${room.name}';
  }

  String _sectionKey(int roomIndex, String section) {
    return '${_roomKey(roomIndex)}::$section';
  }

  String _wallKey(int roomIndex, String wall) {
    return '${_roomKey(roomIndex)}::electricity::$wall';
  }

  String _furnitureKey(int roomIndex, String item) {
    return '${_roomKey(roomIndex)}::furniture::$item';
  }

  TextEditingController _controllerFor(
    int roomIndex,
    String section,
  ) {
    final key = _sectionKey(roomIndex, section);

    return _controllers.putIfAbsent(
      key,
      TextEditingController.new,
    );
  }

  List<XFile> _photosFor(
    int roomIndex,
    String section,
  ) {
    final key = _sectionKey(roomIndex, section);

    return _photos.putIfAbsent(
      key,
      () => <XFile>[],
    );
  }

  List<XFile> _prefillPhotosForRoom(int roomIndex) {
    return _roomPrefillPhotos.putIfAbsent(
      _roomKey(roomIndex),
      () => <XFile>[],
    );
  }

  bool _isConform(
    int roomIndex,
    String section,
  ) {
    return _conformToGeneralities[
          _sectionKey(roomIndex, section)] ??
        false;
  }

  Map<String, int> _electricalItemsFor(
    int roomIndex,
    String wall,
  ) {
    return _electricalQuantities.putIfAbsent(
      _wallKey(roomIndex, wall),
      () => <String, int>{},
    );
  }

  int _blockQuantityFor(
    int roomIndex,
    String wall,
  ) {
    return _electricalBlockQuantities[
          _wallKey(roomIndex, wall)] ??
        0;
  }

  Set<String> _blockComponentsFor(
    int roomIndex,
    String wall,
  ) {
    return _electricalBlockComponents.putIfAbsent(
      _wallKey(roomIndex, wall),
      () => <String>{},
    );
  }

  Set<String> _furnitureItemsFor(int roomIndex) {
    final key = '${_roomKey(roomIndex)}::furniture';

    return _furnitureEquipment.putIfAbsent(
      key,
      () => <String>{},
    );
  }

  TextEditingController _furnitureControllerFor(
    int roomIndex,
    String item,
  ) {
    return _furnitureControllers.putIfAbsent(
      _furnitureKey(roomIndex, item),
      TextEditingController.new,
    );
  }


  String _kitchenKey(int roomIndex, String suffix) {
    return '${_roomKey(roomIndex)}::kitchen::$suffix';
  }

  Set<String> _worktopEquipmentFor(int roomIndex) {
    return _kitchenSelectedWorktopEquipment.putIfAbsent(
      _kitchenKey(roomIndex, 'worktop-equipment'),
      () => <String>{},
    );
  }

  List<_KitchenUnit> _upperUnitsFor(int roomIndex) {
    return _kitchenUpperUnits.putIfAbsent(
      _kitchenKey(roomIndex, 'upper-units'),
      () => <_KitchenUnit>[],
    );
  }

  List<_KitchenUnit> _lowerUnitsFor(int roomIndex) {
    return _kitchenLowerUnits.putIfAbsent(
      _kitchenKey(roomIndex, 'lower-units'),
      () => <_KitchenUnit>[],
    );
  }

  TextEditingController _kitchenControllerFor(
    int roomIndex,
    String field,
  ) {
    return _furnitureControllerFor(
      roomIndex,
      'Cuisine équipée::$field',
    );
  }

  bool _hasElectricalSelection(int roomIndex) {
    return _walls.any((wall) {
      final quantities = _electricalItemsFor(roomIndex, wall);
      final hasEquipment =
          quantities.values.any((quantity) => quantity > 0);
      final hasBlock = _blockQuantityFor(roomIndex, wall) > 0 &&
          _blockComponentsFor(roomIndex, wall).isNotEmpty;

      return hasEquipment || hasBlock;
    });
  }

  bool _sectionHasContent(
    int roomIndex,
    String section,
  ) {
    final controller =
        _controllers[_sectionKey(roomIndex, section)];
    final photos = _photos[_sectionKey(roomIndex, section)];

    final hasText =
        controller != null && controller.text.trim().isNotEmpty;
    final hasPhotos = photos != null && photos.isNotEmpty;
    final isConform = _isConform(roomIndex, section);

    if (section == 'Électricité') {
      return hasText ||
          hasPhotos ||
          isConform ||
          _hasElectricalSelection(roomIndex);
    }

    if (section == 'Mobilier') {
      final selectedItems = _furnitureItemsFor(roomIndex);

      final hasFurnitureDescription = selectedItems.any(
        (item) =>
            _furnitureControllerFor(roomIndex, item)
                .text
                .trim()
                .isNotEmpty,
      );
      final hasKitchenDescription =
          selectedItems.contains('Cuisine équipée') &&
              (_kitchenControllerFor(roomIndex, 'general')
                      .text
                      .trim()
                      .isNotEmpty ||
                  _kitchenControllerFor(roomIndex, 'worktop')
                      .text
                      .trim()
                      .isNotEmpty ||
                  _worktopEquipmentFor(roomIndex).isNotEmpty ||
                  _upperUnitsFor(roomIndex).isNotEmpty ||
                  _lowerUnitsFor(roomIndex).isNotEmpty);

      return hasText ||
          hasPhotos ||
          isConform ||
          selectedItems.isNotEmpty ||
          hasFurnitureDescription ||
          hasKitchenDescription;
    }

    return hasText || hasPhotos || isConform;
  }

  int _completedSectionCount(int roomIndex) {
    return _sections.where((section) {
      return _sectionHasContent(roomIndex, section);
    }).length;
  }

  Future<void> _selectRoom(int index) async {
    if (!AccessService.instance.canOpenRoom(index)) {
      final unlocked = await showOccasionalPaywallDialog(context);
      if (!unlocked || !mounted) return;
    }

    setState(() {
      _selectedRoomIndex = index;
      _selectedSectionIndex = 0;
    });
  }

  void _selectSection(int index) {
    setState(() {
      _selectedSectionIndex = index;
    });
  }

  void _previousRoom() {
    if (_selectedRoomIndex == 0) return;

    setState(() {
      _selectedRoomIndex--;
      _selectedSectionIndex = 0;
    });
  }

  Future<void> _nextRoom() async {
    if (_selectedRoomIndex >= widget.rooms.length - 1) return;
    await _selectRoom(_selectedRoomIndex + 1);
  }

  void _toggleRoomCompleted() {
    final key = _roomKey(_selectedRoomIndex);

    setState(() {
      if (_completedRooms.contains(key)) {
        _completedRooms.remove(key);
      } else {
        _completedRooms.add(key);
      }
    });
  }

  void _toggleGeneralities(bool value) {
    final key = _sectionKey(
      _selectedRoomIndex,
      _currentSection,
    );

    final controller = _controllerFor(
      _selectedRoomIndex,
      _currentSection,
    );

    setState(() {
      _conformToGeneralities[key] = value;

      if (value && controller.text.trim().isEmpty) {
        controller.text = 'Conforme aux généralités.';
      } else if (!value &&
          controller.text.trim() == 'Conforme aux généralités.') {
        controller.clear();
      }
    });
  }

  void _setElectricalQuantity(
    String wall,
    String item,
    int quantity,
  ) {
    final quantities = _electricalItemsFor(
      _selectedRoomIndex,
      wall,
    );

    setState(() {
      if (quantity <= 0) {
        quantities.remove(item);
      } else {
        quantities[item] = quantity;
      }
    });
  }

  void _setBlockQuantity(
    String wall,
    int quantity,
  ) {
    final key = _wallKey(_selectedRoomIndex, wall);

    setState(() {
      if (quantity <= 0) {
        _electricalBlockQuantities.remove(key);
        _blockComponentsFor(
          _selectedRoomIndex,
          wall,
        ).clear();
      } else {
        _electricalBlockQuantities[key] = quantity;
      }
    });
  }

  void _toggleBlockComponent(
    String wall,
    String component,
    bool selected,
  ) {
    final components = _blockComponentsFor(
      _selectedRoomIndex,
      wall,
    );

    setState(() {
      if (selected) {
        components.add(component);
      } else {
        components.remove(component);
      }
    });
  }

  void _toggleFurnitureItem(
    String item,
    bool selected,
  ) {
    final items = _furnitureItemsFor(_selectedRoomIndex);

    setState(() {
      if (selected) {
        items.add(item);
      } else {
        items.remove(item);
        _furnitureControllerFor(
          _selectedRoomIndex,
          item,
        ).clear();

        if (item == 'Cuisine équipée') {
          _kitchenControllerFor(_selectedRoomIndex, 'general').clear();
          _kitchenControllerFor(_selectedRoomIndex, 'worktop').clear();
          for (final equipmentItem
              in _worktopEquipmentFor(_selectedRoomIndex).toList()) {
            _kitchenControllerFor(
              _selectedRoomIndex,
              'worktop-equipment::$equipmentItem',
            ).clear();
          }
          _worktopEquipmentFor(_selectedRoomIndex).clear();

          for (final unit in _upperUnitsFor(_selectedRoomIndex)) {
            unit.dispose();
          }
          for (final unit in _lowerUnitsFor(_selectedRoomIndex)) {
            unit.dispose();
          }

          _upperUnitsFor(_selectedRoomIndex).clear();
          _lowerUnitsFor(_selectedRoomIndex).clear();
        }
      }
    });
  }

  Future<void> _selectPhotos() async {
    try {
      final selectedPhotos = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (selectedPhotos.isEmpty || !mounted) return;

      setState(() {
        _photosFor(
          _selectedRoomIndex,
          _currentSection,
        ).addAll(selectedPhotos);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir la galerie.'),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null || !mounted) return;

      setState(() {
        _photosFor(
          _selectedRoomIndex,
          _currentSection,
        ).add(photo);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La caméra n’est pas disponible sur cet appareil.',
          ),
        ),
      );
    }
  }

  Future<void> _selectPhotosForAutomaticPrefill() async {
    try {
      final selectedPhotos = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (selectedPhotos.isEmpty || !mounted) return;

      setState(() {
        _prefillPhotosForRoom(
          _selectedRoomIndex,
        ).addAll(selectedPhotos);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedPhotos.length} photo(s) ajoutée(s). '
            'Elles sont prêtes pour l’analyse automatique.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’importer les photos de la pièce.',
          ),
        ),
      );
    }
  }


  String _closestKitchenUnitType(String proposed, List<String> allowed) {
    final normalized = proposed.toLowerCase();
    for (final type in allowed) {
      if (normalized.contains(type.toLowerCase()) || type.toLowerCase().contains(normalized)) return type;
    }
    return 'Autre';
  }

  Future<void> _analyzeAndPrefillCurrentRoom() async {
    final roomIndex = _selectedRoomIndex;
    final photos = List<XFile>.from(_prefillPhotosForRoom(roomIndex));
    if (photos.isEmpty) return;
    setState(() => _isAnalyzingRoom = true);
    try {
      final analysis = await _visionService.analyzeRoom(
        roomName: widget.rooms[roomIndex].name,
        roomType: widget.rooms[roomIndex].type,
        photos: photos,
      );
      if (!mounted) return;
      setState(() {
        for (final entry in analysis.sections.entries) {
          if (entry.value.trim().isNotEmpty && _sections.contains(entry.key)) _controllerFor(roomIndex, entry.key).text = entry.value.trim();
        }
        if (analysis.hasKitchen) {
          _furnitureItemsFor(roomIndex).add('Cuisine équipée');
          _kitchenControllerFor(roomIndex, 'general').text = analysis.kitchenGeneral;
          _kitchenControllerFor(roomIndex, 'worktop').text = analysis.worktop;
          final selectedEquipment = _worktopEquipmentFor(roomIndex);
          for (final entry in analysis.worktopEquipment.entries) {
            if (entry.value.trim().isEmpty) continue;
            final known = _kitchenWorktopEquipment.firstWhere((item) => item.toLowerCase() == entry.key.toLowerCase(), orElse: () => 'Autre équipement');
            selectedEquipment.add(known);
            _kitchenControllerFor(roomIndex, 'worktop-equipment::$known').text = entry.value;
          }
          for (final unit in _upperUnitsFor(roomIndex)) { unit.dispose(); }
          _upperUnitsFor(roomIndex)..clear()..addAll(analysis.upperUnits.map((unit) => _KitchenUnit(type: _closestKitchenUnitType(unit['type'] ?? '', _kitchenUpperUnitTypes), comment: unit['comment'] ?? '')));
          for (final unit in _lowerUnitsFor(roomIndex)) { unit.dispose(); }
          _lowerUnitsFor(roomIndex)..clear()..addAll(analysis.lowerUnits.map((unit) => _KitchenUnit(type: _closestKitchenUnitType(unit['type'] ?? '', _kitchenLowerUnitTypes), comment: unit['comment'] ?? '')));
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyse terminée. Vérifiez et corrigez les propositions avant validation.')));
    } catch (error) {
      if (!mounted) return;

      final message = error is FormatException
          ? error.message
          : 'L’analyse des photos a échoué. ${error.toString()}';

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Analyse impossible'),
            content: SelectableText(message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Compris'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isAnalyzingRoom = false);
    }
  }

  Future<void> _showAutomaticPrefillDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final photos =
                _prefillPhotosForRoom(_selectedRoomIndex);

            return AlertDialog(
              title: Text(
                'Préremplir « ${_currentRoom.name} » avec des photos',
              ),
              content: SizedBox(
                width: 760,
                height: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sélectionnez toutes les photos de la pièce. '
                      'Vous ne devez pas les classer manuellement. '
                      'L’analyse visuelle proposera automatiquement des descriptions '
                      'pour les différents postes. Chaque proposition reste modifiable.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () async {
                            await _selectPhotosForAutomaticPrefill();

                            if (dialogContext.mounted) {
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                          ),
                          label: const Text(
                            'Choisir les photos',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${photos.length} photo(s)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: photos.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucune photo sélectionnée.',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: photos.length,
                              itemBuilder: (context, index) {
                                final photo = photos[index];

                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.file(
                                          File(photo.path),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color:
                                                  Colors.grey.shade200,
                                              alignment:
                                                  Alignment.center,
                                              child: const Icon(
                                                Icons
                                                    .broken_image_outlined,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: IconButton.filled(
                                        visualDensity:
                                            VisualDensity.compact,
                                        onPressed: () {
                                          setState(() {
                                            photos.removeAt(index);
                                          });
                                          setDialogState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (_isAnalyzingRoom) ...[
                      const SizedBox(height: 14),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('Analyse des photos en cours...'),
                    ],
                  ],
                ),
              ),
              actions: [
                if (_isAnalyzingRoom)
                  TextButton.icon(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.move_to_inbox_outlined),
                    label: const Text('Mettre en arrière-plan'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Fermer'),
                  ),
                FilledButton.icon(
                  onPressed: photos.isEmpty || _isAnalyzingRoom
                      ? null
                      : () async {
                          final analysisFuture =
                              _analyzeAndPrefillCurrentRoom();
                          setDialogState(() {});
                          await analysisFuture;

                          if (dialogContext.mounted) {
                            setDialogState(() {});
                          }
                        },
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    _isAnalyzingRoom
                        ? 'Analyse en cours…'
                        : 'Analyser et préremplir',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photosFor(
        _selectedRoomIndex,
        _currentSection,
      ).removeAt(index);
    });
  }

  void _showPhoto(XFile photo) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(30),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearCurrentSection() {
    final key = _sectionKey(
      _selectedRoomIndex,
      _currentSection,
    );

    setState(() {
      _controllerFor(
        _selectedRoomIndex,
        _currentSection,
      ).clear();

      _photosFor(
        _selectedRoomIndex,
        _currentSection,
      ).clear();

      _conformToGeneralities[key] = false;

      if (_currentSection == 'Électricité') {
        for (final wall in _walls) {
          _electricalItemsFor(
            _selectedRoomIndex,
            wall,
          ).clear();

          _setBlockQuantity(wall, 0);
        }
      }

      if (_currentSection == 'Mobilier') {
        final selectedFurniture =
            _furnitureItemsFor(_selectedRoomIndex).toList();

        for (final item in selectedFurniture) {
          _furnitureControllerFor(
            _selectedRoomIndex,
            item,
          ).clear();
        }

        _kitchenControllerFor(_selectedRoomIndex, 'general').clear();
        _kitchenControllerFor(_selectedRoomIndex, 'worktop').clear();
        for (final equipmentItem
            in _worktopEquipmentFor(_selectedRoomIndex).toList()) {
          _kitchenControllerFor(
            _selectedRoomIndex,
            'worktop-equipment::$equipmentItem',
          ).clear();
        }
        _worktopEquipmentFor(_selectedRoomIndex).clear();

        for (final unit in _upperUnitsFor(_selectedRoomIndex)) {
          unit.dispose();
        }
        for (final unit in _lowerUnitsFor(_selectedRoomIndex)) {
          unit.dispose();
        }

        _upperUnitsFor(_selectedRoomIndex).clear();
        _lowerUnitsFor(_selectedRoomIndex).clear();
        _furnitureItemsFor(_selectedRoomIndex).clear();
      }
    });
  }

  VisitReportSnapshot _buildReportSnapshot() {
    final roomReports = <VisitRoomReport>[];

    for (var roomIndex = 0; roomIndex < widget.rooms.length; roomIndex++) {
      final room = widget.rooms[roomIndex];
      final sections = <String, String>{};

      for (final section in _sections) {
        final value = _controllers[_sectionKey(roomIndex, section)]
                ?.text
                .trim() ??
            '';
        if (value.isNotEmpty) {
          sections[section] = value;
        }
      }

      final electricalByWall = <String, Map<String, int>>{};
      for (final wall in _walls) {
        final values = <String, int>{};
        final quantities = _electricalQuantities[_wallKey(roomIndex, wall)];
        if (quantities != null) {
          for (final entry in quantities.entries) {
            if (entry.value > 0) {
              values[entry.key] = entry.value;
            }
          }
        }

        final blockQuantity = _blockQuantityFor(roomIndex, wall);
        final components = _blockComponentsFor(roomIndex, wall);
        if (blockQuantity > 0 && components.isNotEmpty) {
          values['Bloc composé (${components.join(', ')})'] = blockQuantity;
        }

        if (values.isNotEmpty) {
          electricalByWall[wall] = values;
        }
      }

      final furnitureDescriptions = <String, String>{};
      final selectedFurniture = _furnitureItemsFor(roomIndex);
      for (final item in selectedFurniture) {
        if (item == 'Cuisine équipée') continue;
        final value = _furnitureControllerFor(roomIndex, item).text.trim();
        if (value.isNotEmpty) {
          furnitureDescriptions[item] = value;
        }
      }

      KitchenReport? kitchen;
      if (selectedFurniture.contains('Cuisine équipée')) {
        final equipment = <String, String>{};
        for (final item in _worktopEquipmentFor(roomIndex)) {
          final value = _kitchenControllerFor(
            roomIndex,
            'worktop-equipment::$item',
          ).text.trim();
          if (value.isNotEmpty) {
            equipment[item] = value;
          }
        }

        kitchen = KitchenReport(
          generalDescription:
              _kitchenControllerFor(roomIndex, 'general').text.trim(),
          worktopDescription:
              _kitchenControllerFor(roomIndex, 'worktop').text.trim(),
          worktopEquipment: equipment,
          upperUnits: _upperUnitsFor(roomIndex)
              .map(
                (unit) => KitchenUnitReport(
                  type: unit.type,
                  comment: unit.commentController.text.trim(),
                ),
              )
              .toList(growable: false),
          lowerUnits: _lowerUnitsFor(roomIndex)
              .map(
                (unit) => KitchenUnitReport(
                  type: unit.type,
                  comment: unit.commentController.text.trim(),
                ),
              )
              .toList(growable: false),
        );
      }

      final photoPaths = <String>[];
      for (final section in _sections) {
        final sectionPhotos = _photos[_sectionKey(roomIndex, section)];
        if (sectionPhotos != null) {
          photoPaths.addAll(sectionPhotos.map((photo) => photo.path));
        }
      }
      final prefillPhotos = _roomPrefillPhotos[_roomKey(roomIndex)];
      if (prefillPhotos != null) {
        photoPaths.addAll(prefillPhotos.map((photo) => photo.path));
      }

      roomReports.add(
        VisitRoomReport(
          name: room.name,
          type: room.type,
          level: room.level,
          sections: sections,
          electricalByWall: electricalByWall,
          furnitureDescriptions: furnitureDescriptions,
          kitchen: kitchen,
          photoPaths: photoPaths.toSet().toList(growable: false),
        ),
      );
    }

    return VisitReportSnapshot(rooms: roomReports);
  }

  @override
  void dispose() {
    widget.controller.detach();

    for (final controller in _controllers.values) {
      controller.dispose();
    }

    for (final controller in _furnitureControllers.values) {
      controller.dispose();
    }

    for (final units in _kitchenUpperUnits.values) {
      for (final unit in units) {
        unit.dispose();
      }
    }
    for (final units in _kitchenLowerUnits.values) {
      for (final unit in units) {
        unit.dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rooms.isEmpty) {
      return const Center(
        child: Text(
          'Aucune pièce disponible.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      );
    }

    final room = _currentRoom;
    final roomCompleted = _completedRooms.contains(
      _roomKey(_selectedRoomIndex),
    );
    final completedSections =
        _completedSectionCount(_selectedRoomIndex);
    final roomProgress =
        completedSections / _sections.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: _buildRoomList(),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                room: room,
                roomCompleted: roomCompleted,
                completedSections: completedSections,
                roomProgress: roomProgress,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 225,
                      child: _buildSectionList(),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildEditor(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildNavigation(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pièces du bien',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.rooms.length} pièce(s)',
          style: const TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            itemCount: widget.rooms.length,
            separatorBuilder: (_, _) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (context, index) {
              final room = widget.rooms[index];
              final selected = index == _selectedRoomIndex;
              final completed = _completedRooms.contains(
                _roomKey(index),
              );
              final completedSections =
                  _completedSectionCount(index);

              return Material(
                color: selected
                    ? const Color(0xFFEAF2FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => _selectRoom(index),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1264F6)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: completed
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFEAF2FF),
                          child: completed
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF16A34A),
                                )
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF1264F6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selected
                                      ? const Color(0xFF1264F6)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$completedSections / ${_sections.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({
    required RoomItem room,
    required bool roomCompleted,
    required int completedSections,
    required double roomProgress,
  }) {
    final prefillPhotoCount =
        _prefillPhotosForRoom(_selectedRoomIndex).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${room.level} • Pièce ${_selectedRoomIndex + 1} / ${widget.rooms.length}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showAutomaticPrefillDialog,
              icon: const Icon(
                Icons.auto_awesome_outlined,
              ),
              label: Text(
                prefillPhotoCount == 0
                    ? 'Préremplir avec des photos'
                    : 'Photos à analyser ($prefillPhotoCount)',
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _toggleRoomCompleted,
              icon: Icon(
                roomCompleted
                    ? Icons.restart_alt
                    : Icons.check_circle_outline,
              ),
              label: Text(
                roomCompleted
                    ? 'Rouvrir la pièce'
                    : 'Terminer la pièce',
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: roomProgress,
                  minHeight: 9,
                  backgroundColor:
                      const Color(0xFFE2E8F0),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$completedSections / ${_sections.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Postes de la pièce',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: _reorderWalls,
              icon: const Icon(Icons.swap_vert_rounded),
              label: const Text('Ordre des murs'),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Expanded(
          child: ListView.separated(
            itemCount: _sections.length,
            separatorBuilder: (_, _) {
              return const SizedBox(height: 7);
            },
            itemBuilder: (context, index) {
              final section = _sections[index];
              final selected =
                  index == _selectedSectionIndex;
              final completed = _sectionHasContent(
                _selectedRoomIndex,
                section,
              );
              final photoCount = _photos[
                      _sectionKey(
                        _selectedRoomIndex,
                        section,
                      )]
                  ?.length ??
                  0;

              return Material(
                color: selected
                    ? const Color(0xFFEAF2FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => _selectSection(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1264F6)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 19,
                          color: completed
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            section,
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: selected
                                  ? const Color(0xFF1264F6)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                        if (photoCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              '📷 $photoCount',
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKitchenTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenUnitList({
    required String title,
    required List<_KitchenUnit> units,
    required List<String> availableTypes,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    units.add(_KitchenUnit(type: availableTypes.first));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez les éléments dans leur ordre de lecture, de gauche à droite.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          if (units.isEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Aucun élément ajouté.',
              style: TextStyle(color: Colors.black45),
            ),
          ],
          ...List.generate(units.length, (index) {
            final unit = units[index];

            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEAF2FF),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF1264F6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: unit.type,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Type d’élément',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: availableTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => unit.type = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Supprimer',
                        onPressed: () {
                          setState(() {
                            final removed = units.removeAt(index);
                            removed.dispose();
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: unit.commentController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Commentaire éventuel sur cet élément...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKitchenModule() {
    final equipment = _worktopEquipmentFor(_selectedRoomIndex);
    final upperUnits = _upperUnitsFor(_selectedRoomIndex);
    final lowerUnits = _lowerUnitsFor(_selectedRoomIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.kitchen_outlined, color: Color(0xFF1264F6)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cuisine équipée — description structurée du mobilier',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildKitchenTextField(
          title: 'Description générale du mobilier de cuisine',
          hintText:
              'Décrivez la composition, les matériaux, les couleurs et l’état général...',
          controller: _kitchenControllerFor(
            _selectedRoomIndex,
            'general',
          ),
        ),
        _buildKitchenTextField(
          title: 'Plan de travail',
          hintText:
              'Décrivez le matériau, la couleur, la disposition, l’état et les défauts...',
          controller: _kitchenControllerFor(
            _selectedRoomIndex,
            'worktop',
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Équipements sur le plan de travail',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _kitchenWorktopEquipment.map((item) {
                  final selected = equipment.contains(item);

                  return FilterChip(
                    label: Text(item),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          equipment.add(item);
                        } else {
                          equipment.remove(item);
                          _kitchenControllerFor(
                            _selectedRoomIndex,
                            'worktop-equipment::$item',
                          ).clear();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (equipment.isNotEmpty) ...[
                const SizedBox(height: 16),
                ..._kitchenWorktopEquipment
                    .where(equipment.contains)
                    .map((item) {
                  final controller = _kitchenControllerFor(
                    _selectedRoomIndex,
                    'worktop-equipment::$item',
                  );

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 9),
                        TextField(
                          controller: controller,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Décrivez le type, la matière, la couleur, l’état et les défauts...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        _buildKitchenUnitList(
          title: 'Meubles hauts — lecture de gauche à droite',
          units: upperUnits,
          availableTypes: _kitchenUpperUnitTypes,
        ),
        _buildKitchenUnitList(
          title: 'Meubles bas et électroménagers — lecture de gauche à droite',
          units: lowerUnits,
          availableTypes: _kitchenLowerUnitTypes,
        ),
      ],
    );
  }

  Widget _buildFurnitureEquipment() {
    final selectedItems =
        _furnitureItemsFor(_selectedRoomIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _furnitureTemplates.map((item) {
              final selected = selectedItems.contains(item);

              return FilterChip(
                label: Text(item),
                selected: selected,
                onSelected: (value) {
                  _toggleFurnitureItem(item, value);
                },
              );
            }).toList(),
          ),
        ),
        if (selectedItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...selectedItems.map((item) {
            if (item == 'Cuisine équipée') {
              return _buildKitchenModule();
            }

            final controller = _furnitureControllerFor(
              _selectedRoomIndex,
              item,
            );

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Décrivez le mobilier, son état et ses défauts...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEditor() {
    final controller = _controllerFor(
      _selectedRoomIndex,
      _currentSection,
    );
    final photos = _photosFor(
      _selectedRoomIndex,
      _currentSection,
    );
    final conform = _isConform(
      _selectedRoomIndex,
      _currentSection,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentSection,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Effacer le poste',
                onPressed: _clearCurrentSection,
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                CheckboxListTile(
                  value: conform,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  title: const Text(
                    'Conforme aux généralités',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Insère automatiquement cette mention dans la description.',
                  ),
                  onChanged: (value) {
                    _toggleGeneralities(value ?? false);
                  },
                ),
                if (_currentSection == 'Électricité') ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Description générale',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: TextField(
                      controller: controller,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText:
                            'Décrivez le type d’installation, la marque, '
                            'la teinte et l’état général des appareillages...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Répartition par mur',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElectricalPanel(
                    walls: _walls,
                    quantitiesForWall: (wall) => _electricalItemsFor(
                      _selectedRoomIndex,
                      wall,
                    ),
                    blockQuantityForWall: (wall) => _blockQuantityFor(
                      _selectedRoomIndex,
                      wall,
                    ),
                    blockComponentsForWall: (wall) => _blockComponentsFor(
                      _selectedRoomIndex,
                      wall,
                    ),
                    onQuantityChanged: (wall, item, quantity) {
                      _setElectricalQuantity(wall, item, quantity);
                    },
                    onBlockQuantityChanged: (wall, quantity) {
                      _setBlockQuantity(wall, quantity);
                    },
                    onBlockComponentChanged: (
                      wall,
                      component,
                      selected,
                    ) {
                      _toggleBlockComponent(
                        wall,
                        component,
                        selected,
                      );
                    },
                  ),
                ],
                if (_currentSection == 'Mobilier') ...[
                  const SizedBox(height: 10),
                  _buildFurnitureEquipment(),
                ],
                if (_currentSection != 'Électricité') ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 190,
                    child: TextField(
                      controller: controller,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText:
                            'Décrivez l’état général de ce poste...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _selectPhotos,
                      icon: const Icon(
                        Icons.collections_outlined,
                      ),
                      label: const Text('Galerie'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(
                        Icons.photo_camera_outlined,
                      ),
                      label: const Text('Photo'),
                    ),
                    const Spacer(),
                    Text(
                      '${photos.length} photo(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 95,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(width: 10);
                      },
                      itemBuilder: (context, index) {
                        final photo = photos[index];

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InkWell(
                              onTap: () => _showPhoto(photo),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Image.file(
                                  File(photo.path),
                                  width: 95,
                                  height: 95,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -7,
                              top: -7,
                              child: IconButton.filled(
                                visualDensity:
                                    VisualDensity.compact,
                                onPressed: () {
                                  _removePhoto(index);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _selectedRoomIndex == 0
              ? null
              : _previousRoom,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Pièce précédente'),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed:
              _selectedRoomIndex ==
                      widget.rooms.length - 1
                  ? null
                  : _nextRoom,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Pièce suivante'),
        ),
      ],
    );
  }
}
