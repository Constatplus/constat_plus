import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/mission_card.dart';
import '../entry/entry_mission_page.dart';
import '../folders/folders_page.dart';
import '../settings/settings_page.dart';
import 'mission_placeholder_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _openMission(String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MissionPlaceholderPage(title: title)),
    );
  }

  void _openEntry() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EntryMissionPage()),
    );
  }

  void _openFolders() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FoldersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 960;
        if (compact) {
          return Scaffold(
            appBar: AppBar(
              title: const _Brand(),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                const SizedBox(width: 8),
              ],
            ),
            body: _currentPage(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) => setState(() => _selectedIndex = value),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
                NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'Dossiers'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Réglages'),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              _Sidebar(
                selectedIndex: _selectedIndex,
                onSelected: (value) => setState(() => _selectedIndex = value),
              ),
              Expanded(
                child: Column(
                  children: [
                    const _TopBar(),
                    Expanded(child: _currentPage()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 1:
        return const FoldersPage();
      case 2:
        return const SettingsPage();
      default:
        return _DashboardContent(
          onEntry: _openEntry,
          onExit: () => _openMission('État des lieux de sortie'),
          onBeforeWorks: () => _openMission('Constat avant travaux'),
          onFolders: _openFolders,
        );
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: _Brand()),
          const SizedBox(height: 34),
          _NavItem(index: 0, icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Tableau de bord', selectedIndex: selectedIndex, onSelected: onSelected),
          _NavItem(index: 1, icon: Icons.folder_outlined, selectedIcon: Icons.folder_rounded, label: 'Mes dossiers', selectedIndex: selectedIndex, onSelected: onSelected),
          _NavItem(index: 2, icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Réglages', selectedIndex: selectedIndex, onSelected: onSelected),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('OUTILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 10),
          const _StaticNavItem(icon: Icons.calculate_outlined, label: 'Calculateur'),
          const _StaticNavItem(icon: Icons.description_outlined, label: 'Modèles de rapport'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, child: Text('GD')),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gianni Di Pasquale', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Géomètre-Expert', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ],
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

class _NavItem extends StatelessWidget {
  const _NavItem({required this.index, required this.icon, required this.selectedIcon, required this.label, required this.selectedIndex, required this.onSelected});

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AppTheme.primary.withValues(alpha: 0.09) : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Icon(selected ? selectedIcon : icon, color: selected ? AppTheme.primary : AppTheme.muted),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w600, color: selected ? AppTheme.primary : AppTheme.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticNavItem extends StatelessWidget {
  const _StaticNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.muted),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.text)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          const Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                decoration: InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Rechercher un dossier, une adresse, un client…', contentPadding: EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
          const CircleAvatar(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, child: Text('GD')),
        ],
      ),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.fact_check_outlined, color: Colors.white),
        ),
        const SizedBox(width: 11),
        Text('Constat+', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.onEntry, required this.onExit, required this.onBeforeWorks, required this.onFolders});

  final VoidCallback onEntry;
  final VoidCallback onExit;
  final VoidCallback onBeforeWorks;
  final VoidCallback onFolders;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(onFolders: onFolders),
              const SizedBox(height: 26),
              const _AiBanner(),
              const SizedBox(height: 28),
              Text('Démarrer une mission', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Choisissez le type de constat à réaliser.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth >= 920 ? (constraints.maxWidth - 36) / 3 : constraints.maxWidth;
                  return Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      SizedBox(width: cardWidth, height: 250, child: MissionCard(icon: Icons.login_rounded, title: 'État des lieux d’entrée', subtitle: 'Décrire le bien, photographier chaque pièce et faire signer les parties.', color: const Color(0xFF318A68), onTap: onEntry)),
                      SizedBox(width: cardWidth, height: 250, child: MissionCard(icon: Icons.logout_rounded, title: 'État des lieux de sortie', subtitle: 'Comparer l’état du bien et calculer les éventuelles indemnités.', color: const Color(0xFFC75C5C), onTap: onExit)),
                      SizedBox(width: cardWidth, height: 250, child: MissionCard(icon: Icons.construction_rounded, title: 'Constat avant travaux', subtitle: 'Documenter les abords, les voisins et les éléments à protéger.', color: const Color(0xFFE39A3B), onTap: onBeforeWorks)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: Text('Dossiers récents', style: Theme.of(context).textTheme.headlineMedium)),
                  TextButton.icon(onPressed: onFolders, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Voir tous les dossiers')),
                ],
              ),
              const SizedBox(height: 14),
              const _RecentFiles(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.onFolders});

  final VoidCallback onFolders;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour Gianni 👋', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 7),
              Text('Voici votre espace de travail Constat+.', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        FilledButton.icon(onPressed: onFolders, icon: const Icon(Icons.add_rounded), label: const Text('Nouveau dossier')),
      ],
    );
  }
}

class _AiBanner extends StatelessWidget {
  const _AiBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF164F56), Color(0xFF0D3338)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Votre assistant IA est prêt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
                SizedBox(height: 6),
                Text('Il peut analyser vos photos, signaler les oublis et améliorer la rédaction du rapport.', style: TextStyle(color: Color(0xFFD0E0E2), height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          OutlinedButton.icon(
            onPressed: null,
            icon: Icon(Icons.auto_awesome_outlined),
            label: Text('Ouvrir l’assistant'),
            style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white), side: WidgetStatePropertyAll(BorderSide(color: Color(0x66FFFFFF)))),
          ),
        ],
      ),
    );
  }
}

class _RecentFiles extends StatelessWidget {
  const _RecentFiles();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Appartement Parc 3/84', 'Mons • État des lieux d’entrée', 'Aujourd’hui', Icons.apartment_rounded, Color(0xFF318A68)),
      ('Maison rue de la Colline', 'Cuesmes • État des lieux de sortie', 'Hier', Icons.home_work_outlined, Color(0xFFC75C5C)),
      ('Avant travaux - Baudour', 'Saint-Ghislain • Constat avant travaux', '12 juillet', Icons.construction_rounded, Color(0xFFE39A3B)),
    ];

    return Column(
      children: [
        for (final item in items) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: item.$5.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
                  child: Icon(item.$4, color: item.$5),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(item.$2, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Text(item.$3, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 12),
                const Icon(Icons.more_horiz_rounded, color: AppTheme.muted),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
