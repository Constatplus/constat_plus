class UsagePeriod {
  final String id;
  final String? userId;
  final String? organizationId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int missionsUsed;
  final int aiAnalysesUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UsagePeriod({
    required this.id,
    this.userId,
    this.organizationId,
    required this.periodStart,
    required this.periodEnd,
    required this.missionsUsed,
    required this.aiAnalysesUsed,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(userId != null || organizationId != null),
       assert(missionsUsed >= 0),
       assert(aiAnalysesUsed >= 0);

  int remainingMissions(int quota) => (quota - missionsUsed).clamp(0, quota);

  int remainingAiAnalyses(int quota) =>
      (quota - aiAnalysesUsed).clamp(0, quota);

  bool contains(DateTime instant) =>
      !instant.isBefore(periodStart) && instant.isBefore(periodEnd);
}
