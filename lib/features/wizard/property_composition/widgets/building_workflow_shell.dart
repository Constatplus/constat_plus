import 'package:flutter/material.dart';

import '../models/property_element.dart';
import '../models/room_item.dart';

class BuildingWorkflowShell extends StatefulWidget {
  const BuildingWorkflowShell({
    super.key,
    required this.elements,
    required this.rooms,
    required this.selectedElementId,
    required this.completedElementIds,
    required this.onSelected,
    required this.onCompletionChanged,
    required this.child,
  });

  final List<PropertyElement> elements;
  final List<RoomItem> rooms;
  final String selectedElementId;
  final Set<String> completedElementIds;
  final ValueChanged<String> onSelected;
  final void Function(String elementId, bool completed) onCompletionChanged;
  final Widget child;

  @override
  State<BuildingWorkflowShell> createState() => _BuildingWorkflowShellState();
}

class _BuildingWorkflowShellState extends State<BuildingWorkflowShell> {
  late bool _showOverview = widget.elements.length > 1;

  List<RoomItem> _roomsFor(String elementId) => widget.rooms
      .where((room) => room.propertyElementId == elementId)
      .toList(growable: false);

  PropertyElement get _selected => widget.elements.firstWhere(
    (element) => element.id == widget.selectedElementId,
    orElse: () => widget.elements.first,
  );

  void _open(PropertyElement element) {
    if (_roomsFor(element.id).isEmpty) return;
    widget.onSelected(element.id);
    setState(() => _showOverview = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.elements.isEmpty) return widget.child;
    if (_showOverview) return _overview();
    final selected = _selected;
    final completed = widget.completedElementIds.contains(selected.id);
    return Column(
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _showOverview = true),
              icon: const Icon(Icons.domain_outlined),
              label: const Text('Liste des bâtiments'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                widget.onCompletionChanged(selected.id, !completed);
                setState(() => _showOverview = true);
              },
              icon: Icon(completed ? Icons.restart_alt : Icons.check_circle),
              label: Text(
                completed ? 'Rouvrir ce bâtiment' : 'Terminer ce bâtiment',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _overview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bâtiments et zones de la mission',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Traitez chaque élément, puis marquez-le comme terminé.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 390,
              mainAxisExtent: 170,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.elements.length,
            itemBuilder: (context, index) {
              final element = widget.elements[index];
              final roomCount = _roomsFor(element.id).length;
              final completed = widget.completedElementIds.contains(element.id);
              return Card(
                child: InkWell(
                  onTap: roomCount == 0 ? null : () => _open(element),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.domain_outlined),
                            const Spacer(),
                            Icon(
                              completed ? Icons.check_circle : Icons.timelapse,
                              color: completed
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          element.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          roomCount == 0
                              ? 'Aucune pièce à traiter'
                              : '$roomCount pièce${roomCount > 1 ? 's' : ''}',
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
}
