import 'package:flutter/material.dart';

class HomeSidebar extends StatelessWidget {
  final VoidCallback onEntry;
  final VoidCallback onExit;
  final VoidCallback onBeforeWorks;
  final VoidCallback onAfterWorks;
  final VoidCallback onFolders;
  final VoidCallback onSettings;
  final VoidCallback? onAdmin;

  const HomeSidebar({
    super.key,
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
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(0, double.infinity),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Constat',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(
                                text: '+',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1264F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "L'assistant intelligent de l'état des lieux",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 28),
                      _menu(Icons.home_rounded, 'Accueil', selected: true),
                      const SizedBox(height: 18),
                      const Text(
                        'MISSIONS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1264F6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _menu(Icons.login_rounded, "État des lieux d'entrée", onTap: onEntry),
                      _menu(Icons.logout_rounded, 'État des lieux de sortie', onTap: onExit, color: Colors.red),
                      _menu(Icons.construction_rounded, 'Avant travaux', onTap: onBeforeWorks, color: Colors.orange),
                      _menu(Icons.fact_check_outlined, 'Récolement après travaux', onTap: onAfterWorks, color: Colors.purple),
                      const SizedBox(height: 14),
                      _menu(Icons.folder_open_rounded, 'Mes dossiers', onTap: onFolders),
                      _menu(Icons.settings, 'Réglages du rapport', onTap: onSettings),
                      if (onAdmin != null)
                        _menu(Icons.admin_panel_settings_outlined, 'Administration', onTap: onAdmin),
                      const Spacer(),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FA),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFFEAF2FF),
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: Color(0xFF1264F6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gianni', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 3),
                                  Text(
                                    'Géomètre-Expert',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _menu(
    IconData icon,
    String title, {
    bool selected = false,
    Color color = const Color(0xFF334155),
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xFFEAF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: selected ? const Color(0xFF1264F6) : color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected ? const Color(0xFF1264F6) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
