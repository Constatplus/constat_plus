import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SignatureResult {
  final String signerName;
  final List<Offset?> points;
  final bool signed;
  final bool postponed;

  const SignatureResult({
    required this.signerName,
    required this.points,
    required this.signed,
    required this.postponed,
  });

  SignatureResult copyWith({
    String? signerName,
    List<Offset?>? points,
    bool? signed,
    bool? postponed,
  }) {
    return SignatureResult(
      signerName: signerName ?? this.signerName,
      points: points ?? this.points,
      signed: signed ?? this.signed,
      postponed: postponed ?? this.postponed,
    );
  }

  static const empty = SignatureResult(
    signerName: '',
    points: <Offset?>[],
    signed: false,
    postponed: false,
  );
}

class StepSignatureController {
  SignatureResult _firstParty = SignatureResult.empty;
  SignatureResult _secondParty = SignatureResult.empty;
  SignatureResult _expert = SignatureResult.empty;

  SignatureResult get firstParty => _firstParty;
  SignatureResult get secondParty => _secondParty;
  SignatureResult get expert => _expert;

  bool get hasAnySignature {
    return _firstParty.signed || _secondParty.signed || _expert.signed;
  }

  bool get isPostponed {
    return _firstParty.postponed || _secondParty.postponed || _expert.postponed;
  }

  void update({
    required SignatureResult firstParty,
    required SignatureResult secondParty,
    required SignatureResult expert,
  }) {
    _firstParty = firstParty;
    _secondParty = secondParty;
    _expert = expert;
  }
}

class StepSignature extends StatefulWidget {
  final StepSignatureController controller;
  final VoidCallback onContinue;
  final VoidCallback onPostpone;

  const StepSignature({
    super.key,
    required this.controller,
    required this.onContinue,
    required this.onPostpone,
  });

  @override
  State<StepSignature> createState() => _StepSignatureState();
}

class _StepSignatureState extends State<StepSignature> {
  late SignatureResult _firstParty;
  late SignatureResult _secondParty;
  late SignatureResult _expert;

  @override
  void initState() {
    super.initState();

    _firstParty = widget.controller.firstParty;
    _secondParty = widget.controller.secondParty;
    _expert = widget.controller.expert;
  }

  void _saveToController() {
    widget.controller.update(
      firstParty: _firstParty,
      secondParty: _secondParty,
      expert: _expert,
    );
  }

