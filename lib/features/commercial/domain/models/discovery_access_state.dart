import 'discovery_policy.dart';

class DiscoveryAccessState {
  final String userId;
  final DiscoveryPolicy policy;
  final bool hasPaidAccess;
  final Set<String> activeMissionIds;
  final Set<String> paidMissionIds;
  final int aiAnalysesUsed;
  final DateTime verifiedAt;
  final DateTime validUntil;

  const DiscoveryAccessState({
    required this.userId,
    required this.policy,
    required this.hasPaidAccess,
    required this.activeMissionIds,
    this.paidMissionIds = const <String>{},
    required this.aiAnalysesUsed,
    required this.verifiedAt,
    required this.validUntil,
  }) : assert(aiAnalysesUsed >= 0);

  bool isFreshAt(DateTime instant) => !instant.isAfter(validUntil);

  bool canCreateMission(String missionId) {
    if (hasPaidAccess || activeMissionIds.contains(missionId)) return true;
    return activeMissionIds.length < policy.maxActiveMissions;
  }

  bool hasPaidAccessFor(String missionId) =>
      hasPaidAccess || paidMissionIds.contains(missionId);

  bool canAddRoom(String missionId, int currentRoomCount) =>
      hasPaidAccessFor(missionId) ||
      currentRoomCount < policy.maxFullyDescribedRooms;

  int get remainingAiAnalyses {
    if (hasPaidAccess) return policy.aiAnalysisQuota;
    final remaining = policy.aiAnalysisQuota - aiAnalysesUsed;
    return remaining < 0 ? 0 : remaining;
  }

  DiscoveryAccessState withActiveMission(String missionId) {
    return DiscoveryAccessState(
      userId: userId,
      policy: policy,
      hasPaidAccess: hasPaidAccess,
      activeMissionIds: <String>{...activeMissionIds, missionId},
      paidMissionIds: paidMissionIds,
      aiAnalysesUsed: aiAnalysesUsed,
      verifiedAt: verifiedAt,
      validUntil: validUntil,
    );
  }

  factory DiscoveryAccessState.fromJson(Map<String, dynamic> json) {
    final policyJson = Map<String, dynamic>.from(json['policy'] as Map);
    return DiscoveryAccessState(
      userId: json['user_id'].toString(),
      policy: DiscoveryPolicy.fromJson(policyJson),
      hasPaidAccess: json['has_paid_access'] == true,
      activeMissionIds: (json['active_mission_ids'] as List? ?? const [])
          .map((value) => value.toString())
          .toSet(),
      paidMissionIds: (json['paid_mission_ids'] as List? ?? const [])
          .map((value) => value.toString())
          .toSet(),
      aiAnalysesUsed: _integer(json['ai_analyses_used']),
      verifiedAt: DateTime.parse(json['verified_at'].toString()).toUtc(),
      validUntil: DateTime.parse(json['valid_until'].toString()).toUtc(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_id': userId,
    'policy': policy.toJson(),
    'has_paid_access': hasPaidAccess,
    'active_mission_ids': activeMissionIds.toList(growable: false),
    'paid_mission_ids': paidMissionIds.toList(growable: false),
    'ai_analyses_used': aiAnalysesUsed,
    'verified_at': verifiedAt.toIso8601String(),
    'valid_until': validUntil.toIso8601String(),
  };

  static int _integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    _ => int.tryParse(value?.toString() ?? '') ?? 0,
  };
}
