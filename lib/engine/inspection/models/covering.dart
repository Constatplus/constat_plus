import 'package:flutter/foundation.dart';

/// Revêtement d'un élément.
///
/// Exemples :
/// - Enduit sous peinture
/// - Papier peint
/// - Carrelage
/// - Lambris
/// - Fibre de verre
@immutable
class Covering {
  final String id;
  final String name;

  const Covering({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      other is Covering &&
      other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}