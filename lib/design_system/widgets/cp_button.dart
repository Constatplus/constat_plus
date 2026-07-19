import 'package:flutter/material.dart';

import '../theme/cp_colors.dart';
import '../theme/cp_radius.dart';

enum CPButtonVariant {
  primary,
  secondary,
  success,
  danger,
}

class CPButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;
  final CPButtonVariant variant;

  const CPButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
    this.variant = CPButtonVariant.primary,
  });

  Color get _background {
    switch (variant) {
      case CPButtonVariant.primary:
        return CPColors.primary;

      case CPButtonVariant.secondary:
        return CPColors.surfaceAlt;

      case CPButtonVariant.success:
        return CPColors.success;

      case CPButtonVariant.danger:
        return CPColors.danger;
    }
  }

  Color get _foreground {
    switch (variant) {
      case CPButtonVariant.secondary:
        return CPColors.textPrimary;

      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _background,
          foregroundColor: _foreground,
          shape: RoundedRectangleBorder(
            borderRadius: CPRadius.radiusMd,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _foreground,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}