class RoomItem {
  final String type;

  String name;
  String level;
  String propertyElementId;

  RoomItem({
    required this.type,
    required this.name,
    required this.level,
    this.propertyElementId = '',
  });
}
