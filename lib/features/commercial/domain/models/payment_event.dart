import 'commercial_enums.dart';

class PaymentEvent {
  final String id;
  final PaymentProviderKind provider;
  final String providerEventId;
  final String eventType;
  final String payloadHash;
  final DateTime receivedAt;
  final DateTime? processedAt;
  final bool processed;
  final String? processingError;

  const PaymentEvent({
    required this.id,
    required this.provider,
    required this.providerEventId,
    required this.eventType,
    required this.payloadHash,
    required this.receivedAt,
    this.processedAt,
    required this.processed,
    this.processingError,
  });
}
