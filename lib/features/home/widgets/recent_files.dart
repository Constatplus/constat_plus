import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';

class RecentFiles extends StatefulWidget {
  final VoidCallback onOpenFolders;

  const RecentFiles({super.key, required this.onOpenFolders});

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  final List<_InspectionAdvice> _advices = const [
    _InspectionAdvice(
      image: 'assets/images/gianni_point.png',
      icon: Icons.stairs_rounded,
      title: 'Commencez par la pièce la plus haute',
      message:
          'Commencez la visite par le dernier étage, puis descendez progressivement jusqu’au rez-de-chaussée et aux extérieurs.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_tablet.png',
      icon: Icons.route_rounded,
      title: 'Suivez toujours le même ordre',
      message:
          'Dans chaque pièce, décrivez les éléments dans un ordre constant : plafond, murs, sol, portes, fenêtres, chauffage, électricité et équipements.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_camera.png',
      icon: Icons.kitchen_rounded,
      title: 'Photographiez l’intérieur des meubles',
      message:
          'Ouvrez les armoires, placards et meubles de cuisine. Photographiez les tablettes, charnières, fonds et éventuelles traces d’humidité.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_camera.png',
      icon: Icons.photo_camera_back_rounded,
      title: 'Prenez des vues générales et détaillées',
      message:
          'Commencez par une vue générale de la pièce, puis photographiez chaque défaut de près avec suffisamment de recul pour pouvoir le localiser.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_point.png',
      icon: Icons.countertops_rounded,
      title: 'Contrôlez le bac évier',
      message:
          'Photographiez le bac évier, la robinetterie, les joints, la bonde et le dessous du meuble afin de repérer les impacts, fuites ou traces d’humidité.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_tablet.png',
      icon: Icons.format_paint_rounded,
      title: 'Notez les références de peinture',
      message:
          'Lorsque l’information est disponible, notez la marque, la teinte, la finition et la référence exacte de la peinture utilisée.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_thinking.png',
      icon: Icons.electrical_services_rounded,
      title: 'Testez les équipements',
      message:
          'Vérifiez les points lumineux, prises, interrupteurs, volets, appareils électroménagers, thermostats et commandes.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_camera.png',
      icon: Icons.water_drop_rounded,
      title: 'Photographiez les compteurs',
      message:
          'Prenez une photo lisible du numéro et de l’index de chaque compteur : eau, gaz, électricité et calorimètres.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_point.png',
      icon: Icons.door_front_door_rounded,
      title: 'Contrôlez les menuiseries',
      message:
          'Ouvrez et fermez les portes, fenêtres, volets et portails. Vérifiez les poignées, serrures, vitrages, joints et mécanismes.',
    ),
    _InspectionAdvice(
      image: 'assets/images/gianni_happy.png',
      icon: Icons.inventory_2_rounded,
      title: 'Vérifiez les éléments remis',
      message:
          'Comptabilisez les clés, badges et télécommandes. Photographiez aussi les manuels, attestations et documents d’entretien.',
    ),
  ];

  int _currentAdvice = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _showNextAdvice(),
    );
  }

  void _showNextAdvice() {
    if (!mounted) return;

    setState(() {
      _currentAdvice = (_currentAdvice + 1) % _advices.length;
    });
  }

  void _showPreviousAdvice() {
    setState(() {
      _currentAdvice = (_currentAdvice - 1 + _advices.length) % _advices.length;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advice = _advices[_currentAdvice];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final padding = Responsive.value(
          context: context,
          mobile: 18.0,
          tablet: 24.0,
          desktop: 28.0,
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 22 : 28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _AdviceHeader(
                isMobile: isMobile,
                onOpenFolders: widget.onOpenFolders,
              ),
              SizedBox(height: isMobile ? 18 : 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey(_currentAdvice),
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: isMobile ? 0 : 260),
                  padding: EdgeInsets.all(isMobile ? 18 : 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            SizedBox(
                              height: 180,
                              child: Image.asset(
                                advice.image,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 90,
                                      color: Color(0xFF1264F6),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _AdviceText(advice: advice, isMobile: true),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: constraints.maxWidth < 950 ? 145 : 190,
                              height: 230,
                              child: Image.asset(
                                advice.image,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 100,
                                      color: Color(0xFF1264F6),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth < 950 ? 18 : 28),
                            Container(
                              width: constraints.maxWidth < 950 ? 58 : 70,
                              height: constraints.maxWidth < 950 ? 58 : 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                advice.icon,
                                size: constraints.maxWidth < 950 ? 29 : 34,
                                color: const Color(0xFF1264F6),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth < 950 ? 16 : 22),
                            Expanded(
                              child: _AdviceText(
                                advice: advice,
                                isMobile: false,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: isMobile ? 14 : 18),
              _AdviceControls(
                currentAdvice: _currentAdvice,
                adviceCount: _advices.length,
                onPrevious: _showPreviousAdvice,
                onNext: _showNextAdvice,
                isMobile: isMobile,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdviceHeader extends StatelessWidget {
  const _AdviceHeader({
    required this.isMobile,
    required this.onOpenFolders,
  });

  final bool isMobile;
  final VoidCallback onOpenFolders;

  @override
  Widget build(BuildContext context) {
    final heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 42 : 48,
          height: isMobile ? 42 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF1264F6),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Les conseils de Gianni',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Les bonnes pratiques d’un Géomètre-Expert de terrain',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onOpenFolders,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Mes dossiers'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: heading),
        TextButton.icon(
          onPressed: onOpenFolders,
          icon: const Icon(Icons.folder_open_outlined),
          label: const Text('Mes dossiers'),
        ),
      ],
    );
  }
}

class _AdviceText extends StatelessWidget {
  const _AdviceText({required this.advice, required this.isMobile});

  final _InspectionAdvice advice;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              advice.icon,
              size: 29,
              color: const Color(0xFF1264F6),
            ),
          ),
        if (isMobile) const SizedBox(height: 14),
        Text(
          advice.title,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 19 : 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          advice.message,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            height: 1.55,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _AdviceControls extends StatelessWidget {
  const _AdviceControls({
    required this.currentAdvice,
    required this.adviceCount,
    required this.onPrevious,
    required this.onNext,
    required this.isMobile,
  });

  final int currentAdvice;
  final int adviceCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final indicators = Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(adviceCount, (index) {
            final selected = index == currentAdvice;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1264F6)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ),
    );

    return Row(
      children: [
        IconButton.outlined(
          tooltip: 'Conseil précédent',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          tooltip: 'Conseil suivant',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
        SizedBox(width: isMobile ? 10 : 18),
        indicators,
        const SizedBox(width: 8),
        Text(
          '${currentAdvice + 1} / $adviceCount',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _InspectionAdvice {
  final String image;
  final IconData icon;
  final String title;
  final String message;

  const _InspectionAdvice({
    required this.image,
    required this.icon,
    required this.title,
    required this.message,
  });
}
