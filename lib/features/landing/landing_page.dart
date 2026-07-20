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

  void _openDemo(BuildContext context) {
    AccessService.instance.startDemo(plan: AccountPlan.occasional);
    _open(context, const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SelectionArea(
          child: ListView(
            children: [
              _TopNavigation(
                onPricing: () => _open(context, const PricingPage()),
                onLogin: () => _open(context, const LoginPage()),
                onRegister: () => _open(context, const RegisterPage()),
              ),
              _Hero(
                onStart: () => _open(context, const RegisterPage()),
                onDemo: () => _openDemo(context),
              ),
              const _TrustStrip(),
              const _MissionSection(),
              const _AiSection(),
              const _WorkflowSection(),
              _FinalCallToAction(
                onStart: () => _open(context, const RegisterPage()),
                onPricing: () => _open(context, const PricingPage()),
              ),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({
    required this.onPricing,
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onPricing;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logo = const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LogoMark(),
              SizedBox(width: 11),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Constat',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: '+',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final buttons = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(onPressed: onPricing, child: const Text('Nos offres')),
              OutlinedButton(
                onPressed: onLogin,
                child: const Text('Se connecter'),
              ),
              FilledButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Commencer'),
              ),
            ],
          );

          if (constraints.maxWidth < 940) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [logo, const SizedBox(height: 16), buttons],
            );
          }

          return Row(children: [logo, const Spacer(), buttons]);
        },
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: .24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.fact_check_rounded, color: Colors.white),
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
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
      child: Container(
        constraints: const BoxConstraints(minHeight: 610),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1220), Color(0xFF142C63), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: .18),
              blurRadius: 40,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(right: -90, top: -90, child: _Glow(size: 330)),
            const Positioned(left: 380, bottom: -150, child: _Glow(size: 300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 44),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final copy = _HeroCopy(onStart: onStart, onDemo: onDemo);
                  const visual = _HeroVisual();

                  if (constraints.maxWidth < 900) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [copy, const SizedBox(height: 36), visual],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 11, child: copy),
                      const SizedBox(width: 36),
                      const Expanded(flex: 9, child: _HeroVisual()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onStart, required this.onDemo});

  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: .14)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: Color(0xFFBFDBFE),
              ),
              SizedBox(width: 8),
              Text(
                'LE LOGICIEL D’ÉTAT DES LIEUX NOUVELLE GÉNÉRATION',
                style: TextStyle(
                  color: Color(0xFFDBEAFE),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Vos constats.\nPlus rapides. Plus précis. Plus professionnels.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 50,
            height: 1.04,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Constat+ transforme votre visite en rapport structuré : photos, descriptions, calculs, signatures et export Word réunis dans un seul outil métier.',
          style: TextStyle(
            color: Color(0xFFD6E4FF),
            fontSize: 18,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1D4ED8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
              ),
              onPressed: onStart,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Créer mon premier constat'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: .45)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
              ),
              onPressed: onDemo,
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Voir la démonstration locale'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 18,
          runSpacing: 12,
          children: [
            _HeroProof(Icons.check_circle_rounded, 'Sans engagement'),
            _HeroProof(Icons.shield_outlined, 'Données sécurisées'),
            _HeroProof(Icons.cloud_off_outlined, 'Utilisable sur le terrain'),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Container(
              height: 310,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: Colors.white.withValues(alpha: .14)),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 8,
            left: 8,
            child: Image.asset(
              'assets/images/gianni_tablet.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) =>
                  const _MascotFallback(),
            ),
          ),
          const Positioned(
            left: 10,
            top: 44,
            child: _FloatingCard(
              icon: Icons.auto_awesome_rounded,
              title: 'Assistant IA',
              subtitle: 'Préremplissage intelligent',
            ),
          ),
          const Positioned(
            right: 0,
            top: 160,
            child: _FloatingCard(
              icon: Icons.photo_camera_back_outlined,
              title: 'Photos analysées',
              subtitle: 'Observations suggérées',
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 32,
            child: _FloatingCard(
              icon: Icons.description_outlined,
              title: 'Rapport prêt',
              subtitle: 'Word et PDF structurés',
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotFallback extends StatelessWidget {
  const _MascotFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircleAvatar(
        radius: 92,
        backgroundColor: Color(0xFFE0EAFF),
        child: Icon(
          Icons.smart_toy_outlined,
          size: 110,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF020617).withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF60A5FA).withValues(alpha: .12),
      ),
    );
  }
}

class _HeroProof extends StatelessWidget {
  const _HeroProof(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF93C5FD)),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD6E4FF),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 28,
        runSpacing: 14,
        children: const [
          _TrustItem(
            Icons.engineering_outlined,
            'Conçu avec un Géomètre-Expert',
          ),
          _TrustItem(
            Icons.home_work_outlined,
            'Pensé pour les professionnels de l’immobilier',
          ),
          _TrustItem(
            Icons.fact_check_outlined,
            'Rapports structurés et contrôlables',
          ),
          _TrustItem(Icons.devices_rounded, 'Windows, web, tablette et mobile'),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 21, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      eyebrow: 'UN OUTIL POUR CHAQUE MISSION',
      title: 'Trois parcours métier, une seule application',
      subtitle:
          'Chaque mission dispose de son propre déroulé pour aller vite sur le terrain sans mélanger les informations.',
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.center,
        children: [
          _MissionCard(
            icon: Icons.login_rounded,
            color: Color(0xFF2563EB),
            title: 'État des lieux d’entrée',
            description:
                'Composition du bien, description pièce par pièce, clés, compteurs, photos et signatures.',
            badge: 'Le plus utilisé',
          ),
          _MissionCard(
            icon: Icons.logout_rounded,
            color: Color(0xFF7C3AED),
            title: 'État des lieux de sortie',
            description:
                'Comparaison, dégâts locatifs, calculs d’indemnisation et synthèse claire des manquements.',
            badge: 'Calculs intégrés',
          ),
          _MissionCard(
            icon: Icons.construction_rounded,
            color: Color(0xFFEA580C),
            title: 'Constat avant travaux',
            description:
                'Façades, voiries, bâtiments voisins, plans et annexes photographiques structurées.',
            badge: 'Preuve photographique',
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.badge,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.55),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Text(
                'Découvrir le parcours',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiSection extends StatelessWidget {
  const _AiSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1180),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFC7D2FE)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final image = SizedBox(
              height: 360,
              child: Image.asset(
                'assets/images/gianni_point.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const _MascotFallback(),
              ),
            );
            const copy = _AiCopy();

            if (constraints.maxWidth < 820) {
              return Column(
                children: [image, const SizedBox(height: 18), copy],
              );
            }
            return Row(
              children: [
                Expanded(flex: 4, child: image),
                const SizedBox(width: 32),
                const Expanded(flex: 6, child: copy),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AiCopy extends StatelessWidget {
  const _AiCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'L’ASSISTANT QUI VOUS FAIT GAGNER DU TEMPS',
          style: TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Votre expertise reste humaine. L’IA s’occupe du travail répétitif.',
          style: TextStyle(
            fontSize: 34,
            height: 1.12,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Assistant Gianni analyse les photos, suggère les postes à compléter, reformule les observations et contrôle la cohérence du rapport avant sa finalisation.',
          style: TextStyle(
            fontSize: 17,
            height: 1.55,
            color: Color(0xFF4B5563),
          ),
        ),
        SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AiChip(Icons.photo_camera_back_outlined, 'Analyse photographique'),
            _AiChip(Icons.edit_note_rounded, 'Rédaction professionnelle'),
            _AiChip(Icons.rule_folder_outlined, 'Contrôle de complétude'),
            _AiChip(
              Icons.lightbulb_outline_rounded,
              'Conseils pendant la visite',
            ),
          ],
        ),
      ],
    );
  }
}

