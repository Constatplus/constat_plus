import 'package:flutter/foundation.dart';

@immutable
abstract class NamedEntity {
  final String id;
  final String name;

  const NamedEntity({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is NamedEntity &&
            other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() => name;
}