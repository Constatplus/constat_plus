import 'dart:typed_data';

enum MissionKind { entry, exit, beforeWorks }

enum MissionStatus { draft, inProgress, completed }

class PlanPoint {
  const PlanPoint(this.dx, this.dy);

  final double dx;
  final double dy;
}

class PlanStroke {
  PlanStroke({
    required this.points,
    required this.colorValue,
    required this.width,
  });

  final List<PlanPoint> points;
  final int colorValue;
  final double width;
}

extension MissionKindX on MissionKind {
  String get label => switch (this) {
        MissionKind.entry => 'État des lieux d’entrée',
        MissionKind.exit => 'État des lieux de sortie',
        MissionKind.beforeWorks => 'Constat avant travaux',
      };

  String get shortLabel => switch (this) {
        MissionKind.entry => 'Entrée',
        MissionKind.exit => 'Sortie',
        MissionKind.beforeWorks => 'Avant travaux',
      };
}

extension MissionStatusX on MissionStatus {
  String get label => switch (this) {
        MissionStatus.draft => 'Brouillon',
        MissionStatus.inProgress => 'En cours',
        MissionStatus.completed => 'Terminé',
      };
}

class PartyData {
  PartyData({this.role = '', this.name = '', this.email = '', this.phone = ''});

  String role;
  String name;
  String email;
  String phone;
}

class MeterReading {
  MeterReading({required this.type, this.number = '', this.index = ''});

  String type;
  String number;
  String index;
}

class KeyItem {
  KeyItem({this.label = 'Clé', this.quantity = 1});

  String label;
  int quantity;
}

class DamageItem {
  DamageItem({
    this.room = '',
    this.description = '',
    this.work = '',
    this.amountExVat = 0,
    this.vatRate = 0.21,
    this.depreciation = 1,
  });

  String room;
  String description;
  String work;
  double amountExVat;
  double vatRate;
  double depreciation;

  double get totalExVat => amountExVat * depreciation;
  double get totalIncVat => totalExVat * (1 + vatRate);
}

class RoomPhoto {
  RoomPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
  String note = '';
}

class RoomData {
  RoomData({required this.name, this.isRoad = false});

  String name;
  bool isRoad;
  String floor = '';
  String ceiling = '';
  String walls = '';
  String woodwork = '';
  String electricity = '';
  String heating = '';
  String furniture = '';
  String sanitary = '';
  String observations = '';
  final List<RoomPhoto> photos = [];

  int get completion {
    final fields = [floor, ceiling, walls, woodwork, electricity, heating, furniture, sanitary, observations];
    final filled = fields.where((value) => value.trim().isNotEmpty).length;
    return ((filled / fields.length) * 100).round();
  }
}

class MissionData {
  MissionData({required this.id, required this.kind, required this.createdAt});

  final String id;
  final MissionKind kind;
  final DateTime createdAt;
  DateTime updatedAt = DateTime.now();
  MissionStatus status = MissionStatus.draft;

  String title = '';
  String address = '';
  String postalCode = '';
  String city = '';
  String client = '';
  String missionDescription = '';
  String conclusion = '';
  Uint8List? cadastralPlanBytes;
  String cadastralPlanName = '';
  String cadastralPlanNotes = '';
  final List<PlanStroke> cadastralPlanStrokes = [];
  DateTime missionDate = DateTime.now();
  String generalNotes = '';
  String legalNotes = '';
  String signatureExpert = '';
  String signatureParty = '';

  final List<PartyData> parties = [];
  final List<RoomData> rooms = [];
  final List<MeterReading> meters = [];
  final List<KeyItem> keys = [];
  final List<DamageItem> damages = [];

  String get displayTitle => title.trim().isNotEmpty
      ? title.trim()
      : address.trim().isNotEmpty
          ? address.trim()
          : kind.label;

  double get damagesTotal => damages.fold(0, (sum, item) => sum + item.totalIncVat);

  int get progress {
    var score = 0;
    var total = 6;
    if (address.trim().isNotEmpty) score++;
    if (client.trim().isNotEmpty) score++;
    if (parties.isNotEmpty && parties.any((p) => p.name.trim().isNotEmpty)) score++;
    if (rooms.isNotEmpty) score++;
    if (rooms.isNotEmpty && rooms.every((room) => room.completion >= 30)) score++;
    if (signatureExpert.trim().isNotEmpty || signatureParty.trim().isNotEmpty) score++;
    return ((score / total) * 100).round();
  }
}
