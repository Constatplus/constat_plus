import 'package:flutter/material.dart';

import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../commercial_formatters.dart';

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool highlighted;
  final VoidCallback onDetails;

  const PlanCard({
    super.key,
    required this.plan,
    required this.highlighted,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = highlighted ? Colors.white : const Color(0xFF0F172A);
    final secondary = highlighted
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    return SizedBox(
      width: 340,
      child: Card(
        color: highlighted ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(
            color: highlighted
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (highlighted) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('Pour les professionnels')),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                plan.name,
                style: TextStyle(
                  color: foreground,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: CommercialFormatters.money(
                        plan.priceMinor,
                        plan.currency,
                      ),
                      style: TextStyle(
                        color: foreground,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (plan.billingPeriod == BillingPeriod.monthly)
                      TextSpan(
                        text: ' / mois',
                        style: TextStyle(color: secondary, fontSize: 15),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(plan.description, style: TextStyle(color: secondary)),
              const SizedBox(height: 22),
              ..._features(plan).map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: highlighted
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF15803D),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(color: foreground, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              highlighted
                  ? FilledButton(
                      onPressed: onDetails,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                      ),
                      child: const Text('Voir le détail'),
                    )
                  : OutlinedButton(
                      onPressed: onDetails,
                      child: const Text('Voir le détail'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _features(SubscriptionPlan value) {
    if (value.billingPeriod == BillingPeriod.none) {
      return const [
        '1 mission payante',
        'Rapport définitif de la mission',
        'Aucun renouvellement automatique',
      ];
    }
    return [
      '${value.missionQuota} missions par période mensuelle',
      '${value.aiAnalysisQuota} analyses IA configurées',
      value.maximumUsers == 1
          ? '1 utilisateur principal'
          : 'Jusqu’à ${value.maximumUsers} utilisateurs à terme',
      'Anciens dossiers conservés en lecture',
    ];
  }
}
