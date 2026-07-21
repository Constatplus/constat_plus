import 'dart:io';

import 'package:flutter/material.dart';

import 'comparison/models/comparison_remark.dart';
import 'exit/models/exit_damage_line.dart';
import 'exit/services/exit_damage_sync.dart';
import 'property_composition/models/room_item.dart';
import 'step_signatures.dart';

class StepExitCalculations extends StatefulWidget {
  const StepExitCalculations({
    super.key,
    required this.rooms,
    required this.remarks,
    required this.lines,
    required this.dismissedSourceIds,
  });

  final List<RoomItem> rooms;
  final List<ComparisonRemark> remarks;
  final List<ExitDamageLine> lines;
  final Set<String> dismissedSourceIds;

  @override
  State<StepExitCalculations> createState() => _StepExitCalculationsState();
}

class _StepExitCalculationsState extends State<StepExitCalculations> {
  static const List<String> _generalCategories = <String>[
    'Nettoyage général',
    'Entretien',
    'Jardin',
    'Déchets et encombrants',
    'Nettoyage des vitres',
    'Nettoyage de la cuisine',
    'Nettoyage des sanitaires',
    'Remplacement des clés',
    'Relevé ou régularisation des compteurs',
    'Divers',
  ];

  static const List<String> _posts = <String>[
    'Sol',
    'Plafond',
    'Mur avant',
    'Mur droit',
    'Mur arrière',
    'Mur gauche',
    'Menuiseries',
    'Électricité',
    'Porte',
    'Radiateur',
    'Châssis',
    'Sanitaires',
    'Mobilier',
    'Autre',
  ];

