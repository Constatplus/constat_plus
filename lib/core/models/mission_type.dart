import 'package:flutter/material.dart';

enum MissionType { entry, exit, beforeWorks }

extension MissionTypeX on MissionType {
  String get label => switch (this) {
        MissionType.entry => "État des lieux d'entrée",
        MissionType.exit => 'État des lieux de sortie',
        MissionType.beforeWorks => 'État des lieux avant travaux',
      };

  String get shortLabel => switch (this) {
        MissionType.entry => 'Entrée',
        MissionType.exit => 'Sortie',
        MissionType.beforeWorks => 'Avant travaux',
      };

  IconData get icon => switch (this) {
        MissionType.entry => Icons.login_rounded,
        MissionType.exit => Icons.logout_rounded,
        MissionType.beforeWorks => Icons.construction_rounded,
      };
}
