import 'package:flutter/material.dart';

class UsageMeter extends StatelessWidget {
  final String label;
  final int used;
  final int quota;
  final IconData icon;

  const UsageMeter({
    super.key,
    required this.label,
    required this.used,
    required this.quota,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = quota <= 0 ? 0.0 : (used / quota).clamp(0.0, 1.0);
    final remaining = (quota - used).clamp(0, quota);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text('$used / $quota'),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 10),
          Text(
            '$remaining restant${remaining > 1 ? 's' : ''}',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
