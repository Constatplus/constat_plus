import 'package:flutter/material.dart';

import '../../domain/models/commercial_enums.dart';
import '../../domain/models/subscription_plan.dart';
import '../commercial_formatters.dart';

class PlanCard extends StatefulWidget {
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
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _hovered = false;

  SubscriptionPlan get plan => widget.plan;

  bool get _highlighted => widget.highlighted || plan.isRecommended;

  bool get _enterprise => plan.isEnterprise;

  @override
  Widget build(BuildContext context) {
    final darkCard = _highlighted || _enterprise;
    final foreground = darkCard ? Colors.white : const Color(0xFF0F172A);
    final secondary = darkCard
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final accent = _enterprise
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF2563EB);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.012 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: darkCard ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: darkCard ? accent : const Color(0xFFE2E8F0),
              width: darkCard ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(
                  alpha: _hovered ? .16 : .08,
                ),
                blurRadius: _hovered ? 32 : 20,
                offset: Offset(0, _hovered ? 18 : 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              children: [
                if (darkCard)
                  Positioned(
                    right: -55,
                    top: -65,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: .15),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderBadge(
                        highlighted: _highlighted,
                        enterprise: _enterprise,
                        accent: accent,
                      ),
                      if (_highlighted || _enterprise)
                        const SizedBox(height: 16),
                      Text(
                        plan.name,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 27,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PriceBlock(
                        plan: plan,
                        foreground: foreground,
                        secondary: secondary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        plan.description,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _QuotaGrid(
                        plan: plan,
                        darkCard: darkCard,
                        accent: accent,
                        foreground: foreground,
                        secondary: secondary,
                      ),
                      const SizedBox(height: 22),
                      Divider(
                        color: darkCard
                            ? Colors.white.withValues(alpha: .12)
                            : const Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 16),
                      ..._features(plan).map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 1),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: .14),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: darkCard
                                      ? const Color(0xFFBFDBFE)
                                      : const Color(0xFF15803D),
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    color: foreground,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (plan.additionalMissionPriceMinor != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: darkCard
                                ? Colors.white.withValues(alpha: .07)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Au-delà : ${CommercialFormatters.money(plan.additionalMissionPriceMinor!, plan.currency)} HTVA par état des lieux supplémentaire',
                            style: TextStyle(
                              color: secondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: darkCard
                            ? FilledButton.icon(
                                onPressed: widget.onDetails,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0F172A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: Icon(
                                  _enterprise
                                      ? Icons.business_center_outlined
                                      : Icons.arrow_forward_rounded,
                                ),
                                label: Text(
                                  _enterprise
                                      ? 'Demander un devis'
                                      : 'Voir le détail',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: widget.onDetails,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1D4ED8),
                                  side: const BorderSide(
                                    color: Color(0xFFBFDBFE),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text(
                                  'Voir le détail',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                      ),
                      if (!_enterprise) ...[
                        const SizedBox(height: 13),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 17,
                              color: secondary,
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                'Crédits IA supplémentaires disponibles',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _features(SubscriptionPlan value) {
    if (value.featureLabels.isNotEmpty) return value.featureLabels;

    if (value.isEnterprise) {
      return const [
        'Tableau de bord de contrôle des collaborateurs',
        'Affectation d’un expert par état des lieux',
        'Validation et contrôle qualité des rapports',
        'Gestion des rôles et des droits utilisateurs',
        'Statistiques de production et de complétude',
        'Crédits IA mutualisés pour toute l’équipe',
        'Accompagnement et support prioritaires',
      ];
    }

    if (value.billingPeriod == BillingPeriod.none) {
      return [
        'Utilisable pour un seul état des lieux',
        '${value.aiAnalysisQuota} analyses IA incluses',
        'Rapports PDF et Word',
        'Aucun abonnement récurrent',
      ];
    }

    return [
      'Jusqu’à ${value.missionQuota} états des lieux par mois',
      '${value.aiAnalysisQuota} analyses IA par mois',
      'Rapports PDF et Word',
      'Signature électronique',
      'Sauvegarde cloud sécurisée',
      if (value.maximumUsers > 1)
        'Jusqu’à ${value.maximumUsers} utilisateurs',
    ];
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.highlighted,
    required this.enterprise,
    required this.accent,
  });

  final bool highlighted;
  final bool enterprise;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (!highlighted && !enterprise) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: .5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enterprise
                  ? Icons.apartment_rounded
                  : Icons.star_rounded,
              color: const Color(0xFFDBEAFE),
              size: 16,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                enterprise ? 'ENTREPRISE' : 'LE PLUS POPULAIRE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .65,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.plan,
    required this.foreground,
    required this.secondary,
  });

  final SubscriptionPlan plan;
  final Color foreground;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    if (plan.isCustomQuote) {
      return Text(
        'Sur devis',
        style: TextStyle(
          color: foreground,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -.9,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: CommercialFormatters.money(
              plan.priceMinor,
              plan.currency,
            ),
            style: TextStyle(
              color: foreground,
              fontSize: 37,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          TextSpan(
            text: ' ${plan.taxDisplay.label}',
            style: TextStyle(
              color: secondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (plan.billingPeriod == BillingPeriod.monthly)
            TextSpan(
              text: ' / mois',
              style: TextStyle(
                color: secondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuotaGrid extends StatelessWidget {
  const _QuotaGrid({
    required this.plan,
    required this.darkCard,
    required this.accent,
    required this.foreground,
    required this.secondary,
  });

  final SubscriptionPlan plan;
  final bool darkCard;
  final Color accent;
  final Color foreground;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 280
            ? constraints.maxWidth
            : (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: width,
              child: _QuotaTile(
                icon: Icons.description_outlined,
                value: plan.missionQuotaLabel,
                label: 'États des lieux',
                darkCard: darkCard,
                accent: accent,
                foreground: foreground,
                secondary: secondary,
              ),
            ),
            SizedBox(
              width: width,
              child: _QuotaTile(
                icon: Icons.auto_awesome_outlined,
                value: plan.aiQuotaLabel,
                label: 'Analyses IA',
                darkCard: darkCard,
                accent: accent,
                foreground: foreground,
                secondary: secondary,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: _QuotaTile(
                icon: Icons.group_outlined,
                value: plan.userQuotaLabel,
                label: 'Accès compris',
                darkCard: darkCard,
                accent: accent,
                foreground: foreground,
                secondary: secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuotaTile extends StatelessWidget {
  const _QuotaTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.darkCard,
    required this.accent,
    required this.foreground,
    required this.secondary,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool darkCard;
  final Color accent;
  final Color foreground;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: darkCard
            ? Colors.white.withValues(alpha: .07)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: darkCard
              ? Colors.white.withValues(alpha: .08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: darkCard ? Colors.white : accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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
