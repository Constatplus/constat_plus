import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, this.controllerMode = false});

  final bool controllerMode;

  @override
  Widget build(BuildContext context) {
    final title = controllerMode ? 'Espace contrôleur' : 'Administration';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(title: Text(title)),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: MediaQuery.sizeOf(context).width > 850 ? 3 : 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: [
          _card(
            Icons.fact_check_outlined,
            'Rapports à relire',
            '0 dossier en attente',
          ),
          _card(Icons.verified_outlined, 'Rapports validés', '0 ce mois-ci'),
          if (!controllerMode)
            _card(
              Icons.people_outline,
              'Utilisateurs',
              'Gestion des comptes et rôles',
            ),
          if (!controllerMode)
            _card(
              Icons.credit_card_outlined,
              'Abonnements',
              'Solo, Pro et Occasionnel',
            ),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 38, color: const Color(0xFF1264F6)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
