import 'package:flutter/material.dart';

import '../commercial/domain/models/discovery_access_state.dart';
import 'property_composition/models/property_element.dart';
import 'property_composition/models/room_item.dart';
import 'property_composition/services/room_reorder.dart';

class StepPropertyComposition extends StatefulWidget {
  const StepPropertyComposition({
    super.key,
    required this.rooms,
    required this.onRoomsChanged,
    required this.missionId,
    required this.discoveryAccess,
    required this.onDiscoveryLimitReached,
    required this.propertyElements,
    required this.selectedPropertyElementId,
    required this.onPropertyElementSelected,
    this.technicalMode = false,
  });

  final List<RoomItem> rooms;
  final VoidCallback onRoomsChanged;
  final bool technicalMode;
  final String missionId;
  final DiscoveryAccessState? discoveryAccess;
  final Future<bool> Function(int roomsUsed, int roomLimit)?
      onDiscoveryLimitReached;
  final List<PropertyElement> propertyElements;
  final String selectedPropertyElementId;
  final ValueChanged<String> onPropertyElementSelected;

  @override
  State<StepPropertyComposition> createState() =>
      _StepPropertyCompositionState();
}

class _StepPropertyCompositionState extends State<StepPropertyComposition> {
  final TextEditingController _customRoomController = TextEditingController();
  int _mobileSectionIndex = 0;

  static const List<String> _propertyTemplates = <String>[
    'Hall d’entrée',
    'Hall de nuit',
    'Dégagement',
    'Séjour',
    'Salon',
    'Salle à manger',
    'Cuisine',
    'WC',
    'Salle de bain',
    'Salle de douche',
    'Chambre',
    'Bureau',
    'Dressing',
    'Buanderie',
    'Cave',
    'Grenier',
    'Garage',
    'Local technique',
    'Terrasse',
    'Jardin',
    'Façade avant',
    'Façade arrière',
    'Façade latérale gauche',
    'Façade latérale droite',
  ];

  static const List<String> _technicalBuildingTemplates = <String>[
    'Hall d’entrée',
    'Séjour',
    'Salon',
    'Salle à manger',
    'Cuisine',
    'Arrière-cuisine',
    'Buanderie',
    'WC',
    'Salle de bain',
    'Salle de douche',
    'Hall de nuit',
    'Chambre',
    'Dressing',
    'Bureau',
    'Véranda',
    'Garage',
    'Cave',
    'Grenier',
    'Local technique',
    'Escalier',
    'Palier',
    'Terrasse',
    'Balcon',
    'Jardin',
    'Façade avant',
    'Façade arrière',
    'Façade gauche',
    'Façade droite',
    'Toiture',
    'Combles',
    'Autre',
  ];

  static const List<String> _roadTemplates = <String>[
    'Chaussée',
    'Trottoir',
    'Accotement',
    'Bordure',
    'Avaloir',
    'Égout',
    'Parking',
    'Signalisation',
    'Marquage au sol',
    'Espace vert',
    'Mobilier urbain',
    'Autre',
  ];

  static const List<String> _levels = <String>[
    'Sous-sol',
    'Rez-de-chaussée',
    '1er étage',
    '2e étage',
    '3e étage',
    'Combles',
    'Extérieur',
    'Annexe',
  ];

  List<String> get _roomTemplates {
    if (!widget.technicalMode) return _propertyTemplates;
    return _selectedElement?.type == PropertyElementType.road
        ? _roadTemplates
        : _technicalBuildingTemplates;
  }

  List<RoomItem> get _rooms => widget.rooms
      .where(
        (room) => room.propertyElementId == widget.selectedPropertyElementId,
      )
      .toList(growable: true);

  PropertyElement? get _selectedElement {
    for (final element in widget.propertyElements) {
      if (element.id == widget.selectedPropertyElementId) return element;
    }
    return null;
  }

  void _notifyChanged() {
    widget.onRoomsChanged();
  }

