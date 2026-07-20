import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/commercial_enums.dart';

class GooglePlayVerificationResult {
  final bool verified;
  final PurchaseOutcome outcome;
  final String? transactionId;
  final String? message;

  const GooglePlayVerificationResult({
    required this.verified,
    required this.outcome,
    this.transactionId,
    this.message,
  });
}

class GooglePlayVerificationRepository {
  GooglePlayVerificationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<GooglePlayVerificationResult> verify({
    required String productId,
    required String purchaseToken,
    required ProductKind productKind,
    String? missionId,
  }) async {
    final body = <String, dynamic>{
      'productId': productId,
      'purchaseToken': purchaseToken,
      'productKind': productKind == ProductKind.subscription
          ? 'subscription'
          : 'one_time',
    };
    if (missionId case final missionId?) {
      body['missionId'] = missionId;
    }
    final response = await _client.functions.invoke(
      'google-play-verify',
      body: body,
    );
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    if (response.status < 200 || response.status >= 300) {
      return GooglePlayVerificationResult(
        verified: false,
        outcome: PurchaseOutcome.failed,
        message: data['message']?.toString() ?? 'Validation serveur refusée.',
      );
    }
    final status = data['status']?.toString();
    return GooglePlayVerificationResult(
      verified: data['verified'] == true,
      outcome: status == 'pending'
          ? PurchaseOutcome.pending
          : data['verified'] == true
          ? PurchaseOutcome.succeeded
          : PurchaseOutcome.failed,
      transactionId: data['transactionId']?.toString(),
      message: data['message']?.toString(),
    );
  }
}
