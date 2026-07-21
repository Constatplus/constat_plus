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
              subtitle:
                  'Une interface claire, une action principale par écran et une logique adaptée à la réalité d’une visite.',
              cards: [
                _InfoCard(
                  Icons.photo_camera_back_outlined,
                  'Photographiez d’abord',
                  'Ajoutez les photos pendant la visite puis complétez les descriptions sans perdre le fil.',
                ),
                _InfoCard(
                  Icons.auto_awesome_outlined,
                  'Rédigez simplement',
                  'Structurez constats, observations et équipements avec une assistance pensée pour l’expert.',
                ),
                _InfoCard(
                  Icons.task_alt_rounded,
                  'Finalisez sur place',
                  'Relisez, signez et préparez le rapport Word ou PDF avant de quitter les lieux.',
                ),
              ],
            ),
            const _DeviceShowcase(),
            const _Section(
              tinted: true,
              label: 'UNE VISITE FLUIDE',
              title: 'Du dossier au rapport, sans rupture',
              subtitle:
                  'Constat+ accompagne votre méthode de travail au lieu de vous imposer la sienne.',
              cards: [
                _InfoCard(
                  Icons.folder_open_rounded,
                  '1. Créez le dossier',
                  'Encodez le bien, les parties et le type de mission.',
                ),
                _InfoCard(
                  Icons.home_work_outlined,
                  '2. Réalisez la visite',
                  'Décrivez les pièces, ajoutez les photos et vos observations.',
                ),
                _InfoCard(
                  Icons.description_outlined,
                  '3. Signez et exportez',
                  'Faites signer les parties et générez le rapport final.',
                ),
              ],
            ),
            const _Comparison(),
            const _Testimonials(),
            _PricingPreview(
              onOffers: () => _open(context, const PricingPage()),
              onStart: () => _open(context, const RegisterPage()),
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
  const _Header({
    required this.onOffers,
    required this.onLogin,
    required this.onStart,
  });

  final VoidCallback onOffers;
  final VoidCallback onLogin;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 16 : 30,
            vertical: 14,
          ),
          child: Row(
            children: [
              const _Brand(),
              const Spacer(),
              if (!mobile)
                TextButton(
                  onPressed: onOffers,
                  child: const Text('Nos offres'),
                ),
              OutlinedButton(
                onPressed: onLogin,
                child: Text(mobile ? 'Connexion' : 'Se connecter'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onStart,
                child: Text(mobile ? 'Essayer' : 'Commencer'),
              ),
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
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.fact_check_rounded, color: Colors.white),
        ),
        const SizedBox(width: 9),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Constat'),
              TextSpan(
                text: '+',
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
            ],
          ),
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: .18),
              blurRadius: 45,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -90,
              top: -120,
              child: _Glow(size: 310, color: Colors.white.withValues(alpha: .12)),
            ),
            Positioned(
              left: -120,
              bottom: -150,
              child: _Glow(
                size: 290,
                color: const Color(0xFF60A5FA).withValues(alpha: .18),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile = constraints.maxWidth < 760;
                final copy = _HeroCopy(
                  compact: mobile,
                  onStart: onStart,
                  onDemo: onDemo,
                );
                final image = _HeroImage(compact: mobile);
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    mobile ? 20 : 44,
                    mobile ? 26 : 46,
                    mobile ? 20 : 34,
                    0,
                  ),
                  child: mobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [copy, image],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 11, child: copy),
                            const SizedBox(width: 28),
                            Expanded(flex: 9, child: image),
                          ],
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.compact,
    required this.onStart,
    required this.onDemo,
  });

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
          child: const Text(
            'CONÇU POUR LES PROFESSIONNELS DU TERRAIN',
            style: TextStyle(
              color: Color(0xFFDBEAFE),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ),
        SizedBox(height: compact ? 18 : 24),
        Text(
          'Laissez le logiciel écrire.\nConcentrez-vous sur ce que vous voyez.',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 33 : 50,
            height: 1.06,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? -1 : -1.7,
          ),
        ),
        SizedBox(height: compact ? 16 : 20),
        Text(
          'Photos, descriptions, calculs, signatures et rapport final : Constat+ vous accompagne pendant toute la visite, sur téléphone comme sur tablette.',
          style: TextStyle(
            color: const Color(0xFFD6E4FF),
            fontSize: compact ? 15 : 18,
            height: 1.55,
          ),
        ),
        SizedBox(height: compact ? 22 : 28),
        _HeroActions(compact: compact, onStart: onStart, onDemo: onDemo),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _HeroProof('Mobile first'),
            _HeroProof('Sauvegarde automatique'),
            _HeroProof('Word et PDF'),
          ],
        ),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.compact,
    required this.onStart,
    required this.onDemo,
  });

  final bool compact;
  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final start = FilledButton.icon(
      onPressed: onStart,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text('Créer mon premier constat'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D4ED8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
    final demo = OutlinedButton.icon(
      onPressed: onDemo,
      icon: const Icon(Icons.play_circle_outline_rounded),
      label: const Text('Voir la démonstration'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
    if (!compact) {
      return Wrap(spacing: 12, runSpacing: 12, children: [start, demo]);
    }
    return Column(
      children: [
        SizedBox(width: double.infinity, child: start),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: demo),
      ],
    );
  }
}

class _HeroProof extends StatelessWidget {
  const _HeroProof(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: Color(0xFF93C5FD),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE0ECFF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.tablet_mac_rounded,
            size: 110,
            color: Colors.white70,
          ),
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF2563EB)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.cards,
    this.tinted = false,
  });

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
            child: Column(
              children: [
                _SectionTitle(label: label, title: title, subtitle: subtitle),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 3
                        : constraints.maxWidth >= 600
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 14) / columns;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: cards
                          .map((card) => SizedBox(width: width, child: card))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w900,
            letterSpacing: -.9,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(height: 17),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DeviceShowcase extends StatelessWidget {
  const _DeviceShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              const _SectionTitle(
                label: 'PARTOUT AVEC VOUS',
                title: 'Une seule expérience sur tous vos écrans',
                subtitle:
                    'Commencez au bureau, poursuivez sur téléphone et terminez le rapport sur tablette ou ordinateur.',
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  final mobile = constraints.maxWidth < 760;
                  final preview = const _AppPreview();
                  final points = const _DevicePoints();
                  return mobile
                      ? const Column(
                          children: [
                            _AppPreview(),
                            SizedBox(height: 24),
                            _DevicePoints(),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 11, child: preview),
                            const SizedBox(width: 34),
                            Expanded(flex: 8, child: points),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppPreview extends StatelessWidget {
  const _AppPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .18),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _WindowDot(Color(0xFFF87171)),
              const SizedBox(width: 6),
              const _WindowDot(Color(0xFFFBBF24)),
              const SizedBox(width: 6),
              const _WindowDot(Color(0xFF34D399)),
              const Spacer(),
              Container(
                width: 130,
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    _MiniStat('Dossier', 'Rue de la Colline'),
                    SizedBox(width: 10),
                    _MiniStat('Progression', '74 %'),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: .74,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _PreviewRow(Icons.photo_camera_outlined, 'Photos', '28'),
                const _PreviewRow(Icons.notes_rounded, 'Descriptions', '18'),
                const _PreviewRow(Icons.key_rounded, 'Clés et compteurs', 'Complet'),
                const _PreviewRow(Icons.draw_rounded, 'Signatures', 'À finaliser'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevicePoints extends StatelessWidget {
  const _DevicePoints();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DevicePoint(
          Icons.phone_android_rounded,
          'Téléphone',
          'Capturez les photos et encodez rapidement pendant la visite.',
        ),
        SizedBox(height: 12),
        _DevicePoint(
          Icons.tablet_mac_rounded,
          'Tablette',
          'Profitez d’un espace confortable pour décrire et faire signer.',
        ),
        SizedBox(height: 12),
        _DevicePoint(
          Icons.desktop_windows_rounded,
          'Ordinateur',
          'Relisez, gérez vos dossiers et finalisez les rapports.',
        ),
      ],
    );
  }
}

class _DevicePoint extends StatelessWidget {
  const _DevicePoint(this.icon, this.title, this.text);

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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

class _Comparison extends StatelessWidget {
  const _Comparison();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Analyse et organisation des photos', true, false),
      ('Assistance à la rédaction', true, false),
      ('Workflow mobile et tablette', true, true),
      ('Calculs de sortie intégrés', true, false),
      ('Signature sur place', true, true),
      ('Export Word et PDF', true, true),
    ];

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 54),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            children: [
              const Text(
                'LA DIFFÉRENCE CONSTAT+',
                style: TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pensé pour le métier, pas adapté après coup',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const _ComparisonHeader(),
                    for (var index = 0; index < rows.length; index++)
                      _ComparisonRow(
                        label: rows[index].$1,
                        constatPlus: rows[index].$2,
                        classic: rows[index].$3,
                        shaded: index.isOdd,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF6FF),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: const Row(
        children: [
          Expanded(flex: 5, child: Text('Fonctionnalité')),
          Expanded(
            flex: 2,
            child: Text(
              'Constat+',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Outil classique',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.constatPlus,
    required this.classic,
    required this.shaded,
  });

  final String label;
  final bool constatPlus;
  final bool classic;
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: shaded ? const Color(0xFFF8FAFC) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(flex: 2, child: _BoolIcon(value: constatPlus)),
          Expanded(flex: 2, child: _BoolIcon(value: classic)),
        ],
      ),
    );
  }
}

class _BoolIcon extends StatelessWidget {
  const _BoolIcon({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Icon(
      value ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
      color: value ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
    );
  }
}

class _Testimonials extends StatelessWidget {
  const _Testimonials();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _QuoteCard(
        'Enfin une interface qui suit réellement le déroulement d’une visite.',
        'Expert immobilier',
      ),
      _QuoteCard(
        'Les photos, descriptions et signatures restent dans un seul dossier.',
        'Gestionnaire locatif',
      ),
      _QuoteCard(
        'Le travail de relecture devient beaucoup plus simple et structuré.',
        'Géomètre-Expert',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              const _SectionTitle(
                label: 'PENSÉ AVEC LE TERRAIN',
                title: 'Une expérience claire dès la première visite',
                subtitle:
                    'Des bénéfices concrets pour les experts, agences et gestionnaires qui doivent produire des rapports fiables.',
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 600
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 14) / columns;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: cards
                        .map((card) => SizedBox(width: width, child: card))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard(this.quote, this.role);

  final String quote;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: Color(0xFF2563EB)),
          const SizedBox(height: 12),
          Text(
            quote,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            role,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingPreview extends StatelessWidget {
  const _PricingPreview({required this.onOffers, required this.onStart});

  final VoidCallback onOffers;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              const _SectionTitle(
                label: 'DES OFFRES SIMPLES',
                title: 'Choisissez selon votre volume de travail',
                subtitle:
                    'Une formule pour un constat occasionnel, une activité régulière ou une équipe professionnelle.',
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 600
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 14) / columns;
                  final cards = [
                    _PlanPreview(
                      title: 'Particulier',
                      subtitle: 'Pour un besoin ponctuel',
                      icon: Icons.person_outline_rounded,
                      onTap: onOffers,
                    ),
                    _PlanPreview(
                      title: 'Solo',
                      subtitle: 'Pour les professionnels indépendants',
                      icon: Icons.workspace_premium_outlined,
                      highlighted: true,
                      onTap: onStart,
                    ),
                    _PlanPreview(
                      title: 'Pro',
                      subtitle: 'Pour les équipes et volumes réguliers',
                      icon: Icons.business_center_outlined,
                      onTap: onOffers,
                    ),
                  ];
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: cards
                        .map((card) => SizedBox(width: width, child: card))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanPreview extends StatelessWidget {
  const _PlanPreview({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF1D4ED8) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withValues(alpha: .22),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: highlighted ? Colors.white : const Color(0xFF2563EB)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: highlighted ? Colors.white : const Color(0xFF0F172A),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: TextStyle(
              color: highlighted ? const Color(0xFFDBEAFE) : const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: highlighted
                ? FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1D4ED8),
                    ),
                    child: const Text('Commencer'),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    child: const Text('Voir l’offre'),
                  ),
          ),
        ],
      ),
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
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRÉÉ PAR UN PROFESSIONNEL DU TERRAIN',
                  style: TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .9,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Gianni Di Pasquale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Géomètre-Expert • Expert immobilier • Formateur',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Constat+ est développé par Gaudium Immo SRL à Mons à partir des besoins réels rencontrés lors des états des lieux, expertises et visites immobilières.',
                  style: TextStyle(color: Color(0xFFCBD5E1), height: 1.5),
                ),
              ],
            ),
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const Text(
              'Prêt à réaliser vos constats autrement ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D4ED8),
                  ),
                  child: const Text('Créer un compte'),
                ),
                OutlinedButton(
                  onPressed: onOffers,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('Voir les offres'),
                ),
              ],
            ),
          ],
        ),
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
      child: Column(
        children: [
          Text(
            'Constat+ • Créé par Gaudium Immo SRL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '19 Avenue du Pont Rouge, 7000 Mons • BE 0786.702.365',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
