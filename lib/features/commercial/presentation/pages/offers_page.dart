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

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SubscriptionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 620;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Offres et tarifs'),
        actions: [
          if (mobile)
            IconButton(
              tooltip: 'Mon abonnement',
              onPressed: _openSubscription,
              icon: const Icon(Icons.workspace_premium_outlined),
            )
          else
            TextButton.icon(
              onPressed: _openSubscription,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Mon abonnement'),
            ),
          SizedBox(width: mobile ? 4 : 12),
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
            padding: EdgeInsets.fromLTRB(
              mobile ? 14 : 28,
              mobile ? 14 : 24,
              mobile ? 14 : 28,
              42,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Hero(
                      compact: mobile,
                      onSubscription: _openSubscription,
                    ),
                    SizedBox(height: mobile ? 28 : 38),
                    const _SectionTitle(
                      eyebrow: 'NOS FORMULES',
                      title: 'Une formule claire pour chaque rythme de mission',
                      subtitle:
                          'Choisissez l’offre adaptée à votre activité. Les prix, quotas et fonctionnalités sont chargés depuis le catalogue sécurisé Constat+.',
                    ),
                    SizedBox(height: mobile ? 22 : 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth < 620
                            ? constraints.maxWidth
                            : constraints.maxWidth < 980
                                ? (constraints.maxWidth - 18) / 2
                                : (constraints.maxWidth - 36) / 3;

                        return Wrap(
                          spacing: 18,
                          runSpacing: 22,
                          alignment: WrapAlignment.center,
                          children: plans
                              .map(
                                (plan) => SizedBox(
                                  width: cardWidth,
                                  child: PlanCard(
                                    plan: plan,
                                    highlighted: plan.code == 'pro',
                                    onDetails: () => _openDetails(plan),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                    ),
                    SizedBox(height: mobile ? 28 : 38),
                    _EnterpriseOffer(
                      onContact: () => _showComingSoon(
                        'Le formulaire de demande Entreprise sera relié au service commercial lors de l’activation des paiements.',
                      ),
                    ),
                    SizedBox(height: mobile ? 30 : 42),
                    _AddOnServices(
                      onReview: () => _showComingSoon(
                        'La commande de relecture professionnelle sera activée avec le module de paiement.',
                      ),
                      onCredits: () => _showComingSoon(
                        'L’achat de crédits IA sera activé avec le module de paiement sécurisé.',
                      ),
                    ),
                    SizedBox(height: mobile ? 30 : 42),
                    const _Benefits(),
                    SizedBox(height: mobile ? 26 : 36),
                    const _TrustStrip(),
                    SizedBox(height: mobile ? 28 : 38),
                    const _Faq(),
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

class _Hero extends StatelessWidget {
  const _Hero({required this.compact, required this.onSubscription});

  final bool compact;
  final VoidCallback onSubscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 22 : 38,
        vertical: compact ? 28 : 42,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B1220),
            Color(0xFF15326D),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 26 : 32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .16),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 17,
                      color: Color(0xFFBFDBFE),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'DES OFFRES PENSÉES POUR VOTRE ACTIVITÉ',
                        style: TextStyle(
                          color: Color(0xFFDBEAFE),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choisissez la formule qui vous correspond',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 32 : 43,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: compact ? -1 : -1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Du constat occasionnel au cabinet réalisant plusieurs missions chaque semaine, Constat+ évolue avec votre activité.',
                style: TextStyle(
                  color: const Color(0xFFD6E4FF),
                  fontSize: compact ? 15.5 : 17,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: compact ? double.infinity : null,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D4ED8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onPressed: onSubscription,
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: const Text('Consulter mon abonnement'),
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 820) return copy;

          return Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 34),
              const Expanded(flex: 4, child: _HeroHighlights()),
            ],
          );
        },
      ),
    );
  }
}

