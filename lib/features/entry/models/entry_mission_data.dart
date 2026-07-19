import 'room_inspection.dart';

class EntryMissionData {
  String propertyAddress = '';
  String propertyType = 'Appartement';
  String landlordName = '';
  String tenantName = '';
  DateTime visitDate = DateTime.now();
  final List<String> rooms = <String>[
    'Hall d’entrée',
    'Séjour',
    'Cuisine',
    'Chambre',
    'Salle de bain',
    'WC',
  ];
  final Map<String, String> roomNotes = <String, String>{};
  final Map<String, RoomInspection> roomInspections = <String, RoomInspection>{};
  String generalNotes = '';
}
