import 'models/inspection_element.dart';

/// Catalogue officiel des éléments d'inspection.
///
/// Une seule source de vérité pour toute l'application.
abstract final class ElementCatalog {
  const ElementCatalog._();

  static const wall = InspectionElement(
    id: 'wall',
    name: 'Mur',
  );

  static const floor = InspectionElement(
    id: 'floor',
    name: 'Sol',
  );

  static const ceiling = InspectionElement(
    id: 'ceiling',
    name: 'Plafond',
  );

  static const skirting = InspectionElement(
    id: 'skirting',
    name: 'Plinthe',
  );

  static const door = InspectionElement(
    id: 'door',
    name: 'Porte',
  );

  static const window = InspectionElement(
    id: 'window',
    name: 'Châssis',
  );

  static const shutter = InspectionElement(
    id: 'shutter',
    name: 'Volet',
  );

  static const radiator = InspectionElement(
    id: 'radiator',
    name: 'Radiateur',
  );

  static const electricity = InspectionElement(
    id: 'electricity',
    name: 'Électricité',
  );

  static const lighting = InspectionElement(
    id: 'lighting',
    name: 'Point lumineux',
  );

  static const furniture = InspectionElement(
    id: 'furniture',
    name: 'Meubles',
  );

  static const worktop = InspectionElement(
    id: 'worktop',
    name: 'Plan de travail',
  );

  static const sink = InspectionElement(
    id: 'sink',
    name: 'Évier',
  );

  static const splashback = InspectionElement(
    id: 'splashback',
    name: 'Crédence',
  );

  static const hood = InspectionElement(
    id: 'hood',
    name: 'Hotte',
  );

  static const appliance = InspectionElement(
    id: 'appliance',
    name: 'Électroménager',
  );

  static const staircase = InspectionElement(
    id: 'staircase',
    name: 'Escalier',
  );

  static const handrail = InspectionElement(
    id: 'handrail',
    name: 'Main courante',
  );

  static const sanitary = InspectionElement(
    id: 'sanitary',
    name: 'Sanitaire',
  );

  static const exterior = InspectionElement(
    id: 'exterior',
    name: 'Aménagement extérieur',
  );

  static const all = <InspectionElement>[
    wall,
    floor,
    ceiling,
    skirting,
    door,
    window,
    shutter,
    radiator,
    electricity,
    lighting,
    furniture,
    worktop,
    sink,
    splashback,
    hood,
    appliance,
    staircase,
    handrail,
    sanitary,
    exterior,
  ];
}