import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(const {});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'sb_publishable_test_key',
    );
  });

  testWidgets('Constat+ démarre', (tester) async {
    await tester.pumpWidget(const ProjectGeoApp());
    await tester.pump();
    expect(find.text('Constat+'), findsOneWidget);
  });
}
