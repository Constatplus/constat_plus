import 'commercial_enums.dart';

class ConsumptionResult {
  final bool allowed;
  final EntitlementReason reason;
  final bool alreadyConsumed;

  const ConsumptionResult({
    required this.allowed,
    required this.reason,
    this.alreadyConsumed = false,
  });
}
