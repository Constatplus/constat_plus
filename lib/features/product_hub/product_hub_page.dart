import 'package:flutter/material.dart';

import '../../core/models/mission_type.dart';
import '../correction/correction_page.dart';
import '../calculator/damage_calculator_page.dart';
import '../local_writing/phrase_library_page.dart';
import '../pricing/pricing_page.dart';
import '../templates/property_templates_page.dart';
import '../wizard/wizard_page.dart';

class ProductHubPage extends StatelessWidget {
  const ProductHubPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final cards = <_HubCardData>[
      _HubCardData(
        'Nouvelle entrée',
        'Créer un état des lieux d’entrée.',
        Icons.login_rounded,
        () => _open(context, const WizardPage(missionType: MissionType.entry)),
      ),
      _HubCardData(
        'Nouvelle sortie',
        'Observations, clés, index, calculs et clôture.',
        Icons.logout_rounded,
        () => _open(context, const WizardPage(missionType: MissionType.exit)),
      ),
      _HubCardData(
        'Avant travaux',
        'Constat avec voirie, plans et annexes photos.',
        Icons.construction_outlined,
        () => _open(
          context,
          const WizardPage(missionType: MissionType.beforeWorks),
        ),
      ),
      _HubCardData(
        'Modèles de biens',
        'Réutiliser une maison ou un appartement.',
        Icons.home_work_outlined,
        () => _open(context, const PropertyTemplatesPage()),
      ),
      _HubCardData(
        'Bibliothèque locale',
        'Créer des phrases sans connexion Internet.',
        Icons.menu_book_outlined,
        () => _open(context, const PhraseLibraryPage()),
      ),
      _HubCardData(
        'Espace correction',
        'Recevoir et corriger les rapports transmis.',
        Icons.fact_check_outlined,
        () => _open(context, const CorrectionPage()),
      ),
      _HubCardData(
        'Calcul des dégâts',
        'Prix, main-d’œuvre, vétusté, TVA et indemnité.',
        Icons.calculate_outlined,
        () => _open(context, const DamageCalculatorPage()),
      ),
      _HubCardData(
        'Tarifs et crédits',
        'Rapports au choix et crédits supplémentaires.',
        Icons.credit_card_outlined,
        () => _open(context, const PricingPage()),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(title: const Text('Constat+ — Espace de travail')),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          mainAxisExtent: 210,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => _HubCard(data: cards[index]),
      ),
    );
  }
}

class _HubCardData {
  final String title;
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _HubCardData(this.title, this.text, this.icon, this.onTap);
}

class _HubCard extends StatelessWidget {
  final _HubCardData data;
  const _HubCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, size: 40),
              const Spacer(),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.text,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
