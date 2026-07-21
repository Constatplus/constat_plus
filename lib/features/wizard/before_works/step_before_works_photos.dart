import 'dart:io';

import 'package:flutter/material.dart';

import 'models/before_works_data.dart';
import 'models/technical_finding.dart';

class StepBeforeWorksPhotos extends StatelessWidget {
  const StepBeforeWorksPhotos({
    super.key,
    required this.findings,
    required this.areas,
  });

  final List<TechnicalFinding> findings;
  final List<BeforeWorksArea> areas;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final withPhotos = findings.where((item) => item.photoPaths.isNotEmpty);
    return ListView(
      children: <Widget>[
        Text(
          'Photos du constat',
          style: TextStyle(
            fontSize: compact ? 24 : 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Vérifiez les photographies, leur zone et leur poste avant la signature.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        if (withPhotos.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Aucune photographie n’a encore été ajoutée. Revenez à la visite pour documenter les constats.',
              ),
            ),
          )
        else
          ...withPhotos.map(
            (finding) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${_areaPath(finding)} • ${finding.post}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: finding.photoPaths
                          .map(
                            (path) => Image.file(
                              File(path),
                              width: compact ? 132 : 180,
                              height: compact ? 100 : 130,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _areaPath(TechnicalFinding finding) {
    final matches = areas.where((area) => area.id == finding.areaId);
    if (matches.isEmpty) return finding.zone;
    final area = matches.first;
    final parents = areas.where((parent) => parent.id == area.parentId);
    return parents.isEmpty ? area.name : '${parents.first.name} › ${area.name}';
  }
}
