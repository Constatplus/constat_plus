import 'package:flutter/material.dart';

import 'property_composition/models/property_element.dart';

class StepPropertyType extends StatelessWidget {
  const StepPropertyType({
    super.key,
    required this.elements,
    required this.selectedElementId,
    required this.onSelected,
    required this.onChanged,
  });

  final List<PropertyElement> elements;
  final String? selectedElementId;
  final ValueChanged<String> onSelected;
  final VoidCallback onChanged;

  Future<void> _addElement(
    BuildContext context,
    PropertyElementType type,
  ) async {
    String? customName;
    if (type == PropertyElementType.custom) {
      final controller = TextEditingController();
      customName = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Ajouter une zone personnalisée'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom de la zone'),
            onSubmitted: (value) => Navigator.pop(dialogContext, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (customName == null || customName.trim().isEmpty) return;
    }

    final sameTypeCount = elements.where((item) => item.type == type).length;
    final defaultName = sameTypeCount == 0
        ? type.label
        : '${type.label} ${sameTypeCount + 1}';
    final element = PropertyElement.create(
      type,
      name: customName ?? defaultName,
    );
    elements.add(element);
    onChanged();
    onSelected(element.id);
  }

  IconData _icon(PropertyElementType type) => switch (type) {
    PropertyElementType.housing => Icons.home_work_outlined,
    PropertyElementType.road => Icons.add_road_outlined,
    PropertyElementType.annex => Icons.other_houses_outlined,
    PropertyElementType.garage => Icons.garage_outlined,
    PropertyElementType.warehouse => Icons.warehouse_outlined,
    PropertyElementType.garden => Icons.yard_outlined,
    PropertyElementType.land => Icons.landscape_outlined,
    PropertyElementType.custom => Icons.dashboard_customize_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 390,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Éléments principaux',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajoutez chaque bâtiment ou zone qui compose la mission.',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: PropertyElementType.values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final type = PropertyElementType.values[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      leading: Icon(
                        _icon(type),
                        color: const Color(0xFF1264F6),
                      ),
                      title: Text(type.label),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => _addElement(context, type),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Composition de la mission (${elements.length})',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Renommez les éléments puis choisissez celui à composer.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: elements.isEmpty
                    ? const Center(
                        child: Text('Ajoutez au moins un élément principal.'),
                      )
                    : ListView.separated(
                        itemCount: elements.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final element = elements[index];
                          final selected = element.id == selectedElementId;
                          return Card(
                            color: selected ? const Color(0xFFEAF2FF) : null,
                            child: ListTile(
                              leading: Icon(_icon(element.type)),
                              title: TextFormField(
                                key: ValueKey(element.id),
                                initialValue: element.name,
                                decoration: const InputDecoration(
                                  labelText: 'Nom de l’élément',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  element.name = value;
                                  onChanged();
                                },
                              ),
                              trailing: selected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF1264F6),
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: () => onSelected(element.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
