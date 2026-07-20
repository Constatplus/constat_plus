import 'package:flutter/material.dart';

import '../../../core/access/access_service.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback onPricing;
  final VoidCallback onDemo;
  final VoidCallback onProfile;
  final VoidCallback onLogin;

  const HomeTopBar({
    super.key,
    required this.onPricing,
    required this.onDemo,
    required this.onProfile,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Bienvenue sur Constat+ 👋",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        _TopButton(
          icon: Icons.sell_outlined,
          title: "Tarifs",
          onTap: onPricing,
        ),
        const SizedBox(width: 10),
        _TopButton(
          icon: Icons.play_circle_outline_rounded,
          title: "Démo",
          onTap: onDemo,
        ),
        const SizedBox(width: 10),
        _TopButton(
          icon: Icons.badge_outlined,
          title: 'Profil',
          onTap: onProfile,
        ),
        const SizedBox(width: 12),
        AnimatedBuilder(
          animation: AccessService.instance,
          builder: (context, _) {
            final access = AccessService.instance;
            final label = access.isAdmin
                ? 'Admin vérifié'
                : access.plan.name.toUpperCase();
            return OutlinedButton.icon(
              onPressed: onLogin,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                access.isAdmin
                    ? Icons.verified_user_outlined
                    : Icons.person_outline,
              ),
              label: Text(
                '$label · Déconnexion',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      icon: Icon(icon, color: const Color(0xFF1264F6)),
      label: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
