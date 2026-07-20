import 'package:flutter/foundation.dart';

/// Défaut pouvant être observé lors d'une inspection.
///
/// Exemples :
/// - Griffure
/// - Percement
/// - Impact
/// - Humidité
/// - Moisissure
@immutable
class Defect {
  final String id;
  final String name;

  const Defect({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is Defect && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
