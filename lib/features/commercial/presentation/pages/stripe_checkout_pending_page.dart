import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/billing/stripe_billing_controller.dart';
import '../../domain/models/commercial_enums.dart';
import 'payment_status_page.dart';

class StripeCheckoutPendingPage extends StatefulWidget {
  final String sessionId;

  const StripeCheckoutPendingPage({super.key, required this.sessionId});

  @override
  State<StripeCheckoutPendingPage> createState() =>
      _StripeCheckoutPendingPageState();
}

class _StripeCheckoutPendingPageState extends State<StripeCheckoutPendingPage> {
  final StripeBillingController _controller = StripeBillingController();
  Timer? _timer;
  bool _checking = false;
  String _status = 'open';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
    _check();
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final status = await _controller.checkoutStatus(widget.sessionId);
      if (!mounted) return;
      setState(() => _status = status);
      if (status == 'complete') {
        _timer?.cancel();
        await Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => const PaymentStatusPage(
              outcome: PurchaseOutcome.succeeded,
              message:
                  'Le webhook Stripe a confirmé le paiement et actualisé vos droits.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = 'connexion temporairement indisponible');
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation Stripe')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text(
                    'Paiement en attente de confirmation',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Terminez Stripe Checkout dans votre navigateur. Cette page attend le webhook sécurisé ; fermer le navigateur ne valide pas le paiement.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text('État serveur : $_status'),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _checking ? null : _check,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Vérifier maintenant'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
