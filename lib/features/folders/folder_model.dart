enum MissionType { entry, exit, beforeWorks }

class FolderModel {
  const FolderModel({
    required this.id,
    required this.title,
    required this.address,
    required this.client,
    required this.missionType,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String address;
  final String client;
  final MissionType missionType;
  final DateTime createdAt;

  String get missionLabel {
    switch (missionType) {
      case MissionType.entry:
        return 'Entrée';
      case MissionType.exit:
        return 'Sortie';
      case MissionType.beforeWorks:
        return 'Avant travaux';
    }
  }
}
