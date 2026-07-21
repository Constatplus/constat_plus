import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onEntry;
  final VoidCallback onExit;

  const HeroSection({super.key, required this.onEntry, required this.onExit});

  Widget _feature(
    IconData icon,
    String title,
    String subtitle, {
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isMobile
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: const Color(0xFF1264F6), size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: _FeatureText(
                    title: title,
                    subtitle: subtitle,
                    centered: false,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: const Color(0xFF1264F6), size: 34),
                const SizedBox(height: 10),
                _FeatureText(title: title, subtitle: subtitle, centered: true),
              ],
            ),
    );
  }

  Widget _textContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 11 : 14,
            vertical: isMobile ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Développé par un Géomètre-Expert • Pensé pour le terrain',
            style: TextStyle(
              fontSize: isMobile ? 11 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          "L'expertise immobilière assistée par l'intelligence artificielle.",
          style: TextStyle(
            fontSize: isMobile ? 26 : 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 14 : 20),
        Text(
          "Constat+ accompagne aussi bien les particuliers que les professionnels de l'immobilier dans la réalisation d'états des lieux d'entrée, de sortie, avant travaux et d'expertises.",
          style: TextStyle(
            fontSize: isMobile ? 15 : 17,
            height: isMobile ? 1.5 : 1.6,
            color: const Color(0xFF475569),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          "Analyse intelligente des photographies, préremplissage des descriptions, organisation automatique des observations et génération d'un rapport Word professionnel en quelques minutes.",
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            height: 1.55,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        if (isMobile)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onEntry,
                  icon: const Icon(Icons.play_arrow),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text('Nouvel état des lieux'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.assignment),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text('État des lieux de sortie'),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onEntry,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Nouvel état des lieux'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onExit,
                icon: const Icon(Icons.assignment),
                label: const Text('État des lieux de sortie'),
              ),
            ],
          ),
        SizedBox(height: isMobile ? 18 : 22),
        const Text(
          'Conçu par',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 2),
        const Text(
          'Di Pasquale Gianni',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const Text(
          'Géomètre-Expert (GEO20/1523)',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 18 : 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 22 : 28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _textContent(isMobile: true),
                    const SizedBox(height: 22),
                    Image.asset(
                      'assets/images/hero.png',
                      height: 230,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: _textContent(isMobile: false)),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 4,
                      child: Image.asset(
                        'assets/images/hero.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: isMobile ? 22 : 32),
              if (isMobile)
                Column(
                  children: [
                    _feature(
                      Icons.auto_awesome,
                      'IA intégrée',
                      'Analyse intelligente des photographies et préremplissage automatique.',
                      isMobile: true,
                    ),
                    const SizedBox(height: 10),
                    _feature(
                      Icons.description,
                      'Rapport Word',
                      'Document professionnel entièrement personnalisable.',
                      isMobile: true,
                    ),
                    const SizedBox(height: 10),
                    _feature(
                      Icons.photo_library,
                      'Photos',
                      'Classement automatique et insertion dans le rapport.',
                      isMobile: true,
                    ),
                    const SizedBox(height: 10),
                    _feature(
                      Icons.groups,
                      'Pour tous',
                      'Particuliers, agents immobiliers, syndics, géomètres et experts.',
                      isMobile: true,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _feature(
                        Icons.auto_awesome,
                        'IA intégrée',
                        'Analyse intelligente des photographies et préremplissage automatique.',
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _feature(
                        Icons.description,
                        'Rapport Word',
                        'Document professionnel entièrement personnalisable.',
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _feature(
                        Icons.photo_library,
                        'Photos',
                        'Classement automatique et insertion dans le rapport.',
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _feature(
                        Icons.groups,
                        'Pour tous',
                        'Particuliers, agents immobiliers, syndics, géomètres et experts.',
                        isMobile: false,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureText extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool centered;

  const _FeatureText({
    required this.title,
    required this.subtitle,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
