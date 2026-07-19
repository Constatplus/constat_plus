import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/app.dart';

void main() {
  testWidgets('Constat+ démarre', (tester) async {
    await tester.pumpWidget(const ProjectGeoApp());
    expect(find.text('Constat+'), findsOneWidget);
  });
}
