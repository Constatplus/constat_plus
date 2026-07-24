import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Identité Constat+
  static const Color primary = Color(0xFF0F4C81);
  static const Color primaryLight = Color(0xFF2E6FA6);
  static const Color primaryDark = Color(0xFF0B365B);
  static const Color onPrimary = Colors.white;

  // Fonds
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF2F4F7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Texte
  static const Color textPrimary = Color(0xFF1D2939);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textDisabled = Color(0xFF98A2B3);
  static const Color textOnDark = Colors.white;

  // États
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Bordures et séparateurs
  static const Color border = Color(0xFFD0D5DD);
  static const Color borderSubtle = Color(0xFFE4E7EC);
  static const Color divider = Color(0xFFE4E7EC);

  // États d'interaction
  static const Color selected = Color(0xFFE8F1F8);
  static const Color hover = Color(0xFFF0F5F9);
  static const Color focus = Color(0xFF84ADCF);

  // Divers
  static const Color shadow = Color(0x14000000);
  static const Color scrim = Color(0x66000000);
}
