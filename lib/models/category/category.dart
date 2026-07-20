import '../element/element.dart';

class Category {
  final String id;
  final String name;

  final List<Element> elements;

  const Category({this.id = '', this.name = '', this.elements = const []});

  Category copyWith({String? id, String? name, List<Element>? elements}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      elements: elements ?? this.elements,
    );
  }
}
