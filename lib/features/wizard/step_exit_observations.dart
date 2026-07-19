import 'package:flutter/material.dart';

import 'property_composition/models/room_item.dart';
import 'step_signatures.dart';

class StepExitObservations extends StatefulWidget {
  final List<RoomItem> rooms;
  const StepExitObservations({super.key, required this.rooms});

  @override
  State<StepExitObservations> createState() => _StepExitObservationsState();
}

class _StepExitObservationsState extends State<StepExitObservations> {
  final List<_ObservationRow> _rows = [_ObservationRow()];
  final SignaturesData _signatures = SignaturesData();

  void _addRow() => setState(() => _rows.add(_ObservationRow()));
  void _removeRow(int index) {
    if (_rows.length == 1) return;
    setState(() => _rows.removeAt(index));
  }

  @override
  void dispose() {
    for (final row in _rows) row.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomNames = widget.rooms.map((room) => room.name).toList();
    return ListView(children: [
      const Text('Observations de sortie', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Ajoutez les constatations sous forme de liste, en sélectionnant la pièce concernée.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
      const SizedBox(height: 22),
      for (var i = 0; i < _rows.length; i++) ...[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text('Observation ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const Spacer(), IconButton(onPressed: () => _removeRow(i), icon: const Icon(Icons.delete_outline))]),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: roomNames.contains(_rows[i].room) ? _rows[i].room : null,
              decoration: _input('Pièce / local'),
              items: roomNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
              onChanged: (value) => setState(() => _rows[i].room = value),
            ),
            const SizedBox(height: 12),
            TextField(controller: _rows[i].description, minLines: 3, maxLines: 8, decoration: _input('Description des constats et observations')),
          ]),
        ),
        const SizedBox(height: 12),
      ],
      Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text('Ajouter une observation'))),
      const SizedBox(height: 26),
      const Divider(),
      const SizedBox(height: 18),
      StepSignatures(data: _signatures, includeExpert: true, embedded: true),
    ]);
  }

  InputDecoration _input(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)));
}

class _ObservationRow {
  String? room;
  final TextEditingController description = TextEditingController();
  void dispose() => description.dispose();
}
