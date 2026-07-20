import 'package:flutter/material.dart';

import '../../core/models/mission.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_shell.dart';
import '../folders/folders_page.dart';
import '../missions/mission_wizard_page.dart';
import '../pricing/pricing_page.dart';
import '../settings/settings_page.dart';
import 'widgets/mascot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardContent(
        onOpenFolders: () => setState(() => _index = 1),
        onOpenSettings: () => setState(() => _index = 2),
      ),
      const FoldersPage(),
      const SettingsPage(),
    ];

    return AppShell(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      child: IndexedStack(index: _index, children: pages),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.onOpenFolders,
    required this.onOpenSettings,
    super.key,
  });

  final VoidCallback onOpenFolders;
  final VoidCallback onOpenSettings;

  Future<void> _create(BuildContext context, MissionKind kind) async {
    final mission = AppScope.of(context).createMission(kind);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MissionWizardPage(mission: mission),
      ),
    );
  }

  void _showAssistantMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFF1264F6)),
            SizedBox(width: 10),
            Text('Assistant Gianni'),
          ],
        ),
        content: const Text(
          'L’assistant conversationnel sera relié au module d’analyse photo. '
          'Pour l’instant, ses conseils de visite sont déjà disponibles sur le tableau de bord.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recent = state.missions.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardTopBar(
                    onPricing: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PricingPage(),
                      ),
                    ),
                    onSettings: onOpenSettings,
                  ),
                  const SizedBox(height: 24),
                  _HeroPanel(onOpenFolders: onOpenFolders),
                  const SizedBox(height: 26),
                  Text(
                    'Créer une nouvelle mission',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choisissez le parcours adapté au constat à réaliser.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1050
                          ? 3
                          : constraints.maxWidth >= 660
                          ? 2
                          : 1;
                      final width =
                          (constraints.maxWidth - ((columns - 1) * 16)) /
                          columns;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _MissionChoice(
                            width: width,
                            kind: MissionKind.entry,
                            icon: Icons.login_rounded,
                            accent: const Color(0xFF1264F6),
                            description:
                                'Composition du bien, visite, clés, compteurs et signatures.',
                            onTap: () => _create(context, MissionKind.entry),
                          ),
                          _MissionChoice(
                            width: width,
                            kind: MissionKind.exit,
                            icon: Icons.logout_rounded,
                            accent: const Color(0xFFF59E0B),
                            description:
                                'Comparaison, dégâts locatifs, calculs et clôture du dossier.',
                            onTap: () => _create(context, MissionKind.exit),
                          ),
                          _MissionChoice(
                            width: width,
                            kind: MissionKind.beforeWorks,
                            icon: Icons.construction_rounded,
                            accent: const Color(0xFF8B5CF6),
                            description:
                                'Voirie, façades, abords, zones sensibles et annexe photo.',
                            onTap: () =>
                                _create(context, MissionKind.beforeWorks),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  HomeMascot(
                    onOpenFile: onOpenFolders,
                    onQuestion: () => _showAssistantMessage(context),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dossiers récents',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onOpenFolders,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('Voir tous les dossiers'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    _EmptyRecent(
                      onCreate: () => _create(context, MissionKind.entry),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final twoColumns = constraints.maxWidth >= 850;
                        final width = twoColumns
                            ? (constraints.maxWidth - 14) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: recent
                              .map(
                                (mission) => SizedBox(
                                  width: width,
                                  child: _RecentMissionTile(mission: mission),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({required this.onPricing, required this.onSettings});

  final VoidCallback onPricing;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue sur Constat+ 👋',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Bonjour Gianni, prêt pour une nouvelle expertise ?',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B)),
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
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Réglages'),
            ),
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFEAF2FF),
              child: Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF1264F6),
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 18), actions],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            actions,
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onOpenFolders});

  final VoidCallback onOpenFolders;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF143E8F), Color(0xFF1264F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1264F6).withValues(alpha: .20),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final content = Padding(
            padding: EdgeInsets.all(compact ? 26 : 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'DÉVELOPPÉ PAR UN GÉOMÈTRE-EXPERT',
                    style: TextStyle(
                      color: Color(0xFFDBEAFE),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: .7,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'L’état des lieux professionnel,\nassisté par l’intelligence artificielle.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 690),
                  child: const Text(
                    'Organisez la visite, analysez les photographies et générez un rapport professionnel sans perdre la maîtrise de votre expertise.',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 17,
                        ),
                      ),
                      onPressed: onOpenFolders,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Ouvrir un dossier'),
                    ),
                  ],
                ),
              ],
            ),
          );

          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 300),
            child: content,
          );
        },
      ),
    );
  }
}

class _MissionChoice extends StatelessWidget {
  const _MissionChoice({
    required this.width,
    required this.kind,
    required this.icon,
    required this.accent,
    required this.description,
    required this.onTap,
  });

  final double width;
  final MissionKind kind;
  final IconData icon;
  final Color accent;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 220,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .035),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent, size: 27),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_outward_rounded, color: accent),
                  ],
                ),
                const SizedBox(height: 17),
                Text(
                  kind.label,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
                const Spacer(),
                Text(
                  'Commencer',
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

class _RecentMissionTile extends StatelessWidget {
  const _RecentMissionTile({required this.mission});

  final MissionData mission;

  Color _accent(MissionKind kind) {
    switch (kind) {
      case MissionKind.entry:
        return const Color(0xFF1264F6);
      case MissionKind.exit:
        return const Color(0xFFF59E0B);
      case MissionKind.beforeWorks:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(mission.kind);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MissionWizardPage(mission: mission),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: mission.progress / 100,
                      strokeWidth: 5,
                      backgroundColor: accent.withValues(alpha: .12),
                      color: accent,
                    ),
                    Text(
                      '${mission.progress}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${mission.kind.shortLabel} • ${mission.status.label}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_copy_outlined,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun dossier récent',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Votre première mission apparaîtra ici.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer un dossier'),
          ),
        ],
      ),
    );
  }
}
