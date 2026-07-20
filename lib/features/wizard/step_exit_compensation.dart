import 'package:flutter/material.dart';

class StepExitCompensation extends StatefulWidget {
  const StepExitCompensation({super.key});

  @override
  State<StepExitCompensation> createState() => _StepExitCompensationState();
}

class _StepExitCompensationState extends State<StepExitCompensation> {
  final List<_CompensationRow> _rows = <_CompensationRow>[_CompensationRow()];

  void _addRow() {
    setState(() => _rows.add(_CompensationRow()));
  }

  void _removeRow(int index) {
    if (_rows.length == 1) return;
    setState(() {
      final row = _rows.removeAt(index);
      row.dispose();
    });
  }

  double get _total {
    return _rows.fold<double>(0, (sum, row) => sum + row.total);
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          'Calcul des indemnités',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          "Ajoutez uniquement les dégâts locatifs ou remises en état imputables au locataire sortant.",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < _rows.length; i++) ...[
          _buildRow(i),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une indemnité'),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Total estimé',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${_total.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(int index) {
    final row = _rows[index];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Poste ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeRow(index),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: row.description,
            decoration: _input('Travaux ou indemnisation'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _input('Quantité'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: row.unitPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _input('Prix unitaire (€)'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: row.depreciation,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _input('Part retenue (%)'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Sous-total : ${row.total.toStringAsFixed(2)} €',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _CompensationRow {
  final TextEditingController description = TextEditingController();
  final TextEditingController quantity = TextEditingController(text: '1');
  final TextEditingController unitPrice = TextEditingController(text: '0');
  final TextEditingController depreciation = TextEditingController(text: '100');

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
  }

  double get total {
    final quantityValue = _parse(quantity);
    final unitPriceValue = _parse(unitPrice);
    final depreciationValue = _parse(depreciation).clamp(0, 100);
    return quantityValue * unitPriceValue * depreciationValue / 100;
  }

  void dispose() {
    description.dispose();
    quantity.dispose();
    unitPrice.dispose();
    depreciation.dispose();
  }
}
