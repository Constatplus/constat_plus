import 'package:flutter/material.dart';
import '../home/widgets/sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final VoidCallback onEntry;
  final VoidCallback onExit;
  final VoidCallback onBeforeWorks;
  final VoidCallback onAfterWorks;
  final VoidCallback onFolders;
  final VoidCallback onSettings;
  final VoidCallback? onAdmin;

  const MainLayout({
    super.key,
    required this.child,
    required this.onEntry,
    required this.onExit,
    required this.onBeforeWorks,
    required this.onAfterWorks,
    required this.onFolders,
    required this.onSettings,
    this.onAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: Row(
        children: [
          HomeSidebar(
            onEntry: onEntry,
            onExit: onExit,
            onBeforeWorks: onBeforeWorks,
            onAfterWorks: onAfterWorks,
            onFolders: onFolders,
            onSettings: onSettings,
            onAdmin: onAdmin,
          ),
          Expanded(child: SafeArea(child: child)),
        ],
      ),
    );
  }
}
