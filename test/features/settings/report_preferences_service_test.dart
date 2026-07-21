import 'package:flutter_app/features/settings/models/report_preferences.dart';
import 'package:flutter_app/features/settings/services/report_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('conserve les notes liminaires du récolement après travaux', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = ReportPreferencesService();
    final preferences = ReportPreferences.defaults().copyWith(
      afterWorksPreliminaryNotes: 'Notes personnalisées du récolement.',
    );

    await service.save(preferences);
    final restored = await service.load();

    expect(
      restored.afterWorksPreliminaryNotes,
      'Notes personnalisées du récolement.',
    );
  });

  test(
    'utilise les notes de récolement par défaut si elles sont absentes',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final restored = await ReportPreferencesService().load();

      expect(
        restored.afterWorksPreliminaryNotes,
        ReportPreferences.defaultAfterWorksNotes,
      );
    },
  );
}
