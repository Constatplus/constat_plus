import 'package:flutter/material.dart';

import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/commercial_repositories.dart';
import '../../infrastructure/repositories/supabase_discovery_access_repository.dart';
import '../../infrastructure/repositories/supabase_product_catalog_repository.dart';
import '../commercial_formatters.dart';
import 'offer_details_page.dart';

class DiscoveryPaywallPage extends StatefulWidget {
  final String missionId;
  final int roomsUsed;
  final int roomLimit;
  final ProductCatalogRepository? catalogRepository;
  final SupabaseDiscoveryAccessRepository? accessRepository;

  const DiscoveryPaywallPage({
    super.key,
    required this.missionId,
    required this.roomsUsed,
    required this.roomLimit,
    this.catalogRepository,
    this.accessRepository,
  });

  @override
  State<DiscoveryPaywallPage> createState() => _DiscoveryPaywallPageState();
}

class _DiscoveryPaywallPageState extends State<DiscoveryPaywallPage> {
  late final ProductCatalogRepository _catalog;
  late final SupabaseDiscoveryAccessRepository _access;
  late Future<List<SubscriptionPlan>> _plans;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalogRepository ?? SupabaseProductCatalogRepository();
    _access = widget.accessRepository ?? SupabaseDiscoveryAccessRepository();
    _plans = _loadPlans();
  }

  Future<List<SubscriptionPlan>> _loadPlans() async {
    final plans = await _catalog.getActivePlans();
    const orderedCodes = <String>['mission_unit', 'solo', 'pro'];
    final selected = plans
        .where((plan) => orderedCodes.contains(plan.code))
        .toList(growable: false);
    selected.sort(
      (left, right) => orderedCodes
          .indexOf(left.code)
          .compareTo(orderedCodes.indexOf(right.code)),
    );
    return selected;
  }

  Future<void> _select(SubscriptionPlan plan) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => OfferDetailsPage(
          plan: plan,
          missionId: plan.code == 'mission_unit' ? widget.missionId : null,
        ),
      ),
    );
    if (!mounted) return;
    await _checkAccess();
  }

  Future<void> _checkAccess() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final state = await _access.getState(forceRefresh: true);
      if (!mounted) return;
      if (state.hasPaidAccessFor(widget.missionId)) {
        Navigator.pop(context, true);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le paiement n’est pas encore confirmé par le fournisseur.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vérification impossible : $error')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: const Text('Continuer avec Constat+')),
      body: FutureBuilder<List<SubscriptionPlan>>(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: () => setState(() => _plans = _loadPlans()),
                child: const Text('Réessayer'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const Icon(Icons.lock_open_rounded, size: 58),
              const SizedBox(height: 14),
              const Text(
                'Votre brouillon reste intégralement conservé',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'Mode Découverte : ${widget.roomsUsed} pièces sur ${widget.roomLimit} utilisées. Choisissez une offre pour poursuivre cette mission sans perdre vos données.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              for (final plan
                  in snapshot.data ?? const <SubscriptionPlan>[]) ...[
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(
                      plan.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(plan.description),
                    trailing: FilledButton(
                      onPressed: () => _select(plan),
                      child: Text(
                        '${CommercialFormatters.money(plan.priceMinor, plan.currency)} ${plan.taxDisplay.label}${plan.billingPeriod.name == 'monthly' ? ' / mois' : ''}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _checking ? null : _checkAccess,
                icon: const Icon(Icons.refresh),
                label: const Text('J’ai payé — vérifier mes droits'),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<bool> showDiscoveryPaywall(
  BuildContext context, {
  required String missionId,
  required int roomsUsed,
  required int roomLimit,
}) async {
  return await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => DiscoveryPaywallPage(
            missionId: missionId,
            roomsUsed: roomsUsed,
            roomLimit: roomLimit,
          ),
        ),
      ) ??
      false;
}
