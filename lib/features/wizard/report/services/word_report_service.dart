import 'dart:io';

import 'package:docx_dart/docx_dart.dart' as docx;
import 'package:file_selector/file_selector.dart';

import '../models/report_settings.dart';
import '../models/visit_report_snapshot.dart';
import 'word_ooxml_styler.dart';

class WordReportService {
  static const List<String> _sectionOrder = <String>[
    'Plafond',
    'Mur',
    'Mur avant',
    'Mur droit',
    'Mur arrière',
    'Mur gauche',
    'Menuiserie intérieure',
    'Menuiserie extérieure',
    'Électricité',
    'Chauffage',
    'Sol',
    'Mobilier',
  ];

  final WordOoxmlStyler _styler = WordOoxmlStyler();

  Future<String?> export({
    required VisitReportSnapshot snapshot,
    required ReportSettings settings,
  }) async {
    final suggestedName = _safeFileName(
      '${settings.reportTitle} - ${settings.propertyAddress}.docx',
    );

    const wordType = XTypeGroup(
      label: 'Document Word',
      extensions: <String>['docx'],
    );

    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const <XTypeGroup>[wordType],
    );
    if (location == null) return null;

    final document = docx.loadDocxDocument();
    document.settings.updateFieldsOnOpen = true;

    _buildCover(document, settings);
    document.addPageBreak();

    // Seuls les titres de pièces utilisent le niveau Heading 1.
    // La table des matières ne reprend donc que les pièces.
    _addMainTitle(document, 'TABLE DES MATIÈRES');
    document.addTableOfContents(minHeadingLevel: 1, maxHeadingLevel: 1);
    document.addPageBreak();

    _buildPreliminaryNotes(document, settings);
    _buildParties(document, settings);
    _buildKeysMaintenanceManuals(document, settings);
    _buildGeneralities(document, settings);
    _buildRooms(document, snapshot);
    _buildConclusion(document, settings);
    _buildSignatures(document, settings);

    final path = location.path.toLowerCase().endsWith('.docx')
        ? location.path
        : '${location.path}.docx';

    document.save(path);

    if (!File(path).existsSync()) {
      throw StateError('Le fichier Word n’a pas pu être créé.');
    }

    final roomTitles = snapshot.rooms
        .map((room) => room.name.trim().toUpperCase())
        .where((title) => title.isNotEmpty)
        .toSet();

