import 'package:flutter/material.dart';

import '../core/access/access_service.dart';
import '../core/auth/auth_service.dart';
import '../core/models/mission_type.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/commercial/presentation/pages/professional_profile_page.dart';
import '../features/folders/folders_page.dart';
import '../features/home/widgets/recent_files.dart';
import '../features/layout/main_layout.dart';
import '../features/pricing/pricing_page.dart';
import '../features/settings/report_settings_page.dart';
import '../features/wizard/wizard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openMission(BuildContext context, MissionType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WizardPage(missionType: type),
      ),
    );
  }

  void _openFolders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FoldersPage()),
    );
  }

  void _openPricing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PricingPage()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReportSettingsPage()),
    );
  }

  void _openProfile(BuildContext context) {
    if (AccessService.instance.isDemo) {
      _message(
        context,
        'Le profil professionnel est indisponible en démonstration locale.',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfessionalProfilePage(),
      ),
    );
  }

  void _openAdmin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminDashboardPage(
          controllerMode: AccessService.instance.isController,
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final demo = AccessService.instance.isDemo;
    AccessService.instance.signOut();

    if (!demo) {
      await AuthService.signOut();
    }

    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = AccessService.instance;

    return MainLayout(
      onEntry: () => _openMission(context, MissionType.entry),
      onExit: () => _openMission(context, MissionType.exit),
      onBeforeWorks: () => _openMission(context, MissionType.beforeWorks),
      onAfterWorks: () => _openMission(context, MissionType.afterWorks),
      onFolders: () => _openFolders(context),
      onSettings: () => _openSettings(context),
      onAdmin: access.isAdmin || access.isController
          ? () => _openAdmin(context)
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 850;
          final pagePadding = compact ? 16.0 : 28.0;

          return ColoredBox(
            color: const Color(0xFFF4F7FB),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pagePadding),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DashboardHeader(
                        compact: compact,
                        onPricing: () => _openPricing(context),
                        onProfile: () => _openProfile(context),
                        onLogout: () => _logout(context),
                      ),
                      const SizedBox(height: 24),
                      _WelcomePanel(
                        compact: compact,
                        onEntry: () => _openMission(context, MissionType.entry),
                        onFolders: () => _openFolders(context),
                      ),
                      const SizedBox(height: 28),
                      const _SectionTitle(
                        title: 'Créer une nouvelle mission',
                        subtitle:
                            'Choisissez le parcours adapté à votre intervention.',
                      ),
                      const SizedBox(height: 16),
                      _MissionGrid(
                        onEntry: () =>
                            _openMission(context, MissionType.entry),
                        onExit: () =>
                            _openMission(context, MissionType.exit),
                        onBeforeWorks: () =>
                            _openMission(context, MissionType.beforeWorks),
                        onAfterWorks: () =>
                            _openMission(context, MissionType.afterWorks),
                      ),
                      const SizedBox(height: 28),
                      _QuickActions(
                        compact: compact,
                        onFolders: () => _openFolders(context),
                        onSettings: () => _openSettings(context),
                        onAssistant: () => _message(
                          context,
                          'Le module Assistant IA sera relié à l’analyse photo.',
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Expanded(
                            child: _SectionTitle(
                              title: 'Dossiers récents',
                              subtitle:
                                  'Retrouvez rapidement vos dernières missions.',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _openFolders(context),
                            icon: const Icon(Icons.folder_open_outlined),
                            label: const Text('Voir tous les dossiers'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      RecentFiles(
                        onOpenFolders: () => _openFolders(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.compact,
    required this.onPricing,
    required this.onProfile,
    required this.onLogout,
  });

  final bool compact;
  final VoidCallback onPricing;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour Gianni',
          style: TextStyle(
            fontSize: compact ? 27 : 34,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Bienvenue dans votre espace professionnel Constat+.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: onPricing,
          icon: const Icon(Icons.workspace_premium_outlined),
          label: const Text('Offres'),
        ),
        OutlinedButton.icon(
          onPressed: onProfile,
          icon: const Icon(Icons.badge_outlined),
          label: const Text('Profil'),
        ),
        FilledButton.tonalIcon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Déconnexion'),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 16), actions],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.compact,
    required this.onEntry,
    required this.onFolders,
  });

  final bool compact;
  final VoidCallback onEntry;
  final VoidCallback onFolders;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 24 : 34),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF143E8F), Color(0xFF1264F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1264F6).withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'TABLEAU DE BORD',
              style: TextStyle(
                color: Color(0xFFDBEAFE),
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: .8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Créez, suivez et finalisez vos constats depuis un seul espace.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 27 : 36,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: const Text(
              'Lancez une nouvelle mission, retrouvez vos dossiers et préparez vos rapports professionnels sans quitter Constat+.',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onEntry,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1264F6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nouvel état des lieux'),
              ),
              OutlinedButton.icon(
                onPressed: onFolders,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Ouvrir mes dossiers'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionGrid extends StatelessWidget {
  const _MissionGrid({
    required this.onEntry,
    required this.onExit,
    required this.onBeforeWorks,
    required this.onAfterWorks,
  });

  final VoidCallback onEntry;
  final VoidCallback onExit;
  final VoidCallback onBeforeWorks;
  final VoidCallback onAfterWorks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1150
            ? 4
            : constraints.maxWidth >= 760
                ? 2
                : 1;
        final width =
            (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _MissionCard(
              width: width,
              icon: Icons.login_rounded,
              title: "État des lieux d'entrée",
              description:
                  'Préparez la composition du bien, les pièces, les compteurs et les signatures.',
              accent: const Color(0xFF1264F6),
              onTap: onEntry,
            ),
            _MissionCard(
              width: width,
              icon: Icons.logout_rounded,
              title: 'État des lieux de sortie',
              description:
                  'Comparez les états, relevez les dégâts et préparez le décompte final.',
              accent: const Color(0xFFDC2626),
              onTap: onExit,
            ),
            _MissionCard(
              width: width,
              icon: Icons.construction_rounded,
              title: 'Constat avant travaux',
              description:
                  'Documentez les façades, voiries, abords et zones sensibles avant chantier.',
              accent: const Color(0xFFF59E0B),
              onTap: onBeforeWorks,
            ),
            _MissionCard(
              width: width,
              icon: Icons.fact_check_outlined,
              title: 'Récolement après travaux',
              description:
                  'Contrôlez les changements et clôturez proprement votre intervention.',
              accent: const Color(0xFF7C3AED),
              onTap: onAfterWorks,
            ),
          ],
        );
      },
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Commencer',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: accent, size: 19),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.compact,
    required this.onFolders,
    required this.onSettings,
    required this.onAssistant,
  });

  final bool compact;
  final VoidCallback onFolders;
  final VoidCallback onSettings;
  final VoidCallback onAssistant;

  @override
  Widget build(BuildContext context) {
    final children = [
      Expanded(
        child: _QuickActionCard(
          icon: Icons.folder_copy_outlined,
          title: 'Mes dossiers',
          subtitle: 'Ouvrir, reprendre ou exporter une mission.',
          onTap: onFolders,
        ),
      ),
      const SizedBox(width: 16, height: 16),
      Expanded(
        child: _QuickActionCard(
          icon: Icons.tune_rounded,
          title: 'Réglages du rapport',
          subtitle: 'Adapter les informations et la présentation.',
          onTap: onSettings,
        ),
      ),
      const SizedBox(width: 16, height: 16),
      Expanded(
        child: _QuickActionCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Assistant IA',
          subtitle: 'Analyse photo et relecture prochainement.',
          onTap: onAssistant,
        ),
      ),
    ];

    if (compact) {
      return Column(
        children: [
          for (final child in children)
            if (child is! SizedBox) ...[
              SizedBox(width: double.infinity, child: child),
              const SizedBox(height: 12),
            ],
        ],
      );
    }

    return Row(children: children);
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF1264F6)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
