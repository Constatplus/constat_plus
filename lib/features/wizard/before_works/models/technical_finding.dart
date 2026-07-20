enum FindingClassification {
  normal,
  existingDisorder,
  fragile,
  watchPoint,
  inaccessible,
  notVisible,
}

extension FindingClassificationLabel on FindingClassification {
  String get label => switch (this) {
    FindingClassification.normal => 'État normal',
    FindingClassification.existingDisorder => 'Désordre existant',
    FindingClassification.fragile => 'Élément fragile',
    FindingClassification.watchPoint => 'Point à surveiller',
    FindingClassification.inaccessible => 'Inaccessible',
    FindingClassification.notVisible => 'Non visible',
  };
}

enum TechnicalDisorderType {
  crack,
  largeCrack,
  microCrack,
  detachment,
  subsidence,
  deformation,
  humidity,
  infiltration,
  corrosion,
  spalling,
  loosening,
  jointDefect,
  other,
}

extension TechnicalDisorderTypeLabel on TechnicalDisorderType {
  String get label => switch (this) {
    TechnicalDisorderType.crack => 'Fissure',
    TechnicalDisorderType.largeCrack => 'Lézarde',
    TechnicalDisorderType.microCrack => 'Microfissure',
    TechnicalDisorderType.detachment => 'Décollement',
    TechnicalDisorderType.subsidence => 'Affaissement',
    TechnicalDisorderType.deformation => 'Déformation',
    TechnicalDisorderType.humidity => 'Humidité',
    TechnicalDisorderType.infiltration => 'Infiltration',
    TechnicalDisorderType.corrosion => 'Corrosion',
    TechnicalDisorderType.spalling => 'Éclat',
    TechnicalDisorderType.loosening => 'Descellement',
    TechnicalDisorderType.jointDefect => 'Défaut de joint',
    TechnicalDisorderType.other => 'Autre',
  };

  bool get isCrack =>
      this == TechnicalDisorderType.crack ||
      this == TechnicalDisorderType.largeCrack ||
      this == TechnicalDisorderType.microCrack;
}

class CrackDetails {
  CrackDetails();

  String location = '';
  String orientation = '';
  String length = '';
  String approximateWidth = '';
  String openingMillimeters = '';
  bool? through;
  bool? active;
  String observation = '';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'location': location,
    'orientation': orientation,
    'length': length,
    'approximateWidth': approximateWidth,
    'openingMillimeters': openingMillimeters,
    'through': through,
    'active': active,
    'observation': observation,
  };

  factory CrackDetails.fromJson(Map<String, dynamic> json) => CrackDetails()
    ..location = json['location'] as String? ?? ''
    ..orientation = json['orientation'] as String? ?? ''
    ..length = json['length'] as String? ?? ''
    ..approximateWidth = json['approximateWidth'] as String? ?? ''
    ..openingMillimeters = json['openingMillimeters'] as String? ?? ''
    ..through = json['through'] as bool?
    ..active = json['active'] as bool?
    ..observation = json['observation'] as String? ?? '';
}

class TechnicalFinding {
  TechnicalFinding({required this.id});

  final String id;
  String areaId = '';
  String zone = '';
  String post = '';
  FindingClassification classification = FindingClassification.normal;
  TechnicalDisorderType disorderType = TechnicalDisorderType.other;
  String description = '';
  final CrackDetails crack = CrackDetails();
  final List<String> photoPaths = <String>[];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'areaId': areaId,
    'zone': zone,
    'post': post,
    'classification': classification.name,
    'disorderType': disorderType.name,
    'description': description,
    'crack': crack.toJson(),
    'photoPaths': photoPaths,
  };

  factory TechnicalFinding.fromJson(Map<String, dynamic> json) {
    final finding = TechnicalFinding(id: json['id'] as String? ?? '');
    finding.areaId = json['areaId'] as String? ?? '';
    finding.zone = json['zone'] as String? ?? '';
    finding.post = json['post'] as String? ?? '';
    finding.classification = FindingClassification.values.firstWhere(
      (value) => value.name == json['classification'],
      orElse: () => FindingClassification.normal,
    );
    finding.disorderType = TechnicalDisorderType.values.firstWhere(
      (value) => value.name == json['disorderType'],
      orElse: () => TechnicalDisorderType.other,
    );
    finding.description = json['description'] as String? ?? '';
    finding.photoPaths.addAll(
      (json['photoPaths'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>(),
    );
    final crackJson = json['crack'];
    if (crackJson is Map) {
      final source = CrackDetails.fromJson(
        Map<String, dynamic>.from(crackJson),
      );
      finding.crack
        ..location = source.location
        ..orientation = source.orientation
        ..length = source.length
        ..approximateWidth = source.approximateWidth
        ..openingMillimeters = source.openingMillimeters
        ..through = source.through
        ..active = source.active
        ..observation = source.observation;
    }
    return finding;
  }
}
