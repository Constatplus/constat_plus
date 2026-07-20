import 'package:image_picker/image_picker.dart';

import 'inspection_ai_service.dart';
import 'vision_service.dart';

class OnlineInspectionAiService implements InspectionAiService {
  OnlineInspectionAiService({VisionService? visionService})
    : _visionService = visionService ?? VisionService();

  final VisionService _visionService;

  @override
  InspectionAiEngine get engine => InspectionAiEngine.online;

  @override
  Future<InspectionAnalysis> analyzePhotos({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  }) async {
    final result = await _visionService.analyzeRoom(
      missionId: missionId,
      missionType: missionType,
      idempotencyKey: idempotencyKey,
      roomName: roomName,
      roomType: roomType,
      photos: photos,
    );
    return InspectionAnalysis(
      sections: result.sections,
      hasKitchen: result.hasKitchen,
      kitchenGeneral: result.kitchenGeneral,
      worktop: result.worktop,
      worktopEquipment: result.worktopEquipment,
      upperUnits: result.upperUnits,
      lowerUnits: result.lowerUnits,
      engine: engine,
      confidence: InspectionConfidence.medium,
    );
  }

  @override
  Future<String> improveDescription({
    required String description,
    required String missionType,
  }) {
    throw UnsupportedError(
      'La reformulation en ligne sera raccordée sans changer le fournisseur actuel.',
    );
  }

  @override
  Future<List<TechnicalSuggestion>> suggestVocabulary({
    required String query,
    required String missionType,
    String? element,
  }) {
    throw UnsupportedError(
      'Les suggestions de vocabulaire seront ajoutées à l’étape 3.',
    );
  }
}
