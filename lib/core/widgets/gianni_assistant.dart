import 'package:flutter/material.dart';

enum GianniMood {
  idle,
  point,
  camera,
  tablet,
  thinking,
  happy,
}

class GianniAssistant extends StatelessWidget {
  final GianniMood mood;
  final String title;
  final String message;

  const GianniAssistant({
    super.key,
    required this.mood,
    required this.title,
    required this.message,
  });

  String get image {
    switch (mood) {
      case GianniMood.idle:
        return 'assets/images/gianni_idle.png';

      case GianniMood.point:
        return 'assets/images/gianni_point.png';

      case GianniMood.camera:
        return 'assets/images/gianni_camera.png';

      case GianniMood.tablet:
        return 'assets/images/gianni_tablet.png';

      case GianniMood.thinking:
        return 'assets/images/gianni_thinking.png';

      case GianniMood.happy:
        return 'assets/images/gianni_happy.png';
    }
  }

  Color get color {
    switch (mood) {
      case GianniMood.camera:
        return Colors.orange;

      case GianniMood.happy:
        return Colors.green;

      case GianniMood.thinking:
        return Colors.deepPurple;

      default:
        return const Color(0xFF1264F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 28),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  message,
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
    );
  }
}