class _HeroHighlights extends StatelessWidget {
  const _HeroHighlights();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: const Column(
        children: [
          _Highlight(Icons.fact_check_outlined, 'Rapports structurés'),
          SizedBox(height: 16),
          _Highlight(Icons.auto_awesome_outlined, 'Assistant IA'),
          SizedBox(height: 16),
          _Highlight(Icons.devices_rounded, 'Multi-support'),
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 620;

    return Column(
      children: [
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w900,
            letterSpacing: .9,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: mobile ? 28 : 35,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: mobile ? 15 : 16,
              height: 1.55,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}


class _EnterpriseOffer extends StatelessWidget {
  const _EnterpriseOffer({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      padding: EdgeInsets.all(mobile ? 22 : 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'ENTREPRISE • SUR DEVIS',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilotez les états des lieux de toute votre équipe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: mobile ? 28 : 36,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Une formule conçue pour les agences, cabinets d’expertise, réseaux et équipes disposant de plusieurs collaborateurs.',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onContact,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D4ED8),
                  minimumSize: Size(mobile ? double.infinity : 0, 52),
                ),
                icon: const Icon(Icons.business_center_outlined),
                label: const Text('Demander une démonstration'),
              ),
            ],
          );

          final features = const _EnterpriseFeatures();

          if (constraints.maxWidth < 850) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 24), features],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: content),
              const SizedBox(width: 34),
              const Expanded(flex: 4, child: _EnterpriseFeatures()),
            ],
          );
        },
      ),
    );
  }
}

class _EnterpriseFeatures extends StatelessWidget {
  const _EnterpriseFeatures();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
      ),
      child: const Column(
        children: [
          _EnterpriseFeature(Icons.dashboard_customize_outlined, 'Tableau de bord de contrôle'),
          _EnterpriseFeature(Icons.assignment_ind_outlined, 'Affectation d’un expert par état des lieux'),
          _EnterpriseFeature(Icons.groups_2_outlined, 'Gestion des collaborateurs et des rôles'),
          _EnterpriseFeature(Icons.fact_check_outlined, 'Validation et contrôle qualité des rapports'),
          _EnterpriseFeature(Icons.monitor_heart_outlined, 'Suivi des dossiers, délais et taux de complétude'),
          _EnterpriseFeature(Icons.auto_awesome_outlined, 'Crédits IA mutualisés pour l’entreprise'),
        ],
      ),
    );
  }
}

