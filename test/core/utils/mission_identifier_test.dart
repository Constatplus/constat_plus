import 'package:flutter_app/core/utils/mission_identifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates distinct RFC 4122 version 4 identifiers', () {
    final first = createMissionIdentifier();
    final second = createMissionIdentifier();
    final uuidV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(first, matches(uuidV4));
    expect(second, matches(uuidV4));
    expect(second, isNot(first));
  });
}
