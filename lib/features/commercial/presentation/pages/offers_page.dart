import 'package:flutter/material.dart';

import '../../../../core/access/access_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../auth/login_page.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/commercial_repositories.dart';
import '../../infrastructure/repositories/supabase_product_catalog_repository.dart';
import '../widgets/plan_card.dart';
import 'offer_details_page.dart';
import 'subscription_page.dart';

class OffersPage extends StatefulWidget {
  final ProductCatalogRepository? repository;

  const OffersPage({super.key, this.repository});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  late final ProductCatalogRepository _repository;
  late Future<List<SubscriptionPlan>> _plans;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseProductCatalogRepository();
    _plans = _repository.getActivePlans();
  }

  void _retry() {
    setState(() => _plans = _repository.getActivePlans());
  }

  void _openDetails(SubscriptionPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OfferDetailsPage(plan: plan)),
    );
  }

  void _openSubscription() {
    if (AccessService.instance.isDemo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connectez-vous avec un compte réel pour consulter un abonnement.',
          ),
        ),
      );
      return;
    }
    if (AuthService.currentUser == null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SubscriptionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Offres et tarifs'),
        actions: [
          TextButton.icon(
            onPressed: _openSubscription,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('Mon abonnement'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<SubscriptionPlan>>(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _CatalogError(error: snapshot.error, onRetry: _retry);
          }
          final plans = snapshot.data ?? const [];
          if (plans.isEmpty) {
            return _CatalogError(
              error: 'Aucune offre active pour le moment.',
              onRetry: _retry,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Une formule claire pour chaque rythme de mission',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Les prix et quotas sont chargés depuis le catalogue sécurisé Constat+.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: plans
                          .map(
                            (plan) => PlanCard(
                              plan: plan,
                              highlighted: plan.code == 'pro',
                              onDetails: () => _openDetails(plan),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.verified_user_outlined),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aucun paiement n’est simulé sur cette page. Les achats seront activés uniquement après validation serveur des fournisseurs.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _CatalogError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 14),
            const Text(
              'Catalogue indisponible',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SelectableText(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