class _EnterpriseFeature extends StatelessWidget {
  const _EnterpriseFeature(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF93C5FD), size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddOnServices extends StatelessWidget {
  const _AddOnServices({required this.onReview, required this.onCredits});

  final VoidCallback onReview;
  final VoidCallback onCredits;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 620;

    return Column(
      children: [
        const _SectionTitle(
          eyebrow: 'SERVICES COMPLÉMENTAIRES',
          title: 'Achetez uniquement ce dont vous avez besoin',
          subtitle:
              'Ajoutez une relecture professionnelle ou rechargez vos analyses IA sans devoir changer immédiatement de formule.',
        ),
        SizedBox(height: mobile ? 22 : 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 800
                ? constraints.maxWidth
                : (constraints.maxWidth - 18) / 2;

            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: width,
                  child: _ServiceCard(
                    icon: Icons.rate_review_outlined,
                    title: 'Relecture professionnelle',
                    price: '99 € HTVA',
                    subtitle: 'par état des lieux',
                    features: const [
                      'Contrôle de cohérence du rapport',
                      'Vérification des oublis et contradictions',
                      'Observations et recommandations professionnelles',
                      'Retour structuré avant remise au client',
                    ],
                    buttonLabel: 'Commander une relecture',
                    onPressed: onReview,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _AiCreditsCard(onPressed: onCredits),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...features.map((feature) => _CheckLine(feature)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _AiCreditsCard extends StatelessWidget {
  const _AiCreditsCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Expanded(
                child: Text('Crédits d’analyse IA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Rechargez votre compte lorsque le quota mensuel est atteint. Les gros volumes bénéficient d’un prix unitaire réduit.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.45),
          ),
          const SizedBox(height: 18),
          const _CreditPack('Pack Découverte', '25 analyses', '19 € HTVA', '0,76 € / analyse'),
          const _CreditPack('Pack Pro', '100 analyses', '69 € HTVA', '0,69 € / analyse'),
          const _CreditPack('Pack Volume', '500 analyses', '299 € HTVA', '0,60 € / analyse'),
          const _CreditPack('Entreprise', 'Volume personnalisé', 'Sur devis', 'Crédits mutualisés'),
          const SizedBox(height: 16),
          const Text(
            'Une analyse correspond à une série de photos traitée ensemble. Le nombre maximal de photos et le coût définitif seront fixés après les tests réels de consommation API.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.add_card_outlined),
            label: const Text('Acheter des crédits IA'),
          ),
        ],
      ),
    );
  }
}

class _CreditPack extends StatelessWidget {
  const _CreditPack(this.name, this.quantity, this.price, this.unit);

  final String name;
  final String quantity;
  final String price;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(quantity, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(unit, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 620;

    return Container(
      padding: EdgeInsets.all(mobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const _SectionTitle(
            eyebrow: 'INCLUS DANS CONSTAT+',
            title: 'Les outils essentiels pour vos missions',
            subtitle:
                'Chaque formule donne accès à une base professionnelle commune. Les quotas et options avancées varient selon l’abonnement.',
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 620
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 18) / 2;

              return Wrap(
                spacing: 18,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: width,
                    child: const _Benefit(
                      Icons.description_outlined,
                      'Rapports structurés',
                      'Des documents organisés pour faciliter la relecture et la remise au client.',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const _Benefit(
                      Icons.photo_camera_back_outlined,
                      'Gestion des photos',
                      'Ajoutez et classez les photographies directement dans vos dossiers.',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const _Benefit(
                      Icons.auto_awesome_outlined,
                      'Assistance intelligente',
                      'Profitez des outils IA disponibles selon les limites de votre formule.',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const _Benefit(
                      Icons.devices_rounded,
                      'Utilisation multi-support',
                      'Travaillez sur ordinateur, tablette ou téléphone selon votre situation.',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.icon, this.title, this.text);

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Wrap(
        spacing: 24,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _TrustItem(Icons.verified_user_outlined, 'Validation serveur sécurisée'),
          _TrustItem(Icons.receipt_long_outlined, 'Catalogue Supabase'),
          _TrustItem(Icons.swap_horiz_rounded, 'Formules évolutives'),
          _TrustItem(Icons.support_agent_outlined, 'Assistance Constat+'),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 620;

    return Container(
      padding: EdgeInsets.all(mobile ? 18 : 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          _SectionTitle(
            eyebrow: 'QUESTIONS FRÉQUENTES',
            title: 'Avant de choisir votre formule',
            subtitle:
                'Les conditions exactes restent celles affichées dans le détail de chaque offre et au moment de la souscription.',
          ),
          SizedBox(height: 18),
          _FaqTile(
            'Puis-je consulter le détail avant de choisir ?',
            'Oui. Utilisez le bouton de détail de chaque carte pour consulter les caractéristiques et limites de la formule.',
          ),
          _FaqTile(
            'Le paiement est-il déjà actif ?',
            'Les achats ne sont activés qu’après validation serveur des fournisseurs de paiement.',
          ),
          _FaqTile(
            'Puis-je accéder aux offres en mode démonstration ?',
            'Vous pouvez consulter le catalogue. La gestion d’un abonnement réel nécessite toutefois un compte connecté.',
          ),
          _FaqTile(
            'Pourquoi l’offre Pro est-elle mise en avant ?',
            'La carte Pro est recommandée visuellement, mais le meilleur choix dépend toujours de votre volume réel de missions.',
          ),
          _FaqTile(
            'Puis-je acheter des analyses IA supplémentaires ?',
            'Oui. Des packs de crédits permettent de continuer à analyser des séries de photos lorsque le quota mensuel est épuisé.',
          ),
          _FaqTile(
            'Que comprend la formule Entreprise ?',
            'Elle comprend notamment le tableau de bord d’équipe, l’affectation des missions, la gestion des rôles, le contrôle qualité et des crédits IA mutualisés.',
          ),
          _FaqTile(
            'Puis-je faire relire un rapport ?',
            'Oui. Une relecture professionnelle peut être commandée au prix de 99 € HTVA par état des lieux.',
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile(this.question, this.answer);

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: const TextStyle(
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ),
      ],
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 14),
              const Text(
                'Catalogue indisponible',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              SelectableText(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
