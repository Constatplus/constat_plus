import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;

        if (!useRail) {
          return Scaffold(
            appBar: AppBar(title: const Text('Constat+')),
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder_rounded),
                  label: 'Dossiers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Réglages',
                ),
              ],
            ),
          );
        }

        final railIsExtended = constraints.maxWidth >= 1180;

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: railIsExtended,
                minWidth: 76,
                minExtendedWidth: 220,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _Brand(compact: !railIsExtended),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: Text('Accueil'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder_rounded),
                    label: Text('Dossiers'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: Text('Réglages'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(Icons.fact_check_outlined, color: Colors.white),
    );

    if (compact) {
      return Tooltip(message: 'Constat+', child: logo);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: 10),
        Text(
          'Constat+',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
