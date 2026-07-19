import 'package:flutter/material.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FA),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Tarifs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez la formule adaptée à votre besoin',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Constat+ est conçu pour réaliser des états des lieux d'entrée et de sortie de manière rapide, claire et professionnelle.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 34),

            const _SectionTitle(title: 'Utilisation occasionnelle'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                _PriceCard(
                  title: 'Pack 1 dossier',
                  price: '99 €',
                  subtitle: 'Idéal pour un particulier ou un propriétaire.',
                  highlighted: true,
                  features: [
                    '1 état des lieux complet',
                    'Entrée ou sortie',
                    'Photos',
                    'Rapport PDF',
                    'Rapport Word',
                    'Signature',
                    'Accès 30 jours',
                  ],
                ),
                _PriceCard(
                  title: 'Pack 5 dossiers',
                  price: '299 €',
                  subtitle: 'Pour petits bailleurs ou usage ponctuel.',
                  features: [
                    '5 états des lieux',
                    'Photos',
                    'Rapports PDF et Word',
                    'Signature',
                    'Accès 60 jours',
                  ],
                ),
                _PriceCard(
                  title: 'Pack 10 dossiers',
                  price: '499 €',
                  subtitle: 'Pour une activité plus régulière.',
                  features: [
                    '10 états des lieux',
                    'Photos',
                    'Rapports PDF et Word',
                    'Signature',
                    'Accès 90 jours',
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            const _SectionTitle(title: 'Abonnements professionnels'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                _PriceCard(
                  title: 'Starter',
                  price: '99 €/mois',
                  subtitle: 'Pour démarrer avec un outil simple.',
                  features: [
                    'Dossiers illimités',
                    'Photos',
                    'Rapport PDF',
                    'Rapport Word',
                    'Sauvegarde locale',
                  ],
                ),
                _PriceCard(
                  title: 'Pro',
                  price: '140 €/mois',
                  subtitle: 'Pour les professionnels réguliers.',
                  highlighted: true,
                  features: [
                    'Tout Starter',
                    'IA de rédaction',
                    'Logo personnalisé',
                    'Modèles personnalisés',
                    'Assistance prioritaire',
                  ],
                ),
                _PriceCard(
                  title: 'Expert',
                  price: '199 €/mois',
                  subtitle: 'Pour les experts et gros volumes.',
                  features: [
                    'Tout Pro',
                    'Multi-utilisateurs',
                    'Tableau de bord',
                    'Export avancé',
                    'Support prioritaire',
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            const _SectionTitle(title: 'Service complémentaire'),
            const SizedBox(height: 16),

            const _VerificationCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool highlighted;

  const _PriceCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlighted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Recommandé',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (highlighted) const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: highlighted ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: highlighted ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                color: highlighted ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 22),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: highlighted ? Colors.white : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: highlighted ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
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

class _VerificationCard extends StatelessWidget {
  const _VerificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.verified_outlined,
              size: 34,
              color: Color(0xFF1D5FD1),
            ),
          ),
          const SizedBox(width: 22),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vérification par un Géomètre-Expert",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Faites vérifier votre état des lieux avant signature ou envoi.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '99 €',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {},
                child: const Text('Demander une vérification'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}