import 'package:flutter/foundation.dart';

@immutable
class MaterialType {
  final String id;
  final String name;

  const MaterialType({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is MaterialType && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
