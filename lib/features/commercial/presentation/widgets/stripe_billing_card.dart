import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/access/access_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../application/billing/stripe_billing_controller.dart';
import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../pages/payment_status_page.dart';
import '../pages/stripe_checkout_pending_page.dart';

class StripeBillingCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final String? missionId;

  const StripeBillingCard({super.key, required this.plan, this.missionId});

  @override
  State<StripeBillingCard> createState() => _StripeBillingCardState();
}

class _StripeBillingCardState extends State<StripeBillingCard> {
  final StripeBillingController _controller = StripeBillingController();
  BillingProduct? _product;
  Object? _error;
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows &&
        !AccessService.instance.isDemo &&
        AuthService.currentUser != null) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    try {
      final product = await _controller.loadProduct(widget.plan);
      if (!mounted) return;
      setState(() {
        _product = product;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _purchase() async {
    final product = _product;
    if (product == null) return;
    setState(() => _purchasing = true);
    final result = await _controller.purchase(
      product,
      missionId: widget.missionId,
    );
    if (!mounted) return;
    setState(() => _purchasing = false);
    final sessionId = result.providerTransactionId;
    if (result.outcome == PurchaseOutcome.pending && sessionId != null) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => StripeCheckoutPendingPage(sessionId: sessionId),
        ),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            PaymentStatusPage(outcome: result.outcome, message: result.message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) return const SizedBox.shrink();
    if (AccessService.instance.isDemo || AuthService.currentUser == null) {
      return const Card(
        color: Color(0xFFFFF7ED),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Connectez-vous avec un compte réel pour payer cette offre avec Stripe.',
          ),
        ),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _product == null) {
      return Card(
        color: const Color(0xFFFFF7ED),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(_error?.toString() ?? 'Prix Stripe indisponible.'),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: const Color(0xFFEFF6FF),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Prix Stripe : ${_product!.displayPrice}. Le paiement s’ouvre dans Stripe Checkout et reste en attente jusqu’au webhook.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _purchasing ? null : _purchase,
          icon: _purchasing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.open_in_browser_outlined),
          label: Text(
            _purchasing
                ? 'Ouverture de Stripe…'
                : 'Continuer avec Stripe Checkout',
          ),
        ),
      ],
    );
  }
}
