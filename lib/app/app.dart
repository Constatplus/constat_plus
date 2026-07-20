import 'package:flutter/material.dart';

import '../features/auth/auth_gate.dart';
import 'theme.dart';

class ProjectGeoApp extends StatelessWidget {
  final Object? startupError;
  final Widget? home;

  const ProjectGeoApp({super.key, this.startupError, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Constat+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home ?? AuthGate(startupError: startupError),
    );
  }
}
