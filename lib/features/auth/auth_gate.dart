import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_service.dart';
import '../../core/auth/auth_profile.dart';
import '../../core/auth/user_role.dart';
import '../../core/access/access_service.dart';
import '../../screens/home_page.dart';
import '../correction/correction_page.dart';
import '../landing/landing_page.dart';
import 'update_password_page.dart';

class AuthGate extends StatefulWidget {
  final Object? startupError;

  const AuthGate({super.key, this.startupError});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _subscription;
  Session? _session;
  bool _passwordRecovery = false;

  @override
  void initState() {
    super.initState();
    if (widget.startupError == null) {
      _session = AuthService.client.auth.currentSession;
      _subscription = AuthService.authStateChanges.listen((state) {
        if (!mounted) return;
        setState(() {
          _session = state.session;
          if (state.event == AuthChangeEvent.passwordRecovery) {
            _passwordRecovery = true;
          } else if (state.event == AuthChangeEvent.signedOut) {
            _passwordRecovery = false;
          }
        });
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
    if (_passwordRecovery) return const UpdatePasswordPage();

    return _AuthenticatedArea(
      key: ValueKey(_session!.user.id),
      email: _session!.user.email ?? '',
    );
  }
}

class _AuthenticatedArea extends StatefulWidget {
  final String email;

  const _AuthenticatedArea({super.key, required this.email});

  @override
  State<_AuthenticatedArea> createState() => _AuthenticatedAreaState();
}

class _AuthenticatedAreaState extends State<_AuthenticatedArea> {
  late Future<AuthProfile> _profile;

  @override
  void initState() {
    super.initState();
    _profile = AuthService.loadCurrentProfile();
  }

  void _retry() {
    setState(() => _profile = AuthService.loadCurrentProfile());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthProfile>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _ProfileLoadError(error: snapshot.error, onRetry: _retry);
        }

        final profile = snapshot.data!;
        if (profile.accountStatus != AuthAccountStatus.active) {
          return _AccountUnavailablePage(status: profile.accountStatus);
        }

        final accountPlan = switch (profile.role) {
          UserRole.admin => AccountPlan.admin,
          UserRole.controller => AccountPlan.controller,
          UserRole.user => AccountPlan.occasional,
        };
        AccessService.instance.setAuthenticatedAccount(
          email: profile.email.isEmpty ? widget.email : profile.email,
          plan: accountPlan,
        );

        return switch (profile.role) {
          UserRole.controller => const CorrectionPage(controllerMode: true),
          UserRole.admin => const HomePage(),
          UserRole.user => const HomePage(),
        };
      },
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 52),
                  const SizedBox(height: 16),
                  const Text(
                    'Profil professionnel indisponible',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'La session est valide, mais le profil ne peut pas être chargé.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    error?.toString() ?? 'Erreur inconnue',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: AuthService.signOut,
                        child: const Text('Se déconnecter'),
                      ),
                      FilledButton(
                        onPressed: onRetry,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountUnavailablePage extends StatelessWidget {
  final AuthAccountStatus status;

  const _AccountUnavailablePage({required this.status});

  @override
  Widget build(BuildContext context) {
    final message = switch (status) {
      AuthAccountStatus.pending =>
        'Votre compte est en attente d’activation. Vérifiez votre adresse e-mail.',
      AuthAccountStatus.suspended =>
        'Votre compte est suspendu. Vos anciens dossiers restent conservés.',
      AuthAccountStatus.closed => 'Ce compte est fermé.',
      AuthAccountStatus.active => '',
    };
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock_outlined, size: 56),
              const SizedBox(height: 18),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: AuthService.signOut,
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
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
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 58,
                    color: Color(0xFFB42318),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Connexion à Constat+ impossible',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vérifiez la configuration Supabase et votre connexion Internet.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
