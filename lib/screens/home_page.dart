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
      MaterialPageRoute<void>(builder: (_) => WizardPage(missionType: type)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le profil professionnel est indisponible en démonstration locale.',
          ),
        ),
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
    if (!demo) await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
          return ColoredBox(
            color: const Color(0xFFF4F7FB),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 16 : 28),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        compact: compact,
                        onPricing: () => _openPricing(context),
                        onProfile: () => _openProfile(context),
                        onLogout: () => _logout(context),
                      ),
                      const SizedBox(height: 24),
                      _Hero(
                        compact: compact,
                        onEntry: () => _openMission(context, MissionType.entry),
                        onFolders: () => _openFolders(context),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Créer une nouvelle mission',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choisissez le parcours adapté à votre intervention.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      _MissionGrid(
                        onEntry: () => _openMission(context, MissionType.entry),
                        onExit: () => _openMission(context, MissionType.exit),
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
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Dossiers récents',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
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
                      RecentFiles(onOpenFolders: () => _openFolders(context)),
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

class _Header extends StatelessWidget {
  const _Header({
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
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
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

    return Row(children: [Expanded(child: title), actions]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
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
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text(
            'Lancez une nouvelle mission, retrouvez vos dossiers et préparez vos rapports professionnels.',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 16),
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
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _MissionCard(
              width: cardWidth,
              icon: Icons.login_rounded,
              title: "État des lieux d'entrée",
              description: 'Préparez le bien, les pièces et les signatures.',
              accent: const Color(0xFF1264F6),
              onTap: onEntry,
            ),
            _MissionCard(
              width: cardWidth,
              icon: Icons.logout_rounded,
              title: 'État des lieux de sortie',
              description: 'Comparez les états et relevez les dégâts.',
              accent: const Color(0xFFDC2626),
              onTap: onExit,
            ),
            _MissionCard(
              width: cardWidth,
              icon: Icons.construction_rounded,
              title: 'Constat avant travaux',
              description: 'Documentez les lieux avant le chantier.',
              accent: const Color(0xFFF59E0B),
              onTap: onBeforeWorks,
            ),
            _MissionCard(
              width: cardWidth,
              icon: Icons.fact_check_outlined,
              title: 'Récolement après travaux',
              description: 'Contrôlez les changements après intervention.',
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
      height: 225,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
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
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                Text(
                  'Commencer →',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
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
  });

  final bool compact;
  final VoidCallback onFolders;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _QuickCard(
        icon: Icons.folder_copy_outlined,
        title: 'Mes dossiers',
        subtitle: 'Ouvrir, reprendre ou exporter une mission.',
        onTap: onFolders,
      ),
      _QuickCard(
        icon: Icons.tune_rounded,
        title: 'Réglages du rapport',
        subtitle: 'Adapter les informations et la présentation.',
        onTap: onSettings,
      ),
    ];

    if (compact) {
      return Column(
        children: [
          for (final card in cards) ...[
            SizedBox(width: double.infinity, child: card),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
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