  late final List<_DamageLine> _lines;
  final SignaturesData _signatures = SignaturesData();
  final TextEditingController _rentalLoss = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    ExitDamageSync.synchronize(
      remarks: widget.remarks,
      lines: widget.lines,
      dismissedSourceIds: widget.dismissedSourceIds,
    );
    _lines = widget.lines.map(_DamageLine.new).toList(growable: true);
  }

  double _n(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;

  double _lineTotal(_DamageLine line) {
    final gross =
        _n(line.quantity.text) * _n(line.unitPrice.text) + _n(line.labor.text);
    final afterAge =
        gross * (1 - (_n(line.depreciation.text) / 100).clamp(0, 1));
    final tenant = afterAge * (_n(line.tenantShare.text) / 100).clamp(0, 1);
    return tenant * (1 + (_n(line.vat.text) / 100).clamp(0, 1));
  }

  double get _total =>
      _lines.fold<double>(0.0, (sum, line) => sum + _lineTotal(line)) +
      _n(_rentalLoss.text);

  void _addLine() {
    final data = ExitDamageLine(
      id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
    );
    setState(() {
      widget.lines.add(data);
      _lines.add(_DamageLine(data));
    });
  }

  void _removeLine(int index) {
    setState(() {
      final line = _lines.removeAt(index);
      if (line.data.sourceRemarkId.isNotEmpty) {
        widget.dismissedSourceIds.add(line.data.sourceRemarkId);
      }
      widget.lines.remove(line.data);
      line.dispose();
    });
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _rentalLoss.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomNames = widget.rooms.map((room) => room.name).toList();
    final compact = MediaQuery.sizeOf(context).width < 700;

    return ListView(
      children: <Widget>[
        Text(
          'Calcul de l’indemnité compensatoire',
          style: TextStyle(
            fontSize: compact ? 24 : 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rattachez chaque calcul à une pièce et à un poste, ou à une généralité comme le nettoyage ou l’entretien.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < _lines.length; i++) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Poste ${i + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _removeLine(i),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SegmentedButton<ExitDamageOriginType>(
                  direction: compact ? Axis.vertical : Axis.horizontal,
                  segments: const <ButtonSegment<ExitDamageOriginType>>[
                    ButtonSegment<ExitDamageOriginType>(
                      value: ExitDamageOriginType.room,
                      icon: Icon(Icons.meeting_room_outlined),
                      label: Text('Lié à une pièce'),
                    ),
                    ButtonSegment<ExitDamageOriginType>(
                      value: ExitDamageOriginType.general,
                      icon: Icon(Icons.home_repair_service_outlined),
                      label: Text('Généralité'),
                    ),
                  ],
                  selected: <ExitDamageOriginType>{_lines[i].originType},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _lines[i].originType = selection.first;
                      _lines[i].room = null;
                      _lines[i].post = null;
                      _lines[i].generalCategory = null;
                    });
                  },
                ),
                const SizedBox(height: 14),
                if (_lines[i].originType == ExitDamageOriginType.room)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          initialValue: roomNames.contains(_lines[i].room)
                              ? _lines[i].room
                              : null,
                          decoration: _input('Pièce concernée'),
                          items: roomNames
                              .map(
                                (name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _lines[i].room = value),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          initialValue: _lines[i].post,
                          decoration: _input('Poste concerné'),
                          items: _posts
                              .map(
                                (post) => DropdownMenuItem<String>(
                                  value: post,
                                  child: Text(post),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _lines[i].post = value),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: 420,
                    child: DropdownButtonFormField<String>(
                      initialValue: _lines[i].generalCategory,
                      decoration: _input('Catégorie générale'),
                      items: _generalCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _lines[i].generalCategory = value),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lines[i].label,
                  decoration: _input('Remarque / travaux concernés'),
                ),
                if (_lines[i].data.photoPaths.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _lines[i].data.photoPaths
                        .map(
                          (path) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(path),
                              width: 110,
                              height: 82,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 110,
                                height: 82,
                                child: ColoredBox(
                                  color: Color(0xFFE2E8F0),
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _number(_lines[i].quantity, 'Quantité'),
                    _number(_lines[i].unitPrice, 'Prix unitaire HTVA'),
                    _number(_lines[i].labor, 'Main-d’œuvre HTVA'),
                    _number(_lines[i].depreciation, 'Vétusté (%)'),
                    _number(_lines[i].tenantShare, 'Part locative (%)'),
                    _number(_lines[i].vat, 'TVA (%)'),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const Text(
                      'Montant retenu TVAC',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${_lineTotal(_lines[i]).toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un poste'),
            ),
            FilledButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Recalculer'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 320,
          child: TextField(
            controller: _rentalLoss,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _input('Chômage locatif éventuel (€)'),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Indemnité compensatoire totale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_total.toStringAsFixed(2)} € TVAC',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    const Text(
                      'Indemnité compensatoire totale',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_total.toStringAsFixed(2)} € TVAC',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 26),
        StepSignatures(data: _signatures, includeExpert: true, embedded: true),
      ],
    );
  }

  Widget _number(TextEditingController controller, String label) => SizedBox(
    width: 210,
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _input(label),
    ),
  );

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _DamageLine {
  _DamageLine(this.data) {
    label = TextEditingController(text: data.remark);
    quantity = TextEditingController(text: _format(data.quantity));
    unitPrice = TextEditingController(text: _format(data.unitPrice));
    labor = TextEditingController(text: _format(data.labor));
    depreciation = TextEditingController(
      text: _format(data.depreciationPercent),
    );
    tenantShare = TextEditingController(text: _format(data.tenantSharePercent));
    vat = TextEditingController(text: _format(data.vatPercent));

    label.addListener(() => data.remark = label.text);
    quantity.addListener(() => data.quantity = _number(quantity.text));
    unitPrice.addListener(() => data.unitPrice = _number(unitPrice.text));
    labor.addListener(() => data.labor = _number(labor.text));
    depreciation.addListener(
      () => data.depreciationPercent = _number(depreciation.text),
    );
    tenantShare.addListener(
      () => data.tenantSharePercent = _number(tenantShare.text),
    );
    vat.addListener(() => data.vatPercent = _number(vat.text));
  }

  final ExitDamageLine data;
  late final TextEditingController label;
  late final TextEditingController quantity;
  late final TextEditingController unitPrice;
  late final TextEditingController labor;
  late final TextEditingController depreciation;
  late final TextEditingController tenantShare;
  late final TextEditingController vat;

  ExitDamageOriginType get originType => data.originType;
  set originType(ExitDamageOriginType value) => data.originType = value;

  String? get room => data.room;
  set room(String? value) => data.room = value;

  String? get post => data.element;
  set post(String? value) => data.element = value;

  String? get generalCategory => data.generalCategory;
  set generalCategory(String? value) => data.generalCategory = value;

  static double _number(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;

  static String _format(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  void dispose() {
    for (final controller in <TextEditingController>[
      label,
      quantity,
      unitPrice,
      labor,
      depreciation,
      tenantShare,
      vat,
    ]) {
      controller.dispose();
    }
  }
}
