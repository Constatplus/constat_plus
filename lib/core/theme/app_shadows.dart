import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static final card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}