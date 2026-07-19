import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_service.dart';
import '../../core/auth/user_role.dart';
import '../../screens/home_page.dart';
import '../correction/correction_page.dart';
import '../landing/landing_page.dart';

class AuthGate extends StatefulWidget {
  final Object? startupError;

  const AuthGate({super.key, this.startupError});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _subscription;
  Session? _session;

  @override
  void initState() {
    super.initState();
    if (widget.startupError == null) {
      _session = AuthService.client.auth.currentSession;
      _subscription = AuthService.authStateChanges.listen((state) {
        if (!mounted) return;
        setState(() => _session = state.session);
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startupError != null) {
      return _StartupErrorPage(error: widget.startupError!);
    }
    if (_session == null) return const LandingPage();

    final metadata = _session!.user.userMetadata ?? const <String, dynamic>{};
    final role = UserRole.fromValue(metadata['role']);
    return switch (role) {
      UserRole.controller => const CorrectionPage(controllerMode: true),
      UserRole.admin => const HomePage(),
      UserRole.user => const HomePage(),
    };
  }
}

class _StartupErrorPage extends StatelessWidget {
  final Object error;

  const _StartupErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 58, color: Color(0xFFB42318)),
                  const SizedBox(height: 18),
                  const Text('Connexion à Constat+ impossible', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const Text('Vérifiez la configuration Supabase et votre connexion Internet.', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  SelectableText(error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
