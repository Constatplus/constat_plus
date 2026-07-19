import 'package:flutter/material.dart';

class RepresentativeEntry {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  String quality = 'Représentant';
  String represents = 'Bailleur';

  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
  }
}

class KeyEntryData {
  String name;
  int quantity;
  String observation;

  KeyEntryData({
    required this.name,
    this.quantity = 1,
    this.observation = '',
  });

  String get reportLine {
    final note = observation.trim();
    return '${quantity}x $name${note.isEmpty ? '' : ' - $note'}';
  }
}

class MaintenanceEntryData {
  String name;
  bool selected;
  DateTime? date;
  String company;
  String observation;

  MaintenanceEntryData(
    this.name, {
    this.selected = false,
    this.date,
    this.company = '',
    this.observation = '',
  });

  String get reportLine {
    final parts = <String>[name];
    if (date != null) {
      parts.add(
        '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
      );
    }
    if (company.trim().isNotEmpty) parts.add(company.trim());
    if (observation.trim().isNotEmpty) parts.add(observation.trim());
    return parts.join(' - ');
  }
}

class DocumentEntryData {
  String name;
  bool selected;
  String observation;

  DocumentEntryData(
    this.name, {
    this.selected = false,
    this.observation = '',
  });

  String get reportLine {
    final note = observation.trim();
    return '$name${note.isEmpty ? '' : ' - $note'}';
  }
}

class WizardData {
  final street = TextEditingController();
  final number = TextEditingController();
  final box = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();

  final ownerName = TextEditingController();
  final ownerPhone = TextEditingController();
  final ownerEmail = TextEditingController();
  final tenantName = TextEditingController();
  final tenantPhone = TextEditingController();
  final tenantEmail = TextEditingController();
  final missionTime = TextEditingController();

  DateTime missionDate = DateTime.now();
  bool ownerPresent = true;
  bool tenantPresent = true;
  bool expertPresent = true;
  bool agentPresent = false;
  String expertQuality = 'Géomètre-Expert';

  final representatives = <RepresentativeEntry>[];
  final keys = <KeyEntryData>[];
  final maintenance = <MaintenanceEntryData>[];
  final documents = <DocumentEntryData>[];

  String get formattedDate =>
      '${missionDate.day.toString().padLeft(2, '0')}/${missionDate.month.toString().padLeft(2, '0')}/${missionDate.year}';

  String get propertyAddress {
    final firstLine = [street.text.trim(), number.text.trim()]
        .where((value) => value.isNotEmpty)
        .join(' ');
    final boxValue = box.text.trim();
    final secondLine = [postalCode.text.trim(), city.text.trim()]
        .where((value) => value.isNotEmpty)
        .join(' ');
    return [
      if (firstLine.isNotEmpty) '$firstLine${boxValue.isEmpty ? '' : ' bte $boxValue'}',
      if (secondLine.isNotEmpty) secondLine,
    ].join(' - ');
  }

  void dispose() {
    for (final controller in <TextEditingController>[
      street,
      number,
      box,
      postalCode,
      city,
      ownerName,
      ownerPhone,
      ownerEmail,
      tenantName,
      tenantPhone,
      tenantEmail,
      missionTime,
    ]) {
      controller.dispose();
    }
    for (final representative in representatives) {
      representative.dispose();
    }
  }
}
