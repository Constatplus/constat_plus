import 'package:flutter/material.dart';

/// Représente un type d'inspection.
///
/// Exemples :
/// - Cuisine
/// - Chambre
/// - Salle de bain
/// - Façade
/// - Garage
///
/// Cette classe décrit uniquement le type.
/// Les observations réalisées pendant une visite
/// seront stockées dans d'autres modèles.
@immutable
class InspectionType {
  final String id;

  final String name;

  final IconData icon;

  final Color color;

  const InspectionType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    return other is InspectionType &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}