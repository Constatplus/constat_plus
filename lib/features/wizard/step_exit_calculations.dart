import 'package:flutter/material.dart';

import 'step_signatures.dart';

class StepExitCalculations extends StatefulWidget {
  const StepExitCalculations({super.key});

  @override
  State<StepExitCalculations> createState() => _StepExitCalculationsState();
}

class _StepExitCalculationsState extends State<StepExitCalculations> {
  final List<_DamageLine> _lines = [_DamageLine()];
  final SignaturesData _signatures = SignaturesData();
  final TextEditingController _rentalLoss = TextEditingController(text: '0');

  double _n(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;
  double _lineTotal(_DamageLine line) {
    final gross = _n(line.quantity.text) * _n(line.unitPrice.text) + _n(line.labor.text);
    final afterAge = gross * (1 - (_n(line.depreciation.text) / 100).clamp(0, 1));
    final tenant = afterAge * (_n(line.tenantShare.text) / 100).clamp(0, 1);
    return tenant * (1 + (_n(line.vat.text) / 100).clamp(0, 1));
  }

  double get _total => _lines.fold<double>(0.0, (sum, line) => sum + _lineTotal(line)) + _n(_rentalLoss.text);

  void _addLine() => setState(() => _lines.add(_DamageLine()));
  void _removeLine(int index) {
    if (_lines.length == 1) return;
    setState(() {
      _lines[index].dispose();
      _lines.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final line in _lines) line.dispose();
    _rentalLoss.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const Text('Calcul de l’indemnité compensatoire', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Utilisez le module de calcul pour chaque dégât. Le détail sera repris dans l’annexe du rapport.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
      const SizedBox(height: 22),
      for (var i = 0; i < _lines.length; i++) ...[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text('Poste ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), IconButton(onPressed: () => _removeLine(i), icon: const Icon(Icons.delete_outline))]),
            const SizedBox(height: 10),
            TextField(controller: _lines[i].label, decoration: _input('Travaux / dégât concerné')),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _number(_lines[i].quantity, 'Quantité'),
              _number(_lines[i].unitPrice, 'Prix unitaire HTVA'),
              _number(_lines[i].labor, 'Main-d’œuvre HTVA'),
              _number(_lines[i].depreciation, 'Vétusté (%)'),
              _number(_lines[i].tenantShare, 'Part locative (%)'),
              _number(_lines[i].vat, 'TVA (%)'),
            ]),
            const SizedBox(height: 14),
            Row(children: [const Text('Montant retenu TVAC', style: TextStyle(fontWeight: FontWeight.w700)), const Spacer(), Text('${_lineTotal(_lines[i]).toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]),
          ]),
        ),
        const SizedBox(height: 12),
      ],
      Row(children: [OutlinedButton.icon(onPressed: _addLine, icon: const Icon(Icons.add), label: const Text('Ajouter un poste')), const SizedBox(width: 12), FilledButton.icon(onPressed: () => setState(() {}), icon: const Icon(Icons.calculate_outlined), label: const Text('Recalculer'))]),
      const SizedBox(height: 18),
      SizedBox(width: 320, child: TextField(controller: _rentalLoss, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _input('Chômage locatif éventuel (€)'))),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(18)), child: Row(children: [const Text('Indemnité compensatoire totale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const Spacer(), Text('${_total.toStringAsFixed(2)} € TVAC', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)))])),
      const SizedBox(height: 26),
      StepSignatures(data: _signatures, includeExpert: true, embedded: true),
    ]);
  }

  Widget _number(TextEditingController c, String label) => SizedBox(width: 210, child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _input(label)));
  InputDecoration _input(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)));
}

class _DamageLine {
  final label = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final unitPrice = TextEditingController(text: '0');
  final labor = TextEditingController(text: '0');
  final depreciation = TextEditingController(text: '0');
  final tenantShare = TextEditingController(text: '100');
  final vat = TextEditingController(text: '21');
  void dispose() {
    for (final c in [label, quantity, unitPrice, labor, depreciation, tenantShare, vat]) c.dispose();
  }
}
