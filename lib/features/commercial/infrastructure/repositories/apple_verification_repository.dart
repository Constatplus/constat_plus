import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/commercial_enums.dart';

class AppleVerificationResult {
  final bool verified;
  final PurchaseOutcome outcome;
  final String? transactionId;
  final String? message;

  const AppleVerificationResult({
    required this.verified,
    required this.outcome,
    this.transactionId,
    this.message,
  });
}

class AppleVerificationRepository {
  AppleVerificationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AppleVerificationResult> verify({
    required String productId,
    required String transactionId,
    required String signedTransaction,
    required ProductKind productKind,
    String? missionId,
  }) async {
    final body = <String, dynamic>{
      'productId': productId,
      'transactionId': transactionId,
      'signedTransaction': signedTransaction,
      'productKind': productKind == ProductKind.subscription
          ? 'subscription'
          : 'one_time',
      'missionId': ?missionId,
    };
    final response = await _client.functions.invoke('apple-verify', body: body);
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    if (response.status < 200 || response.status >= 300) {
      return AppleVerificationResult(
        verified: false,
        outcome: PurchaseOutcome.failed,
        message:
            data['message']?.toString() ?? 'Validation serveur Apple refusée.',
      );
    }
    final status = data['status']?.toString();
    return AppleVerificationResult(
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
