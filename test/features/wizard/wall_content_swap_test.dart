import 'package:flutter_app/features/wizard/visit/services/wall_content_swap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('échange les contenus de deux murs sans changer leurs clés', () {
    final descriptions = <String, String>{
      'mur-avant': 'Description avant',
      'mur-droit': 'Description droite',
    };

    swapMapEntries(descriptions, 'mur-avant', 'mur-droit');

    expect(descriptions['mur-avant'], 'Description droite');
    expect(descriptions['mur-droit'], 'Description avant');
  });

  test('déplace le contenu lorsque le second mur est vide', () {
    final photos = <String, List<String>>{
      'mur-avant': <String>['photo-1.jpg'],
    };

    swapMapEntries(photos, 'mur-avant', 'mur-droit');

    expect(photos.containsKey('mur-avant'), isFalse);
    expect(photos['mur-droit'], <String>['photo-1.jpg']);
  });

  test('ne modifie rien lorsque les deux clés sont identiques', () {
    final values = <String, int>{'mur-avant': 2};

    swapMapEntries(values, 'mur-avant', 'mur-avant');

    expect(values, <String, int>{'mur-avant': 2});
  });
}
