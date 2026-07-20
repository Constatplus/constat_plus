import 'package:flutter_app/features/wizard/before_works/models/technical_finding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un constat de fissure conserve ses données techniques', () {
    final finding = TechnicalFinding(id: 'finding-1')
      ..zone = 'Façade avant'
      ..post = 'Murs'
      ..classification = FindingClassification.existingDisorder
      ..disorderType = TechnicalDisorderType.crack
      ..description = 'Fissure verticale sous la baie';
    finding.crack
      ..location = 'Sous le seuil'
      ..orientation = 'Verticale'
      ..length = '85 cm'
      ..openingMillimeters = '1.2'
      ..through = false
      ..active = null;

    final restored = TechnicalFinding.fromJson(finding.toJson());

    expect(restored.zone, 'Façade avant');
    expect(restored.classification, FindingClassification.existingDisorder);
    expect(restored.disorderType.isCrack, isTrue);
    expect(restored.crack.openingMillimeters, '1.2');
    expect(restored.crack.through, isFalse);
    expect(restored.crack.active, isNull);
  });
}
