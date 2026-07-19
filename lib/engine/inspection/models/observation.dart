import 'package:flutter/foundation.dart';

import 'condition.dart';
import 'covering.dart';
import 'defect.dart';
import 'inspection_element.dart';
import 'material.dart';

/// Représente une observation réalisée par l'expert
/// sur un élément d'inspection.
///
/// Cette classe sera progressivement enrichie au fil
/// du développement du moteur métier.
@immutable
class Observation {
  /// Élément inspecté (mur, sol, plafond, ...)
  final InspectionElement element;

  /// Support / matériau de l'élément
  final MaterialType? material;

  /// Revêtement de l'élément
  final Covering? covering;

  /// État général de l'élément
  final Condition? condition;

  /// Défauts constatés
  final List<Defect> defects;

  /// Commentaire libre éventuel
  final String? comment;

  const Observation({
    required this.element,
    this.material,
    this.covering,
    this.condition,
    this.defects = const [],
    this.comment,
  });

  /// Indique si l'élément présente au moins un défaut.
  bool get hasDefect => defects.isNotEmpty;

  /// Indique si aucun défaut n'a été constaté.
  bool get isPerfect => defects.isEmpty;
}