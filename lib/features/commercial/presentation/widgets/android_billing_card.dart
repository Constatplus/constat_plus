import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/access/access_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../application/billing/android_billing_controller.dart';
import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../pages/payment_status_page.dart';

class AndroidBillingCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final String? missionId;

  const AndroidBillingCard({super.key, required this.plan, this.missionId});

  @override
  State<AndroidBillingCard> createState() => _AndroidBillingCardState();
}

class _AndroidBillingCardState extends State<AndroidBillingCard> {
  final AndroidBillingController _controller = AndroidBillingController();
  BillingProduct? _product;
  StreamSubscription<PurchaseUpdate>? _updates;
  Object? _error;
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid &&
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
    if (!Platform.isAndroid) {
      return const Card(
        color: Color(0xFFFFF7ED),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Cette offre sera payable par Stripe sur Windows et par Apple sur iPhone/iPad dans les prochains lots.',
          ),
        ),
      );
    }
    if (AccessService.instance.isDemo || AuthService.currentUser == null) {
      return const Card(
        color: Color(0xFFFFF7ED),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Connectez-vous avec un compte réel pour acheter cette offre avec Google Play.',
          ),
        ),
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _product == null) {
      return Card(
        color: const Color(0xFFFFF7ED),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(_error?.toString() ?? 'Produit Google Play indisponible.'),
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
              'Prix Google Play : ${_product!.displayPrice}. '
              'Les droits seront activés uniquement après validation serveur.',
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
              : const Icon(Icons.payment_outlined),
          label: Text(
            _purchasing
                ? 'Confirmation Google Play en cours…'
                : 'Acheter avec Google Play',
          ),
        ),
      ],
    );
  }
}
