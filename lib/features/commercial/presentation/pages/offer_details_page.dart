import 'package:flutter/material.dart';

import '../../../auth/register_page.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../commercial_formatters.dart';
import '../widgets/platform_billing_card.dart';

class OfferDetailsPage extends StatelessWidget {
  final SubscriptionPlan plan;
  final String? missionId;

  const OfferDetailsPage({super.key, required this.plan, this.missionId});

  @override
  Widget build(BuildContext context) {
    final monthly = plan.billingPeriod == BillingPeriod.monthly;
    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${CommercialFormatters.money(plan.priceMinor, plan.currency)}${monthly ? ' / mois' : ''}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(plan.description),
                    const SizedBox(height: 26),
                    _DetailLine(
                      label: 'Missions incluses',
                      value: monthly
                          ? '${plan.missionQuota} par mois'
                          : '${plan.missionQuota}',
                    ),
                    _DetailLine(
                      label: 'Analyses IA',
                      value: plan.aiAnalysisQuota == 0
                          ? 'Non incluses'
                          : '${plan.aiAnalysisQuota} par mois',
                    ),
                    _DetailLine(
                      label: 'Utilisateurs',
                      value: '${plan.maximumUsers} maximum',
                    ),
                    _DetailLine(
                      label: 'Renouvellement',
                      value: monthly ? 'Mensuel automatique' : 'Aucun',
                    ),
                    const SizedBox(height: 24),
                    PlatformBillingCard(plan: plan, missionId: missionId),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterPage(),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Créer un compte'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
