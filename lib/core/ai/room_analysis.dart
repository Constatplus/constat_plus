class RoomAnalysis {
  final int schemaVersion;
  final String roomName;
  final String roomType;
  final Map<String, SectionAnalysis> sections;
  final KitchenAnalysis kitchen;
  final List<String> warnings;

  const RoomAnalysis({
    required this.schemaVersion,
    required this.roomName,
    required this.roomType,
    required this.sections,
    required this.kitchen,
    required this.warnings,
  });

  factory RoomAnalysis.empty({
    required String roomName,
    required String roomType,
  }) {
    return RoomAnalysis(
      schemaVersion: 1,
      roomName: roomName,
      roomType: roomType,
      sections: const <String, SectionAnalysis>{},
      kitchen: const KitchenAnalysis.empty(),
      warnings: const <String>[],
    );
  }

  factory RoomAnalysis.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final sections = <String, SectionAnalysis>{};

    if (rawSections is Map) {
      for (final entry in rawSections.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          sections[entry.key.toString()] = SectionAnalysis.fromJson(value);
        } else if (value is Map) {
          sections[entry.key.toString()] = SectionAnalysis.fromJson(
            value.map(
              (key, item) => MapEntry(key.toString(), item),
            ),
          );
        } else if (value != null) {
          sections[entry.key.toString()] = SectionAnalysis(
            description: value.toString(),
            confidence: 0,
            detectedItems: const <DetectedItem>[],
            defects: const <DetectedDefect>[],
          );
        }
      }
    }

    final rawKitchen = json['kitchen'];

    return RoomAnalysis(
      schemaVersion: _asInt(json['schemaVersion'], fallback: 1),
      roomName: _asString(json['roomName']),
      roomType: _asString(json['roomType']),
      sections: sections,
      kitchen: rawKitchen is Map
          ? KitchenAnalysis.fromJson(
              rawKitchen.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : const KitchenAnalysis.empty(),
      warnings: _asStringList(json['warnings']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'roomName': roomName,
      'roomType': roomType,
      'sections': sections.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'kitchen': kitchen.toJson(),
      'warnings': warnings,
    };
  }

  SectionAnalysis section(String name) {
    return sections[name] ?? const SectionAnalysis.empty();
  }
}

class SectionAnalysis {
  final String description;
  final int confidence;
  final List<DetectedItem> detectedItems;
  final List<DetectedDefect> defects;

  const SectionAnalysis({
    required this.description,
    required this.confidence,
    required this.detectedItems,
    required this.defects,
  });

  const SectionAnalysis.empty()
      : description = '',
        confidence = 0,
        detectedItems = const <DetectedItem>[],
        defects = const <DetectedDefect>[];

  factory SectionAnalysis.fromJson(Map<String, dynamic> json) {
    return SectionAnalysis(
      description: _asString(json['description']),
      confidence: _clampConfidence(json['confidence']),
      detectedItems: _mapList(
        json['detectedItems'],
        DetectedItem.fromJson,
      ),
      defects: _mapList(
        json['defects'],
        DetectedDefect.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'description': description,
      'confidence': confidence,
      'detectedItems': detectedItems.map((item) => item.toJson()).toList(),
      'defects': defects.map((item) => item.toJson()).toList(),
    };
  }
}

class DetectedItem {
  final String type;
  final String material;
  final String color;
  final int quantity;
  final String position;
  final String description;
  final int confidence;

  const DetectedItem({
    required this.type,
    required this.material,
    required this.color,
    required this.quantity,
    required this.position,
    required this.description,
    required this.confidence,
  });

  factory DetectedItem.fromJson(Map<String, dynamic> json) {
    return DetectedItem(
      type: _asString(json['type']),
      material: _asString(json['material']),
      color: _asString(json['color']),
      quantity: _asInt(json['quantity']),
      position: _asString(json['position']),
      description: _asString(json['description']),
      confidence: _clampConfidence(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'material': material,
      'color': color,
      'quantity': quantity,
      'position': position,
      'description': description,
      'confidence': confidence,
    };
  }
}

class DetectedDefect {
  final String type;
  final String location;
  final String size;
  final String description;
  final int confidence;

