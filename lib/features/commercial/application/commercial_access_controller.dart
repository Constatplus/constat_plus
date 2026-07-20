import '../../../core/access/access_service.dart';
import '../domain/models/commercial_enums.dart';
import '../domain/models/consumption_result.dart';
import '../infrastructure/repositories/supabase_usage_repository.dart';

class CommercialAccessController {
  CommercialAccessController([this._usageRepository]);

  final SupabaseUsageRepository? _usageRepository;

  Future<ConsumptionResult> authorizeFinalReport({
    required String missionId,
    required String missionType,
  }) async {
    if (AccessService.instance.isDemo) {
      return const ConsumptionResult(
        allowed: false,
        reason: EntitlementReason.missionPaymentRequired,
      );
    }
    return (_usageRepository ?? SupabaseUsageRepository()).consumeMission(
      missionId: missionId,
      missionType: missionType,
      idempotencyKey: 'mission-final:$missionId',
    );
  }

  Future<ConsumptionResult> authorizeWordExport({
    required String missionId,
  }) async {
    if (AccessService.instance.isDemo) {
      return const ConsumptionResult(
        allowed: false,
        reason: EntitlementReason.missionPaymentRequired,
      );
    }
    return (_usageRepository ?? SupabaseUsageRepository()).authorizePaidExport(
      missionId: missionId,
    );
  }
}
