import '../category/category.dart';

class Room {
  final String id;
  final String name;
  final int order;

  final List<Category> categories;

  const Room({
    this.id = '',
    this.name = '',
    this.order = 0,
    this.categories = const [],
  });

  Room copyWith({
    String? id,
    String? name,
    int? order,
    List<Category>? categories,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      categories: categories ?? this.categories,
    );
  }
}