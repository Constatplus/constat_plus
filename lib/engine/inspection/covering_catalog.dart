import 'models/covering.dart';

abstract final class CoveringCatalog {
  const CoveringCatalog._();

  static const paint = Covering(
    id: 'paint',
    name: 'Enduit sous peinture',
  );

  static const wallpaper = Covering(
    id: 'wallpaper',
    name: 'Papier peint',
  );

  static const fiberglass = Covering(
    id: 'fiberglass',
    name: 'Fibre de verre',
  );

  static const tiles = Covering(
    id: 'tiles',
    name: 'Carrelage',
  );

  static const parquet = Covering(
    id: 'parquet',
    name: 'Parquet',
  );

  static const laminate = Covering(
    id: 'laminate',
    name: 'Stratifié',
  );

  static const vinyl = Covering(
    id: 'vinyl',
    name: 'Vinyle',
  );

  static const lvt = Covering(
    id: 'lvt',
    name: 'LVT',
  );

  static const carpet = Covering(
    id: 'carpet',
    name: 'Moquette',
  );

  static const naturalStone = Covering(
    id: 'natural_stone',
    name: 'Pierre naturelle',
  );

  static const paneling = Covering(
    id: 'paneling',
    name: 'Lambris',
  );

  static const all = <Covering>[
    paint,
    wallpaper,
    fiberglass,
    tiles,
    parquet,
    laminate,
    vinyl,
    lvt,
    carpet,
    naturalStone,
    paneling,
  ];
}