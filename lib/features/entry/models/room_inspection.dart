import 'photo_item.dart';

class QuantityItem {
  QuantityItem({required this.label, this.selected = false, this.quantity = 1});

  final String label;
  bool selected;
  int quantity;
}

class FurnitureItem {
  FurnitureItem({required this.label, this.selected = false, this.description = ''});

  final String label;
  bool selected;
  String description;
}

class RoomInspection {
  RoomInspection({required this.roomName})
      : electricalItems = <QuantityItem>[
          QuantityItem(label: 'Prise'),
          QuantityItem(label: 'Double prise'),
          QuantityItem(label: 'Triple prise'),
          QuantityItem(label: 'Interrupteur'),
          QuantityItem(label: 'Interrupteur avec prise'),
          QuantityItem(label: 'Prise Proximus'),
          QuantityItem(label: 'Prise TV'),
          QuantityItem(label: 'Prise Ethernet'),
          QuantityItem(label: 'Lampe murale'),
          QuantityItem(label: 'Point lumineux au plafond'),
          QuantityItem(label: 'Détecteur de fumée'),
          QuantityItem(label: 'Bloc composé'),
        ],
        furnitureItems = <FurnitureItem>[
          FurnitureItem(label: 'Placard'),
          FurnitureItem(label: 'Dressing'),
          FurnitureItem(label: 'Douche'),
          FurnitureItem(label: 'Baignoire'),
          FurnitureItem(label: 'Meuble lavabo'),
          FurnitureItem(label: 'Lavabo'),
          FurnitureItem(label: 'Évier'),
          FurnitureItem(label: 'Meuble de cuisine'),
          FurnitureItem(label: 'Plan de travail'),
          FurnitureItem(label: 'Hotte'),
          FurnitureItem(label: 'Radiateur'),
          FurnitureItem(label: 'Poêle ou cheminée'),
        ];

  final String roomName;
  String floor = '';
  String walls = '';
  String ceiling = '';
  String woodwork = '';
  String doors = '';
  String windows = '';
  String heating = '';
  String sanitary = '';
  String generalObservations = '';
  final List<QuantityItem> electricalItems;
  final List<FurnitureItem> furnitureItems;
  final List<PhotoItem> photos = <PhotoItem>[];

  bool get hasContent {
    return floor.trim().isNotEmpty ||
        walls.trim().isNotEmpty ||
        ceiling.trim().isNotEmpty ||
        woodwork.trim().isNotEmpty ||
        generalObservations.trim().isNotEmpty ||
        electricalItems.any((item) => item.selected) ||
        furnitureItems.any((item) => item.selected) ||
        photos.isNotEmpty;
  }
}
