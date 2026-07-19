import 'package:flutter/material.dart';

import '../../core/access/access_service.dart';
import '../../screens/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  static const _adminEmail = 'info@gaudiumimmo.be';
  static const _adminPassword = 'Constat2026!';
  static const _controllerEmail = 'controleur@constatplus.be';
  static const _controllerPassword = 'Controle2026!';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Complétez votre adresse e-mail et votre mot de passe.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));

    AccountPlan? plan;
    if (email == _adminEmail && password == _adminPassword) {
      plan = AccountPlan.admin;
    } else if (email == _controllerEmail && password == _controllerPassword) {
      plan = AccountPlan.controller;
    } else if (password == 'Demo2026!') {
      if (email.startsWith('solo@')) {
        plan = AccountPlan.solo;
      } else if (email.startsWith('pro@')) {
        plan = AccountPlan.pro;
      } else if (email.startsWith('occasionnel@')) {
        plan = AccountPlan.occasional;
      }
    }

    if (!mounted) return;

    if (plan == null) {
      setState(() {
        _loading = false;
        _error = 'Identifiants incorrects. Utilisez un compte de démonstration.';
      });
      return;
    }

    AccessService.instance.signIn(email: email, plan: plan);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  void _fillDemo(String email) {
    _emailController.text = email;
    _passwordController.text = 'Demo2026!';
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 820;
                    final presentation = _PresentationPanel(compact: compact);
                    final form = _LoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      loading: _loading,
                      error: _error,
                      onTogglePassword: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      onLogin: _login,
                      onDemo: _fillDemo,
                    );

                    return compact
                        ? Column(mainAxisSize: MainAxisSize.min, children: [presentation, form])
                        : IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: presentation),
                                Expanded(child: form),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresentationPanel extends StatelessWidget {
  final bool compact;

  const _PresentationPanel({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 320 : 650),
      padding: const EdgeInsets.all(42),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Constat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: '+',
                  style: TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            'Laissez le logiciel écrire.\nConcentrez-vous sur ce que vous voyez.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Visite guidée, analyse photo, rapport Word et contrôle humain dans un même espace professionnel.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 16,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 34),
          const _FeatureLine(icon: Icons.auto_awesome, label: 'Assistant IA de terrain'),
          const _FeatureLine(icon: Icons.description_outlined, label: 'Rapports Word personnalisables'),
          const _FeatureLine(icon: Icons.verified_user_outlined, label: 'Compte administrateur vérifié'),
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFBFDBFE)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool loading;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final ValueChanged<String> onDemo;

  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loading,
    required this.error,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(42),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connexion',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accédez à vos dossiers et à votre abonnement.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              prefixIcon: Icon(Icons.mail_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            onSubmitted: (_) => onLogin(),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: Color(0xFFB91C1C))),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onLogin,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Se connecter'),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Comptes de vérification',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('Contrôleur'),
                onPressed: () {
                  emailController.text = 'controleur@constatplus.be';
                  passwordController.text = 'Controle2026!';
                },
              ),
              ActionChip(
                label: const Text('Occasionnel'),
                onPressed: () => onDemo('occasionnel@demo.constatplus.be'),
              ),
              ActionChip(
                label: const Text('Solo'),
                onPressed: () => onDemo('solo@demo.constatplus.be'),
              ),
              ActionChip(
                label: const Text('Pro'),
                onPressed: () => onDemo('pro@demo.constatplus.be'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Démo : Demo2026! • Contrôleur : Controle2026!',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
