import 'package:flutter/material.dart';

import '../models/mission.dart';

class AppState extends ChangeNotifier {
  final List<MissionData> _missions = [];
  bool assistantEnabled = true;
  bool autoSaveEnabled = true;
  String professionalSignature = 'Géomètre-Expert GEO20/1523';

  List<MissionData> get missions {
    final copy = [..._missions];
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(copy);
  }

  MissionData createMission(MissionKind kind) {
    final now = DateTime.now();
    final mission =
        MissionData(
            id: now.microsecondsSinceEpoch.toString(),
            kind: kind,
            createdAt: now,
          )
          ..title = kind.label
          ..rooms.addAll(_defaultRooms(kind));
    _missions.add(mission);
    notifyListeners();
    return mission;
  }

  void touch(MissionData mission) {
    mission.updatedAt = DateTime.now();
    if (mission.status == MissionStatus.draft && mission.progress > 15) {
      mission.status = MissionStatus.inProgress;
    }
    notifyListeners();
  }

  void complete(MissionData mission) {
    mission.status = MissionStatus.completed;
    mission.updatedAt = DateTime.now();
    notifyListeners();
  }

  void deleteMission(MissionData mission) {
    _missions.removeWhere((item) => item.id == mission.id);
    notifyListeners();
  }

  void updateSettings({bool? assistant, bool? autoSave, String? signature}) {
    if (assistant != null) assistantEnabled = assistant;
    if (autoSave != null) autoSaveEnabled = autoSave;
    if (signature != null) professionalSignature = signature;
    notifyListeners();
  }

  List<RoomData> _defaultRooms(MissionKind kind) {
    if (kind == MissionKind.beforeWorks) {
      return [
        RoomData(name: 'Façades et abords'),
        RoomData(name: 'Zone de travaux'),
      ];
    }
    return [
      RoomData(name: 'Hall d’entrée'),
      RoomData(name: 'Séjour'),
      RoomData(name: 'Cuisine'),
      RoomData(name: 'Salle de bain'),
      RoomData(name: 'Chambre 1'),
    ];
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({required AppState state, required super.child, super.key})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope introuvable');
    return scope!.notifier!;
  }
}
