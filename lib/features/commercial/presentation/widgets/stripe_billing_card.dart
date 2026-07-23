import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/access/access_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../application/billing/stripe_billing_controller.dart';
import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../commercial_formatters.dart';
import '../pages/payment_status_page.dart';
import '../pages/stripe_checkout_pending_page.dart';
import '../secure_checkout_page.dart';

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
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

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
        _product = null;
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _purchase() async {
    final product = _product;

    if (product == null || _purchasing) return;

    setState(() {
      _purchasing = true;
    });

    try {
      final result = await _controller.purchase(
        product,
        missionId: widget.missionId,
      );

      if (!mounted) return;

      final sessionId = result.providerTransactionId;

      if (result.outcome == PurchaseOutcome.pending && sessionId != null) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => StripeCheckoutPendingPage(sessionId: sessionId),
          ),
        );

        return;
      }

      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PaymentStatusPage(
            outcome: result.outcome,
            message: result.message,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PaymentStatusPage(
            outcome: PurchaseOutcome.failed,
            message:
                'Une erreur est survenue lors de l’ouverture du paiement : $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _purchasing = false;
        });
      }
    }
  }

  Future<void> _openSecureCheckout() async {
    final product = _product;

    if (product == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SecureCheckoutPage(
          planName: widget.plan.name,
          priceLabel: product.displayPrice,
          billingLabel: _billingLabel(),
          pricingNotice: _pricingNotice(),
          features: _featuresForPlan(),
          onCheckout: _purchase,
          isLoading: _purchasing,
        ),
      ),
    );
  }

  String _billingLabel() {
    if (widget.plan.code.endsWith('_annual')) {
      return '/ an';
    }
    final planName = widget.plan.name.toLowerCase();

    if (planName.contains('solo') || planName.contains('pro')) {
      return '/ mois';
    }

    return 'paiement unique';
  }

  List<String> _featuresForPlan() {
    if (widget.plan.featureLabels.isNotEmpty) {
      return widget.plan.featureLabels;
    }
    final planName = widget.plan.name.toLowerCase();

    if (planName.contains('pro')) {
      return const [
        'Jusqu’à 10 états des lieux par mois',
        '150 analyses IA par mois',
        'Toutes les fonctionnalités Solo',
        'Gestion d’équipe',
        'Tableau de bord entreprise',
        'Contrôle interne',
        'Affectation des experts',
        'Historique complet',
        'Communication interne par dossier',
      ];
    }

    if (planName.contains('solo')) {
      return const [
        'Jusqu’à 5 états des lieux par mois',
        '50 analyses IA par mois',
        'Rapports PDF et Word',
        'Signature électronique',
        'Sauvegarde cloud',
      ];
    }

    return const [
      'Utilisable pour un seul état des lieux',
      '5 analyses IA',
      'Pas d’abonnement',
    ];
  }

  String _pricingNotice() {
    final additionalPrice = widget.plan.additionalMissionPriceMinor;
    if (additionalPrice != null) {
      return 'Prix affiché ${widget.plan.taxDisplay.label}. Au-delà des ${widget.plan.missionQuota} états des lieux inclus, chaque état des lieux supplémentaire est facturé ${CommercialFormatters.money(additionalPrice, widget.plan.currency)} HTVA.';
    }
    return 'Prix affiché ${widget.plan.taxDisplay.label}. Paiement unique sans abonnement.';
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return const SizedBox.shrink();
    }

    if (AccessService.instance.isDemo || AuthService.currentUser == null) {
      return Card(
        elevation: 0,
        color: const Color(0xFFFFF7ED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFFED7AA)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFFEA580C)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Connectez-vous avec un compte réel pour acheter cette offre.',
                  style: TextStyle(height: 1.4, color: Color(0xFF9A3412)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _product == null) {
      return Card(
        elevation: 0,
        color: const Color(0xFFFFF7ED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFFED7AA)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Le prix de cette offre est temporairement indisponible.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _error?.toString() ?? 'Prix Stripe indisponible.',
                style: const TextStyle(height: 1.4, color: Color(0xFF7C2D12)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock_outline, color: Color(0xFF1264F6)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Paiement sécurisé',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Prix de l’offre : ${_product!.displayPrice}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choisissez votre moyen de paiement sur la page sécurisée : Bancontact, Visa, Mastercard, Apple Pay ou Google Pay selon les moyens activés.',
                  style: TextStyle(height: 1.45, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PaymentMethodBadge(label: 'Bancontact'),
                    _PaymentMethodBadge(label: 'Visa'),
                    _PaymentMethodBadge(label: 'Mastercard'),
                    _PaymentMethodBadge(label: 'Apple Pay'),
                    _PaymentMethodBadge(label: 'Google Pay'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _purchasing ? null : _openSecureCheckout,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFF1264F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: _purchasing
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.lock_outline),
          label: Text(
            _purchasing
                ? 'Ouverture du paiement…'
                : 'S’abonner – Paiement sécurisé',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Les Conditions Générales d’Utilisation et les Conditions Générales de Vente devront être acceptées avant le paiement.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodBadge extends StatelessWidget {
  final String label;

  const _PaymentMethodBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}
