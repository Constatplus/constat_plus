import 'dart:io';

import 'package:flutter/material.dart';

import '../../application/billing/android_billing_controller.dart';
import '../../application/billing/apple_billing_controller.dart';
import '../../application/billing/stripe_billing_controller.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_overview.dart';
import '../../domain/repositories/commercial_repositories.dart';
import '../../infrastructure/repositories/supabase_subscription_overview_repository.dart';
import '../commercial_formatters.dart';
import 'stripe_invoices_page.dart';
import '../widgets/usage_meter.dart';

class SubscriptionPage extends StatefulWidget {
  final SubscriptionOverviewRepository? repository;

  const SubscriptionPage({super.key, this.repository});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final AndroidBillingController _billingController =
      AndroidBillingController();
  final StripeBillingController _stripeBillingController =
      StripeBillingController();
  final AppleBillingController _appleBillingController =
      AppleBillingController();
  late final SubscriptionOverviewRepository _repository;
  late Future<SubscriptionOverview> _overview;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseSubscriptionOverviewRepository();
    _overview = _repository.loadOverview();
  }

  void _retry() {
    setState(() => _overview = _repository.loadOverview());
  }

  Future<void> _restorePurchases() async {
    try {
      if (Platform.isIOS) {
        await _appleBillingController.restorePurchases();
      } else {
        await _billingController.restorePurchases();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Restauration lancée. Les achats seront affichés après validation serveur.',
          ),
        ),
      );
      _retry();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restauration impossible : $error')),
      );
    }
  }

  Future<void> _manageSubscription() async {
    try {
      if (Platform.isWindows) {
        await _stripeBillingController.manageSubscription();
      } else if (Platform.isIOS) {
        await _appleBillingController.manageSubscription();
      } else {
        await _billingController.manageSubscription();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ouverture impossible : $error')));
    }
  }

  void _openInvoices() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const StripeInvoicesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: const Text('Mon abonnement')),
      body: FutureBuilder<SubscriptionOverview>(
        future: _overview,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error?.toString() ?? 'Données indisponibles.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final overview = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _retry();
              await _overview;
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: overview.hasSubscription
                        ? _ActiveSubscription(
                            overview: overview,
                            onManage:
                                Platform.isAndroid ||
                                    Platform.isWindows ||
                                    Platform.isIOS
                                ? _manageSubscription
                                : null,
                            manageLabel: Platform.isWindows
                                ? 'Gérer mon abonnement Stripe'
                                : Platform.isIOS
                                ? 'Gérer dans l’App Store'
                                : 'Gérer sur Google Play',
                            onRestore: Platform.isAndroid || Platform.isIOS
                                ? _restorePurchases
                                : null,
                            onInvoices: Platform.isWindows
                                ? _openInvoices
                                : null,
                          )
                        : _NoSubscription(
                            overview: overview,
                            onRestore: Platform.isAndroid || Platform.isIOS
                                ? _restorePurchases
                                : null,
                            onInvoices: Platform.isWindows
                                ? _openInvoices
                                : null,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveSubscription extends StatelessWidget {
  final SubscriptionOverview overview;
  final VoidCallback? onManage;
  final VoidCallback? onRestore;
  final VoidCallback? onInvoices;
  final String manageLabel;

  const _ActiveSubscription({
    required this.overview,
    required this.manageLabel,
    this.onManage,
    this.onRestore,
    this.onInvoices,
  });

  @override
  Widget build(BuildContext context) {
    final plan = overview.plan!;
    final subscription = overview.subscription!;
    final usage = overview.usagePeriod;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CommercialFormatters.subscriptionStatus(
                              subscription.status,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.payment_outlined, size: 18),
                      label: Text(
                        CommercialFormatters.provider(subscription.provider),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                _InfoRow(
                  label: 'Début',
                  value: CommercialFormatters.date(subscription.startedAt),
                ),
                _InfoRow(
                  label: 'Période actuelle',
                  value:
                      '${CommercialFormatters.date(subscription.currentPeriodStart)} – ${CommercialFormatters.date(subscription.currentPeriodEnd)}',
                ),
                _InfoRow(
                  label: 'Prochaine échéance',
                  value: subscription.cancelAtPeriodEnd
                      ? 'Annulation prévue en fin de période'
                      : CommercialFormatters.date(
                          subscription.currentPeriodEnd,
                        ),
                ),
                if (subscription.status == SubscriptionStatus.pastDue)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Le paiement est en retard. Les anciens dossiers restent accessibles en lecture.',
                      style: TextStyle(color: Color(0xFFB42318)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (usage == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'La période de consommation n’est pas encore disponible. Synchronisez à nouveau après activation serveur.',
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final mission = UsageMeter(
                label: 'Missions',
                used: usage.missionsUsed,
                quota: plan.missionQuota,
                icon: Icons.assignment_outlined,
              );
              final ai = UsageMeter(
                label: 'Analyses IA',
                used: usage.aiAnalysesUsed,
                quota: plan.aiAnalysisQuota,
                icon: Icons.auto_awesome_outlined,
              );
              if (constraints.maxWidth < 680) {
                return Column(
                  children: [mission, const SizedBox(height: 14), ai],
                );
              }
              return Row(
                children: [
                  Expanded(child: mission),
                  const SizedBox(width: 14),
                  Expanded(child: ai),
                ],
              );
            },
          ),
        const SizedBox(height: 18),
        _PurchasesSummary(overview: overview),
        const SizedBox(height: 18),
        if (onManage != null)
          FilledButton.icon(
            onPressed: onManage,
            icon: const Icon(Icons.manage_accounts_outlined),
            label: Text(manageLabel),
          ),
        if (onInvoices != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onInvoices,
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Consulter mes factures Stripe'),
          ),
        ],
        if (onRestore != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.restore_outlined),
            label: const Text('Restaurer mes achats'),
          ),
        ],
      ],
    );
  }
}

class _NoSubscription extends StatelessWidget {
  final SubscriptionOverview overview;
  final VoidCallback? onRestore;
  final VoidCallback? onInvoices;

  const _NoSubscription({
    required this.overview,
    this.onRestore,
    this.onInvoices,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              children: [
                Icon(Icons.workspace_premium_outlined, size: 54),
                SizedBox(height: 14),
                Text(
                  'Aucun abonnement actif',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 10),
                Text(
                  'Vous pourrez choisir un abonnement ou acheter une mission à l’unité.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _PurchasesSummary(overview: overview),
        const SizedBox(height: 18),
        if (onInvoices != null)
          OutlinedButton.icon(
            onPressed: onInvoices,
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Consulter mes factures Stripe'),
          ),
        if (onRestore != null)
          OutlinedButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.restore_outlined),
            label: Text(
              Platform.isIOS
                  ? 'Restaurer mes achats Apple'
                  : 'Restaurer mes achats Google Play',
            ),
          ),
      ],
    );
  }
}

class _PurchasesSummary extends StatelessWidget {
  final SubscriptionOverview overview;

  const _PurchasesSummary({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 34),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Missions achetées à l’unité',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${overview.purchases.length} achat(s) enregistré(s) · ${overview.availableOneTimeMissions} disponible(s)',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
