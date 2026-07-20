import 'package:flutter/foundation.dart';

import 'covering.dart';
import 'defect.dart';
import 'inspection_element.dart';
import 'material.dart';

/// Décrit complètement un élément d'inspection.
///
/// Exemple :
///
/// Mur
/// ├─ matériaux
/// ├─ revêtements
/// └─ défauts possibles
@immutable
class ElementDefinition {
  final InspectionElement element;

  final List<MaterialType> materials;

  final List<Covering> coverings;

  final List<Defect> defects;

  const ElementDefinition({
    required this.element,
    this.materials = const [],
    this.coverings = const [],
    this.defects = const [],
  });
}
