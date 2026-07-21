import 'package:flutter/material.dart';

import 'property_composition/models/property_element.dart';

class StepPropertyType extends StatelessWidget {
  const StepPropertyType({
    super.key,
    required this.elements,
    required this.selectedElementId,
    required this.onSelected,
    required this.onChanged,
    this.technicalMode = false,
  });

  final List<PropertyElement> elements;
  final String? selectedElementId;
  final ValueChanged<String> onSelected;
  final VoidCallback onChanged;
  final bool technicalMode;

  static const _buildingTypes = <PropertyElementType>[
    PropertyElementType.apartment,
    PropertyElementType.duplex,
    PropertyElementType.house,
    PropertyElementType.villa,
    PropertyElementType.garage,
    PropertyElementType.warehouse,
    PropertyElementType.hangar,
    PropertyElementType.other,
  ];

  List<PropertyElementType> get _availableTypes => widgetTypes(technicalMode);

  static List<PropertyElementType> widgetTypes(bool technicalMode) =>
      <PropertyElementType>[
        if (technicalMode) PropertyElementType.road,
        ..._buildingTypes,
      ];

  Future<String?> _askCustomName(BuildContext context) async {
    final controller = TextEditingController();
    final customName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Autre type de bien'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom du bien'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    controller.dispose();

    final value = customName?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> _addTechnicalElement(
    BuildContext context,
    PropertyElementType type,
  ) async {
    String? customName;
    if (type == PropertyElementType.other) {
      customName = await _askCustomName(context);
      if (customName == null) return;
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

  Future<void> _selectClassicType(
    BuildContext context,
    PropertyElementType type,
  ) async {
    String? customName;
    if (type == PropertyElementType.other) {
      customName = await _askCustomName(context);
      if (customName == null) return;
    }

    final current = elements.isEmpty ? null : elements.first;
    if (current != null &&
        current.type == type &&
        type != PropertyElementType.other) {
      onSelected(current.id);
      return;
    }

    final element = PropertyElement.create(
      type,
      name: customName ?? type.label,
    );

    elements
      ..clear()
      ..add(element);
    onChanged();
    onSelected(element.id);
  }

  IconData _icon(PropertyElementType type) => switch (type) {
    PropertyElementType.apartment => Icons.apartment_outlined,
    PropertyElementType.duplex => Icons.stairs_outlined,
    PropertyElementType.house => Icons.home_outlined,
    PropertyElementType.villa => Icons.villa_outlined,
    PropertyElementType.hangar => Icons.factory_outlined,
    PropertyElementType.other => Icons.more_horiz,
    PropertyElementType.housing => Icons.home_work_outlined,
    PropertyElementType.road => Icons.add_road_outlined,
    PropertyElementType.annex => Icons.other_houses_outlined,
    PropertyElementType.garage => Icons.garage_outlined,
    PropertyElementType.warehouse => Icons.warehouse_outlined,
    PropertyElementType.garden => Icons.yard_outlined,
    PropertyElementType.land => Icons.landscape_outlined,
    PropertyElementType.custom => Icons.dashboard_customize_outlined,
  };

  Widget _buildTechnicalTypeList(BuildContext context) {
    return ListView.separated(
      itemCount: _availableTypes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final type = _availableTypes[index];
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
          onTap: () => _addTechnicalElement(context, type),
        );
      },
    );
  }

  Widget _buildClassicTypeGrid(BuildContext context) {
    final selectedType = elements.isEmpty ? null : elements.first.type;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 650
                ? 3
                : constraints.maxWidth >= 380
                    ? 2
                    : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columnCount == 1 ? 2.45 : 1.12,
          ),
          itemCount: _buildingTypes.length,
          itemBuilder: (context, index) {
            final type = _buildingTypes[index];
            final selected = selectedType == type;

            return Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: selected ? const Color(0xFFEAF2FF) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF1264F6)
                      : const Color(0xFFDCE5F0),
                  width: selected ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                hoverColor: const Color(0xFFEAF2FF),
                splashColor: const Color(0xFFDCE9FF),
                onTap: () => _selectClassicType(context, type),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFD9E8FF)
                                    : const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                _icon(type),
                                size: 29,
                                color: const Color(0xFF1264F6),
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              type.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF172033),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selected)
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF1264F6),
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedProperty() {
    if (elements.isEmpty) {
      return const Center(
        child: Text('Sélectionnez un type de bien.'),
      );
    }

    final element = elements.first;
    return Card(
      color: const Color(0xFFEAF2FF),
      child: ListTile(
        leading: Icon(
          _icon(element.type),
          color: const Color(0xFF1264F6),
        ),
        title: TextFormField(
          key: ValueKey(element.id),
          initialValue: element.name,
          decoration: const InputDecoration(
            labelText: 'Nom du bien',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            element.name = value;
            onChanged();
          },
        ),
        trailing: const Icon(
          Icons.check_circle,
          color: Color(0xFF1264F6),
        ),
        onTap: () => onSelected(element.id),
      ),
    );
  }

  Widget _buildTechnicalComposition() {
    return elements.isEmpty
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
          );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet = constraints.maxWidth < 1050;
        final titleSize = isMobile ? 24.0 : 30.0;

        final selector = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              technicalMode ? 'Éléments principaux' : 'Type de bien',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              technicalMode
                  ? 'Ajoutez chaque bâtiment ou zone qui compose la mission.'
                  : 'Sélectionnez un seul type de bien. Les pièces et dépendances seront ajoutées à l’étape suivante.',
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: technicalMode
                  ? _buildTechnicalTypeList(context)
                  : _buildClassicTypeGrid(context),
            ),
          ],
        );

        final selection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              technicalMode
                  ? 'Composition de la mission (${elements.length})'
                  : 'Bien sélectionné',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              technicalMode
                  ? 'Renommez les éléments puis choisissez celui à composer.'
                  : 'Vous pourrez composer le bien dans l’étape suivante.',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: technicalMode
                  ? _buildTechnicalComposition()
                  : _buildSelectedProperty(),
            ),
          ],
        );

        if (isTablet) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: selector),
              const SizedBox(height: 22),
              Expanded(flex: technicalMode ? 2 : 1, child: selection),
            ],
          );
        }

        final leftWidth = technicalMode
            ? 390.0
            : constraints.maxWidth >= 1450
                ? 720.0
                : constraints.maxWidth >= 1150
                    ? 560.0
                    : 440.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: leftWidth, child: selector),
            const SizedBox(width: 28),
            Expanded(child: selection),
          ],
        );
      },
    );
  }
}
