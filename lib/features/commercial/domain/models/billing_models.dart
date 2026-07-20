import 'commercial_enums.dart';

class BillingProduct {
  final String id;
  final String planCode;
  final ProductKind kind;
  final String title;
  final String description;
  final String displayPrice;

  const BillingProduct({
    required this.id,
    required this.planCode,
    required this.kind,
    required this.title,
    required this.description,
    required this.displayPrice,
  });
}

class PurchaseRequest {
  final BillingProduct product;
  final String userId;
  final String? missionId;
  final String idempotencyKey;

  const PurchaseRequest({
    required this.product,
    required this.userId,
    this.missionId,
    required this.idempotencyKey,
  });
}

class PurchaseResult {
  final PurchaseOutcome outcome;
  final PaymentProviderKind provider;
  final String? providerTransactionId;
  final String? message;

  const PurchaseResult({
    required this.outcome,
    required this.provider,
    this.providerTransactionId,
    this.message,
  });
}

class PurchaseUpdate {
  final PaymentProviderKind provider;
  final String productId;
  final String providerTransactionId;
  final PurchaseOutcome outcome;
  final String? message;

  const PurchaseUpdate({
    required this.provider,
    required this.productId,
    required this.providerTransactionId,
    required this.outcome,
    this.message,
  });
}
