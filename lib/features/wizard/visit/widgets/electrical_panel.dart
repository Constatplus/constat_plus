import 'package:flutter/material.dart';

class ElectricalPanel extends StatelessWidget {
  final List<String> walls;
  final Map<String, int> Function(String wall) quantitiesForWall;
  final int Function(String wall) blockQuantityForWall;
  final Set<String> Function(String wall) blockComponentsForWall;
  final void Function(String wall, String item, int quantity)
      onQuantityChanged;
  final void Function(String wall, int quantity) onBlockQuantityChanged;
  final void Function(
    String wall,
    String component,
    bool selected,
  ) onBlockComponentChanged;

  const ElectricalPanel({
    super.key,
    required this.walls,
    required this.quantitiesForWall,
    required this.blockQuantityForWall,
    required this.blockComponentsForWall,
    required this.onQuantityChanged,
    required this.onBlockQuantityChanged,
    required this.onBlockComponentChanged,
  });

  static const List<String> equipmentCatalog = [
    'Prise',
    'Double prise',
    'Triple prise',
    'Interrupteur',
    'Double interrupteur',
    'Interrupteur avec prise',
    'Prise Proximus',
    'Prise TV',
    'Prise Ethernet',
    'Prise USB',
    'Lampe murale',
    'Point lumineux',
    'Thermostat',
    'Sonnette / interphone',
    'Détecteur',
    'Autre équipement',
  ];

  static const List<String> blockComponentCatalog = [
    'Prise',
    'Interrupteur',
    'Prise Proximus',
    'Prise TV',
    'Prise Ethernet',
    'Prise USB',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: walls.map((wall) {
        final quantities = quantitiesForWall(wall);
        final blockQuantity = blockQuantityForWall(wall);
        final blockComponents = blockComponentsForWall(wall);
        final totalEquipment = quantities.values.fold<int>(
              0,
              (total, quantity) => total + quantity,
            ) +
            blockQuantity;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: ExpansionTile(
            initiallyExpanded: wall == 'Mur avant' || totalEquipment > 0,
            title: Text(
              wall,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$totalEquipment équipement(s)'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              ...equipmentCatalog.map((item) {
                final quantity = quantities[item] ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontWeight: quantity > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      _QuantitySelector(
                        quantity: quantity,
                        onChanged: (value) {
                          onQuantityChanged(wall, item, value);
                        },
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 26),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Bloc composé',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _QuantitySelector(
                    quantity: blockQuantity,
                    onChanged: (value) {
                      onBlockQuantityChanged(wall, value);
                    },
                  ),
                ],
              ),
              if (blockQuantity > 0) ...[
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Composition du bloc',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: blockComponentCatalog.map((component) {
                    final selected = blockComponents.contains(component);

                    return FilterChip(
                      label: Text(component),
                      selected: selected,
                      onSelected: (value) {
                        onBlockComponentChanged(wall, component, value);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          visualDensity: VisualDensity.compact,
          onPressed: quantity <= 0 ? null : () => onChanged(quantity - 1),
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 38,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton.outlined(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(quantity + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
