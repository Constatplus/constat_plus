import 'package:flutter/material.dart';

import '../core/access/access_service.dart';
import '../core/models/mission_type.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/auth/login_page.dart';
import '../features/folders/folders_page.dart';
import '../features/home/widgets/hero_section.dart';
import '../features/home/widgets/recent_files.dart';
import '../features/home/widgets/top_bar.dart';
import '../features/layout/main_layout.dart';
import '../features/pricing/pricing_page.dart';
import '../features/settings/report_settings_page.dart';
import '../features/wizard/wizard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openMission(BuildContext context, MissionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WizardPage(missionType: type)),
    );
  }

  void _openFolders(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FoldersPage()));
  }

  void _openPricing(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingPage()));
  }

  void _openSettings(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportSettingsPage()));
  }

  void _openAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardPage(
          controllerMode: AccessService.instance.isController,
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    AccessService.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final access = AccessService.instance;
    return MainLayout(
      onEntry: () => _openMission(context, MissionType.entry),
      onExit: () => _openMission(context, MissionType.exit),
      onBeforeWorks: () => _openMission(context, MissionType.beforeWorks),
      onFolders: () => _openFolders(context),
      onSettings: () => _openSettings(context),
      onAdmin: (access.isAdmin || access.isController) ? () => _openAdmin(context) : null,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            HomeTopBar(
              onPricing: () => _openPricing(context),
              onDemo: () => _message(context, 'Vidéo démo prévue prochainement.'),
              onLogin: () => _logout(context),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeroSection(
                      onEntry: () => _openMission(context, MissionType.entry),
                      onExit: () => _openMission(context, MissionType.exit),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openMission(context, MissionType.beforeWorks),
                        icon: const Icon(Icons.construction_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Créer un état des lieux avant travaux'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    RecentFiles(onOpenFolders: () => _openFolders(context)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
