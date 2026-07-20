import 'package:flutter/foundation.dart';

import 'element_catalog.dart';
import 'repository/inspection_repository.dart';

void testRepository() {
  const repository = InspectionRepository();

  final wall = repository.getDefinition(ElementCatalog.wall);

  debugPrint(wall?.element.name);
  debugPrint(wall?.materials.length.toString());
}
