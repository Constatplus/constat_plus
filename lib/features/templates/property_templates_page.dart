import 'package:flutter/material.dart';

import '../../core/storage/local_json_store.dart';

class PropertyTemplatesPage extends StatefulWidget {
  const PropertyTemplatesPage({super.key});
  @override
  State<PropertyTemplatesPage> createState() => _PropertyTemplatesPageState();
}

class _PropertyTemplatesPageState extends State<PropertyTemplatesPage> {
  static const _key = 'property_templates_v1';
  final _store = const LocalJsonStore();
  final _name = TextEditingController();
  final _rooms = TextEditingController(text: 'Hall, Séjour, Cuisine, Chambre, Salle de bain');
  List<Map<String, dynamic>> templates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await _store.readList(_key);
    if (!mounted) return;
    setState(() => templates = values);
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final item = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': name,
      'rooms': _rooms.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    setState(() => templates = [...templates, item]);
    await _store.writeList(_key, templates);
    _name.clear();
  }

  Future<void> _remove(String id) async {
    setState(() => templates = templates.where((e) => e['id'] != id).toList());
    await _store.writeList(_key, templates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modèles de biens')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Préconfigurer un bien', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Conservez la structure durable d’un appartement ou d’une maison et réutilisez-la dans un nouveau dossier.', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom du modèle', hintText: 'Maison — Rue du Centre', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: _rooms, decoration: const InputDecoration(labelText: 'Pièces séparées par des virgules', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Enregistrer le modèle'))),
          ]))),
          const SizedBox(height: 24),
          if (templates.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Aucun modèle enregistré.'))),
          ...templates.map((item) {
            final rooms = (item['rooms'] as List? ?? const []).join(' • ');
            return Card(child: ListTile(leading: const Icon(Icons.home_work_outlined), title: Text(item['name']?.toString() ?? ''), subtitle: Text(rooms), trailing: IconButton(onPressed: () => _remove(item['id'].toString()), icon: const Icon(Icons.delete_outline))));
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _rooms.dispose();
    super.dispose();
  }
}
