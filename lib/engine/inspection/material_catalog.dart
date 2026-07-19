import 'models/material.dart';

abstract final class MaterialCatalog {
  const MaterialCatalog._();

  static const block = MaterialType(
    id: 'block',
    name: 'Bloc',
  );

  static const brick = MaterialType(
    id: 'brick',
    name: 'Brique',
  );

  static const concrete = MaterialType(
    id: 'concrete',
    name: 'Béton',
  );

  static const plasterboard = MaterialType(
    id: 'plasterboard',
    name: 'Gyproc',
  );

  static const wood = MaterialType(
    id: 'wood',
    name: 'Bois',
  );

  static const pvc = MaterialType(
    id: 'pvc',
    name: 'PVC',
  );

  static const aluminium = MaterialType(
    id: 'aluminium',
    name: 'Aluminium',
  );

  static const steel = MaterialType(
    id: 'steel',
    name: 'Acier',
  );

  static const ceramic = MaterialType(
    id: 'ceramic',
    name: 'Céramique',
  );

  static const granite = MaterialType(
    id: 'granite',
    name: 'Granit',
  );

  static const quartz = MaterialType(
    id: 'quartz',
    name: 'Quartz',
  );

  static const laminate = MaterialType(
    id: 'laminate',
    name: 'Stratifié',
  );

  static const naturalStone = MaterialType(
    id: 'natural_stone',
    name: 'Pierre naturelle',
  );

  static const all = <MaterialType>[
    block,
    brick,
    concrete,
    plasterboard,
    wood,
    pvc,
    aluminium,
    steel,
    ceramic,
    granite,
    quartz,
    laminate,
    naturalStone,
  ];
}