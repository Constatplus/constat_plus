import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Applique la charte graphique Constat+ directement dans le contenu OOXML.
///
/// Seuls les titres sont colores. Les descriptions restent en noir.
class WordOoxmlStyler {
  static const Set<String> _descriptiveTitles = <String>{
    'PLAFOND',
    'MUR',
    'MUR(S)',
    'MUR AVANT',
    'MUR DROIT',
    'MUR ARRIERE',
    'MUR GAUCHE',
    'SOL',
    'MOBILIER',
    'MOBILIER DE CUISINE',
    'PLAN DE TRAVAIL',
    'EQUIPEMENTS DU PLAN DE TRAVAIL',
    'MEUBLES HAUTS - LECTURE DE GAUCHE A DROITE',
    'MEUBLES BAS - LECTURE DE GAUCHE A DROITE',
  };

  static const Set<String> _technicalTitles = <String>{
    'ELECTRICITE',
    'CHAUFFAGE',
    'MENUISERIE INTERIEURE',
    'MENUISERIES INTERIEURES',
    'MENUISERIE EXTERIEURE',
    'MENUISERIES EXTERIEURES',
    'SANITAIRES',
    'VENTILATION',
    'CLIMATISATION',
  };

  Future<void> apply({
    required String path,
    required Set<String> roomTitles,
  }) async {
    final file = File(path);
    final originalBytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(originalBytes);

    final documentFile = archive.findFile('word/document.xml');
    if (documentFile == null) {
      throw StateError('Le fichier word/document.xml est introuvable.');
    }

    final documentBytes = _archiveFileBytes(documentFile);
    final document = XmlDocument.parse(String.fromCharCodes(documentBytes));
    final normalizedRoomTitles = roomTitles.map(_normalize).toSet();

    for (final paragraph in document.findAllElements('w:p')) {
      final text = paragraph
          .findAllElements('w:t')
          .map((node) => node.innerText)
          .join()
          .trim();

      if (text.isEmpty) continue;

      final normalized = _normalize(text);
      if (normalizedRoomTitles.contains(normalized)) {
        _styleParagraph(
          paragraph,
          color: '000000',
          sizeHalfPoints: 32,
        );
      } else if (_descriptiveTitles.contains(normalized)) {
        _styleParagraph(
          paragraph,
          color: '1E5AA8',
          sizeHalfPoints: 26,
        );
      } else if (_technicalTitles.contains(normalized)) {
        _styleParagraph(
          paragraph,
          color: '238636',
          sizeHalfPoints: 26,
        );
      } else {
        _applyBodyFont(paragraph);
      }
    }

    final updatedXml = Uint8List.fromList(
      document.toXmlString().codeUnits,
    );

    // ArchiveFile est immuable dans archive 4.x : il faut remplacer
    // l'entree au lieu de modifier sa propriete content.
    archive.removeFile(documentFile);
    archive.addFile(
      ArchiveFile(
        'word/document.xml',
        updatedXml.length,
        updatedXml,
      ),
    );

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw StateError('Impossible de finaliser le document Word.');
    }

    await file.writeAsBytes(encoded, flush: true);
  }

  Uint8List _archiveFileBytes(ArchiveFile file) {
    final content = file.content;
    if (content is Uint8List) return content;
    if (content is List<int>) return Uint8List.fromList(content);

    throw StateError(
      'Le contenu de ${file.name} ne peut pas etre lu.',
    );
  }

  String _normalize(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('À', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ä', 'A')
        .replaceAll('Î', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Ô', 'O')
        .replaceAll('Ö', 'O')
        .replaceAll('Ù', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll('Ç', 'C');
  }

  void _styleParagraph(
    XmlElement paragraph, {
    required String color,
    required int sizeHalfPoints,
  }) {
    for (final run in paragraph.findAllElements('w:r')) {
      final runProperties = _childOrCreate(run, 'w:rPr');
      _setSingleton(runProperties, 'w:b');
      _setVal(runProperties, 'w:color', color);
      _setVal(runProperties, 'w:sz', '$sizeHalfPoints');
      _setVal(runProperties, 'w:szCs', '$sizeHalfPoints');
      _setFonts(runProperties);
    }
  }

  void _applyBodyFont(XmlElement paragraph) {
    for (final run in paragraph.findAllElements('w:r')) {
      final runProperties = _childOrCreate(run, 'w:rPr');
      _setFonts(runProperties);
      _setVal(runProperties, 'w:color', '000000');
      _setVal(runProperties, 'w:sz', '22');
      _setVal(runProperties, 'w:szCs', '22');
    }
  }

  XmlElement _childOrCreate(XmlElement parent, String qualifiedName) {
    final localName = qualifiedName.split(':').last;
    final existing = parent.childElements
        .where((element) => element.name.local == localName)
        .firstOrNull;

    if (existing != null) return existing;

    final created = XmlElement(XmlName(localName, 'w'));
    parent.children.insert(0, created);
    return created;
  }

  void _setSingleton(XmlElement parent, String qualifiedName) {
    final localName = qualifiedName.split(':').last;
    parent.children.removeWhere(
      (node) => node is XmlElement && node.name.local == localName,
    );
    parent.children.add(XmlElement(XmlName(localName, 'w')));
  }

  void _setVal(XmlElement parent, String qualifiedName, String value) {
    final localName = qualifiedName.split(':').last;
    parent.children.removeWhere(
      (node) => node is XmlElement && node.name.local == localName,
    );
    parent.children.add(
      XmlElement(
        XmlName(localName, 'w'),
        <XmlAttribute>[
          XmlAttribute(XmlName('val', 'w'), value),
        ],
      ),
    );
  }

  void _setFonts(XmlElement runProperties) {
    runProperties.children.removeWhere(
      (node) => node is XmlElement && node.name.local == 'rFonts',
    );
    runProperties.children.add(
      XmlElement(
        XmlName('rFonts', 'w'),
        <XmlAttribute>[
          XmlAttribute(XmlName('ascii', 'w'), 'Aptos'),
          XmlAttribute(XmlName('hAnsi', 'w'), 'Aptos'),
          XmlAttribute(XmlName('eastAsia', 'w'), 'Aptos'),
          XmlAttribute(XmlName('cs', 'w'), 'Aptos'),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