  Future<void> _addRoom(String type) async {
    setState(() {
      widget.rooms.add(
        RoomItem(type: type, name: type, level: _defaultLevelFor(type))
          ..propertyElementId = widget.selectedPropertyElementId,
      );
      _mobileSectionIndex = 1;
    });
    _notifyChanged();
  }

  String _defaultLevelFor(String type) {
    const exteriorRooms = <String>{
      'Terrasse',
      'Jardin',
      'Façade avant',
      'Façade arrière',
      'Façade latérale gauche',
      'Façade latérale droite',
      'Façade gauche',
      'Façade droite',
      'Toiture',
      'Balcon',
      'Façade',
      'Pignon',
      'Mur mitoyen',
      'Trottoir',
      'Voirie',
      'Clôture',
      'Mur de soutènement',
      'Bâtiment voisin',
      'Chaussée',
      'Accotement',
      'Bordure',
      'Avaloir',
      'Égout',
      'Parking',
      'Signalisation',
      'Marquage au sol',
      'Espace vert',
      'Mobilier urbain',
    };

    if (exteriorRooms.contains(type)) return 'Extérieur';
    if (type == 'Cave') return 'Sous-sol';
    if (type == 'Grenier') return 'Combles';
    return 'Rez-de-chaussée';
  }

  Future<void> _addCustomRoom() async {
    final name = _customRoomController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez le nom de la pièce.')),
      );
      return;
    }

    await _addRoom(name);
    if (!mounted) return;
    _customRoomController.clear();
  }

  void _removeRoom(int index) {
    setState(() => widget.rooms.remove(_rooms[index]));
    _notifyChanged();
  }

  void _moveRoomUp(int index) {
    if (index <= 0) return;
    setState(() => _swapScopedRooms(index, index - 1));
    _notifyChanged();
  }

  void _moveRoomDown(int index) {
    if (index >= _rooms.length - 1) return;
    setState(() => _swapScopedRooms(index, index + 1));
    _notifyChanged();
  }

  void _swapScopedRooms(int first, int second) {
    final scoped = _rooms;
    final firstGlobal = widget.rooms.indexOf(scoped[first]);
    final secondGlobal = widget.rooms.indexOf(scoped[second]);
    final value = widget.rooms[firstGlobal];
    widget.rooms[firstGlobal] = widget.rooms[secondGlobal];
    widget.rooms[secondGlobal] = value;
  }

  void _reorderScopedRooms(int oldIndex, int newIndex) {
    final reordered = _rooms;
    reorderRooms(reordered, oldIndex, newIndex);
    final globalIndices = <int>[
      for (var index = 0; index < widget.rooms.length; index++)
        if (widget.rooms[index].propertyElementId ==
            widget.selectedPropertyElementId)
          index,
    ];
    for (var index = 0; index < globalIndices.length; index++) {
      widget.rooms[globalIndices[index]] = reordered[index];
    }
  }

  IconData _iconForRoom(String type) {
    switch (type) {
      case 'Hall d’entrée':
      case 'Hall de nuit':
      case 'Dégagement':
        return Icons.meeting_room_outlined;
      case 'Séjour':
      case 'Salon':
      case 'Salle à manger':
        return Icons.weekend_outlined;
      case 'Cuisine':
        return Icons.kitchen_outlined;
      case 'WC':
        return Icons.wc_outlined;
      case 'Salle de bain':
      case 'Salle de douche':
        return Icons.bathtub_outlined;
      case 'Chambre':
        return Icons.bed_outlined;
      case 'Bureau':
        return Icons.business_center_outlined;
      case 'Dressing':
        return Icons.checkroom_outlined;
      case 'Buanderie':
        return Icons.local_laundry_service_outlined;
      case 'Cave':
        return Icons.inventory_2_outlined;
      case 'Grenier':
        return Icons.roofing_outlined;
      case 'Garage':
        return Icons.garage_outlined;
      case 'Local technique':
        return Icons.build_outlined;
      case 'Terrasse':
        return Icons.deck_outlined;
      case 'Jardin':
        return Icons.yard_outlined;
      case 'Façade avant':
      case 'Façade arrière':
      case 'Façade latérale gauche':
      case 'Façade latérale droite':
      case 'Façade':
      case 'Pignon':
      case 'Mur mitoyen':
      case 'Toiture':
      case 'Bâtiment voisin':
        return Icons.home_work_outlined;
      case 'Trottoir':
      case 'Voirie':
      case 'Chaussée':
      case 'Accotement':
      case 'Bordure':
      case 'Parking':
      case 'Marquage au sol':
        return Icons.add_road_outlined;
      case 'Clôture':
      case 'Mur de soutènement':
        return Icons.fence_outlined;
      default:
        return Icons.add_home_work_outlined;
    }
  }

  @override
  void dispose() {
    _customRoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        return Column(
          children: [
            _buildElementSelector(compact: compact),
            const SizedBox(height: 16),
            if (compact) _buildMobileSectionSelector(),
            if (compact) const SizedBox(height: 12),
            Expanded(
              child: compact
                  ? IndexedStack(
                      index: _mobileSectionIndex,
                      children: [
                        _buildTemplatesPanel(compact: true),
                        _buildCompositionPanel(compact: true),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth < 1100 ? 300 : 340,
                          child: _buildTemplatesPanel(),
                        ),
                        const SizedBox(width: 28),
                        Expanded(child: _buildCompositionPanel()),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildElementSelector({required bool compact}) {
    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.propertyElements
          .map(
            (element) => ChoiceChip(
              label: Text(
                element.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected: element.id == widget.selectedPropertyElementId,
              onSelected: (_) => widget.onPropertyElementSelected(element.id),
            ),
          )
          .toList(growable: false),
    );

    if (compact) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bâtiment ou zone',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            chips,
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Bâtiment ou zone :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: chips),
      ],
    );
  }

  Widget _buildMobileSectionSelector() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment<int>(
            value: 0,
            icon: const Icon(Icons.add_home_work_outlined),
            label: Text(widget.technicalMode ? 'Zones' : 'Ajouter'),
          ),
          ButtonSegment<int>(
            value: 1,
            icon: const Icon(Icons.format_list_numbered),
            label: Text('Composition (${_rooms.length})'),
          ),
        ],
        selected: <int>{_mobileSectionIndex},
        showSelectedIcon: false,
        onSelectionChanged: (selection) {
          setState(() => _mobileSectionIndex = selection.first);
        },
      ),
    );
  }

  Widget _buildTemplatesPanel({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.technicalMode ? 'Zones proposées' : 'Pièces proposées',
          style: TextStyle(
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Touchez plusieurs fois une pièce pour l’ajouter plusieurs fois.',
          style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _roomTemplates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final room = _roomTemplates[index];
              return Material(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _addRoom(room),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconForRoom(room),
                            size: 21,
                            color: const Color(0xFF1264F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            room,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF1264F6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customRoomController,
          decoration: InputDecoration(
            labelText: widget.technicalMode
                ? 'Zone personnalisée'
                : 'Pièce personnalisée',
            hintText: 'Exemple : Véranda',
            prefixIcon: const Icon(Icons.edit_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addCustomRoom(),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addCustomRoom,
            icon: const Icon(Icons.add),
            label: Text(
              widget.technicalMode
                  ? 'Ajouter cette zone'
                  : 'Ajouter cette pièce',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompositionPanel({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.technicalMode
                    ? 'Composition de ${_selectedElement?.name ?? 'la zone'}'
                    : 'Pièces de ${_selectedElement?.name ?? 'l’élément'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              _buildRoomCounter(),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.technicalMode
                      ? 'Composition de ${_selectedElement?.name ?? 'la zone'}'
                      : 'Pièces de ${_selectedElement?.name ?? 'l’élément'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _buildRoomCounter(),
            ],
          ),
        const SizedBox(height: 6),
        const Text(
          'Renommez les pièces et indiquez leur niveau dans l’ordre de la visite.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _rooms.isEmpty
              ? _buildEmptyState(compact: compact)
              : ReorderableListView.builder(
                  padding: EdgeInsets.zero,
                  buildDefaultDragHandles: false,
                  itemCount: _rooms.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() => _reorderScopedRooms(oldIndex, newIndex));
                    _notifyChanged();
                  },
                  itemBuilder: (context, index) => _buildRoomCard(
                    room: _rooms[index],
                    index: index,
                    compact: compact,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRoomCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${_rooms.length} pièce${_rooms.length > 1 ? 's' : ''}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1264F6),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: compact ? 48 : 62,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune pièce ajoutée',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ajoutez une pièce depuis l’onglet précédent pour commencer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard({
    required RoomItem room,
    required int index,
    required bool compact,
  }) {
    return Card(
      key: ValueKey(room),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 14),
        child: compact
            ? _buildCompactRoomCardContent(room: room, index: index)
            : _buildWideRoomCardContent(room: room, index: index),
      ),
    );
  }

  Widget _buildWideRoomCardContent({
    required RoomItem room,
    required int index,
  }) {
    return Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.drag_indicator_rounded,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _buildRoomAvatar(room),
        const SizedBox(width: 14),
        Expanded(flex: 3, child: _buildRoomNameField(room)),
        const SizedBox(width: 14),
        Expanded(flex: 2, child: _buildLevelField(room)),
        const SizedBox(width: 8),
        _buildRoomActions(index),
      ],
    );
  }

  Widget _buildCompactRoomCardContent({
    required RoomItem room,
    required int index,
  }) {
    return Column(
      children: [
        Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            _buildRoomAvatar(room),
            const Spacer(),
            IconButton(
              tooltip: 'Supprimer',
              onPressed: () => _removeRoom(index),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildRoomNameField(room),
        const SizedBox(height: 12),
        _buildLevelField(room),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: index == 0 ? null : () => _moveRoomUp(index),
              icon: const Icon(Icons.arrow_upward, size: 18),
              label: const Text('Monter'),
            ),
            TextButton.icon(
              onPressed: index == _rooms.length - 1
                  ? null
                  : () => _moveRoomDown(index),
              icon: const Icon(Icons.arrow_downward, size: 18),
              label: const Text('Descendre'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomAvatar(RoomItem room) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFEAF2FF),
      child: Icon(
        _iconForRoom(room.type),
        color: const Color(0xFF1264F6),
      ),
    );
  }

  Widget _buildRoomNameField(RoomItem room) {
    return TextFormField(
      key: ValueKey('name-${room.hashCode}'),
      initialValue: room.name,
      decoration: const InputDecoration(
        labelText: 'Nom de la pièce',
        isDense: true,
      ),
      onChanged: (value) {
        room.name = value;
        _notifyChanged();
      },
    );
  }

  Widget _buildLevelField(RoomItem room) {
    final value = _levels.contains(room.level) ? room.level : _levels.first;
    return DropdownButtonFormField<String>(
      key: ValueKey('level-${room.hashCode}-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Niveau', isDense: true),
      items: _levels
          .map(
            (level) => DropdownMenuItem<String>(
              value: level,
              child: Text(level, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: (newValue) {
        if (newValue == null) return;
        setState(() => room.level = newValue);
        _notifyChanged();
      },
    );
  }

  Widget _buildRoomActions(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Monter',
          onPressed: index == 0 ? null : () => _moveRoomUp(index),
          icon: const Icon(Icons.arrow_upward),
        ),
        IconButton(
          tooltip: 'Descendre',
          onPressed: index == _rooms.length - 1
              ? null
              : () => _moveRoomDown(index),
          icon: const Icon(Icons.arrow_downward),
        ),
        IconButton(
          tooltip: 'Supprimer',
          onPressed: () => _removeRoom(index),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
