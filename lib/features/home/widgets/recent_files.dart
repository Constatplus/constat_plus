import 'dart:async';

import 'package:flutter/material.dart';

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Les conseils de Gianni',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Les bonnes pratiques d’un Géomètre-Expert de terrain',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: widget.onOpenFolders,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Mes dossiers'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(_currentAdvice),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 260),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 190,
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
                  const SizedBox(width: 28),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      advice.icon,
                      size: 34,
                      color: const Color(0xFF1264F6),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          advice.message,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              IconButton.outlined(
                tooltip: 'Conseil précédent',
                onPressed: _showPreviousAdvice,
                icon: const Icon(Icons.chevron_left),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Conseil suivant',
                onPressed: _showNextAdvice,
                icon: const Icon(Icons.chevron_right),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Row(
                  children: List.generate(_advices.length, (index) {
                    final selected = index == _currentAdvice;

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
              Text(
                '${_currentAdvice + 1} / ${_advices.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
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