class _AiChip extends StatelessWidget {
  const _AiChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDDE3FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4F46E5), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionShell(
      eyebrow: 'DU TERRAIN AU RAPPORT',
      title: 'Un processus simple, même pour un dossier complexe',
      subtitle:
          'Vous restez concentré sur le constat. Constat+ organise le reste.',
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _StepCard(
            number: '01',
            icon: Icons.add_home_work_outlined,
            title: 'Créez le dossier',
            text: 'Encodez les parties, l’adresse et la composition du bien.',
          ),
          _StepCard(
            number: '02',
            icon: Icons.photo_camera_outlined,
            title: 'Réalisez la visite',
            text: 'Décrivez, photographiez et complétez chaque poste.',
          ),
          _StepCard(
            number: '03',
            icon: Icons.auto_awesome_outlined,
            title: 'Laissez l’IA assister',
            text:
                'Recevez des suggestions sans perdre la maîtrise de votre expertise.',
          ),
          _StepCard(
            number: '04',
            icon: Icons.description_outlined,
            title: 'Générez le rapport',
            text:
                'Exportez un document structuré, professionnel et personnalisable.',
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
  });

  final String number;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFBFDBFE),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
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

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
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
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 35,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.55,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalCallToAction extends StatelessWidget {
  const _FinalCallToAction({required this.onStart, required this.onPricing});

  final VoidCallback onStart;
  final VoidCallback onPricing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 70),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1180),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 42),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final text = const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prêt à professionnaliser vos états des lieux ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Créez votre compte et découvrez une nouvelle manière de travailler sur le terrain.',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 16),
                  ),
                ],
              );
              final buttons = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: onStart,
                    child: const Text('Commencer maintenant'),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                    ),
                    onPressed: onPricing,
                    child: const Text('Voir les offres'),
                  ),
                ],
              );

              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [text, const SizedBox(height: 22), buttons],
                );
              }
              return Row(
                children: [
                  const Expanded(child: Column()),
                  Expanded(flex: 3, child: text),
                  const Spacer(),
                  buttons,
                ],
              );
            },
          ),
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
      padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Center(
        child: Text(
          'Constat+ • Conçu pour les professionnels de l’immobilier et de l’expertise',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
