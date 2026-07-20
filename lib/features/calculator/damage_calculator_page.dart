import 'package:flutter/material.dart';

class DamageCalculatorPage extends StatefulWidget {
  const DamageCalculatorPage({super.key});
  @override
  State<DamageCalculatorPage> createState() => _DamageCalculatorPageState();
}

class _DamageCalculatorPageState extends State<DamageCalculatorPage> {
  final quantity = TextEditingController(text: '1');
  final unitPrice = TextEditingController(text: '0');
  final labor = TextEditingController(text: '0');
  final depreciation = TextEditingController(text: '0');
  final tenantShare = TextEditingController(text: '100');
  final vat = TextEditingController(text: '21');

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  double get net {
    final gross = _number(quantity) * _number(unitPrice) + _number(labor);
    final afterDepreciation =
        gross * (1 - (_number(depreciation) / 100).clamp(0, 1));
    return afterDepreciation * (_number(tenantShare) / 100).clamp(0, 1);
  }

  double get total => net * (1 + (_number(vat) / 100).clamp(0, 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calcul des dégâts locatifs')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Calculateur compensatoire',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les prix proposés resteront modifiables et pourront provenir d’une base personnelle ou Constat+.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _input('Quantité', quantity),
              _input('Prix unitaire HTVA', unitPrice),
              _input('Main-d’œuvre HTVA', labor),
              _input('Vétusté (%)', depreciation),
              _input('Part locative (%)', tenantShare),
              _input('TVA (%)', vat),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculer'),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant retenu HTVA : ${net.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total TVAC : ${total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Le détail de chaque poste sera repris dans une annexe calculs du rapport.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) => SizedBox(
    width: 260,
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  void dispose() {
    for (final controller in [
      quantity,
      unitPrice,
      labor,
      depreciation,
      tenantShare,
      vat,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }
}
