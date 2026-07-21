enum PropertyElementType {
  housing('Habitation'),
  road('Voirie'),
  annex('Bâtiment annexe'),
  garage('Garage'),
  warehouse('Entrepôt'),
  garden('Jardin'),
  land('Terrain'),
  custom('Zone personnalisée');

  const PropertyElementType(this.label);

  final String label;
}

class PropertyElement {
  PropertyElement({required this.id, required this.type, required this.name});

  factory PropertyElement.create(PropertyElementType type, {String? name}) {
    return PropertyElement(
      id: 'element-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
      type: type,
      name: name?.trim().isNotEmpty == true ? name!.trim() : type.label,
    );
  }

  PropertyElement copy() => PropertyElement(id: id, type: type, name: name);

  static int _nextId = 0;

  final String id;
  final PropertyElementType type;
  String name;
}
