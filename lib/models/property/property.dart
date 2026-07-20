import '../shared/enums.dart';

class Property {
  final PropertyType type;

  final String street;
  final String number;
  final String box;
  final String zipCode;
  final String city;

  final int floors;
  final int bedrooms;
  final int bathrooms;

  final bool hasCellar;
  final bool hasGarage;
  final bool hasGarden;
  final bool hasTerrace;

  const Property({
    this.type = PropertyType.apartment,
    this.street = '',
    this.number = '',
    this.box = '',
    this.zipCode = '',
    this.city = '',
    this.floors = 1,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.hasCellar = false,
    this.hasGarage = false,
    this.hasGarden = false,
    this.hasTerrace = false,
  });

  Property copyWith({
    PropertyType? type,
    String? street,
    String? number,
    String? box,
    String? zipCode,
    String? city,
    int? floors,
    int? bedrooms,
    int? bathrooms,
    bool? hasCellar,
    bool? hasGarage,
    bool? hasGarden,
    bool? hasTerrace,
  }) {
    return Property(
      type: type ?? this.type,
      street: street ?? this.street,
      number: number ?? this.number,
      box: box ?? this.box,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      floors: floors ?? this.floors,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      hasCellar: hasCellar ?? this.hasCellar,
      hasGarage: hasGarage ?? this.hasGarage,
      hasGarden: hasGarden ?? this.hasGarden,
      hasTerrace: hasTerrace ?? this.hasTerrace,
    );
  }
}
