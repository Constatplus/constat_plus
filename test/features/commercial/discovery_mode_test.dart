import 'package:flutter_app/features/commercial/domain/models/discovery_access_state.dart';
import 'package:flutter_app/features/commercial/domain/models/discovery_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = DiscoveryPolicy(
    revision: 1,
    maxActiveMissions: 1,
    maxFullyDescribedRooms: 3,
    aiAnalysisQuota: 5,
    cacheTtlHours: 24,
    previewEnabled: true,
    wordExportEnabled: false,
    finalPdfExportEnabled: false,
  );
  final now = DateTime.utc(2026, 7, 20, 12);

  DiscoveryAccessState state({
    bool paid = false,
    Set<String> missions = const <String>{},
    Set<String> paidMissions = const <String>{},
    int aiUsed = 0,
  }) {
    return DiscoveryAccessState(
      userId: 'user-1',
      policy: policy,
      hasPaidAccess: paid,
      activeMissionIds: missions,
      paidMissionIds: paidMissions,
      aiAnalysesUsed: aiUsed,
      verifiedAt: now,
      validUntil: now.add(const Duration(hours: 24)),
    );
  }

  test('limite le mode découverte à une mission active', () {
    expect(state().canCreateMission('mission-1'), isTrue);
    expect(
      state(
        missions: const <String>{'mission-1'},
      ).canCreateMission('mission-2'),
      isFalse,
    );
  });

  test('ouvre le paywall avant la quatrième pièce', () {
    final discovery = state();
    expect(discovery.canAddRoom('mission-1', 2), isTrue);
    expect(discovery.canAddRoom('mission-1', 3), isFalse);
  });

  test('un paiement confirmé reprend la mission sans limite découverte', () {
    final paidMission = state(paidMissions: const <String>{'mission-1'});
    expect(paidMission.canAddRoom('mission-1', 3), isTrue);
    expect(paidMission.canAddRoom('mission-2', 3), isFalse);
  });

  test('le quota IA restant vient uniquement de la politique', () {
    expect(state(aiUsed: 2).remainingAiAnalyses, 3);
    expect(state(aiUsed: 8).remainingAiAnalyses, 0);
  });

  test('les exports gratuits sont désactivés par la politique', () {
    expect(policy.previewEnabled, isTrue);
    expect(policy.wordExportEnabled, isFalse);
    expect(policy.finalPdfExportEnabled, isFalse);
  });
}
