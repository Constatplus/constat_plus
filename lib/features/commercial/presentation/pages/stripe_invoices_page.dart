import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/billing_document.dart';
import '../../infrastructure/repositories/stripe_invoice_repository.dart';
import '../commercial_formatters.dart';

class StripeInvoicesPage extends StatefulWidget {
  const StripeInvoicesPage({super.key});

  @override
  State<StripeInvoicesPage> createState() => _StripeInvoicesPageState();
}

class _StripeInvoicesPageState extends State<StripeInvoicesPage> {
  late Future<List<BillingDocument>> _invoices;

  @override
  void initState() {
    super.initState();
    _invoices = StripeInvoiceRepository().loadInvoices();
  }

  void _retry() {
    setState(() => _invoices = StripeInvoiceRepository().loadInvoices());
  }

  Future<void> _open(BillingDocument invoice) async {
    final url = invoice.hostedUrl;
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document Stripe indisponible.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes factures Stripe')),
      body: FutureBuilder<List<BillingDocument>>(
        future: _invoices,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          final invoices = snapshot.data ?? const [];
          if (invoices.isEmpty) {
            return const Center(
              child: Text('Aucune facture Stripe disponible.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: invoices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(
                    invoice.number.isEmpty ? 'Facture Stripe' : invoice.number,
                  ),
                  subtitle: Text(CommercialFormatters.date(invoice.issuedAt)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CommercialFormatters.money(
                          invoice.amountMinor,
                          invoice.currency,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Ouvrir la facture',
                        onPressed: invoice.hostedUrl == null
                            ? null
                            : () => _open(invoice),
                        icon: const Icon(Icons.open_in_new),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
