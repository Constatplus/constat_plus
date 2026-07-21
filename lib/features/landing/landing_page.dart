import 'package:flutter/material.dart';

import '../../core/access/access_service.dart';
import '../../screens/home_page.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../pricing/pricing_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _demo(BuildContext context) {
    AccessService.instance.startDemo(plan: AccountPlan.occasional);
    _open(context, const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: ListView(
          children: [
            _Header(
              onOffers: () => _open(context, const PricingPage()),
              onLogin: () => _open(context, const LoginPage()),
              onStart: () => _open(context, const RegisterPage()),
            ),
            _Hero(
              onStart: () => _open(context, const RegisterPage()),
              onDemo: () => _demo(context),
            ),
            const _Proofs(),
            const _Section(
              label: 'UN OUTIL MÉTIER, PAS UN FORMULAIRE',
              title: 'Tout ce qu’il faut pour avancer plus vite',
              subtitle: 'Une interface claire, une action principale par écran et une logique adaptée à la réalité d’une visite.',
              cards: [
                _InfoCard(Icons.photo_camera_back_outlined, 'Photographiez d’abord', 'Ajoutez les photos pendant la visite puis complétez les descriptions sans perdre le fil.'),
                _InfoCard(Icons.auto_awesome_outlined, 'Rédigez simplement', 'Structurez constats, observations et équipements avec une assistance pensée pour l’expert.'),
                _InfoCard(Icons.task_alt_rounded, 'Finalisez sur place', 'Relisez, signez et préparez le rapport Word ou PDF avant de quitter les lieux.'),
              ],
            ),
            const _Section(
              tinted: true,
              label: 'UNE VISITE FLUIDE',
              title: 'Du dossier au rapport, sans rupture',
              subtitle: 'Constat+ accompagne votre méthode de travail au lieu de vous imposer la sienne.',
              cards: [
                _InfoCard(Icons.folder_open_rounded, '1. Créez le dossier', 'Encodez le bien, les parties et le type de mission.'),
                _InfoCard(Icons.home_work_outlined, '2. Réalisez la visite', 'Décrivez les pièces, ajoutez les photos et vos observations.'),
                _InfoCard(Icons.description_outlined, '3. Signez et exportez', 'Faites signer les parties et générez le rapport final.'),
              ],
            ),
            const _Creator(),
            _Cta(
              onStart: () => _open(context, const RegisterPage()),
              onOffers: () => _open(context, const PricingPage()),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onOffers, required this.onLogin, required this.onStart});

  final VoidCallback onOffers;
  final VoidCallback onLogin;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 30, vertical: 14),
          child: Row(
            children: [
              const _Brand(),
              const Spacer(),
              if (!mobile) TextButton(onPressed: onOffers, child: const Text('Nos offres')),
              OutlinedButton(onPressed: onLogin, child: Text(mobile ? 'Connexion' : 'Se connecter')),
              const SizedBox(width: 8),
              FilledButton(onPressed: onStart, child: Text(mobile ? 'Essayer' : 'Commencer')),
            ],
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4F46E5)]),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.fact_check_rounded, color: Colors.white),
        ),
        const SizedBox(width: 9),
        const Text.rich(
          TextSpan(children: [TextSpan(text: 'Constat'), TextSpan(text: '+', style: TextStyle(color: Color(0xFF2563EB)))]),
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.8),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onStart, required this.onDemo});

  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF173E8F), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 760;
            final copy = _HeroCopy(compact: mobile, onStart: onStart, onDemo: onDemo);
            final image = _HeroImage(compact: mobile);
            return Padding(
              padding: EdgeInsets.fromLTRB(mobile ? 20 : 44, mobile ? 26 : 46, mobile ? 20 : 34, 0),
              child: mobile
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, image])
                  : Row(children: [Expanded(flex: 11, child: copy), const SizedBox(width: 28), Expanded(flex: 9, child: image)]),
            );
          },
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact, required this.onStart, required this.onDemo});

  final bool compact;
  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
          ),
          child: const Text('CONÇU POUR LES PROFESSIONNELS DU TERRAIN', style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .6)),
        ),
        SizedBox(height: compact ? 18 : 24),
        Text(
          'Laissez le logiciel écrire.\nConcentrez-vous sur ce que vous voyez.',
          style: TextStyle(color: Colors.white, fontSize: compact ? 33 : 50, height: 1.06, fontWeight: FontWeight.w900, letterSpacing: compact ? -1 : -1.7),
        ),
        SizedBox(height: compact ? 16 : 20),
        Text(
          'Photos, descriptions, calculs, signatures et rapport final : Constat+ vous accompagne pendant toute la visite, sur téléphone comme sur tablette.',
          style: TextStyle(color: const Color(0xFFD6E4FF), fontSize: compact ? 15 : 18, height: 1.55),
        ),
        SizedBox(height: compact ? 22 : 28),
        _HeroActions(compact: compact, onStart: onStart, onDemo: onDemo),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [_HeroProof('Mobile first'), _HeroProof('Sauvegarde automatique'), _HeroProof('Word et PDF')],
        ),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({required this.compact, required this.onStart, required this.onDemo});

  final bool compact;
  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final start = FilledButton.icon(
      onPressed: onStart,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text('Créer mon premier constat'),
      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1D4ED8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
    );
    final demo = OutlinedButton.icon(
      onPressed: onDemo,
      icon: const Icon(Icons.play_circle_outline_rounded),
      label: const Text('Voir la démonstration'),
      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
    );
    if (!compact) return Wrap(spacing: 12, runSpacing: 12, children: [start, demo]);
    return Column(children: [SizedBox(width: double.infinity, child: start), const SizedBox(height: 10), SizedBox(width: double.infinity, child: demo)]);
  }
}

