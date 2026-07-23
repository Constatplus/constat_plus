import '../models/report_document.dart';
import '../models/report_theme.dart';
import 'room_report_section_builder.dart';

/// Central entry point used to create the neutral report document consumed by
/// Flutter, PDF and Word renderers.
class ReportBuilder {
  const ReportBuilder({
    this.roomBuilder = const RoomReportSectionBuilder(),
  });

  final RoomReportSectionBuilder roomBuilder;

  ReportDocument build(ReportBuildData data) {
    final sections = <ReportSection>[
      _buildCover(data),
      ...data.introductionSections,
      ...data.rooms.map(_buildRoom),
      ...data.trailingSections,
    ];

    return ReportDocument(
      id: data.id,
      title: data.title,
      kind: data.kind,
      theme: data.theme,
      metadata: data.metadata,
      sections: sections,
      generatedAt: data.generatedAt ?? DateTime.now(),
    );
  }

  ReportSection _buildCover(ReportBuildData data) {
    final metadata = data.metadata;
    final blocks = <ReportBlock>[
      ReportHeadingBlock(data.title),
      if (metadata.reference.trim().isNotEmpty)
        ReportKeyValueBlock(
          label: 'Référence',
          value: metadata.reference.trim(),
          emphasized: true,
        ),
      ReportKeyValueBlock(
        label: metadata.propertyLabel,
        value: metadata.propertyAddress,
      ),
      ReportKeyValueBlock(
        label: 'Date de visite',
        value: metadata.visitDateLabel,
      ),
      ReportKeyValueBlock(
        label: 'Propriétaire',
        value: metadata.ownerLabel,
      ),
      ReportKeyValueBlock(
        label: 'Locataire',
        value: metadata.tenantLabel,
      ),
      if (metadata.author.trim().isNotEmpty)
        ReportKeyValueBlock(
          label: 'Auteur',
          value: metadata.author.trim(),
        ),
    ];

    return ReportSection(
      id: 'cover',
      title: data.title,
      type: ReportSectionType.cover,
      blocks: blocks,
      keepTogether: true,
    );
  }

  ReportSection _buildRoom(ReportRoomData room) {
    return roomBuilder.build(
      roomId: room.id,
      roomName: room.name,
      descriptions: room.descriptions,
      photos: room.photos,
      observations: room.observations,
      startOnNewPage: room.startOnNewPage,
      photoColumns: room.photoColumns,
      showPhotoCaptions: room.showPhotoCaptions,
    );
  }
}

/// Input contract for the central report builder.
///
/// Existing wizard/domain models can be mapped to this class without making
/// the neutral reporting layer depend on UI state or storage implementations.
class ReportBuildData {
  const ReportBuildData({
    required this.id,
    required this.title,
    required this.kind,
    required this.theme,
    required this.metadata,
    required this.rooms,
    this.introductionSections = const [],
    this.trailingSections = const [],
    this.generatedAt,
  });

  final String id;
  final String title;
  final ReportKind kind;
  final ReportTheme theme;
  final ReportMetadata metadata;
  final List<ReportRoomData> rooms;
  final List<ReportSection> introductionSections;
  final List<ReportSection> trailingSections;
  final DateTime? generatedAt;
}

/// Neutral representation of one room before it becomes a report section.
class ReportRoomData {
  const ReportRoomData({
    required this.id,
    required this.name,
    required this.descriptions,
    this.photos = const [],
    this.observations,
    this.startOnNewPage = true,
    this.photoColumns = 2,
    this.showPhotoCaptions = true,
  });

  final String id;
  final String name;
  final List<ReportDescriptionRow> descriptions;

  /// All photos belonging to the room as a whole.
  /// They are not linked to individual description rows.
  final List<ReportPhoto> photos;

  final String? observations;
  final bool startOnNewPage;
  final int photoColumns;
  final bool showPhotoCaptions;
}
