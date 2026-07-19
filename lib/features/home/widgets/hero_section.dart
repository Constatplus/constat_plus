import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onEntry;
  final VoidCallback onExit;

  const HeroSection({
    super.key,
    required this.onEntry,
    required this.onExit,
  });

  Widget _feature(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1264F6),
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "Développé par un Géomètre-Expert • Pensé pour le terrain",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "L'expertise immobilière assistée par l'intelligence artificielle.",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Constat+ accompagne aussi bien les particuliers que les professionnels de l'immobilier dans la réalisation d'états des lieux d'entrée, de sortie, avant travaux et d'expertises.",
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Analyse intelligente des photographies, préremplissage des descriptions, organisation automatique des observations et génération d'un rapport Word professionnel en quelques minutes.",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onEntry,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Nouvel état des lieux"),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: onExit,
                          icon: const Icon(Icons.assignment),
                          label: const Text("État des lieux de sortie"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "Conçu par",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      "Di Pasquale Gianni",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const Text(
                      "Géomètre-Expert (GEO20/1523)",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 4,
                child: Image.asset(
                  "assets/images/hero.png",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _feature(
                Icons.auto_awesome,
                "IA intégrée",
                "Analyse intelligente des photographies et préremplissage automatique.",
              ),
              const SizedBox(width: 14),
              _feature(
                Icons.description,
                "Rapport Word",
                "Document professionnel entièrement personnalisable.",
              ),
              const SizedBox(width: 14),
              _feature(
                Icons.photo_library,
                "Photos",
                "Classement automatique et insertion dans le rapport.",
              ),
              const SizedBox(width: 14),
              _feature(
                Icons.groups,
                "Pour tous",
                "Particuliers, agents immobiliers, syndics, géomètres et experts.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}