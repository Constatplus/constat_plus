import 'package:flutter/material.dart';

import '../../core/access/access_service.dart';

Future<bool> showOccasionalPaywallDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const Icon(Icons.lock_outline_rounded, size: 42),
        title: const Text('Débloquez cette mission'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: const Text(
            'Vous avez terminé les trois premières pièces du mode découverte. '
            'Le paiement unique de 69 € débloque la suite de cette mission, '
            'l’analyse IA et les exports Word/PDF.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Plus tard'),
          ),
          FilledButton.icon(
            onPressed: () {
              AccessService.instance.unlockOccasionalMissionForTesting();
              Navigator.pop(dialogContext, true);
            },
            icon: const Icon(Icons.credit_card_rounded),
            label: const Text('Paiement test — 69 €'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
