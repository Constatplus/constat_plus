import 'package:flutter/material.dart';

import '../../core/models/mission.dart';

class ReportPreviewPage extends StatelessWidget {
  const ReportPreviewPage({required this.mission, this.embedded = false, super.key});
  final MissionData mission;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Constat+', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                Text(mission.kind.label, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(mission.displayTitle, style: Theme.of(context).textTheme.titleLarge),
                Text('${mission.address}, ${mission.postalCode} ${mission.city}'),
                const Divider(height: 36),
                if (mission.cadastralPlanBytes != null) ...[
                  Text('Plan cadastral', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.white),
                          Image.memory(mission.cadastralPlanBytes!, fit: BoxFit.contain),
                          CustomPaint(painter: _ReportPlanPainter(mission.cadastralPlanStrokes)),
                        ],
                      ),
                    ),
                  ),
                  if (mission.cadastralPlanNotes.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(mission.cadastralPlanNotes),
                  ],
                  const SizedBox(height: 24),
                ],
                if (mission.kind == MissionKind.beforeWorks) ...[
                  _section(
                    context,
                    'Donneur d’ordre et mission',
                    '${mission.client.isEmpty ? 'Non renseigné' : mission.client}\n\n${mission.missionDescription.isEmpty ? 'Description non renseignée.' : mission.missionDescription}',
                  ),
                  _section(
                    context,
                    'Notes liminaires',
                    mission.legalNotes.isEmpty ? 'Non renseignées.' : mission.legalNotes,
                  ),
                ],
                _section(context, mission.kind == MissionKind.beforeWorks ? 'Personnes présentes' : 'Parties', mission.parties.isEmpty ? 'Aucune partie encodée.' : mission.parties.map((p) => '${p.role} : ${p.name}').join('\n')),
                _section(context, 'Pièces', mission.rooms.map((room) => '${room.name} (${room.completion}% complété)\n${_roomSummary(room)}').join('\n\n')),
                if (mission.kind != MissionKind.beforeWorks) ...[
                  _section(context, 'Clés', mission.keys.isEmpty ? 'Aucune.' : mission.keys.map((k) => '${k.quantity} × ${k.label}').join('\n')),
                  _section(context, 'Compteurs', mission.meters.isEmpty ? 'Aucun.' : mission.meters.map((m) => '${m.type} — ${m.number} — index ${m.index}').join('\n')),
                ],
                if (mission.kind == MissionKind.exit) _section(context, 'Indemnités', '${mission.damages.length} poste(s) — total ${mission.damagesTotal.toStringAsFixed(2)} € TVAC'),
                if (mission.kind == MissionKind.beforeWorks)
                  _section(context, 'Conclusion', mission.conclusion.isEmpty ? 'Non renseignée.' : mission.conclusion)
                else
                  _section(context, 'Observations générales', mission.generalNotes.isEmpty ? 'Néant.' : mission.generalNotes),
                _section(context, 'Signatures', 'Expert : ${mission.signatureExpert.isEmpty ? 'Non signé' : mission.signatureExpert}\nPartie : ${mission.signatureParty.isEmpty ? 'Non signé' : mission.signatureParty}'),
                const SizedBox(height: 18),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération PDF prévue dans le module publication.'))), icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('Générer le PDF')),
                  OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Envoi par e-mail prévu dans le module publication.'))), icon: const Icon(Icons.email_outlined), label: const Text('Envoyer par e-mail')),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
    if (embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Aperçu du rapport')), body: content);
  }

  Widget _section(BuildContext context, String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(body)]));

  String _roomSummary(RoomData room) {
    final parts = <String>[];
    if (room.floor.isNotEmpty) parts.add('${room.isRoad ? 'Chaussée et revêtement' : 'Sol'} : ${room.floor}');
    if (room.walls.isNotEmpty) parts.add('${room.isRoad ? 'Bordures et accotements' : 'Murs'} : ${room.walls}');
    if (room.ceiling.isNotEmpty) parts.add('${room.isRoad ? 'Pentes, niveaux et déformations' : 'Plafond'} : ${room.ceiling}');
    if (room.woodwork.isNotEmpty) parts.add('${room.isRoad ? 'Ouvrages et équipements' : 'Menuiseries'} : ${room.woodwork}');
    if (room.electricity.isNotEmpty) parts.add('${room.isRoad ? 'Éclairage et réseaux visibles' : 'Électricité'} : ${room.electricity}');
    if (room.heating.isNotEmpty) parts.add('${room.isRoad ? 'Drainage et évacuation' : 'Chauffage'} : ${room.heating}');
    if (room.furniture.isNotEmpty) parts.add('${room.isRoad ? 'Mobilier urbain et signalisation' : 'Mobilier'} : ${room.furniture}');
    if (room.sanitary.isNotEmpty) parts.add('${room.isRoad ? 'Regards, avaloirs et raccords' : 'Sanitaires'} : ${room.sanitary}');
    if (room.observations.isNotEmpty) parts.add('Observations : ${room.observations}');
    return parts.isEmpty ? 'Aucune description.' : parts.join('\n');
  }
}


class _ReportPlanPainter extends CustomPainter {
  const _ReportPlanPainter(this.strokes);

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
  bool shouldRepaint(covariant _ReportPlanPainter oldDelegate) => true;
}
