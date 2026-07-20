import 'package:flutter/material.dart';

enum MissionType { entry, exit, beforeWorks, afterWorks }

extension MissionTypeX on MissionType {
  String get databaseValue => switch (this) {
    MissionType.entry => 'entry',
    MissionType.exit => 'exit',
    MissionType.beforeWorks => 'before_works',
    MissionType.afterWorks => 'after_works',
  };

  String get label => switch (this) {
    MissionType.entry => "État des lieux d'entrée",
    MissionType.exit => 'État des lieux de sortie',
    MissionType.beforeWorks => 'État des lieux avant travaux',
    MissionType.afterWorks => 'Récolement après travaux',
  };

  String get shortLabel => switch (this) {
    MissionType.entry => 'Entrée',
    MissionType.exit => 'Sortie',
    MissionType.beforeWorks => 'Avant travaux',
    MissionType.afterWorks => 'Récolement',
  };

  IconData get icon => switch (this) {
    MissionType.entry => Icons.login_rounded,
    MissionType.exit => Icons.logout_rounded,
    MissionType.beforeWorks => Icons.construction_rounded,
    MissionType.afterWorks => Icons.fact_check_outlined,
  };
}
