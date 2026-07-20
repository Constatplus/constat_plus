import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ijdacmvwjdyjdodaysjf.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_y-gjBWNqlBdTb8o16BR-ng_zP_90bkY',
  );

  static const String authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'https://constatplus.be/auth/callback',
  );

  static Future<void> initialize() async {
    if (url.trim().isEmpty || publishableKey.trim().isEmpty) {
      throw StateError(
        'La configuration Supabase est absente. Définissez SUPABASE_URL '
        'et SUPABASE_PUBLISHABLE_KEY.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}
