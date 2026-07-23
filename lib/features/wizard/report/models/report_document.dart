import 'report_theme.dart';

/// Neutral report representation shared by preview, Word and PDF renderers.
///
/// The document contains content only. Renderers decide how each block is
/// drawn, but they must not rebuild business data independently.
class ReportDocument {
  const ReportDocument({
    required this.id,
    required this.title,
    required this.kind,
    required this.theme,
    required this.metadata,
    required this.sections,
    this.generatedAt,
  });

  final String id;
  final String title;
  final ReportKind kind;
  final ReportTheme theme;
  final ReportMetadata metadata;
  final List<ReportSection> sections;
  final DateTime? generatedAt;

  List<ReportSection> get enabledSections =>
      sections.where((section) => section.enabled).toList(growable: false);

  ReportSection? sectionById(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }
}

enum ReportKind {
  entry,
  exit,
  beforeWorks,
  afterWorks,
}

class ReportMetadata {
  const ReportMetadata({
    required this.propertyLabel,
    required this.propertyAddress,
    required this.visitDateLabel,
    required this.ownerLabel,
    required this.tenantLabel,
    this.reference = '',
    this.author = '',
  });

  final String propertyLabel;
  final String propertyAddress;
  final String visitDateLabel;
  final String ownerLabel;
  final String tenantLabel;
  final String reference;
  final String author;
}

class ReportSection {
  const ReportSection({
    required this.id,
    required this.title,
    required this.type,
    required this.blocks,
    this.enabled = true,
    this.keepTogether = false,
    this.startOnNewPage = false,
  });

  final String id;
  final String title;
  final ReportSectionType type;
  final List<ReportBlock> blocks;
  final bool enabled;
  final bool keepTogether;
  final bool startOnNewPage;

  ReportSection copyWith({
    String? id,
    String? title,
    ReportSectionType? type,
    List<ReportBlock>? blocks,
    bool? enabled,
    bool? keepTogether,
    bool? startOnNewPage,
  }) {
    return ReportSection(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      blocks: blocks ?? this.blocks,
      enabled: enabled ?? this.enabled,
      keepTogether: keepTogether ?? this.keepTogether,
      startOnNewPage: startOnNewPage ?? this.startOnNewPage,
    );
  }
}

enum ReportSectionType {
  cover,
  tableOfContents,
  notes,
  parties,
  keys,
  generalities,
  room,
  calculations,
  annexes,
  conclusion,
  signatures,
  custom,
}

sealed class ReportBlock {
  const ReportBlock();
}

class ReportHeadingBlock extends ReportBlock {
  const ReportHeadingBlock(this.text, {this.level = 1});

  final String text;
  final int level;
}

class ReportParagraphBlock extends ReportBlock {
  const ReportParagraphBlock(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.justified = true,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool justified;
}

class ReportKeyValueBlock extends ReportBlock {
  const ReportKeyValueBlock({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;
}

class ReportDescriptionTableBlock extends ReportBlock {
  const ReportDescriptionTableBlock({
    required this.rows,
    this.firstColumnRatio = .28,
  });

  final List<ReportDescriptionRow> rows;
  final double firstColumnRatio;
}

class ReportDescriptionRow {
  const ReportDescriptionRow({
    required this.label,
    required this.description,
    this.condition,
  });

  final String label;
  final String description;
  final String? condition;
}

class ReportPhotoGridBlock extends ReportBlock {
  const ReportPhotoGridBlock({
    required this.photos,
    this.columns = 2,
    this.showCaptions = true,
  });

  final List<ReportPhoto> photos;
  final int columns;
  final bool showCaptions;
}

class ReportPhoto {
  const ReportPhoto({
    required this.id,
    required this.path,
    required this.caption,
    this.roomId,
    this.takenAt,
  });

  final String id;
  final String path;
  final String caption;
  final String? roomId;
  final DateTime? takenAt;
}

class ReportCalculationTableBlock extends ReportBlock {
  const ReportCalculationTableBlock({
    required this.rows,
    required this.totalLabel,
    required this.totalAmount,
    this.currency = 'EUR',
  });

  final List<ReportCalculationRow> rows;
  final String totalLabel;
  final double totalAmount;
  final String currency;
}

class ReportCalculationRow {
  const ReportCalculationRow({
    required this.label,
    required this.calculation,
    required this.amount,
    this.vatRate,
  });

  final String label;
  final String calculation;
  final double amount;
  final double? vatRate;
}

class ReportSignatureBlock extends ReportBlock {
  const ReportSignatureBlock({required this.signatories});

  final List<ReportSignatory> signatories;
}

class ReportSignatory {
  const ReportSignatory({
    required this.role,
    required this.name,
    this.signaturePath,
    this.signedAt,
  });

  final String role;
  final String name;
  final String? signaturePath;
  final DateTime? signedAt;
}

class ReportPageBreakBlock extends ReportBlock {
  const ReportPageBreakBlock();
}

class ReportSpacerBlock extends ReportBlock {
  const ReportSpacerBlock([this.height = 12]);

  final double height;
}
