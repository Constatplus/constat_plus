import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/mission.dart';

class CadastralPlanStep extends StatefulWidget {
  const CadastralPlanStep({
    required this.mission,
    required this.picker,
    required this.onChanged,
    super.key,
  });

  final MissionData mission;
  final ImagePicker picker;
  final VoidCallback onChanged;

  @override
  State<CadastralPlanStep> createState() => _CadastralPlanStepState();
}

class _CadastralPlanStepState extends State<CadastralPlanStep> {
  Color _color = const Color(0xFFE53935);
  double _width = 4;
  List<PlanPoint>? _activePoints;

  Future<void> _pickImage() async {
    final file = await widget.picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      widget.mission.cadastralPlanBytes = bytes;
      widget.mission.cadastralPlanName = file.name;
      widget.mission.cadastralPlanStrokes.clear();
    });
    widget.onChanged();
  }

  void _removeImage() {
    setState(() {
      widget.mission.cadastralPlanBytes = null;
      widget.mission.cadastralPlanName = '';
      widget.mission.cadastralPlanNotes = '';
      widget.mission.cadastralPlanStrokes.clear();
    });
    widget.onChanged();
  }

  void _undo() {
    if (widget.mission.cadastralPlanStrokes.isEmpty) return;
    setState(widget.mission.cadastralPlanStrokes.removeLast);
    widget.onChanged();
  }

  void _clear() {
    if (widget.mission.cadastralPlanStrokes.isEmpty) return;
    setState(widget.mission.cadastralPlanStrokes.clear);
    widget.onChanged();
  }

  PlanPoint _normalized(Offset local, Size size) {
    final dx = (local.dx / size.width).clamp(0.0, 1.0);
    final dy = (local.dy / size.height).clamp(0.0, 1.0);
    return PlanPoint(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = widget.mission.cadastralPlanBytes;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan cadastral', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text(
                'Ajoutez le plan après la mission, puis dessinez directement sur l’image pour repérer les parcelles, limites ou zones concernées.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: Text(bytes == null ? 'Insérer une image' : 'Remplacer l’image'),
                          ),
                          if (bytes != null)
                            OutlinedButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Supprimer'),
                            ),
                          if (bytes != null)
                            OutlinedButton.icon(
                              onPressed: _undo,
                              icon: const Icon(Icons.undo),
                              label: const Text('Annuler le dernier trait'),
                            ),
                          if (bytes != null)
                            OutlinedButton.icon(
                              onPressed: _clear,
                              icon: const Icon(Icons.layers_clear_outlined),
                              label: const Text('Effacer les dessins'),
                            ),
                        ],
                      ),
                      if (bytes == null) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.map_outlined, size: 54, color: Color(0xFF64748B)),
                              SizedBox(height: 12),
                              Text('Aucun plan cadastral inséré', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                              SizedBox(height: 6),
                              Text('Formats image pris en charge par l’appareil : JPG, PNG, WEBP…', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 18),
                        _DrawingToolbar(
                          color: _color,
                          width: _width,
                          onColorChanged: (value) => setState(() => _color = value),
                          onWidthChanged: (value) => setState(() => _width = value),
                        ),
                        const SizedBox(height: 14),
                        Text(widget.mission.cadastralPlanName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = Size(constraints.maxWidth, constraints.maxHeight);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: (details) {
                                    final points = <PlanPoint>[_normalized(details.localPosition, size)];
                                    setState(() {
                                      _activePoints = points;
                                      widget.mission.cadastralPlanStrokes.add(
                                        PlanStroke(points: points, colorValue: _color.toARGB32(), width: _width),
                                      );
                                    });
                                  },
                                  onPanUpdate: (details) {
                                    setState(() => _activePoints?.add(_normalized(details.localPosition, size)));
                                  },
                                  onPanEnd: (_) {
                                    _activePoints = null;
                                    widget.onChanged();
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Container(color: Colors.white),
                                      Image.memory(bytes, fit: BoxFit.contain),
                                      CustomPaint(
                                        painter: _PlanPainter(widget.mission.cadastralPlanStrokes),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Astuce : utilisez le rouge pour les limites ou désordres et une épaisseur plus forte pour entourer une parcelle.', style: TextStyle(color: Color(0xFF64748B))),
                      ],
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: widget.mission.cadastralPlanNotes,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Observations relatives au plan',
                          hintText: 'Exemple : la parcelle concernée est entourée en rouge.',
                          alignLabelWithHint: true,
                        ),
                        onChanged: (value) {
                          widget.mission.cadastralPlanNotes = value;
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawingToolbar extends StatelessWidget {
  const _DrawingToolbar({
    required this.color,
    required this.width,
    required this.onColorChanged,
    required this.onWidthChanged,
  });

  final Color color;
  final double width;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFE53935),
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFFFA000),
      Color(0xFF111827),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.draw_outlined), SizedBox(width: 7), Text('Dessiner', style: TextStyle(fontWeight: FontWeight.w800))]),
        ...colors.map(
          (item) => InkWell(
            onTap: () => onColorChanged(item),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color == item ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1), width: color == item ? 3 : 1),
              ),
              child: DecoratedBox(decoration: BoxDecoration(color: item, shape: BoxShape.circle)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text('Épaisseur'),
        DropdownButton<double>(
          value: width,
          items: const [2.0, 4.0, 6.0, 9.0]
              .map((value) => DropdownMenuItem(value: value, child: Text('${value.toInt()} px')))
              .toList(),
          onChanged: (value) {
            if (value != null) onWidthChanged(value);
          },
        ),
      ],
    );
  }
}

class _PlanPainter extends CustomPainter {
  const _PlanPainter(this.strokes);

  final List<PlanStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = Color(stroke.colorValue)
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      final first = stroke.points.first;
      path.moveTo(first.dx * size.width, first.dy * size.height);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlanPainter oldDelegate) => true;
}
