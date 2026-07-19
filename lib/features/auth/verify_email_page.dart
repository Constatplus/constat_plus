import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_service.dart';
import 'widgets/auth_shell.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _loading = false;

  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      await AuthService.resendConfirmation(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Un nouvel e-mail de confirmation a été envoyé.')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Confirmez votre adresse e-mail',
      subtitle: 'Une dernière étape protège votre compte et vos futurs dossiers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              children: [
                const Icon(Icons.outgoing_mail, size: 48, color: Color(0xFF1264F6)),
                const SizedBox(height: 14),
                const Text(
                  'Consultez votre boîte de réception',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cliquez sur le lien reçu, puis revenez vous connecter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF475569), height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Retour à la connexion'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : _resend,
            child: Text(_loading ? 'Envoi en cours…' : 'Renvoyer l’e-mail'),
          ),
        ],
      ),
    );
  }
}
