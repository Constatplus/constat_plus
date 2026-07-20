import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/auth/supabase_config.dart';
import 'features/commercial/infrastructure/payments/google_play_payment_provider.dart';
import 'features/commercial/infrastructure/payments/apple_payment_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;
  try {
    await SupabaseConfig.initialize();
    GooglePlayPaymentProvider.instance.initialize();
    ApplePaymentProvider.instance.initialize();
  } catch (error) {
    startupError = error;
  }

  runApp(ProjectGeoApp(startupError: startupError));
}