class _HeroProof extends StatelessWidget {
  const _HeroProof(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF93C5FD)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: Color(0xFFE0ECFF), fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 285 : 500,
      child: Image.asset(
        'assets/images/gianni_tablet.png',
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.tablet_mac_rounded, size: 110, color: Colors.white70)),
      ),
    );
  }
}

class _Proofs extends StatelessWidget {
  const _Proofs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 4, 18, 34),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          _Chip(Icons.camera_alt_outlined, 'Photo avant rédaction'),
          _Chip(Icons.cloud_off_outlined, 'Pensé pour le terrain'),
          _Chip(Icons.draw_outlined, 'Signature sur tablette'),
          _Chip(Icons.description_outlined, 'Export professionnel'),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 17, color: const Color(0xFF2563EB)),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(color: Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.title, required this.subtitle, required this.cards, this.tinted = false});

  final String label;
  final String title;
  final String subtitle;
  final List<Widget> cards;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: tinted ? const Color(0xFFEEF4FF) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Column(children: [
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 29, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -.9)),
              const SizedBox(height: 12),
              ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.5))),
              const SizedBox(height: 28),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 600 ? 2 : 1;
                final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(spacing: 14, runSpacing: 14, children: cards.map((card) => SizedBox(width: width, child: card)).toList());
              }),
            ]),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.icon, this.title, this.text);
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF2563EB))),
        const SizedBox(height: 17),
        Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
      ]),
    );
  }
}

class _Creator extends StatelessWidget {
  const _Creator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(26)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CRÉÉ PAR UN PROFESSIONNEL DU TERRAIN', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .9)),
              SizedBox(height: 12),
              Text('Gianni Di Pasquale', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
              SizedBox(height: 6),
              Text('Géomètre-Expert • Expert immobilier • Formateur', style: TextStyle(color: Color(0xFFBFDBFE), fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              Text('Constat+ est développé par Gaudium Immo SRL à Mons à partir des besoins réels rencontrés lors des états des lieux, expertises et visites immobilières.', style: TextStyle(color: Color(0xFFCBD5E1), height: 1.5)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.onStart, required this.onOffers});
  final VoidCallback onStart;
  final VoidCallback onOffers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF4F46E5)]), borderRadius: BorderRadius.circular(28)),
        child: Column(children: [
          const Text('Prêt à réaliser vos constats autrement ?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10, children: [
            FilledButton(onPressed: onStart, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1D4ED8)), child: const Text('Créer un compte')),
            OutlinedButton(onPressed: onOffers, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)), child: const Text('Voir les offres')),
          ]),
        ]),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(children: [
        Text('Constat+ • Créé par Gaudium Immo SRL', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w800)),
        SizedBox(height: 5),
        Text('19 Avenue du Pont Rouge, 7000 Mons • BE 0786.702.365', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ]),
    );
  }
}