  void _continue() {
    _saveToController();

    if (!_firstParty.signed && !_secondParty.signed && !_expert.signed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ajoutez au moins une signature ou choisissez '
            '« Remettre à plus tard ».',
          ),
        ),
      );
      return;
    }

    widget.onContinue();
  }

  void _postpone() {
    setState(() {
      _firstParty = _firstParty.copyWith(postponed: !_firstParty.signed);

      _secondParty = _secondParty.copyWith(postponed: !_secondParty.signed);

      _expert = _expert.copyWith(postponed: !_expert.signed);
    });

    _saveToController();
    widget.onPostpone();
  }

  void _updateFirstParty(SignatureResult result) {
    setState(() {
      _firstParty = result;
    });
    _saveToController();
  }

  void _updateSecondParty(SignatureResult result) {
    setState(() {
      _secondParty = result;
    });
    _saveToController();
  }

  void _updateExpert(SignatureResult result) {
    setState(() {
      _expert = result;
    });
    _saveToController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1050;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signatures',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les parties peuvent signer maintenant. '
              'La signature peut également être remise à plus tard '
              'sans bloquer la création du rapport.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: compact
                  ? ListView(
                      children: [
                        _SignatureCard(
                          title: 'Première partie',
                          subtitle: 'Propriétaire, bailleur ou représentant',
                          initialName: _firstParty.signerName,
                          initialPoints: _firstParty.points,
                          postponed: _firstParty.postponed,
                          onChanged: _updateFirstParty,
                        ),
                        const SizedBox(height: 18),
                        _SignatureCard(
                          title: 'Deuxième partie',
                          subtitle: 'Locataire, occupant ou représentant',
                          initialName: _secondParty.signerName,
                          initialPoints: _secondParty.points,
                          postponed: _secondParty.postponed,
                          onChanged: _updateSecondParty,
                        ),
                        const SizedBox(height: 18),
                        _SignatureCard(
                          title: 'Expert',
                          subtitle: 'Géomètre-expert ou rédacteur',
                          initialName: _expert.signerName,
                          initialPoints: _expert.points,
                          postponed: _expert.postponed,
                          onChanged: _updateExpert,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _SignatureCard(
                              title: 'Première partie',
                              subtitle:
                                  'Propriétaire, bailleur ou représentant',
                              initialName: _firstParty.signerName,
                              initialPoints: _firstParty.points,
                              postponed: _firstParty.postponed,
                              onChanged: _updateFirstParty,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _SignatureCard(
                              title: 'Deuxième partie',
                              subtitle: 'Locataire, occupant ou représentant',
                              initialName: _secondParty.signerName,
                              initialPoints: _secondParty.points,
                              postponed: _secondParty.postponed,
                              onChanged: _updateSecondParty,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _SignatureCard(
                              title: 'Expert',
                              subtitle: 'Géomètre-expert ou rédacteur',
                              initialName: _expert.signerName,
                              initialPoints: _expert.points,
                              postponed: _expert.postponed,
                              onChanged: _updateExpert,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF1264F6)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Le bouton « Remettre à plus tard » conserve le dossier '
                                'et permet de passer directement à la génération du rapport.',
                                style: TextStyle(color: Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _postpone,
                          icon: const Icon(Icons.schedule_outlined),
                          label: const Text('Remettre à plus tard'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _continue,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Valider et continuer'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF1264F6),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Le bouton « Remettre à plus tard » conserve le dossier '
                            'et permet de passer directement à la génération du rapport.',
                            style: TextStyle(color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _postpone,
                          icon: const Icon(Icons.schedule_outlined),
                          label: const Text('Remettre à plus tard'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _continue,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Valider et continuer'),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SignatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String initialName;
  final List<Offset?> initialPoints;
  final bool postponed;
  final ValueChanged<SignatureResult> onChanged;

  const _SignatureCard({
    required this.title,
    required this.subtitle,
    required this.initialName,
    required this.initialPoints,
    required this.postponed,
    required this.onChanged,
  });

  @override
  State<_SignatureCard> createState() => _SignatureCardState();
}

class _SignatureCardState extends State<_SignatureCard> {
  late final TextEditingController _nameController;
  late List<Offset?> _points;
  late bool _postponed;

  bool get _hasSignature {
    return _points.whereType<Offset>().length >= 2;
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);

    _points = List<Offset?>.from(widget.initialPoints);
    _postponed = widget.postponed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      SignatureResult(
        signerName: _nameController.text.trim(),
        points: List<Offset?>.unmodifiable(_points),
        signed: _hasSignature,
        postponed: _postponed,
      ),
    );
  }

  void _addPoint(Offset point) {
    setState(() {
      _points.add(point);
      _postponed = false;
    });

    _notifyChange();
  }

  void _endStroke() {
    setState(() {
      _points.add(null);
    });

    _notifyChange();
  }

  void _clear() {
    setState(() {
      _points.clear();
      _postponed = false;
    });

    _notifyChange();
  }

  void _togglePostponed(bool value) {
    setState(() {
      _postponed = value;

      if (value) {
        _points.clear();
      }
    });

    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _postponed
        ? 'À signer plus tard'
        : _hasSignature
        ? 'Signature enregistrée'
        : 'En attente de signature';

    final statusColor = _postponed
        ? const Color(0xFFD97706)
        : _hasSignature
        ? const Color(0xFF16A34A)
        : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _hasSignature
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom du signataire',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (_) => _notifyChange(),
          ),
          const SizedBox(height: 14),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _postponed
                  ? const Color(0xFFFFFBEB)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _postponed
                    ? const Color(0xFFFCD34D)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: _postponed
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 42,
                          color: Color(0xFFD97706),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Signature remise à plus tard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (details) {
                            _addPoint(details.localPosition);
                          },
                          onPanUpdate: (details) {
                            final point = details.localPosition;

                            if (point.dx < 0 ||
                                point.dy < 0 ||
                                point.dx > constraints.maxWidth ||
                                point.dy > constraints.maxHeight) {
                              return;
                            }

                            _addPoint(point);
                          },
                          onPanEnd: (_) => _endStroke(),
                          child: CustomPaint(
                            painter: _SignaturePainter(points: _points),
                            child: _points.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Signez dans cette zone',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  )
                                : const SizedBox.expand(),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _postponed
                    ? Icons.schedule_outlined
                    : _hasSignature
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _hasSignature ? _clear : null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Effacer'),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: _postponed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Cette personne signera plus tard'),
              onChanged: (value) {
                _togglePostponed(value ?? false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  const _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < points.length - 1; index++) {
      final current = points[index];
      final next = points[index + 1];

      if (current == null || next == null) {
        continue;
      }

      final path = ui.Path()
        ..moveTo(current.dx, current.dy)
        ..lineTo(next.dx, next.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

/// Compatibility container used by the mission-specific screens.
/// It keeps the same signature state when the widget is rebuilt.
class SignaturesData {
  final StepSignatureController controller;

  SignaturesData({StepSignatureController? controller})
    : controller = controller ?? StepSignatureController();
}

/// Embedded compatibility widget for the exit workflow screens.
/// The main wizard still uses [StepSignature] directly for navigation.
class StepSignatures extends StatelessWidget {
  final SignaturesData data;
  final bool includeExpert;
  final bool embedded;

  const StepSignatures({
    super.key,
    required this.data,
    this.includeExpert = true,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: embedded ? 760 : 820,
      child: StepSignature(
        controller: data.controller,
        onContinue: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signatures enregistrées.')),
          );
        },
        onPostpone: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signatures remises à plus tard.')),
          );
        },
      ),
    );
  }
}
