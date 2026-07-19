import '../observation/observation.dart';
import '../photo/photo.dart';

class Element {
  final String id;
  final String name;

  final List<Photo> photos;
  final List<Observation> observations;

  const Element({
    this.id = '',
    this.name = '',
    this.photos = const [],
    this.observations = const [],
  });

  Element copyWith({
    String? id,
    String? name,
    List<Photo>? photos,
    List<Observation>? observations,
  }) {
    return Element(
      id: id ?? this.id,
      name: name ?? this.name,
      photos: photos ?? this.photos,
      observations: observations ?? this.observations,
    );
  }
}