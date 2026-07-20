import 'package:flutter/material.dart';

import '../design_system.dart';

class CPCard extends StatefulWidget {
  final Widget child;

  final VoidCallback? onPressed;

  final EdgeInsetsGeometry padding;

  final Color? backgroundColor;

  final bool outlined;

  final double? width;

  final double? height;

  const CPCard({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(CPSpacing.xl),
    this.backgroundColor,
    this.outlined = false,
    this.width,
    this.height,
  });

  @override
  State<CPCard> createState() => _CPCardState();
}

class _CPCardState extends State<CPCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? CPColors.surface,
        borderRadius: CPRadius.radiusLg,
        border: widget.outlined ? Border.all(color: CPColors.border) : null,
        boxShadow: _hover ? CPShadows.lg : CPShadows.md,
      ),
      child: widget.child,
    );

    if (widget.onPressed == null) {
      return card;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: CPRadius.radiusLg,
          onTap: widget.onPressed,
          child: card,
        ),
      ),
    );
  }
}
