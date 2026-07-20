import 'commercial_enums.dart';

class BillingDocument {
  final String id;
  final String userId;
  final PaymentProviderKind provider;
  final String providerDocumentId;
  final String number;
  final int amountMinor;
  final String currency;
  final DateTime issuedAt;
  final Uri? hostedUrl;

  const BillingDocument({
    required this.id,
    required this.userId,
    required this.provider,
    required this.providerDocumentId,
    required this.number,
    required this.amountMinor,
    required this.currency,
    required this.issuedAt,
    this.hostedUrl,
  }) : assert(amountMinor >= 0),
       assert(currency.length == 3);
}
