import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final availableHeight =
                (constraints.maxHeight - 48).clamp(0.0, double.infinity);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 1160,
                    minHeight: availableHeight,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 34,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: compact
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _BrandPanel(compact: true),
                              _FormPanel(
                                title: title,
                                subtitle: subtitle,
                                child: child,
                                compact: true,
                              ),
                            ],
                          )
                        : IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: _BrandPanel(compact: false),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: _FormPanel(
                                    title: title,
                                    subtitle: subtitle,
                                    child: child,
                                    compact: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  final bool compact;

  const _BrandPanel({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 250 : 680),
      padding: EdgeInsets.all(compact ? 28 : 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2C5C), Color(0xFF1264F6)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Constat',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '+',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF9DC2FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Vos états des lieux,\nréinventés grâce à l’IA.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 28 : 38,
              height: 1.18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyse des photos, rédaction assistée, rapports professionnels et synchronisation de vos dossiers.',
            style: TextStyle(
              color: Color(0xFFDCE9FF),
              fontSize: 16,
              height: 1.55,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 38),
            const _Benefit(
              icon: Icons.auto_awesome_rounded,
              text: 'Préremplissage intelligent des pièces',
            ),
            const _Benefit(
              icon: Icons.cloud_done_outlined,
              text: 'Sauvegarde et synchronisation Cloud',
            ),
            const _Benefit(
              icon: Icons.description_outlined,
              text: 'Rapports Word et PDF professionnels',
            ),
            const SizedBox(height: 48),
            const Divider(color: Color(0x55FFFFFF)),
            const SizedBox(height: 22),
            const Text(
              'Conçu par Di Pasquale Gianni\nGéomètre-Expert (GEO20/1523)',
              style: TextStyle(
                color: Color(0xFFDCE9FF),
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool compact;

  const _FormPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 0 : 680),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 24 : 42,
        vertical: compact ? 32 : 46,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            compact ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }
}
