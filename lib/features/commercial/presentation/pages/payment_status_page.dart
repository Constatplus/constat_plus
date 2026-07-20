import 'package:flutter/material.dart';

import '../../domain/models/commercial_enums.dart';

class PaymentStatusPage extends StatelessWidget {
  final PurchaseOutcome outcome;
  final String? message;

  const PaymentStatusPage({super.key, required this.outcome, this.message});

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, fallback) = switch (outcome) {
      PurchaseOutcome.succeeded => (
        Icons.check_circle_outline,
        const Color(0xFF15803D),
        'Paiement confirmé',
        'Google Play a confirmé le paiement et le serveur Constat+ a actualisé vos droits.',
      ),
      PurchaseOutcome.pending => (
        Icons.schedule_outlined,
        const Color(0xFFB45309),
        'Paiement en attente',
        'Google Play attend encore la finalisation du paiement. Aucun droit n’est accordé avant la confirmation serveur.',
      ),
      PurchaseOutcome.canceled => (
        Icons.cancel_outlined,
        const Color(0xFF64748B),
        'Paiement annulé',
        'Aucun paiement ni droit supplémentaire n’a été enregistré.',
      ),
      PurchaseOutcome.failed => (
        Icons.error_outline,
        const Color(0xFFB42318),
        'Paiement non validé',
        'Le paiement n’a pas pu être confirmé. Vous pouvez réessayer sans double facturation.',
      ),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement Google Play')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 68),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message?.trim().isNotEmpty == true ? message! : fallback,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour aux offres'),
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
