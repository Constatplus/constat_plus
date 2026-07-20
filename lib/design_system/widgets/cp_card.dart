import 'package:flutter/material.dart';

import '../theme/cp_colors.dart';
import '../theme/cp_radius.dart';
import '../theme/cp_shadows.dart';
import '../theme/cp_spacing.dart';

class CPCard extends StatelessWidget {
  final Widget child;

  final VoidCallback? onPressed;

  final EdgeInsetsGeometry padding;

  final Color? backgroundColor;

  final bool outlined;

  final List<BoxShadow>? shadow;

  final double? width;

  final double? height;

  const CPCard({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(CPSpacing.xl),
    this.backgroundColor,
    this.outlined = false,
    this.shadow,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final widget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? CPColors.surface,
        borderRadius: CPRadius.radiusLg,
        border: outlined ? Border.all(color: CPColors.border) : null,
        boxShadow: shadow ?? CPShadows.md,
      ),
      child: child,
    );

    if (onPressed == null) {
      return widget;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: CPRadius.radiusLg,
        onTap: onPressed,
        child: widget,
      ),
    );
  }
}
