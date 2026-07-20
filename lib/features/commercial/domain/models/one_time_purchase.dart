import 'commercial_enums.dart';

class OneTimePurchase {
  final String id;
  final String userId;
  final String? missionId;
  final PaymentProviderKind provider;
  final String providerTransactionId;
  final String providerProductId;
  final int amountMinor;
  final String currency;
  final PurchaseStatus status;
  final DateTime purchasedAt;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OneTimePurchase({
    required this.id,
    required this.userId,
    this.missionId,
    required this.provider,
    required this.providerTransactionId,
    required this.providerProductId,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.purchasedAt,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(amountMinor >= 0),
       assert(currency.length == 3);

  bool get canBeAssigned =>
      status == PurchaseStatus.verified && missionId == null;
}
