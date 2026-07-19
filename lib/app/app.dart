import 'package:flutter/material.dart';

import '../features/auth/login_page.dart';
import 'theme.dart';

class ProjectGeoApp extends StatelessWidget {
  const ProjectGeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Constat+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
