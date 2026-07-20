import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/access/access_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../application/billing/apple_billing_controller.dart';
import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../pages/payment_status_page.dart';

class AppleBillingCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final String? missionId;

  const AppleBillingCard({super.key, required this.plan, this.missionId});

  @override
  State<AppleBillingCard> createState() => _AppleBillingCardState();
}

class _AppleBillingCardState extends State<AppleBillingCard> {
  final AppleBillingController _controller = AppleBillingController();
  BillingProduct? _product;
  StreamSubscription<PurchaseUpdate>? _updates;
  Object? _error;
  bool _loading = true;
  bool _purchasing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS &&
        !AccessService.instance.isDemo &&
        AuthService.currentUser != null) {
      _load();
      _updates = _controller.updates.listen(_handleUpdate);
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
    setState(() => _purchasing = result.outcome == PurchaseOutcome.pending);
    if (result.outcome != PurchaseOutcome.pending) {
      await _openStatus(result.outcome, result.message);
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      await _controller.restorePurchases();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restauration Apple lancée.')),
      );
    } catch (error) {
      if (!mounted) return;
      await _openStatus(PurchaseOutcome.failed, error.toString());
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _handleUpdate(PurchaseUpdate update) async {
    if (!mounted || update.productId != _product?.id) return;
    setState(() => _purchasing = update.outcome == PurchaseOutcome.pending);
    if (update.outcome != PurchaseOutcome.pending) {
      await _openStatus(update.outcome, update.message);
    }
  }

  Future<void> _openStatus(PurchaseOutcome outcome, String? message) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PaymentStatusPage(outcome: outcome, message: message),
      ),
    );
  }

  @override
  void dispose() {
    _updates?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox.shrink();
    if (AccessService.instance.isDemo || AuthService.currentUser == null) {
      return const Card(
        color: Color(0xFFFFF7ED),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Connectez-vous avec un compte réel pour acheter via l’App Store.',
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
              Text(_error?.toString() ?? 'Produit Apple indisponible.'),
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
              'Prix App Store : ${_product!.displayPrice}. Les droits sont '
              'activés uniquement après validation serveur Apple.',
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
              : const Icon(Icons.apple),
          label: Text(
            _purchasing ? 'Confirmation Apple en cours…' : 'Acheter avec Apple',
          ),
        ),
        TextButton.icon(
          onPressed: _restoring ? null : _restore,
          icon: const Icon(Icons.restore),
          label: Text(_restoring ? 'Restauration…' : 'Restaurer mes achats'),
        ),
      ],
    );
  }
}