  const DetectedDefect({
    required this.type,
    required this.location,
    required this.size,
    required this.description,
    required this.confidence,
  });

  factory DetectedDefect.fromJson(Map<String, dynamic> json) {
    return DetectedDefect(
      type: _asString(json['type']),
      location: _asString(json['location']),
      size: _asString(json['size']),
      description: _asString(json['description']),
      confidence: _clampConfidence(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'location': location,
      'size': size,
      'description': description,
      'confidence': confidence,
    };
  }
}

class KitchenAnalysis {
  final bool detected;
  final int confidence;
  final String generalDescription;
  final String worktopDescription;
  final List<KitchenEquipmentAnalysis> worktopEquipment;
  final List<KitchenUnitAnalysis> upperUnits;
  final List<KitchenUnitAnalysis> lowerUnits;

  const KitchenAnalysis({
    required this.detected,
    required this.confidence,
    required this.generalDescription,
    required this.worktopDescription,
    required this.worktopEquipment,
    required this.upperUnits,
    required this.lowerUnits,
  });

  const KitchenAnalysis.empty()
      : detected = false,
        confidence = 0,
        generalDescription = '',
        worktopDescription = '',
        worktopEquipment = const <KitchenEquipmentAnalysis>[],
        upperUnits = const <KitchenUnitAnalysis>[],
        lowerUnits = const <KitchenUnitAnalysis>[];

  factory KitchenAnalysis.fromJson(Map<String, dynamic> json) {
    return KitchenAnalysis(
      detected: _asBool(json['detected']),
      confidence: _clampConfidence(json['confidence']),
      generalDescription: _asString(json['generalDescription']),
      worktopDescription: _asString(json['worktopDescription']),
      worktopEquipment: _mapList(
        json['worktopEquipment'],
        KitchenEquipmentAnalysis.fromJson,
      ),
      upperUnits: _mapList(
        json['upperUnits'],
        KitchenUnitAnalysis.fromJson,
      ),
      lowerUnits: _mapList(
        json['lowerUnits'],
        KitchenUnitAnalysis.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'detected': detected,
      'confidence': confidence,
      'generalDescription': generalDescription,
      'worktopDescription': worktopDescription,
      'worktopEquipment': worktopEquipment
          .map((equipment) => equipment.toJson())
          .toList(),
      'upperUnits': upperUnits.map((unit) => unit.toJson()).toList(),
      'lowerUnits': lowerUnits.map((unit) => unit.toJson()).toList(),
    };
  }
}

class KitchenEquipmentAnalysis {
  final String type;
  final String description;
  final int confidence;

  const KitchenEquipmentAnalysis({
    required this.type,
    required this.description,
    required this.confidence,
  });

  factory KitchenEquipmentAnalysis.fromJson(Map<String, dynamic> json) {
    return KitchenEquipmentAnalysis(
      type: _asString(json['type']),
      description: _asString(json['description']),
      confidence: _clampConfidence(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'description': description,
      'confidence': confidence,
    };
  }
}

class KitchenUnitAnalysis {
  final String type;
  final String comment;
  final int confidence;

  const KitchenUnitAnalysis({
    required this.type,
    required this.comment,
    required this.confidence,
  });

  factory KitchenUnitAnalysis.fromJson(Map<String, dynamic> json) {
    return KitchenUnitAnalysis(
      type: _asString(json['type'], fallback: 'Autre'),
      comment: _asString(json['comment']),
      confidence: _clampConfidence(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'comment': comment,
      'confidence': confidence,
    };
  }
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

int _clampConfidence(dynamic value) {
  final confidence = _asInt(value);
  if (confidence < 0) return 0;
  if (confidence > 100) return 100;
  return confidence;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<T> _mapList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) converter,
) {
  if (value is! List) return <T>[];

  return value.whereType<Map>().map((item) {
    return converter(
      item.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }).toList(growable: false);
}
