import 'package:flutter/material.dart';

/// Rayons officiels Constat+
///
/// Tous les BorderRadius de l'application doivent
/// provenir de cette classe.

abstract final class CPRadius {
  const CPRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;

  static BorderRadius get radiusXs => BorderRadius.circular(xs);

  static BorderRadius get radiusSm => BorderRadius.circular(sm);

  static BorderRadius get radiusMd => BorderRadius.circular(md);

  static BorderRadius get radiusLg => BorderRadius.circular(lg);

  static BorderRadius get radiusXl => BorderRadius.circular(xl);

  static BorderRadius get radiusXxl => BorderRadius.circular(xxl);
}
