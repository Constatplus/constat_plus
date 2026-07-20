import 'package:flutter/material.dart';

import '../core/access/access_service.dart';
import '../core/auth/auth_service.dart';
import '../core/models/mission_type.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/folders/folders_page.dart';
import '../features/home/widgets/hero_section.dart';
import '../features/home/widgets/recent_files.dart';
import '../features/home/widgets/top_bar.dart';
import '../features/layout/main_layout.dart';
import '../features/pricing/pricing_page.dart';
import '../features/commercial/presentation/pages/professional_profile_page.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoldersPage()),
    );
  }

  void _openPricing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PricingPage()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportSettingsPage()),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfessionalProfilePage()),
    );
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

  Future<void> _logout(BuildContext context) async {
    final demo = AccessService.instance.isDemo;
    AccessService.instance.signOut();
    if (!demo) await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
      onAfterWorks: () => _openMission(context, MissionType.afterWorks),
      onFolders: () => _openFolders(context),
      onSettings: () => _openSettings(context),
      onAdmin: (access.isAdmin || access.isController)
          ? () => _openAdmin(context)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            HomeTopBar(
              onPricing: () => _openPricing(context),
              onDemo: () =>
                  _message(context, 'Vidéo démo prévue prochainement.'),
              onProfile: () => _openProfile(context),
              onLogin: () async => _logout(context),
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openMission(context, MissionType.beforeWorks),
                            icon: const Icon(Icons.construction_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Créer un constat avant travaux'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openMission(context, MissionType.afterWorks),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Créer un récolement après travaux'),
                            ),
                          ),
                        ),
                      ],
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
