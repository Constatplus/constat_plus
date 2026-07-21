import 'package:flutter_app/features/wizard/comparison/models/comparison_remark.dart';
import 'package:flutter_app/features/wizard/exit/models/exit_damage_line.dart';
import 'package:flutter_app/features/wizard/exit/services/exit_damage_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crée une ligne complète pour chaque remarque retenue', () {
    final remark = ComparisonRemark(id: 'remark-1')
      ..zone = 'Cuisine'
      ..post = 'Mur avant'
      ..afterDescription = 'Impact près de la porte.'
      ..afterPhotoPaths.add('impact.jpg');
    final lines = <ExitDamageLine>[];

    ExitDamageSync.synchronize(
      remarks: <ComparisonRemark>[remark],
      lines: lines,
      dismissedSourceIds: <String>{},
    );

    expect(lines, hasLength(1));
    expect(lines.single.room, 'Cuisine');
    expect(lines.single.element, 'Mur avant');
    expect(lines.single.remark, 'Impact près de la porte.');
    expect(lines.single.photoPaths, <String>['impact.jpg']);
  });

  test('évite les doublons et conserve les valeurs complétées', () {
    final remark = ComparisonRemark(id: 'remark-1')
      ..zone = 'Cuisine'
      ..post = 'Mur avant'
      ..afterDescription = 'Impact initial.';
    final lines = <ExitDamageLine>[];
    ExitDamageSync.synchronize(
      remarks: <ComparisonRemark>[remark],
      lines: lines,
      dismissedSourceIds: <String>{},
    );
    final line = lines.single
      ..remark = 'Formulation adaptée par l’expert.'
      ..unitPrice = 120
      ..labor = 30
      ..depreciationPercent = 25
      ..vatPercent = 6;
    remark.afterDescription = 'Impact source actualisé.';

    ExitDamageSync.synchronize(
      remarks: <ComparisonRemark>[remark],
      lines: lines,
      dismissedSourceIds: <String>{},
    );

    expect(lines, hasLength(1));
    expect(line.remark, 'Formulation adaptée par l’expert.');
    expect(line.unitPrice, 120);
    expect(line.labor, 30);
    expect(line.depreciationPercent, 25);
    expect(line.vatPercent, 6);
  });

  test('ne recrée pas une ligne supprimée volontairement', () {
    final remark = ComparisonRemark(id: 'remark-1')
      ..afterDescription = 'Remarque retenue.';
    final lines = <ExitDamageLine>[];

    ExitDamageSync.synchronize(
      remarks: <ComparisonRemark>[remark],
      lines: lines,
      dismissedSourceIds: <String>{'remark-1'},
    );

    expect(lines, isEmpty);
  });
}
