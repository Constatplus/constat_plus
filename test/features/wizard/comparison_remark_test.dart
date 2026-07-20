import 'package:flutter_app/features/wizard/comparison/models/comparison_remark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tous les statuts et conclusions ont un libellé', () {
    for (final status in ComparisonStatus.values) {
      expect(status.label, isNotEmpty);
    }
    for (final conclusion in TechnicalConclusion.values) {
      expect(conclusion.label, isNotEmpty);
    }
  });

  test('une remarque de récolement ne contient aucun montant', () {
    final remark = ComparisonRemark(id: 'remark-1')
      ..zone = 'Pignon voisin'
      ..status = ComparisonStatus.worsened
      ..conclusion = TechnicalConclusion.likelyLink;

    expect(remark.zone, 'Pignon voisin');
    expect(remark.status.label, contains('Aggravation'));
  });
}
