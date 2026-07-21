import 'package:flutter/material.dart';

import '../../legal/legal_documents_page.dart';

class SecureCheckoutPage extends StatefulWidget {
  const SecureCheckoutPage({
    super.key,
    required this.planName,
    required this.priceLabel,
    required this.billingLabel,
    required this.pricingNotice,
    required this.features,
    required this.onCheckout,
    this.isLoading = false,
  });

  final String planName;
  final String priceLabel;
  final String billingLabel;
  final String pricingNotice;
  final List<String> features;
  final Future<void> Function() onCheckout;
  final bool isLoading;

  @override
  State<SecureCheckoutPage> createState() => _SecureCheckoutPageState();
}

class _SecureCheckoutPageState extends State<SecureCheckoutPage> {
  bool _acceptedTerms = false;
  bool _immediatePerformance = false;
  bool _localLoading = false;

  bool get _isBusy => widget.isLoading || _localLoading;

  bool get _isSubscription {
    final planName = widget.planName.toLowerCase();
    return planName.contains('solo') || planName.contains('pro');
  }

  String get _checkoutButtonLabel {
    if (_isBusy) {
      return 'Ouverture du paiement…';
    }

    return _isSubscription ? 'S’abonner maintenant' : 'Payer maintenant';
  }

  Future<void> _startCheckout() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions générales.'),
        ),
      );
      return;
    }

    if (!_immediatePerformance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez confirmer votre demande d’accès immédiat au service.',
          ),
        ),
      );
      return;
    }

    setState(() => _localLoading = true);

    try {
      await widget.onCheckout();
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  void _openLegal(LegalDocumentType document) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentsPage(initialDocument: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        title: const Text('Paiement sécurisé'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 850;

            if (compact) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      children: [
                        _buildPlanCard(context),
                        const SizedBox(height: 20),
                        _buildPaymentCard(context),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPlanCard(context)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildPaymentCard(context)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.planName.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF1264F6),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                widget.priceLabel,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  widget.billingLabel,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              widget.pricingNotice,
              style: const TextStyle(
                height: 1.4,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...widget.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 21,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        height: 1.4,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isSubscription
                      ? 'Vous pourrez gérer ou résilier votre abonnement '
                            'depuis votre compte ou depuis la boutique utilisée '
                            'pour l’achat.'
                      : 'La mission est consommée uniquement lors de la '
                            'génération du rapport définitif.',
                  style: const TextStyle(height: 1.4, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF1264F6)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Paiement 100 % sécurisé',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Le paiement s’ouvre dans une page sécurisée. '
            'Constat+ ne stocke aucune donnée bancaire complète.',
            style: TextStyle(height: 1.45, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),
          const Text(
            'Moyens de paiement proposés',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PaymentBadge(label: 'Bancontact'),
              _PaymentBadge(label: 'Visa'),
              _PaymentBadge(label: 'Mastercard'),
              _PaymentBadge(label: 'Apple Pay'),
              _PaymentBadge(label: 'Google Pay'),
            ],
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _acceptedTerms,
              onChanged: _isBusy
                  ? null
                  : (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('J’ai lu et j’accepte les '),
                  _LegalLink(
                    label: 'Conditions Générales d’Utilisation',
                    onTap: () => _openLegal(LegalDocumentType.termsOfUse),
                  ),
                  const Text(' et les '),
                  _LegalLink(
                    label: 'Conditions Générales de Vente',
                    onTap: () => _openLegal(LegalDocumentType.termsOfSale),
                  ),
                  const Text('.'),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _immediatePerformance,
              onChanged: _isBusy
                  ? null
                  : (value) {
                      setState(() {
                        _immediatePerformance = value ?? false;
                      });
                    },
              title: const Text(
                'Je demande l’accès immédiat au service avant l’expiration '
                'du délai légal de rétractation. Les conséquences éventuelles '
                'sur ce droit me seront confirmées lors du paiement.',
                style: TextStyle(height: 1.35),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _isBusy ? null : _startCheckout,
              icon: _isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_outline),
              label: Text(
                _checkoutButtonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1264F6),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF94A3B8),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Transaction chiffrée • Aucun numéro de carte conservé',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(22);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1264F6),
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
