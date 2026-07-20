import 'package:flutter_app/core/ai/inspection_ai_service.dart';
import 'package:flutter_app/core/ai/offline_inspection_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  final online = _FakeInspectionAiService(InspectionAiEngine.online);
  final offline = _FakeInspectionAiService(InspectionAiEngine.offline);

  test('le mode explicite sélectionne toujours le moteur demandé', () async {
    final selector = InspectionAiServiceSelector(
      online: online,
      offline: offline,
      networkAvailable: () async => false,
    );

    expect(
      (await selector.select(InspectionAiMode.online)).engine,
      InspectionAiEngine.online,
    );
    expect(
      (await selector.select(InspectionAiMode.offline)).engine,
      InspectionAiEngine.offline,
    );
  });

  test('le mode automatique bascule hors ligne sans connexion', () async {
    final selector = InspectionAiServiceSelector(
      online: online,
      offline: offline,
      networkAvailable: () async => false,
    );

    expect(
      (await selector.select(InspectionAiMode.automatic)).engine,
      InspectionAiEngine.offline,
    );
  });

  test('le mode automatique utilise le service actuel en ligne', () async {
    final selector = InspectionAiServiceSelector(
      online: online,
      offline: offline,
      networkAvailable: () async => true,
    );

    expect(
      (await selector.select(InspectionAiMode.automatic)).engine,
      InspectionAiEngine.online,
    );
  });

  test('le moteur texte local ne prétend pas analyser les photos', () async {
    final service = OfflineInspectionAiService();

    await expectLater(
      service.analyzePhotos(
        missionId: 'mission',
        missionType: 'entry',
        idempotencyKey: 'offline-test',
        roomName: 'Pièce',
        roomType: 'Pièce',
        photos: <XFile>[XFile('photo-locale.jpg')],
      ),
      throwsA(isA<OfflineVisionUnavailableException>()),
    );
  });
}

class _FakeInspectionAiService implements InspectionAiService {
  _FakeInspectionAiService(this.engine);

  @override
  final InspectionAiEngine engine;

  @override
  Future<InspectionAnalysis> analyzePhotos({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  }) async {
    return InspectionAnalysis(
      sections: const <String, String>{},
      hasKitchen: false,
      kitchenGeneral: '',
      worktop: '',
      worktopEquipment: const <String, String>{},
      upperUnits: const <Map<String, String>>[],
      lowerUnits: const <Map<String, String>>[],
      engine: engine,
      confidence: InspectionConfidence.medium,
    );
  }

  @override
  Future<String> improveDescription({
    required String description,
    required String missionType,
  }) async => description;

  @override
  Future<List<TechnicalSuggestion>> suggestVocabulary({
    required String query,
    required String missionType,
    String? element,
  }) async => const <TechnicalSuggestion>[];
}
