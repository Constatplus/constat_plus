import 'package:shared_preferences/shared_preferences.dart';

import '../models/report_preferences.dart';
import '../models/subscription_plan.dart';

class ReportPreferencesService {
  static const _prefix = 'report_settings_';

  Future<ReportPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = ReportPreferences.defaults();

    final planName = prefs.getString('${_prefix}plan');
    final plan = SubscriptionPlan.values.firstWhere(
      (value) => value.name == planName,
      orElse: () => defaults.plan,
    );

    final storedOrder =
        prefs.getStringList('${_prefix}section_order') ?? const [];
    final disabled =
        (prefs.getStringList('${_prefix}disabled_sections') ?? const [])
            .toSet();
    final byId = {for (final section in defaults.sections) section.id: section};
    final ordered = <ReportSectionPreference>[];

    for (final id in storedOrder) {
      final section = byId.remove(id);
      if (section != null) {
        ordered.add(section.copyWith(enabled: !disabled.contains(id)));
      }
    }
    for (final section in byId.values) {
      ordered.add(section.copyWith(enabled: !disabled.contains(section.id)));
    }

    double readDouble(String key, double fallback) {
      return prefs.getDouble('$_prefix$key') ?? fallback;
    }

    String readString(String key, String fallback) {
      return prefs.getString('$_prefix$key') ?? fallback;
    }

    bool readBool(String key, bool fallback) {
      return prefs.getBool('$_prefix$key') ?? fallback;
    }

    return ReportPreferences(
      plan: plan,
      templateName: readString('template_name', defaults.templateName),
      logoPath: readString('logo_path', defaults.logoPath),
      companyName: readString('company_name', defaults.companyName),
      companyAddress: readString('company_address', defaults.companyAddress),
      companyPhone: readString('company_phone', defaults.companyPhone),
      companyEmail: readString('company_email', defaults.companyEmail),
      companyWebsite: readString('company_website', defaults.companyWebsite),
      professionalNumber: readString(
        'professional_number',
        defaults.professionalNumber,
      ),
      vatNumber: readString('vat_number', defaults.vatNumber),
      footerText: readString('footer_text', defaults.footerText),
      entryPreliminaryNotes: readString(
        'entry_notes',
        defaults.entryPreliminaryNotes,
      ),
      exitPreliminaryNotes: readString(
        'exit_notes',
        defaults.exitPreliminaryNotes,
      ),
      beforeWorksPreliminaryNotes: readString(
        'before_works_notes',
        defaults.beforeWorksPreliminaryNotes,
      ),
      afterWorksPreliminaryNotes: readString(
        'after_works_notes',
        defaults.afterWorksPreliminaryNotes,
      ),
      sections: ordered,
      primaryColorHex: readString('primary_color', defaults.primaryColorHex),
      secondaryColorHex: readString(
        'secondary_color',
        defaults.secondaryColorHex,
      ),
      headingColorHex: readString('heading_color', defaults.headingColorHex),
      bodyColorHex: readString('body_color', defaults.bodyColorHex),
      fontFamily: readString('font_family', defaults.fontFamily),
      titleFontSize: readDouble('title_font_size', defaults.titleFontSize),
      headingFontSize: readDouble(
        'heading_font_size',
        defaults.headingFontSize,
      ),
      bodyFontSize: readDouble('body_font_size', defaults.bodyFontSize),
      pageMarginMm: readDouble('page_margin_mm', defaults.pageMarginMm),
      showLogo: readBool('show_logo', defaults.showLogo),
      showPageNumbers: readBool('show_page_numbers', defaults.showPageNumbers),
    );
  }

  Future<void> save(ReportPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}plan', value.plan.name);
    await prefs.setString('${_prefix}template_name', value.templateName);
    await prefs.setString('${_prefix}logo_path', value.logoPath);
    await prefs.setString('${_prefix}company_name', value.companyName);
    await prefs.setString('${_prefix}company_address', value.companyAddress);
    await prefs.setString('${_prefix}company_phone', value.companyPhone);
    await prefs.setString('${_prefix}company_email', value.companyEmail);
    await prefs.setString('${_prefix}company_website', value.companyWebsite);
    await prefs.setString(
      '${_prefix}professional_number',
      value.professionalNumber,
    );
    await prefs.setString('${_prefix}vat_number', value.vatNumber);
    await prefs.setString('${_prefix}footer_text', value.footerText);
    await prefs.setString('${_prefix}entry_notes', value.entryPreliminaryNotes);
    await prefs.setString('${_prefix}exit_notes', value.exitPreliminaryNotes);
    await prefs.setString(
      '${_prefix}before_works_notes',
      value.beforeWorksPreliminaryNotes,
    );
    await prefs.setString(
      '${_prefix}after_works_notes',
      value.afterWorksPreliminaryNotes,
    );
    await prefs.setString('${_prefix}primary_color', value.primaryColorHex);
    await prefs.setString('${_prefix}secondary_color', value.secondaryColorHex);
    await prefs.setString('${_prefix}heading_color', value.headingColorHex);
    await prefs.setString('${_prefix}body_color', value.bodyColorHex);
    await prefs.setString('${_prefix}font_family', value.fontFamily);
    await prefs.setDouble('${_prefix}title_font_size', value.titleFontSize);
    await prefs.setDouble('${_prefix}heading_font_size', value.headingFontSize);
    await prefs.setDouble('${_prefix}body_font_size', value.bodyFontSize);
    await prefs.setDouble('${_prefix}page_margin_mm', value.pageMarginMm);
    await prefs.setBool('${_prefix}show_logo', value.showLogo);
    await prefs.setBool('${_prefix}show_page_numbers', value.showPageNumbers);
    await prefs.setStringList(
      '${_prefix}section_order',
      value.sections.map((section) => section.id).toList(),
    );
    await prefs.setStringList(
      '${_prefix}disabled_sections',
      value.sections
          .where((section) => !section.enabled)
          .map((section) => section.id)
          .toList(),
    );
  }
}
