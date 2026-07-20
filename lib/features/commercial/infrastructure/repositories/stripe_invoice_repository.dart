import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/billing_document.dart';
import '../../domain/models/commercial_enums.dart';

class StripeInvoiceRepository {
  StripeInvoiceRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<BillingDocument>> loadInvoices() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final response = await _client.functions.invoke(
      'stripe-customer-tools',
      body: const <String, dynamic>{'action': 'invoices'},
    );
    final data = response.data is Map ? response.data as Map : const {};
    if (response.status != 200) {
      throw StateError(
        data['message']?.toString() ?? 'Factures indisponibles.',
      );
    }
    final invoices = data['invoices'];
    if (invoices is! List) return const [];
    return invoices
        .whereType<Map>()
        .map((invoice) {
          final url = invoice['pdfUrl'] ?? invoice['hostedUrl'];
          return BillingDocument(
            id: invoice['id'].toString(),
            userId: user.id,
            provider: PaymentProviderKind.stripe,
            providerDocumentId: invoice['id'].toString(),
            number: invoice['number']?.toString() ?? '',
            amountMinor: (invoice['amount'] as num?)?.toInt() ?? 0,
            currency: invoice['currency']?.toString() ?? 'EUR',
            issuedAt: DateTime.parse(invoice['issuedAt'].toString()),
            hostedUrl: url == null ? null : Uri.tryParse(url.toString()),
          );
        })
        .toList(growable: false);
  }
}
