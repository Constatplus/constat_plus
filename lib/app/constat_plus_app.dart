import 'package:flutter/material.dart';

import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import '../features/landing/landing_page.dart';

class ConstatPlusApp extends StatefulWidget {
  const ConstatPlusApp({super.key});

  @override
  State<ConstatPlusApp> createState() => _ConstatPlusAppState();
}

class _ConstatPlusAppState extends State<ConstatPlusApp> {
  final AppState _state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Constat+',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LandingPage(),
      ),
    );
  }
}
