import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/commercial_enums.dart';
import '../../domain/models/consumption_result.dart';
import '../../domain/models/usage_period.dart';
import '../../domain/repositories/commercial_repositories.dart';

class SupabaseUsageRepository implements UsageRepository {
  SupabaseUsageRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<UsagePeriod?> getCurrentPeriod() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('usage_periods')
        .select()
        .eq('user_id', userId)
        .lte('period_start', DateTime.now().toUtc().toIso8601String())
        .gt('period_end', DateTime.now().toUtc().toIso8601String())
        .order('period_end', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return UsagePeriod(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      organizationId: row['organization_id'] as String?,
      periodStart: DateTime.parse(row['period_start'] as String),
      periodEnd: DateTime.parse(row['period_end'] as String),
      missionsUsed: row['missions_used'] as int,
      aiAnalysesUsed: row['ai_analyses_used'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Future<ConsumptionResult> consumeMission({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
  }) async {
    final value = await _client.rpc(
      'consume_mission_entitlement',
      params: <String, dynamic>{
        'p_mission_id': missionId,
        'p_mission_type': missionType,
        'p_idempotency_key': idempotencyKey,
      },
    );
    return _parse(value);
  }

  @override
  Future<ConsumptionResult> consumeAiAnalysis({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
  }) async {
    final value = await _client.rpc(
      'consume_ai_analysis',
      params: <String, dynamic>{
        'p_mission_id': missionId,
        'p_mission_type': missionType,
        'p_idempotency_key': idempotencyKey,
      },
    );
    return _parse(value);
  }

  Future<ConsumptionResult> authorizePaidExport({
    required String missionId,
  }) async {
    final value = await _client.rpc(
      'can_export_paid_report',
      params: <String, dynamic>{'p_mission_id': missionId},
    );
    return _parse(value);
  }

  static ConsumptionResult _parse(dynamic value) {
    final json = value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
    final allowed = json['allowed'] == true;
    return ConsumptionResult(
      allowed: allowed,
      reason: allowed
          ? EntitlementReason.allowed
          : _reason(json['reason']?.toString()),
      alreadyConsumed: json['already_consumed'] == true,
    );
  }

  static EntitlementReason _reason(String? value) => switch (value) {
    'not_authenticated' => EntitlementReason.notAuthenticated,
    'account_inactive' => EntitlementReason.accountInactive,
    'mission_not_found' => EntitlementReason.missionNotFound,
    'mission_quota_reached' => EntitlementReason.missionQuotaReached,
    'subscription_required' => EntitlementReason.subscriptionRequired,
    _ => EntitlementReason.missionPaymentRequired,
  };
}
