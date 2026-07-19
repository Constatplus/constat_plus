import 'package:flutter/material.dart';

/// Ombres officielles Constat+
///
/// Toute l'application doit utiliser ces ombres.

abstract final class CPShadows {
  const CPShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];
}