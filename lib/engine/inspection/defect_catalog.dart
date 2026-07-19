import 'models/defect.dart';

abstract final class DefectCatalog {
  const DefectCatalog._();

  static const scratch = Defect(
    id: 'scratch',
    name: 'Griffure',
  );

  static const hole = Defect(
    id: 'hole',
    name: 'Percement',
  );

  static const impact = Defect(
    id: 'impact',
    name: 'Impact',
  );

  static const crack = Defect(
    id: 'crack',
    name: 'Fissure',
  );

  static const chip = Defect(
    id: 'chip',
    name: 'Éclat',
  );

  static const humidity = Defect(
    id: 'humidity',
    name: 'Humidité',
  );

  static const mould = Defect(
    id: 'mould',
    name: 'Moisissure',
  );

  static const dirt = Defect(
    id: 'dirt',
    name: 'Salissure',
  );

  static const stain = Defect(
    id: 'stain',
    name: 'Tache',
  );

  static const wear = Defect(
    id: 'wear',
    name: 'Usure',
  );

  static const rust = Defect(
    id: 'rust',
    name: 'Rouille',
  );

  static const loose = Defect(
    id: 'loose',
    name: 'Décollement',
  );

  static const deformation = Defect(
    id: 'deformation',
    name: 'Déformation',
  );

  static const swelling = Defect(
    id: 'swelling',
    name: 'Gonflement',
  );

  static const broken = Defect(
    id: 'broken',
    name: 'Cassé',
  );

  static const missing = Defect(
    id: 'missing',
    name: 'Manquant',
  );

  static const all = <Defect>[
    scratch,
    hole,
    impact,
    crack,
    chip,
    humidity,
    mould,
    dirt,
    stain,
    wear,
    rust,
    loose,
    deformation,
    swelling,
    broken,
    missing,
  ];
}