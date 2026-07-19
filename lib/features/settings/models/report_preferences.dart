import 'subscription_plan.dart';

class ReportSectionPreference {
  final String id;
  final String label;
  final bool enabled;

  const ReportSectionPreference({
    required this.id,
    required this.label,
    required this.enabled,
  });

  ReportSectionPreference copyWith({bool? enabled}) {
    return ReportSectionPreference(
      id: id,
      label: label,
      enabled: enabled ?? this.enabled,
    );
  }
}

class ReportPreferences {
  final SubscriptionPlan plan;
  final String templateName;
  final String logoPath;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String companyWebsite;
  final String professionalNumber;
  final String vatNumber;
  final String footerText;
  final String entryPreliminaryNotes;
  final String exitPreliminaryNotes;
  final String beforeWorksPreliminaryNotes;
  final List<ReportSectionPreference> sections;
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

  const ReportPreferences({
    required this.plan,
    required this.templateName,
    required this.logoPath,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.companyEmail,
    required this.companyWebsite,
    required this.professionalNumber,
    required this.vatNumber,
    required this.footerText,
    required this.entryPreliminaryNotes,
    required this.exitPreliminaryNotes,
    required this.beforeWorksPreliminaryNotes,
    required this.sections,
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
  });

  static const defaultEntryNotes =
      'Le présent état des lieux d’entrée est établi contradictoirement entre les parties. '
      'Les constatations sont limitées aux éléments visibles et accessibles au moment de la visite. '
      'Les éléments non décrits sont réputés en bon état d’usage, sous réserve des généralités sélectionnées.';

  static const defaultExitNotes =
      'Le présent état des lieux de sortie est établi contradictoirement et doit être lu en comparaison avec '
      'l’état des lieux d’entrée. Les différences relevant de l’usure normale, de la vétusté ou d’un défaut '
      'd’entretien sont appréciées séparément.';

  static const defaultBeforeWorksNotes =
      'Le présent constat avant travaux décrit l’état apparent et visible des lieux au jour de la visite. '
      'Il a pour objet de conserver la preuve des désordres préexistants avant le commencement des travaux.';

  factory ReportPreferences.defaults() {
    return const ReportPreferences(
      plan: SubscriptionPlan.solo,
      templateName: 'Modèle Gaudium',
      logoPath: '',
      companyName: 'Gaudium Immo',
      companyAddress: '19 Avenue du Pont Rouge - 7000 Mons',
      companyPhone: '0478/228477',
      companyEmail: 'info@gaudiumimmo.be',
      companyWebsite: '',
      professionalNumber: 'GEO20/1523',
      vatNumber: '',
      footerText: 'Géomètre-Expert GEO20/1523',
      entryPreliminaryNotes: defaultEntryNotes,
      exitPreliminaryNotes: defaultExitNotes,
      beforeWorksPreliminaryNotes: defaultBeforeWorksNotes,
      primaryColorHex: '1E5AA8',
      secondaryColorHex: '238636',
      headingColorHex: '1E293B',
      bodyColorHex: '111827',
      fontFamily: 'Sylfaen',
      titleFontSize: 22,
      headingFontSize: 15,
      bodyFontSize: 11,
      pageMarginMm: 20,
      showLogo: true,
      showPageNumbers: true,
      sections: [
        ReportSectionPreference(id: 'cover', label: 'Page de garde', enabled: true),
        ReportSectionPreference(id: 'toc', label: 'Table des matières', enabled: true),
        ReportSectionPreference(id: 'notes', label: 'Notes liminaires', enabled: true),
        ReportSectionPreference(id: 'parties', label: 'Identification des parties', enabled: true),
        ReportSectionPreference(id: 'keys', label: 'Clés, entretiens et documents', enabled: true),
        ReportSectionPreference(id: 'generalities', label: 'Généralités', enabled: true),
        ReportSectionPreference(id: 'rooms', label: 'Pièces', enabled: true),
        ReportSectionPreference(id: 'conclusion', label: 'Conclusion', enabled: true),
        ReportSectionPreference(id: 'signatures', label: 'Signatures', enabled: true),
      ],
    );
  }

  ReportPreferences copyWith({
    SubscriptionPlan? plan,
    String? templateName,
    String? logoPath,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyWebsite,
    String? professionalNumber,
    String? vatNumber,
    String? footerText,
    String? entryPreliminaryNotes,
    String? exitPreliminaryNotes,
    String? beforeWorksPreliminaryNotes,
    List<ReportSectionPreference>? sections,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? headingColorHex,
    String? bodyColorHex,
    String? fontFamily,
    double? titleFontSize,
    double? headingFontSize,
    double? bodyFontSize,
    double? pageMarginMm,
    bool? showLogo,
    bool? showPageNumbers,
  }) {
    return ReportPreferences(
      plan: plan ?? this.plan,
      templateName: templateName ?? this.templateName,
      logoPath: logoPath ?? this.logoPath,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      professionalNumber: professionalNumber ?? this.professionalNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      footerText: footerText ?? this.footerText,
      entryPreliminaryNotes: entryPreliminaryNotes ?? this.entryPreliminaryNotes,
      exitPreliminaryNotes: exitPreliminaryNotes ?? this.exitPreliminaryNotes,
      beforeWorksPreliminaryNotes: beforeWorksPreliminaryNotes ?? this.beforeWorksPreliminaryNotes,
      sections: sections ?? this.sections,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      headingColorHex: headingColorHex ?? this.headingColorHex,
      bodyColorHex: bodyColorHex ?? this.bodyColorHex,
      fontFamily: fontFamily ?? this.fontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      headingFontSize: headingFontSize ?? this.headingFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      pageMarginMm: pageMarginMm ?? this.pageMarginMm,
      showLogo: showLogo ?? this.showLogo,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
    );
  }
}
