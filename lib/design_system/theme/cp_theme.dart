import 'package:flutter/material.dart';

import 'cp_colors.dart';
import 'cp_radius.dart';

abstract final class CPTheme {
  const CPTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CPColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CPColors.primary,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: CPColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: CPRadius.radiusLg,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: CPRadius.radiusMd,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CPColors.surface,
        border: OutlineInputBorder(
          borderRadius: CPRadius.radiusMd,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CPRadius.radiusMd,
          borderSide: const BorderSide(color: CPColors.border),
        ),
      ),
    );
  }
}