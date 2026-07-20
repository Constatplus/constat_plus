enum ComparisonStatus {
  unchanged,
  newDisorder,
  worsened,
  improved,
  repaired,
  disappearedOrReplaced,
  notCheckable,
  additionalObservation,
}

extension ComparisonStatusLabel on ComparisonStatus {
  String get label => switch (this) {
    ComparisonStatus.unchanged => 'Aucun changement',
    ComparisonStatus.newDisorder => 'Nouveau désordre',
    ComparisonStatus.worsened => 'Aggravation d’un désordre existant',
    ComparisonStatus.improved => 'Amélioration',
    ComparisonStatus.repaired => 'Réparation constatée',
    ComparisonStatus.disappearedOrReplaced => 'Élément disparu ou remplacé',
    ComparisonStatus.notCheckable => 'Non contrôlable',
    ComparisonStatus.additionalObservation => 'Observation complémentaire',
  };
}

enum TechnicalConclusion {
  noApparentChange,
  undeterminedLink,
  likelyLink,
  noApparentLink,
  additionalExpertise,
  repairRecommended,
  monitoringRecommended,
}

extension TechnicalConclusionLabel on TechnicalConclusion {
  String get label => switch (this) {
    TechnicalConclusion.noApparentChange => 'Sans modification apparente',
    TechnicalConclusion.undeterminedLink =>
      'Lien avec les travaux non déterminé',
    TechnicalConclusion.likelyLink => 'Lien vraisemblable avec les travaux',
    TechnicalConclusion.noApparentLink =>
      'Absence de lien apparent avec les travaux',
    TechnicalConclusion.additionalExpertise =>
      'Expertise complémentaire recommandée',
    TechnicalConclusion.repairRecommended => 'Remise en état recommandée',
    TechnicalConclusion.monitoringRecommended => 'Surveillance recommandée',
  };
}

class ComparisonRemark {
  ComparisonRemark({required this.id});

  final String id;
  String zone = '';
  String post = '';
  String referenceFindingId = '';
  ComparisonStatus status = ComparisonStatus.unchanged;
  String afterDescription = '';
  TechnicalConclusion conclusion = TechnicalConclusion.noApparentChange;
  String recommendation = '';
  final List<String> afterPhotoPaths = <String>[];
}
