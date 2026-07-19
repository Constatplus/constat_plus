import 'package:flutter/foundation.dart';

/// Représente un élément pouvant être inspecté
/// dans une pièce.
///
/// Exemples :
///
/// - Mur
/// - Sol
/// - Plafond
/// - Porte
/// - Châssis
/// - Radiateur
/// - Electricité
/// - Plan de travail
/// - Evier
///
/// Cet objet ne contient encore aucune observation.
/// Il décrit simplement l'élément.
@immutable
class InspectionElement {
  final String id;

  final String name;

  const InspectionElement({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      other is InspectionElement &&
      other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}