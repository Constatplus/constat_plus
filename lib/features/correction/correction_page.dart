import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_service.dart';

class CorrectionPage extends StatelessWidget {
  final bool controllerMode;

  const CorrectionPage({super.key, this.controllerMode = false});

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Constat+ Contrôle'),
        automaticallyImplyLeading: !controllerMode,
        actions: [
          if (controllerMode)
            IconButton(
              tooltip: 'Se déconnecter',
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Text(
            'File de contrôle',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les rapports transmis apparaissent ici. Le contrôleur peut les prendre en charge, les corriger, les valider et les retourner à leur auteur.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.45),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _Metric('En attente', '0', Icons.inbox_outlined),
              _Metric('En cours', '0', Icons.edit_note_rounded),
              _Metric('Corrigés', '0', Icons.fact_check_outlined),
              _Metric('Terminés', '0', Icons.task_alt_rounded),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 46,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Aucun rapport à contrôler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Les dossiers envoyés par les utilisateurs seront affichés dans cette file.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Correction dès 99 € HTVA • bien meublé : supplément de 50 %',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEFF6FF),
                child: Icon(icon, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(label, style: const TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
