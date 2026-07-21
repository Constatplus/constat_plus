import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750 || Responsive.isMobile(context);

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenue sur Constat+ 👋',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _TopButton(
                    icon: Icons.sell_outlined,
                    title: 'Tarifs',
                    onTap: onPricing,
                    compact: true,
                  ),
                  _TopButton(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Démo',
                    onTap: onDemo,
                    compact: true,
                  ),
                  _TopButton(
                    icon: Icons.badge_outlined,
                    title: 'Profil',
                    onTap: onProfile,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: _AccessButton(onLogin: onLogin, compact: true),
              ),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(
              child: Text(
                'Bienvenue sur Constat+ 👋',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 20),
            _TopButton(
              icon: Icons.sell_outlined,
              title: 'Tarifs',
              onTap: onPricing,
            ),
            const SizedBox(width: 10),
            _TopButton(
              icon: Icons.play_circle_outline_rounded,
              title: 'Démo',
              onTap: onDemo,
            ),
            const SizedBox(width: 10),
            _TopButton(
              icon: Icons.badge_outlined,
              title: 'Profil',
              onTap: onProfile,
            ),
            const SizedBox(width: 12),
            _AccessButton(onLogin: onLogin),
          ],
        );
      },
    );
  }
}

class _AccessButton extends StatelessWidget {
  final VoidCallback onLogin;
  final bool compact;

  const _AccessButton({required this.onLogin, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessService.instance,
      builder: (context, _) {
        final access = AccessService.instance;

        final label = access.isAdmin
            ? 'Admin vérifié'
            : access.plan.name.toUpperCase();

        return OutlinedButton.icon(
          onPressed: onLogin,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 13 : 18,
            ),
            alignment: compact
                ? Alignment.centerLeft
                : AlignmentDirectional.center,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: Icon(
            access.isAdmin
                ? Icons.verified_user_outlined
                : Icons.person_outline,
            size: compact ? 19 : 24,
          ),
          label: Text(
            '$label · Déconnexion',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool compact;

  const _TopButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 18,
          vertical: compact ? 10 : 18,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, color: const Color(0xFF1264F6), size: compact ? 19 : 24),
      label: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
          fontSize: compact ? 13 : 14,
        ),
      ),
    );
  }
}
