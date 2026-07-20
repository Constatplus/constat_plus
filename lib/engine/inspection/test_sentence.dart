import 'package:flutter/foundation.dart';

import 'condition_catalog.dart';
import 'covering_catalog.dart';
import 'defect_catalog.dart';
import 'element_catalog.dart';
import 'generator/sentence_generator.dart';
import 'material_catalog.dart';
import 'models/observation.dart';

void testSentence() {
  const generator = SentenceGenerator();

  final observation = Observation(
    element: ElementCatalog.wall,
    material: MaterialCatalog.block,
    covering: CoveringCatalog.paint,
    condition: ConditionCatalog.good,
    defects: const [DefectCatalog.scratch, DefectCatalog.hole],
  );

  debugPrint(generator.generate(observation));
}
