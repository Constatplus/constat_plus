import 'dart:typed_data';

class PhotoItem {
  PhotoItem({
    required this.id,
    required this.name,
    required this.bytes,
    required this.createdAt,
    this.note = '',
    this.selected = true,
  });

  final String id;
  final String name;
  final Uint8List bytes;
  final DateTime createdAt;
  String note;
  bool selected;
}
