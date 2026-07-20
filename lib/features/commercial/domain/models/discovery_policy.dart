class DiscoveryPolicy {
  final int revision;
  final int maxActiveMissions;
  final int maxFullyDescribedRooms;
  final int aiAnalysisQuota;
  final int cacheTtlHours;
  final int? optionalDurationDays;
  final bool previewEnabled;
  final bool wordExportEnabled;
  final bool finalPdfExportEnabled;

  const DiscoveryPolicy({
    required this.revision,
    required this.maxActiveMissions,
    required this.maxFullyDescribedRooms,
    required this.aiAnalysisQuota,
    required this.cacheTtlHours,
    this.optionalDurationDays,
    required this.previewEnabled,
    required this.wordExportEnabled,
    required this.finalPdfExportEnabled,
  }) : assert(revision > 0),
       assert(maxActiveMissions >= 0),
       assert(maxFullyDescribedRooms >= 0),
       assert(aiAnalysisQuota >= 0),
       assert(cacheTtlHours > 0 && cacheTtlHours <= 24);

  factory DiscoveryPolicy.fromJson(Map<String, dynamic> json) {
    return DiscoveryPolicy(
      revision: _integer(json['revision']),
      maxActiveMissions: _integer(json['max_active_missions']),
      maxFullyDescribedRooms: _integer(json['max_fully_described_rooms']),
      aiAnalysisQuota: _integer(json['ai_analysis_quota']),
      cacheTtlHours: _integer(json['cache_ttl_hours']),
      optionalDurationDays: json['optional_duration_days'] == null
          ? null
          : _integer(json['optional_duration_days']),
      previewEnabled: json['preview_enabled'] == true,
      wordExportEnabled: json['word_export_enabled'] == true,
      finalPdfExportEnabled: json['final_pdf_export_enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'revision': revision,
    'max_active_missions': maxActiveMissions,
    'max_fully_described_rooms': maxFullyDescribedRooms,
    'ai_analysis_quota': aiAnalysisQuota,
    'cache_ttl_hours': cacheTtlHours,
    'optional_duration_days': optionalDurationDays,
    'preview_enabled': previewEnabled,
    'word_export_enabled': wordExportEnabled,
    'final_pdf_export_enabled': finalPdfExportEnabled,
  };

  static int _integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    _ => int.parse(value.toString()),
  };
}
