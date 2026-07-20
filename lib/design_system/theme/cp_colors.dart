import 'package:flutter/material.dart';

/// Palette officielle Constat+
///
/// Toutes les couleurs de l'application doivent provenir
/// exclusivement de cette classe.
abstract final class CPColors {
  // Couleur principale
  static const primary = Color(0xFF1264F6);
  static const primaryDark = Color(0xFF0B4BC4);
  static const primaryLight = Color(0xFFEAF2FF);

  // Couleurs d'état
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF0EA5E9);

  // Fond
  static const background = Color(0xFFF4F8FA);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF8FAFC);

  // Bordures
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFE5E7EB);

  // Texte
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);

  // Désactivé
  static const disabled = Color(0xFFCBD5E1);

  // États
  static const selected = primaryLight;
  static const hover = Color(0xFFF1F5F9);
}
