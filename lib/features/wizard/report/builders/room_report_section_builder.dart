import '../models/report_document.dart';

/// Builds one complete room section.
///
/// Photos are intentionally attached to the room as a whole. They are never
/// assigned to individual items such as floors, walls, ceilings or furniture,
/// because one image commonly shows several of those elements at once.
class RoomReportSectionBuilder {
  const RoomReportSectionBuilder();

  ReportSection build({
    required String roomId,
    required String roomName,
    required List<ReportDescriptionRow> descriptions,
    required List<ReportPhoto> photos,
    String? observations,
    bool startOnNewPage = true,
    int photoColumns = 2,
    bool showPhotoCaptions = true,
  }) {
    final normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) {
      throw ArgumentError.value(roomId, 'roomId', 'Room id cannot be empty.');
    }

    final roomPhotos = photos
        .map(
          (photo) => ReportPhoto(
            id: photo.id,
            path: photo.path,
            caption: photo.caption,
            roomId: normalizedRoomId,
            takenAt: photo.takenAt,
          ),
        )
        .toList(growable: false);

    final blocks = <ReportBlock>[
      if (descriptions.isNotEmpty)
        ReportDescriptionTableBlock(rows: descriptions),
      if (observations != null && observations.trim().isNotEmpty) ...[
        const ReportHeadingBlock('Observations', level: 2),
        ReportParagraphBlock(observations.trim()),
      ],
      if (roomPhotos.isNotEmpty) ...[
        const ReportHeadingBlock('Photos de la pièce', level: 2),
        ReportPhotoGridBlock(
          photos: roomPhotos,
          columns: photoColumns,
          showCaptions: showPhotoCaptions,
        ),
      ],
    ];

    return ReportSection(
      id: 'room-$normalizedRoomId',
      title: roomName.trim(),
      type: ReportSectionType.room,
      blocks: blocks,
      startOnNewPage: startOnNewPage,
    );
  }
}
