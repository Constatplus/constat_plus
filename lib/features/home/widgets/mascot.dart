import 'dart:async';

import 'package:flutter/material.dart';

class HomeMascot extends StatefulWidget {
  final VoidCallback onOpenFile;
  final VoidCallback onQuestion;

  const HomeMascot({
    super.key,
    required this.onOpenFile,
    required this.onQuestion,
  });

  @override
  State<HomeMascot> createState() => _HomeMascotState();
}

class _HomeMascotState extends State<HomeMascot> {
  final List<_MascotMessage> _messages = const [
    _MascotMessage(
      image: 'assets/images/gianni_idle.png',
      text: 'Je vous accompagne pendant toute la visite.',
    ),
    _MascotMessage(
      image: 'assets/images/gianni_point.png',
      text: 'Commencez par la pièce située le plus haut.',
    ),
    _MascotMessage(
      image: 'assets/images/gianni_camera.png',
      text: 'Prenez une vue générale avant les photos de détail.',
    ),
    _MascotMessage(
      image: 'assets/images/gianni_tablet.png',
      text: 'Suivez toujours le même ordre de description.',
    ),
    _MascotMessage(
      image: 'assets/images/gianni_thinking.png',
      text: 'Pensez à vérifier les clés, compteurs et entretiens.',
    ),
    _MascotMessage(
      image: 'assets/images/gianni_happy.png',
      text: 'Un parcours méthodique évite les oublis.',
    ),
  ];

  int _currentIndex = 0;
  bool _showActions = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _showActions) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _messages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleActions() {
    setState(() {
      _showActions = !_showActions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _messages[_currentIndex];

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          SizedBox(
            width: 190,
            height: 250,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                current.image,
                key: ValueKey(current.image),
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Image de Gianni introuvable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF1264F6)),
                    SizedBox(width: 10),
                    Text(
                      'Assistant Gianni',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    current.text,
                    key: ValueKey(current.text),
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _toggleActions,
                  icon: Icon(
                    _showActions
                        ? Icons.close_rounded
                        : Icons.help_outline_rounded,
                  ),
                  label: Text(_showActions ? 'Fermer' : 'Besoin d’aide ?'),
                ),
                if (_showActions) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.onOpenFile,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('Ouvrir mes dossiers'),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.onQuestion,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Poser une question'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotMessage {
  final String image;
  final String text;

  const _MascotMessage({required this.image, required this.text});
}
