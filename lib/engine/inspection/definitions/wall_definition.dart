import '../covering_catalog.dart';
import '../defect_catalog.dart';
import '../element_catalog.dart';
import '../material_catalog.dart';
import '../models/element_definition.dart';

const wallDefinition = ElementDefinition(
  element: ElementCatalog.wall,

  materials: [
    MaterialCatalog.block,
    MaterialCatalog.brick,
    MaterialCatalog.concrete,
    MaterialCatalog.plasterboard,
  ],

  coverings: [
    CoveringCatalog.paint,
    CoveringCatalog.wallpaper,
    CoveringCatalog.fiberglass,
    CoveringCatalog.tiles,
    CoveringCatalog.paneling,
  ],

  defects: [
    DefectCatalog.scratch,
    DefectCatalog.hole,
    DefectCatalog.impact,
    DefectCatalog.crack,
    DefectCatalog.humidity,
    DefectCatalog.mould,
    DefectCatalog.loose,
    DefectCatalog.stain,
    DefectCatalog.dirt,
  ],
);