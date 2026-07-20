import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'inspection_knowledge.dart';

class RoomPhotoAnalysis {
  final Map<String, String> sections;
  final bool hasKitchen;
  final String kitchenGeneral;
  final String worktop;
  final Map<String, String> worktopEquipment;
  final List<Map<String, String>> upperUnits;
  final List<Map<String, String>> lowerUnits;

  const RoomPhotoAnalysis({
    required this.sections,
    required this.hasKitchen,
    required this.kitchenGeneral,
    required this.worktop,
    required this.worktopEquipment,
    required this.upperUnits,
    required this.lowerUnits,
  });

  factory RoomPhotoAnalysis.fromJson(Map<String, dynamic> json) {
    Map<String, String> toStringMap(dynamic value) {
      if (value is! Map) return <String, String>{};

      return value.map(
        (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
      );
    }

    List<Map<String, String>> toUnitList(dynamic value) {
      if (value is! List) return <Map<String, String>>[];

      return value.whereType<Map>().map((item) {
        return <String, String>{
          'type': item['type']?.toString() ?? 'Autre',
          'comment': item['comment']?.toString() ?? '',
        };
      }).toList();
    }

    final rawSections = toStringMap(json['sections']);
    final normalizedSections = _normalizeSections(rawSections);

    return RoomPhotoAnalysis(
      sections: normalizedSections,
      hasKitchen: json['hasKitchen'] == true,
      kitchenGeneral: json['kitchenGeneral']?.toString() ?? '',
      worktop: json['worktop']?.toString() ?? '',
      worktopEquipment: toStringMap(json['worktopEquipment']),
      upperUnits: toUnitList(json['upperUnits']),
      lowerUnits: toUnitList(json['lowerUnits']),
    );
  }

  static Map<String, String> _normalizeSections(Map<String, String> sections) {
    const sectionNames = <String>[
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

    const emptyAllowedSections = <String>{'Électricité', 'Mobilier'};

    final result = <String, String>{};
    for (final section in sectionNames) {
      final value = sections[section]?.trim() ?? '';
      if (value.isNotEmpty) {
        result[section] = value;
      } else if (emptyAllowedSections.contains(section)) {
        result[section] = '';
      } else {
        result[section] = 'Sans remarque.';
      }
    }

    const directionalWalls = <String>[
      'Mur avant',
      'Mur droit',
      'Mur arrière',
      'Mur gauche',
    ];
    final wallValues = directionalWalls
        .map((wall) => result[wall] ?? 'Sans remarque.')
        .toList();

    final firstWall = wallValues.first;
    final allWallsIdentical =
        firstWall != 'Sans remarque.' &&
        wallValues.every((value) => value == firstWall);

    if (allWallsIdentical) {
      if (result['Mur'] == 'Sans remarque.') {
        result['Mur'] = firstWall;
      }
      for (final wall in directionalWalls) {
        result[wall] = 'Sans remarque.';
      }
    }

    return result;
  }
}

class VisionService {
  static const int _maximumPhotoCount = 6;
  static const int _columnCount = 2;
  static const int _cellWidth = 512;
  static const int _cellHeight = 384;

  Future<RoomPhotoAnalysis> analyzeRoom({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  }) async {
    _validateConfiguration(photos);

    final selectedPhotos = photos.take(_maximumPhotoCount).toList();
    final contactSheet = await _createContactSheet(selectedPhotos);

    final content = <Map<String, dynamic>>[
      {
        'type': 'input_text',
        'text': _buildPrompt(
          roomName: roomName,
          roomType: roomType,
          photoCount: selectedPhotos.length,
        ),
      },
      {
        'type': 'input_image',
        'image_url': 'data:image/png;base64,${base64Encode(contactSheet)}',
        'detail': 'low',
      },
    ];

    final response = await Supabase.instance.client.functions.invoke(
      'analyze-room-photos',
      body: <String, dynamic>{
        'missionId': missionId,
        'missionType': missionType,
        'idempotencyKey': idempotencyKey,
        'openAiRequest': _buildRequestBody(content),
      },
    );
    final responseText = response.data is String
        ? response.data as String
        : jsonEncode(response.data);
    _throwForHttpError(statusCode: response.status, responseText: responseText);
    final outputText = _extractOutputText(responseText);
    final decodedAnalysis = jsonDecode(outputText);

    if (decodedAnalysis is! Map<String, dynamic>) {
      throw const FormatException(
        'Le résultat de l’analyse photo n’est pas valide.',
      );
    }

    return RoomPhotoAnalysis.fromJson(decodedAnalysis);
  }

  void _validateConfiguration(List<XFile> photos) {
    if (photos.isEmpty) {
      throw const FormatException('Aucune photo à analyser.');
    }
  }

  Future<List<int>> _createContactSheet(List<XFile> photos) async {
    final rowCount = (photos.length / _columnCount).ceil();
    final sheetWidth = _columnCount * _cellWidth;
    final sheetHeight = rowCount * _cellHeight;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, sheetWidth.toDouble(), sheetHeight.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFF1F5F9),
    );

    for (var index = 0; index < photos.length; index++) {
      final bytes = await File(photos[index].path).readAsBytes();
      final image = await _decodeImage(bytes);

      final column = index % _columnCount;
      final row = index ~/ _columnCount;
      final destination = ui.Rect.fromLTWH(
        (column * _cellWidth).toDouble(),
        (row * _cellHeight).toDouble(),
        _cellWidth.toDouble(),
        _cellHeight.toDouble(),
      );

      final source = _coverSourceRect(
        imageWidth: image.width.toDouble(),
        imageHeight: image.height.toDouble(),
        destinationWidth: destination.width,
        destinationHeight: destination.height,
      );

      canvas.drawImageRect(
        image,
        source,
        destination,
        ui.Paint()..filterQuality = ui.FilterQuality.low,
      );

      canvas.drawRect(
        destination.deflate(1),
        ui.Paint()
          ..color = const ui.Color(0x99FFFFFF)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      image.dispose();
    }

    final picture = recorder.endRecording();
    final sheetImage = await picture.toImage(sheetWidth, sheetHeight);
    picture.dispose();

    final byteData = await sheetImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    sheetImage.dispose();

    if (byteData == null) {
      throw const FormatException(
        'Impossible de préparer les photos pour l’analyse.',
      );
    }

    return byteData.buffer.asUint8List();
  }

  Future<ui.Image> _decodeImage(List<int> bytes) async {
    final codec = await ui.instantiateImageCodec(
      Uint8List.fromList(bytes),
      targetWidth: _cellWidth,
    );

    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  ui.Rect _coverSourceRect({
    required double imageWidth,
    required double imageHeight,
    required double destinationWidth,
    required double destinationHeight,
  }) {
    final imageRatio = imageWidth / imageHeight;
    final destinationRatio = destinationWidth / destinationHeight;

    if (imageRatio > destinationRatio) {
      final sourceWidth = imageHeight * destinationRatio;
      final left = (imageWidth - sourceWidth) / 2;
      return ui.Rect.fromLTWH(left, 0, sourceWidth, imageHeight);
    }

    final sourceHeight = imageWidth / destinationRatio;
    final top = (imageHeight - sourceHeight) / 2;
    return ui.Rect.fromLTWH(0, top, imageWidth, sourceHeight);
  }

  String _buildPrompt({
    required String roomName,
    required String roomType,
    required int photoCount,
  }) {
    return '''
La planche contient $photoCount vues d’une seule pièce d’état des lieux.

Pièce : $roomName
Type déclaré : $roomType

Retourne uniquement le JSON demandé.

RÈGLE PRIORITAIRE POUR LES MURS
- La clé « Mur » reçoit la description commune à tous les murs de la pièce.
- Les clés « Mur avant », « Mur droit », « Mur arrière » et « Mur gauche » reçoivent uniquement les différences, défauts ou particularités propres à ces murs.
- Ne répète jamais dans les quatre murs une finition déjà placée dans « Mur ».
- Lorsqu'un poste descriptif ne présente aucune observation particulière, écris exactement « Sans remarque. ». Pour Électricité et Mobilier, laisse une chaîne vide s'il n'y a rien de visible.
- N'énumère jamais des absences de défauts. N'écris pas « pas de fissure », « pas de trou » ou équivalent.

${InspectionKnowledge.roomPhotoRules}
''';
  }

  Map<String, dynamic> _buildRequestBody(List<Map<String, dynamic>> content) {
    final sectionProperties = <String, dynamic>{
      'Plafond': {'type': 'string'},
      'Mur': {'type': 'string'},
      'Mur avant': {'type': 'string'},
      'Mur droit': {'type': 'string'},
      'Mur arrière': {'type': 'string'},
      'Mur gauche': {'type': 'string'},
      'Menuiserie intérieure': {'type': 'string'},
      'Menuiserie extérieure': {'type': 'string'},
      'Électricité': {'type': 'string'},
      'Chauffage': {'type': 'string'},
      'Sol': {'type': 'string'},
      'Mobilier': {'type': 'string'},
    };

    final worktopProperties = <String, dynamic>{
      'Évier': {'type': 'string'},
      'Égouttoir': {'type': 'string'},
      'Robinetterie': {'type': 'string'},
      'Taque vitrocéramique': {'type': 'string'},
      'Taque à induction': {'type': 'string'},
      'Taque au gaz': {'type': 'string'},
      'Hotte': {'type': 'string'},
      'Crédence': {'type': 'string'},
      'Prises': {'type': 'string'},
      'Éclairage du plan de travail': {'type': 'string'},
      'Autre équipement': {'type': 'string'},
    };

    return <String, dynamic>{
      'max_output_tokens': 1200,
      'input': [
        {'role': 'user', 'content': content},
      ],
      'text': {
        'format': {
          'type': 'json_schema',
          'name': 'room_photo_analysis',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'properties': {
              'sections': {
                'type': 'object',
                'additionalProperties': false,
                'properties': sectionProperties,
                'required': sectionProperties.keys.toList(),
              },
              'hasKitchen': {'type': 'boolean'},
              'kitchenGeneral': {'type': 'string'},
              'worktop': {'type': 'string'},
              'worktopEquipment': {
                'type': 'object',
                'additionalProperties': false,
                'properties': worktopProperties,
                'required': worktopProperties.keys.toList(),
              },
              'upperUnits': {'type': 'array', 'items': _unitSchema},
              'lowerUnits': {'type': 'array', 'items': _unitSchema},
            },
            'required': [
              'sections',
              'hasKitchen',
              'kitchenGeneral',
              'worktop',
              'worktopEquipment',
              'upperUnits',
              'lowerUnits',
            ],
          },
        },
      },
    };
  }

  Map<String, dynamic> get _unitSchema => <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'type': {'type': 'string'},
      'comment': {'type': 'string'},
    },
    'required': ['type', 'comment'],
  };

  void _throwForHttpError({
    required int statusCode,
    required String responseText,
  }) {
    if (statusCode == 402) {
      final decoded = jsonDecode(responseText);
      final reason = decoded is Map ? decoded['reason']?.toString() : null;
      throw FormatException(
        reason == 'ai_quota_reached'
            ? 'Votre quota d’analyses IA est épuisé.'
            : 'Une offre active avec des analyses IA est nécessaire.',
      );
    }

    if (statusCode == 401) {
      throw const FormatException(
        'Connectez-vous pour utiliser l’analyse automatique.',
      );
    }

    if (statusCode == 429) {
      throw const FormatException(
        'Le quota OpenAI est insuffisant. Vérifiez les crédits et la '
        'facturation du compte API.',
      );
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw HttpException('Analyse impossible ($statusCode) : $responseText');
    }
  }

  String _extractOutputText(String responseText) {
    final decoded = jsonDecode(responseText);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Réponse OpenAI invalide.');
    }

    var outputText = decoded['output_text']?.toString();

    final outputs = decoded['output'];
    if (outputs is List) {
      for (final output in outputs) {
        if (output is! Map) continue;

        final parts = output['content'];
        if (parts is! List) continue;

        for (final part in parts) {
          if (part is Map && part['type'] == 'output_text') {
            outputText = part['text']?.toString();
          }
        }
      }
    }

    if (outputText == null || outputText.trim().isEmpty) {
      throw const FormatException(
        'La réponse ne contient aucune analyse exploitable.',
      );
    }

    return outputText;
  }
}
