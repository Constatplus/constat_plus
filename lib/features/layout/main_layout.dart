import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
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

  HomeSidebar _buildSidebar() {
    return HomeSidebar(
      onEntry: onEntry,
      onExit: onExit,
      onBeforeWorks: onBeforeWorks,
      onAfterWorks: onAfterWorks,
      onFolders: onFolders,
      onSettings: onSettings,
      onAdmin: onAdmin,
    );
  }

  double _drawerWidth(BuildContext context) {
    final screenWidth = Responsive.width(context);

    if (screenWidth < 360) {
      return screenWidth * 0.86;
    }

    if (screenWidth < 430) {
      return 285;
    }

    return 320;
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8FA),
        drawer: Drawer(
          width: _drawerWidth(context),
          child: SafeArea(
            child: _buildSidebar(),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Constat',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '+',
                  style: TextStyle(
                    color: Color(0xFF1264F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SizedBox.expand(
            child: child,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: Responsive.sideMenuWidth(context),
              child: _buildSidebar(),
            ),
            Expanded(
              child: SizedBox.expand(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
