import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class StepBeforeWorksCadastral extends StatefulWidget {
  const StepBeforeWorksCadastral({super.key});

  @override
  State<StepBeforeWorksCadastral> createState() => _StepBeforeWorksCadastralState();
}

class _StepBeforeWorksCadastralState extends State<StepBeforeWorksCadastral> {
  XFile? _document;
  final List<TextEditingController> _persons = [TextEditingController()];

  Future<void> _pickDocument() async {
    const group = XTypeGroup(label: 'Documents cadastraux', extensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx']);
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file != null && mounted) setState(() => _document = file);
  }

  @override
  void dispose() {
    for (final c in _persons) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const Text('Document cadastral et personnes présentes', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Sélectionnez le document utile et renseignez les personnes présentes lors de la visite.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Partie cadastrale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: _pickDocument, icon: const Icon(Icons.attach_file), label: const Text('Sélectionner un document')),
        if (_document != null) ...[
          const SizedBox(height: 12),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.description_outlined), title: Text(_document!.name), subtitle: Text(_document!.path), trailing: IconButton(onPressed: () => setState(() => _document = null), icon: const Icon(Icons.close))),
        ],
      ])),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Personnes présentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        for (var i = 0; i < _persons.length; i++) ...[
          Row(children: [Expanded(child: TextField(controller: _persons[i], decoration: InputDecoration(labelText: 'Nom, qualité et partie représentée', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))))), const SizedBox(width: 8), IconButton(onPressed: _persons.length == 1 ? null : () => setState(() { _persons[i].dispose(); _persons.removeAt(i); }), icon: const Icon(Icons.delete_outline))]),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(onPressed: () => setState(() => _persons.add(TextEditingController())), icon: const Icon(Icons.person_add_alt_1), label: const Text('Ajouter une personne')),
      ])),
    ]);
  }
}
