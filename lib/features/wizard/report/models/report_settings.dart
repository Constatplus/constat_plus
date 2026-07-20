enum InspectionReportType { entry, exit, beforeWorks, afterWorks }

extension InspectionReportTypeLabel on InspectionReportType {
  String get label => switch (this) {
    InspectionReportType.entry => 'État des lieux d’entrée',
    InspectionReportType.exit => 'État des lieux de sortie',
    InspectionReportType.beforeWorks => 'Constat avant travaux',
    InspectionReportType.afterWorks => 'Récolement après travaux',
  };
}

class ReportSettings {
  final InspectionReportType reportType;
  final String companyName;
  final String expertName;
  final String expertRegistration;
  final String email;
  final bool includeExpertSignature;
  final String reportTitle;
  final String propertyAddress;
  final String visitDate;
  final String ownerName;
  final String tenantName;
  final List<String> preliminaryNotes;
  final List<String> keys;
  final List<String> maintenance;
  final List<String> manuals;
  final List<String> documents;
  final Map<String, String> generalities;

  const ReportSettings({
    required this.reportType,
    required this.companyName,
    required this.expertName,
    required this.expertRegistration,
    required this.email,
    required this.includeExpertSignature,
    required this.reportTitle,
    required this.propertyAddress,
    required this.visitDate,
    required this.ownerName,
    required this.tenantName,
    required this.preliminaryNotes,
    required this.keys,
    required this.maintenance,
    required this.manuals,
    required this.documents,
    required this.generalities,
  });

  factory ReportSettings.defaults(InspectionReportType type) {
    return ReportSettings(
      reportType: type,
      companyName: 'Constat+',
      expertName: 'Nom de l’expert',
      expertRegistration: '',
      email: '',
      includeExpertSignature: true,
      reportTitle: type.label,
      propertyAddress: 'Adresse du bien à compléter',
      visitDate: '',
      ownerName: '',
      tenantName: '',
      preliminaryNotes: _defaultNotes(type),
      keys: const <String>[],
      maintenance: const <String>[],
      manuals: const <String>[],
      documents: const <String>[],
      generalities: const <String, String>{
        'Plafond': '',
        'Mur': '',
        'Menuiserie intérieure': '',
        'Menuiserie extérieure': '',
        'Électricité': '',
        'Chauffage': '',
        'Sol': '',
        'Mobilier': '',
      },
    );
  }

  static List<String> _defaultNotes(InspectionReportType type) {
    final common = <String>[
      'Le présent état des lieux est descriptif et contradictoire. Il est limité aux éléments apparents et accessibles au moment de la visite.',
      'Les constatations sont exclusivement visuelles et non destructives. Le présent document ne constitue ni un diagnostic technique ni un certificat de conformité.',
      'Les photographies constituent un complément descriptif. En cas de divergence, la description textuelle prévaut.',
      'Les murs sont désignés par rapport à la porte d’entrée de la pièce : mur avant, mur droit, mur arrière et mur gauche.',
    ];

    if (type == InspectionReportType.exit) {
      return <String>[
        ...common,
        'Le présent état des lieux de sortie permet la comparaison avec l’état des lieux d’entrée et relève les modifications, dégradations ou manquements visibles à la fin de l’occupation.',
      ];
    }

    if (type == InspectionReportType.beforeWorks) {
      return <String>[
        ...common,
        'Le présent constat constitue le rapport de référence de l’état apparent des zones accessibles avant le commencement des travaux.',
      ];
    }

    if (type == InspectionReportType.afterWorks) {
      return <String>[
        ...common,
        'Le présent récolement compare les constatations visibles après travaux au rapport avant travaux de référence.',
      ];
    }

    return <String>[
      ...common,
      'Le présent état des lieux d’entrée décrit l’état apparent du bien au début de l’occupation.',
    ];
  }
}
