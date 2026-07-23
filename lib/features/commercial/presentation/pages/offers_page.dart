import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/access/access_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../auth/login_page.dart';
import '../../../auth/register_page.dart';
import '../../domain/models/official_pricing_catalog.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/commercial_repositories.dart';
import '../../infrastructure/repositories/supabase_product_catalog_repository.dart';
import '../commercial_formatters.dart';
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
  PricingAudience _audience = PricingAudience.professional;
  PricingPeriod _period = PricingPeriod.monthly;
  bool _openingOffer = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseProductCatalogRepository();
  }

  Future<void> _openSubscription() async {
    if (AccessService.instance.isDemo || AuthService.currentUser == null) {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SubscriptionPage()),
    );
  }

  Future<void> _selectOffer(PricingOffer offer) async {
    if (_openingOffer) return;
    if (offer.customQuote) {
      await _showContactForm();
      return;
    }
    if (offer.free) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
      );
      return;
    }

    if (AccessService.instance.isDemo || AuthService.currentUser == null) {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
      if (!mounted || AuthService.currentUser == null) return;
    }

    setState(() => _openingOffer = true);
    try {
      // La lecture confirme que le catalogue backend est joignable. Le prix et
      // les droits restent validés par le backend au moment du paiement.
      await _repository.getPlan(offer.checkoutCode(_period));
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) =>
              OfferDetailsPage(plan: offer.toSubscriptionPlan(_period)),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de charger le paiement sécurisé pour le moment : $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingOffer = false);
    }
  }

  Future<void> _showDetails(PricingOffer offer) async {
    final compact = MediaQuery.sizeOf(context).width < 620;
    final content = _OfferDetails(
      offer: offer,
      period: _period,
      onSubscribe: () {
        Navigator.of(context).pop();
        _selectOffer(offer);
      },
    );
    if (compact) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => FractionallySizedBox(heightFactor: .94, child: content),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),
            child: content,
          ),
        ),
      );
    }
  }

  Future<void> _showContactForm() => showDialog<void>(
    context: context,
    builder: (_) => const _EnterpriseContactDialog(),
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 620;
    final offers = OfficialPricingCatalog.forAudience(_audience);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Offres et tarifs'),
        actions: [
          if (compact)
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
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 14 : 28,
          20,
          compact ? 14 : 28,
          48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(compact: compact),
                const SizedBox(height: 26),
                _Selectors(
                  audience: _audience,
                  period: _period,
                  onAudience: (value) => setState(() => _audience = value),
                  onPeriod: (value) => setState(() => _period = value),
                ),
                if (OfficialPricingCatalog.launchOfferEnabled &&
                    _audience == PricingAudience.professional) ...[
                  const SizedBox(height: 20),
                  const _LaunchBanner(),
                ],
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 620
                        ? 1
                        : constraints.maxWidth < 1050
                        ? 2
                        : 4;
                    final cardWidth =
                        (constraints.maxWidth - ((columns - 1) * 18)) / columns;
                    return Wrap(
                      spacing: 18,
                      runSpacing: 20,
                      children: [
                        for (final offer in offers)
                          SizedBox(
                            width: cardWidth,
                            child: _OfferCard(
                              offer: offer,
                              period: _period,
                              busy: _openingOffer,
                              onDetails: () => _showDetails(offer),
                              onSubscribe: () => _selectOffer(offer),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (_audience == PricingAudience.professional) ...[
                  const SizedBox(height: 34),
                  const _ExtraUsage(),
                  const SizedBox(height: 28),
                  const _ProfessionalServices(),
                ],
                const SizedBox(height: 36),
                _Comparison(audience: _audience),
                const SizedBox(height: 36),
                const _Faq(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(compact ? 24 : 36),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0B1220), Color(0xFF15326D), Color(0xFF2563EB)],
      ),
      borderRadius: BorderRadius.circular(compact ? 24 : 30),
    ),
    child: Column(
      children: [
        Text(
          'Choisissez la formule qui vous correspond',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 29 : 39,
            height: 1.12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Une tarification claire pour les particuliers, les indépendants et les équipes.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD6E4FF),
            fontSize: 16,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}

class _Selectors extends StatelessWidget {
  const _Selectors({
    required this.audience,
    required this.period,
    required this.onAudience,
    required this.onPeriod,
  });

  final PricingAudience audience;
  final PricingPeriod period;
  final ValueChanged<PricingAudience> onAudience;
  final ValueChanged<PricingPeriod> onPeriod;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 12,
    alignment: WrapAlignment.center,
    children: [
      SegmentedButton<PricingAudience>(
        segments: const [
          ButtonSegment(
            value: PricingAudience.individual,
            label: Text('Particulier'),
            icon: Icon(Icons.person_outline),
          ),
          ButtonSegment(
            value: PricingAudience.professional,
            label: Text('Professionnel'),
            icon: Icon(Icons.business_center_outlined),
          ),
        ],
        selected: {audience},
        onSelectionChanged: (values) => onAudience(values.first),
      ),
      SegmentedButton<PricingPeriod>(
        segments: const [
          ButtonSegment(value: PricingPeriod.monthly, label: Text('Mensuel')),
          ButtonSegment(
            value: PricingPeriod.annual,
            label: Text('Annuel – 2 mois offerts'),
          ),
        ],
        selected: {period},
        onSelectionChanged: (values) => onPeriod(values.first),
      ),
    ],
  );
}

class _LaunchBanner extends StatelessWidget {
  const _LaunchBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF93C5FD)),
    ),
    child: const Column(
      children: [
        Text(
          'Offre de lancement : Solo à 49 € HTVA/mois et Pro à 99 € HTVA/mois pendant les 6 premiers mois. Tarif garanti pendant la période promotionnelle.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A8A),
            height: 1.4,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Premier rapport d’essai gratuit, sans carte bancaire.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.period,
    required this.busy,
    required this.onDetails,
    required this.onSubscribe,
  });

  final PricingOffer offer;
  final PricingPeriod period;
  final bool busy;
  final VoidCallback onDetails;
  final VoidCallback onSubscribe;

  String get _price {
    if (offer.free) return 'Gratuit';
    if (offer.customQuote) return 'Sur devis';
    final money = CommercialFormatters.money(offer.priceMinor(period), 'EUR');
    if (offer.oneTime) {
      return '$money ${offer.taxDisplay.label} / état des lieux';
    }
    return period == PricingPeriod.annual
        ? '$money ${offer.taxDisplay.label} / an'
        : '$money ${offer.taxDisplay.label} / mois';
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = offer.badge != null;
    final compact = MediaQuery.sizeOf(context).width < 620;
    final desktopHeight = offer.audience == PricingAudience.professional
        ? 980.0
        : 950.0;
    return SizedBox(
      height: compact ? null : desktopHeight,
      child: Card(
        elevation: highlighted ? 7 : 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: highlighted
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (offer.badge case final badge?)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(badge),
                    avatar: const Icon(Icons.star_rounded, size: 18),
                  ),
                ),
              Text(
                offer.name,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _price,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D4ED8),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                offer.description,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
              ),
              const Divider(height: 30),
              for (final feature in offer.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 19,
                        color: Color(0xFF15803D),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              if (offer.disclaimer case final disclaimer?) ...[
                const SizedBox(height: 4),
                Text(
                  disclaimer,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
              if (compact) const SizedBox(height: 18) else const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onDetails,
                  child: const Text('Plus d’informations'),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : onSubscribe,
                  child: Text(offer.actionLabel, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtraUsage extends StatelessWidget {
  const _ExtraUsage();

  @override
  Widget build(BuildContext context) => const _InfoSection(
    title: 'Besoin de plus ?',
    lines: [
      'État des lieux supplémentaire : 7 € HTVA',
      'Analyse IA supplémentaire : 5 € HTVA',
      'Utilisateur supplémentaire : 12 € HTVA / mois',
      'Stockage longue durée : disponible en option',
      'Signature électronique à distance : selon la formule ou le coût du prestataire',
    ],
    footer:
        'Les crédits non utilisés peuvent être reportés pendant 3 mois maximum.',
  );
}

class _ProfessionalServices extends StatelessWidget {
  const _ProfessionalServices();

  @override
  Widget build(BuildContext context) => const _InfoSection(
    title: 'Faites vérifier votre rapport par un professionnel',
    lines: [
      'Relecture humaine simple : 89 € HTVA par rapport',
      'Relecture avec corrections détaillées : 129 € HTVA par rapport',
      'Récolement et calcul des dégâts locatifs : à partir de 175 € HTVA',
      'Intervention supplémentaire : 70 € HTVA / heure',
      'Traitement urgent sous 24 heures : supplément de 30 %',
    ],
    footer:
        'Les prestations sont réalisées à distance sur la base des informations, photographies et documents transmis. Un devis complémentaire peut être proposé lorsque le dossier nécessite un travail plus important.',
  );
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.lines,
    required this.footer,
  });

  final String title;
  final List<String> lines;
  final String footer;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              for (final line in lines)
                SizedBox(width: 390, child: Text('• $line')),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            footer,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
          ),
        ],
      ),
    ),
  );
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.audience});

  final PricingAudience audience;

  static const labels = [
    'Nombre d’états des lieux',
    'Nombre d’utilisateurs',
    'Analyses IA',
    'Rapports PDF',
    'Photographies',
    'Signatures',
    'Comparaison entrée-sortie',
    'Inventaire des biens meublés',
    'Personnalisation avec logo',
    'Tableau de bord d’équipe',
    'Rôle contrôleur',
    'Assistance prioritaire',
  ];

  String _value(PricingOffer offer, int index) => switch (index) {
    0 => offer.customQuote ? 'Sur mesure' : '${offer.missionQuota}',
    1 => offer.customQuote ? 'Sur mesure' : '${offer.maximumUsers}',
    2 =>
      offer.aiQuota == 0
          ? (offer.customQuote ? 'Sur mesure' : '—')
          : '${offer.aiQuota}',
    3 || 4 || 5 => offer.free ? '—' : '✓',
    6 =>
      offer.code == 'solo' ||
              offer.code == 'pro' ||
              offer.code == 'agency' ||
              offer.customQuote
          ? '✓'
          : '—',
    7 || 8 || 9 =>
      offer.code == 'pro' || offer.code == 'agency' || offer.customQuote
          ? '✓'
          : '—',
    10 => offer.code == 'agency' || offer.customQuote ? '✓' : '—',
    11 =>
      offer.code == 'pro' || offer.code == 'agency' || offer.customQuote
          ? '✓'
          : '—',
    _ => '—',
  };

  @override
  Widget build(BuildContext context) {
    final offers = OfficialPricingCatalog.forAudience(audience);
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Comparatif des fonctionnalités',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        if (compact)
          for (final offer in offers)
            Card(
              child: ExpansionTile(
                title: Text(
                  offer.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                children: [
                  for (var i = 0; i < labels.length; i++)
                    ListTile(
                      dense: true,
                      title: Text(labels[i]),
                      trailing: Text(
                        _value(offer, i),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
            )
        else
          Card(
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Fonctionnalité')),
                    for (final offer in offers)
                      DataColumn(label: Text(offer.name)),
                  ],
                  rows: [
                    for (var i = 0; i < labels.length; i++)
                      DataRow(
                        cells: [
                          DataCell(Text(labels[i])),
                          for (final offer in offers)
                            DataCell(Text(_value(offer, i))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq();

  static const items = <(String, String)>[
    (
      'Que se passe-t-il si je dépasse mon nombre d’états des lieux ?',
      'Vous pouvez acheter des unités supplémentaires au tarif indiqué ou changer de formule.',
    ),
    (
      'Une analyse IA est-elle obligatoire ?',
      'Non. Elle reste une assistance facultative.',
    ),
    (
      'Puis-je modifier le rapport généré par l’IA ?',
      'Oui, le contenu reste modifiable avant finalisation.',
    ),
    (
      'Les crédits non utilisés sont-ils reportés ?',
      'Oui, pendant 3 mois maximum pour les offres professionnelles.',
    ),
    (
      'Quelle est la différence entre l’abonnement et la relecture professionnelle ?',
      'L’abonnement donne accès à l’application ; la relecture est une prestation humaine optionnelle.',
    ),
    (
      'Puis-je changer de formule ?',
      'Oui, selon les conditions de facturation et de prise d’effet indiquées dans les CGV.',
    ),
    (
      'Les prix sont-ils HTVA ou TVAC ?',
      'Les prix particuliers sont TVAC et les prix professionnels sont HTVA.',
    ),
    (
      'Mes rapports et mes photographies sont-ils sauvegardés ?',
      'Oui, selon la durée d’archivage de la formule choisie.',
    ),
    (
      'L’état des lieux peut-il être signé par plusieurs parties ?',
      'Oui, les formules comprenant la signature permettent la signature des parties concernées.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        'Questions fréquentes',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 14),
      for (final item in items)
        Card(
          child: ExpansionTile(
            title: Text(item.$1),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item.$2, style: const TextStyle(height: 1.45)),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _OfferDetails extends StatelessWidget {
  const _OfferDetails({
    required this.offer,
    required this.period,
    required this.onSubscribe,
  });

  final PricingOffer offer;
  final PricingPeriod period;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: Column(
      children: [
        ListTile(
          title: Text(
            offer.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          subtitle: Text(offer.targetAudience),
          trailing: IconButton(
            tooltip: 'Fermer',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DetailGroup(
                  title: 'Fonctionnalités incluses',
                  lines: offer.features,
                ),
                _DetailGroup(title: 'Non inclus', lines: offer.exclusions),
                _DetailGroup(title: 'Analyses IA', lines: [offer.aiDetails]),
                if (offer.audience == PricingAudience.professional)
                  const _DetailGroup(
                    title: 'Dépassements',
                    lines: [
                      '7 € HTVA par état des lieux, 5 € HTVA par analyse IA et 12 € HTVA/mois par utilisateur.',
                    ],
                  ),
                _DetailGroup(title: 'Archivage', lines: [offer.archiveDetails]),
                _DetailGroup(
                  title: 'Assistance',
                  lines: [offer.supportDetails],
                ),
                _DetailGroup(
                  title: 'Changement ou résiliation',
                  lines: [offer.changeDetails],
                ),
                Text(
                  'Prix affiché ${offer.taxDisplay.label}.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onSubscribe,
                  child: Text(offer.actionLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.lines});
  final String title;
  final List<String> lines;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('• $line'),
          ),
      ],
    ),
  );
}

class _EnterpriseContactDialog extends StatefulWidget {
  const _EnterpriseContactDialog();

  @override
  State<_EnterpriseContactDialog> createState() =>
      _EnterpriseContactDialogState();
}

class _EnterpriseContactDialogState extends State<_EnterpriseContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(8, (_) => TextEditingController());
  bool _consent = false;
  bool _sending = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate() || !_consent || _sending) {
      if (!_consent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez accepter d’être recontacté.')),
        );
      }
      return;
    }
    setState(() => _sending = true);
    final labels = [
      'Nom',
      'Entreprise',
      'TVA',
      'E-mail',
      'Téléphone',
      'Utilisateurs',
      'Missions/mois',
      'Besoins',
    ];
    final body = List.generate(
      labels.length,
      (i) => '${labels[i]} : ${_controllers[i].text}',
    ).join('\n');
    final uri = Uri(
      scheme: 'mailto',
      path: 'contact@constatplus.be',
      queryParameters: {
        'subject': 'Demande d’offre Entreprise Constat+',
        'body': body,
      },
    );
    final launched = await launchUrl(uri);
    if (!mounted) return;
    setState(() => _sending = false);
    if (launched) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Votre messagerie a été ouverte avec la demande préremplie.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune messagerie n’est disponible sur cet appareil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Nom et prénom',
      'Entreprise',
      'Numéro de TVA',
      'Adresse e-mail',
      'Téléphone',
      'Nombre d’utilisateurs',
      'Nombre estimé d’états des lieux par mois',
      'Besoins particuliers',
    ];
    return AlertDialog(
      title: const Text('Demander une offre Entreprise'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  TextFormField(
                    controller: _controllers[i],
                    minLines: i == 7 ? 3 : 1,
                    maxLines: i == 7 ? 5 : 1,
                    keyboardType: i == 3
                        ? TextInputType.emailAddress
                        : (i == 5 || i == 6
                              ? TextInputType.number
                              : TextInputType.text),
                    decoration: InputDecoration(labelText: labels[i]),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Champ obligatoire';
                      }
                      if (i == 3 && !value.contains('@')) {
                        return 'Adresse e-mail invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _consent,
                  onChanged: (value) =>
                      setState(() => _consent = value ?? false),
                  title: const Text('J’accepte d’être recontacté.'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _sending ? null : _send,
          icon: _sending
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: const Text('Envoyer la demande'),
        ),
      ],
    );
  }
}
