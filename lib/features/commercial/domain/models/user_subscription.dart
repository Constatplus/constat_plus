import 'commercial_enums.dart';

class UserSubscription {
  final String id;
  final String userId;
  final String? organizationId;
  final String planCode;
  final PaymentProviderKind provider;
  final String? providerCustomerId;
  final String providerSubscriptionId;
  final String providerProductId;
  final String? providerPurchaseToken;
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? canceledAt;
  final DateTime? gracePeriodEnd;
  final DateTime lastVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    this.organizationId,
    required this.planCode,
    required this.provider,
    this.providerCustomerId,
    required this.providerSubscriptionId,
    required this.providerProductId,
    this.providerPurchaseToken,
    required this.status,
    required this.startedAt,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.canceledAt,
    this.gracePeriodEnd,
    required this.lastVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool isEffectiveAt(DateTime instant) {
    if (!status.grantsAccess) return false;
    return !instant.isBefore(currentPeriodStart) &&
        instant.isBefore(currentPeriodEnd);
  }
}