    await _styler.apply(path: path, roomTitles: roomTitles);
    return path;
  }

  void _buildCover(dynamic document, ReportSettings settings) {
    document.addParagraph(text: settings.reportTitle, style: 'Title');
    document.addParagraph(text: settings.propertyAddress);

    if (settings.visitDate.trim().isNotEmpty) {
      document.addParagraph(text: 'Date : ${settings.visitDate.trim()}');
    }

    document.addParagraph(text: '');
    if (settings.companyName.trim().isNotEmpty) {
      document.addParagraph(text: settings.companyName.trim());
    }
    if (settings.expertName.trim().isNotEmpty) {
      document.addParagraph(text: 'Expert : ${settings.expertName.trim()}');
    }
    if (settings.expertRegistration.trim().isNotEmpty) {
      document.addParagraph(
        text: 'Matricule : ${settings.expertRegistration.trim()}',
      );
    }
    if (settings.email.trim().isNotEmpty) {
      document.addParagraph(text: settings.email.trim());
    }
  }

  void _buildPreliminaryNotes(dynamic document, ReportSettings settings) {
    final notes = settings.preliminaryNotes
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (notes.isEmpty) return;

    _addMainTitle(document, 'NOTES LIMINAIRES');
    for (final note in notes) {
      document.addParagraph(text: note);
    }
    document.addPageBreak();
  }

  void _buildParties(dynamic document, ReportSettings settings) {
    _addMainTitle(document, 'DÉSIGNATION DES PARTIES');

    final table = document.addTable(2, 2, style: 'Table Grid');
    table.cell(0, 0).text = 'PROPRIÉTAIRE';
    table.cell(0, 1).text = 'LOCATAIRE';
    table.cell(1, 0).text = _emptyFallback(settings.ownerName);
    table.cell(1, 1).text = _emptyFallback(settings.tenantName);

    if (settings.includeExpertSignature &&
        settings.expertName.trim().isNotEmpty) {
      document.addParagraph(text: 'Expert : ${settings.expertName.trim()}');
    }
    document.addPageBreak();
  }

  void _buildKeysMaintenanceManuals(dynamic document, ReportSettings settings) {
    _addMainTitle(document, 'CLÉS - ENTRETIENS - MANUELS - DOCUMENTS');
    _addListSection(document, 'CLÉS', settings.keys);
    _addListSection(document, 'ENTRETIENS', settings.maintenance);
    _addListSection(document, 'MANUELS ET MODES D’EMPLOI', settings.manuals);
    _addListSection(document, 'DOCUMENTS', settings.documents);
    document.addPageBreak();
  }

  void _addListSection(dynamic document, String title, List<String> values) {
    _addSubtitle(document, title);
    final items = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      document.addParagraph(text: 'Néant.');
      return;
    }

    for (final item in items) {
      document.addParagraph(text: '- $item');
    }
  }

  void _buildGeneralities(dynamic document, ReportSettings settings) {
    _addMainTitle(document, 'GÉNÉRALITÉS');
    final entries = settings.generalities.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList();

    if (entries.isEmpty) {
      document.addParagraph(
        text: 'Aucune généralité n’a été définie pour ce rapport.',
      );
    } else {
      for (final entry in entries) {
        _addColoredSectionTitle(document, entry.key);
        document.addParagraph(text: entry.value.trim());
      }
    }
    document.addPageBreak();
  }

  void _buildRooms(dynamic document, VisitReportSnapshot snapshot) {
    for (var roomIndex = 0; roomIndex < snapshot.rooms.length; roomIndex++) {
      final room = snapshot.rooms[roomIndex];
      document.addHeading(text: room.name.toUpperCase(), level: 1);

      if (room.level.trim().isNotEmpty) {
        document.addParagraph(text: 'Niveau : ${room.level.trim()}');
      }

      for (final section in _sectionOrder) {
        if (section == 'Électricité') {
          _buildElectrical(document, room);
          continue;
        }
        if (section == 'Mobilier') {
          _buildFurniture(document, room);
          continue;
        }

        final value = room.sections[section]?.trim() ?? '';
        if (value.isEmpty) continue;

        _addColoredSectionTitle(document, section);
        document.addParagraph(text: value);
      }

      _buildPhotos(document, room);

      if (roomIndex < snapshot.rooms.length - 1) {
        document.addPageBreak();
      }
    }
  }

  void _buildElectrical(dynamic document, VisitRoomReport room) {
    final general = room.sections['Électricité']?.trim() ?? '';
    final hasWallItems = room.electricalByWall.values.any(
      (items) => items.values.any((quantity) => quantity > 0),
    );
    if (general.isEmpty && !hasWallItems) return;

    _addColoredSectionTitle(document, 'ÉLECTRICITÉ');
    if (general.isNotEmpty) {
      document.addParagraph(text: general);
    }

    for (final wallEntry in room.electricalByWall.entries) {
      final items = wallEntry.value.entries
          .where((entry) => entry.value > 0)
          .toList();
      if (items.isEmpty) continue;

      _addSubtitle(document, wallEntry.key.toUpperCase());
      final line = items
          .map((entry) => '${entry.value}x ${entry.key.toLowerCase()}')
          .join(' + ');
      document.addParagraph(text: line);
    }
  }

  void _buildFurniture(dynamic document, VisitRoomReport room) {
    final general = room.sections['Mobilier']?.trim() ?? '';
    final hasFurniture = room.furnitureDescriptions.values.any(
      (value) => value.trim().isNotEmpty,
    );
    final hasKitchen = room.kitchen?.hasContent ?? false;
    if (general.isEmpty && !hasFurniture && !hasKitchen) return;

    _addColoredSectionTitle(document, 'MOBILIER');
    if (general.isNotEmpty) {
      document.addParagraph(text: general);
    }

    for (final entry in room.furnitureDescriptions.entries) {
      final description = entry.value.trim();
      if (description.isEmpty || entry.key == 'Cuisine équipée') continue;
      _addSubtitle(document, entry.key.toUpperCase());
      document.addParagraph(text: description);
    }

    final kitchen = room.kitchen;
    if (kitchen == null || !kitchen.hasContent) return;

    _addColoredSectionTitle(document, 'MOBILIER DE CUISINE');
    if (kitchen.generalDescription.trim().isNotEmpty) {
      document.addParagraph(text: kitchen.generalDescription.trim());
    }

    if (kitchen.worktopDescription.trim().isNotEmpty) {
      _addColoredSectionTitle(document, 'PLAN DE TRAVAIL');
      document.addParagraph(text: kitchen.worktopDescription.trim());
    }

    if (kitchen.worktopEquipment.isNotEmpty) {
      _addColoredSectionTitle(document, 'ÉQUIPEMENTS DU PLAN DE TRAVAIL');
      for (final entry in kitchen.worktopEquipment.entries) {
        final description = entry.value.trim();
        if (description.isEmpty) continue;
        document.addParagraph(text: '${entry.key} : $description');
      }
    }

    _buildKitchenUnits(
      document,
      title: 'MEUBLES HAUTS - LECTURE DE GAUCHE À DROITE',
      units: kitchen.upperUnits,
    );
    _buildKitchenUnits(
      document,
      title: 'MEUBLES BAS - LECTURE DE GAUCHE À DROITE',
      units: kitchen.lowerUnits,
    );
  }

  void _buildKitchenUnits(
    dynamic document, {
    required String title,
    required List<KitchenUnitReport> units,
  }) {
    if (units.isEmpty) return;
    _addColoredSectionTitle(document, title);

    for (var index = 0; index < units.length; index++) {
      final unit = units[index];
      final comment = unit.comment.trim();
      final text = comment.isEmpty
          ? '- ${unit.type}.'
          : '- ${unit.type}. $comment';
      document.addParagraph(text: text);
    }
  }

  void _buildPhotos(dynamic document, VisitRoomReport room) {
    final paths = room.photoPaths
        .where((path) => path.trim().isNotEmpty && File(path).existsSync())
        .toList();
    if (paths.isEmpty) return;

    _addSubtitle(document, 'PHOTOS');
    for (var index = 0; index < paths.length; index++) {
      try {
        document.addPicture(paths[index], width: docx.Inches(3));
        document.addParagraph(text: '${room.name} - Photo ${index + 1}');
      } catch (_) {
        document.addParagraph(
          text: 'Photo ${index + 1} non insérée : fichier illisible.',
        );
      }
    }
  }

  void _buildConclusion(dynamic document, ReportSettings settings) {
    document.addPageBreak();
    _addMainTitle(document, 'CONCLUSION');

    final text = settings.reportType == InspectionReportType.exit
        ? 'Les parties déclarent que le présent état des lieux de sortie décrit fidèlement et contradictoirement l’état apparent du bien à la fin de l’occupation, sous réserve de sa comparaison avec l’état des lieux d’entrée.'
        : 'Les parties déclarent que le présent état des lieux d’entrée décrit fidèlement et contradictoirement l’état apparent du bien au début de l’occupation.';

    document.addParagraph(text: text);
    document.addParagraph(
      text: 'Fait le ${_emptyFallback(settings.visitDate)}.',
    );
  }

  void _buildSignatures(dynamic document, ReportSettings settings) {
    _addMainTitle(document, 'SIGNATURES');
    final columns = settings.includeExpertSignature ? 3 : 2;
    final table = document.addTable(2, columns, style: 'Table Grid');

    table.cell(0, 0).text = 'LE PROPRIÉTAIRE';
    table.cell(0, 1).text = 'LE LOCATAIRE';
    table.cell(1, 0).text = settings.ownerName.trim();
    table.cell(1, 1).text = settings.tenantName.trim();

    if (settings.includeExpertSignature) {
      table.cell(0, 2).text = 'L’EXPERT';
      table.cell(1, 2).text = settings.expertName.trim();
    }
  }

  void _addMainTitle(dynamic document, String title) {
    document.addParagraph(text: title);
  }

  void _addColoredSectionTitle(dynamic document, String title) {
    document.addParagraph(text: title.toUpperCase());
  }

  void _addSubtitle(dynamic document, String title) {
    document.addParagraph(text: title.toUpperCase());
  }

  String _emptyFallback(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'À compléter' : trimmed;
  }

  String _safeFileName(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-').trim();
    return cleaned.isEmpty ? 'etat_des_lieux.docx' : cleaned;
  }
}
