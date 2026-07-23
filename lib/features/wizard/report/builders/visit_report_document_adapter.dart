import '../models/report_document.dart';
import '../models/report_settings.dart';
import '../models/report_theme.dart';
import '../models/visit_report_snapshot.dart';
import 'report_builder.dart';

/// Maps the existing wizard visit snapshot to the neutral report engine.
///
/// This adapter is the migration boundary: the wizard keeps its current models
/// while preview, PDF and Word can progressively consume one ReportDocument.
class VisitReportDocumentAdapter {
  const VisitReportDocumentAdapter({
    this.builder = const ReportBuilder(),
  });

  final ReportBuilder builder;

  ReportDocument build({
    required String missionId,
    required ReportSettings settings,
    required ReportTheme theme,
    required VisitReportSnapshot snapshot,
  }) {
    return builder.build(
      ReportBuildData(
        id: missionId,
        title: settings.reportTitle,
        kind: _kind(settings.reportType),
        theme: theme,
        metadata: ReportMetadata(
          propertyLabel: 'Adresse du bien',
          propertyAddress: settings.propertyAddress,
          visitDateLabel: settings.visitDate,
          ownerLabel: settings.ownerName,
          tenantLabel: settings.tenantName,
          reference: missionId,
          author: _author(settings),
        ),
        introductionSections: _introductionSections(settings),
        rooms: snapshot.rooms
            .asMap()
            .entries
            .map((entry) => _room(entry.key, entry.value))
            .toList(growable: false),
      ),
    );
  }

  ReportRoomData _room(int index, VisitRoomReport room) {
    final descriptions = <ReportDescriptionRow>[
      ...room.sections.entries.map(
        (entry) => ReportDescriptionRow(
          label: entry.key,
          description: entry.value,
        ),
      ),
      ..._electricalRows(room),
      ...room.furnitureDescriptions.entries.map(
        (entry) => ReportDescriptionRow(
          label: 'Mobilier - ${entry.key}',
          description: entry.value,
        ),
      ),
      ..._kitchenRows(room.kitchen),
    ].where((row) => row.description.trim().isNotEmpty).toList(growable: false);

    final roomId = _roomId(index, room);
    final photos = room.photoPaths
        .asMap()
        .entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map(
          (entry) => ReportPhoto(
            id: '$roomId-photo-${entry.key + 1}',
            path: entry.value.trim(),
            caption: 'Photo ${entry.key + 1}',
            roomId: roomId,
          ),
        )
        .toList(growable: false);

    return ReportRoomData(
      id: roomId,
      name: room.name.trim().isEmpty ? room.type : room.name.trim(),
      descriptions: descriptions,
      photos: photos,
    );
  }

  Iterable<ReportDescriptionRow> _electricalRows(VisitRoomReport room) sync* {
    for (final wall in room.electricalByWall.entries) {
      final elements = wall.value.entries
          .where((entry) => entry.value > 0)
          .map((entry) => '${entry.value} × ${entry.key}')
          .join(', ');
      if (elements.isEmpty) continue;
      yield ReportDescriptionRow(
        label: 'Électricité - ${wall.key}',
        description: elements,
      );
    }
  }

  Iterable<ReportDescriptionRow> _kitchenRows(KitchenReport? kitchen) sync* {
    if (kitchen == null || !kitchen.hasContent) return;

    if (kitchen.generalDescription.trim().isNotEmpty) {
      yield ReportDescriptionRow(
        label: 'Cuisine',
        description: kitchen.generalDescription.trim(),
      );
    }
    if (kitchen.worktopDescription.trim().isNotEmpty) {
      yield ReportDescriptionRow(
        label: 'Plan de travail',
        description: kitchen.worktopDescription.trim(),
      );
    }
    for (final equipment in kitchen.worktopEquipment.entries) {
      if (equipment.value.trim().isEmpty) continue;
      yield ReportDescriptionRow(
        label: 'Équipement - ${equipment.key}',
        description: equipment.value.trim(),
      );
    }
    for (var index = 0; index < kitchen.upperUnits.length; index++) {
      final unit = kitchen.upperUnits[index];
      yield ReportDescriptionRow(
        label: 'Meuble haut ${index + 1} - ${unit.type}',
        description: unit.comment,
      );
    }
    for (var index = 0; index < kitchen.lowerUnits.length; index++) {
      final unit = kitchen.lowerUnits[index];
      yield ReportDescriptionRow(
        label: 'Meuble bas ${index + 1} - ${unit.type}',
        description: unit.comment,
      );
    }
  }

  List<ReportSection> _introductionSections(ReportSettings settings) {
    final sections = <ReportSection>[];

    if (settings.preliminaryNotes.isNotEmpty) {
      sections.add(
        ReportSection(
          id: 'preliminary-notes',
          title: 'Notes préliminaires',
          type: ReportSectionType.notes,
          blocks: settings.preliminaryNotes
              .where((note) => note.trim().isNotEmpty)
              .map((note) => ReportParagraphBlock(note.trim()))
              .toList(growable: false),
        ),
      );
    }

    final handoverBlocks = <ReportBlock>[
      ..._listBlocks('Clés, badges et télécommandes', settings.keys),
      ..._listBlocks('Entretiens', settings.maintenance),
      ..._listBlocks('Manuels et modes d’emploi', settings.manuals),
      ..._listBlocks('Documents remis', settings.documents),
    ];
    if (handoverBlocks.isNotEmpty) {
      sections.add(
        ReportSection(
          id: 'handover',
          title: 'Éléments remis',
          type: ReportSectionType.keys,
          blocks: handoverBlocks,
        ),
      );
    }

    if (settings.generalities.isNotEmpty) {
      sections.add(
        ReportSection(
          id: 'generalities',
          title: 'Généralités',
          type: ReportSectionType.generalities,
          blocks: settings.generalities.entries
              .where((entry) => entry.value.trim().isNotEmpty)
              .map(
                (entry) => ReportKeyValueBlock(
                  label: entry.key,
                  value: entry.value.trim(),
                ),
              )
              .toList(growable: false),
        ),
      );
    }

    return sections;
  }

  Iterable<ReportBlock> _listBlocks(String title, List<String> values) sync* {
    final items = values.where((value) => value.trim().isNotEmpty).toList();
    if (items.isEmpty) return;
    yield ReportHeadingBlock(title, level: 2);
    for (final item in items) {
      yield ReportParagraphBlock(item.trim(), justified: false);
    }
  }

  String _roomId(int index, VisitRoomReport room) {
    final normalized = room.name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'room-${index + 1}' : '$normalized-${index + 1}';
  }

  String _author(ReportSettings settings) {
    final registration = settings.expertRegistration.trim();
    final name = settings.expertName.trim();
    if (registration.isEmpty) return name;
    if (name.isEmpty) return registration;
    return '$name - $registration';
  }

  ReportKind _kind(InspectionReportType type) {
    return switch (type) {
      InspectionReportType.entry => ReportKind.entry,
      InspectionReportType.exit => ReportKind.exit,
      InspectionReportType.beforeWorks => ReportKind.beforeWorks,
      InspectionReportType.afterWorks => ReportKind.afterWorks,
    };
  }
}
