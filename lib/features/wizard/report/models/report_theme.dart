import '../../../settings/models/report_preferences.dart';

/// Shared visual configuration used by the live preview and every exporter.
///
/// Exporters must read their colors, font sizes and page geometry from this
/// object instead of defining their own constants.
class ReportTheme {
  const ReportTheme({
    required this.templateName,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.headingColorHex,
    required this.bodyColorHex,
    required this.fontFamily,
    required this.titleFontSize,
    required this.headingFontSize,
    required this.bodyFontSize,
    required this.pageMarginMm,
    required this.showLogo,
    required this.showPageNumbers,
    required this.footerText,
  });

  final String templateName;
  final String primaryColorHex;
  final String secondaryColorHex;
  final String headingColorHex;
  final String bodyColorHex;
  final String fontFamily;
  final double titleFontSize;
  final double headingFontSize;
  final double bodyFontSize;
  final double pageMarginMm;
  final bool showLogo;
  final bool showPageNumbers;
  final String footerText;

  factory ReportTheme.fromPreferences(ReportPreferences preferences) {
    return ReportTheme(
      templateName: preferences.templateName,
      primaryColorHex: _normalizeHex(preferences.primaryColorHex),
      secondaryColorHex: _normalizeHex(preferences.secondaryColorHex),
      headingColorHex: _normalizeHex(preferences.headingColorHex),
      bodyColorHex: _normalizeHex(preferences.bodyColorHex),
      fontFamily: preferences.fontFamily.trim().isEmpty
          ? 'Arial'
          : preferences.fontFamily.trim(),
      titleFontSize: preferences.titleFontSize.clamp(16, 40).toDouble(),
      headingFontSize: preferences.headingFontSize.clamp(11, 28).toDouble(),
      bodyFontSize: preferences.bodyFontSize.clamp(8, 18).toDouble(),
      pageMarginMm: preferences.pageMarginMm.clamp(8, 35).toDouble(),
      showLogo: preferences.showLogo,
      showPageNumbers: preferences.showPageNumbers,
      footerText: preferences.footerText.trim(),
    );
  }

  static String _normalizeHex(String value) {
    final normalized = value
        .trim()
        .replaceFirst('#', '')
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();

    if (normalized.length == 6) return normalized;
    if (normalized.length == 8) return normalized.substring(2);
    return '000000';
  }
}
