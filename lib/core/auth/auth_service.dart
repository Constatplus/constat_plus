import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? company,
    String? phone,
    String? profession,
  }) {
    return client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: SupabaseConfig.authRedirectUrl,
      data: <String, dynamic>{
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'company': company?.trim() ?? '',
        'phone': phone?.trim() ?? '',
        'profession': profession?.trim() ?? '',
      },
    );
  }

  static Future<void> sendPasswordReset(String email) {
    return client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: SupabaseConfig.authRedirectUrl,
    );
  }

  static Future<void> resendConfirmation(String email) async {
    await client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
      emailRedirectTo: SupabaseConfig.authRedirectUrl,
    );
  }

  static Future<void> signOut() => client.auth.signOut();
}
