import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/mission.dart';
import '../../core/state/app_state.dart';
import 'cadastral_plan_step.dart';
import 'report_preview_page.dart';
import 'services/damage_item_sync.dart';

class MissionWizardPage extends StatefulWidget {
  const MissionWizardPage({required this.mission, super.key});
  final MissionData mission;

  @override
  State<MissionWizardPage> createState() => _MissionWizardPageState();
}

class _MissionWizardPageState extends State<MissionWizardPage> {
  int _step = 0;
  final _picker = ImagePicker();

  MissionData get mission => widget.mission;

  void _changed() {
    AppScope.of(context).touch(mission);
    setState(() {});
  }

  void _openStep(int nextStep) {
    if (mission.kind == MissionKind.exit && nextStep == 6) {
      final result = DamageItemSync.synchronize(mission);
      if (result.changed) AppScope.of(context).touch(mission);
    }
    setState(() => _step = nextStep);
  }

  @override
  Widget build(BuildContext context) {
    final labels = switch (mission.kind) {
      MissionKind.exit => [
        'Mission',
        'Plan cadastral',
        'Parties',
        'Pièces',
        'Visite',
        'Clés & compteurs',
        'Indemnités',
        'Signatures',
        'Rapport',
      ],
      MissionKind.beforeWorks => [
        'Mission',
        'Plan cadastral',
        'Notes liminaires',
        'Personnes présentes',
        'Pièces & voirie',
        'Description',
        'Conclusion',
        'Rapport',
      ],
      MissionKind.entry => [
        'Mission',
        'Plan cadastral',
        'Parties',
        'Pièces',
        'Visite',
        'Clés & compteurs',
        'Observations',
        'Signatures',
        'Rapport',
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(mission.kind.label),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${mission.progress}% complété',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / labels.length,
            minHeight: 4,
          ),
          Expanded(
            child: Row(
              children: [
                if (MediaQuery.sizeOf(context).width >= 980)
                  SizedBox(
                    width: 250,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: labels.length,
                      itemBuilder: (context, index) => ListTile(
                        selected: index == _step,
                        leading: CircleAvatar(
                          radius: 15,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(labels[index]),
                        onTap: () => _openStep(index),
                      ),
                    ),
                  ),
                if (MediaQuery.sizeOf(context).width >= 980)
                  const VerticalDivider(width: 1),
                Expanded(child: _buildStep()),
              ],
            ),
          ),
          _BottomBar(
            step: _step,
            count: labels.length,
            onBack: _step == 0 ? null : () => setState(() => _step--),
            onNext: () {
              if (_step < labels.length - 1) {
                _openStep(_step + 1);
              } else {
                AppScope.of(context).complete(mission);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    if (mission.kind == MissionKind.beforeWorks) {
      return switch (_step) {
        0 => _BeforeWorksMissionStep(mission: mission, onChanged: _changed),
        1 => CadastralPlanStep(
          mission: mission,
          picker: _picker,
          onChanged: _changed,
        ),
        2 => _PreliminaryNotesStep(mission: mission, onChanged: _changed),
        3 => _PartiesStep(mission: mission, onChanged: _changed),
        4 => _RoomsStep(mission: mission, onChanged: _changed),
        5 => _VisitStep(mission: mission, picker: _picker, onChanged: _changed),
        6 => _ConclusionStep(mission: mission, onChanged: _changed),
        _ => ReportPreviewPage(mission: mission, embedded: true),
      };
    }

    return switch (_step) {
      0 => _MissionInfoStep(mission: mission, onChanged: _changed),
      1 => CadastralPlanStep(
        mission: mission,
        picker: _picker,
        onChanged: _changed,
      ),
      2 => _PartiesStep(mission: mission, onChanged: _changed),
      3 => _RoomsStep(mission: mission, onChanged: _changed),
      4 => _VisitStep(mission: mission, picker: _picker, onChanged: _changed),
      5 => _KeysMetersStep(mission: mission, onChanged: _changed),
      6 =>
        mission.kind == MissionKind.exit
            ? _DamagesStep(mission: mission, onChanged: _changed)
            : _NotesStep(mission: mission, onChanged: _changed),
      7 => _SignaturesStep(mission: mission, onChanged: _changed),
      _ => ReportPreviewPage(mission: mission, embedded: true),
    };
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    ),
  );
}

class _MissionInfoStep extends StatelessWidget {
  const _MissionInfoStep({required this.mission, required this.onChanged});
  final MissionData mission;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Informations générales',
    subtitle: 'Identifiez le dossier et le bien.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            TextFormField(
              initialValue: mission.title,
              decoration: const InputDecoration(labelText: 'Titre du dossier'),
              onChanged: (v) {
                mission.title = v;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.address,
              decoration: const InputDecoration(
                labelText: 'Adresse du bien',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onChanged: (v) {
                mission.address = v;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: mission.postalCode,
                    decoration: const InputDecoration(labelText: 'Code postal'),
                    onChanged: (v) {
                      mission.postalCode = v;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: mission.city,
                    decoration: const InputDecoration(labelText: 'Localité'),
                    onChanged: (v) {
                      mission.city = v;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.client,
              decoration: const InputDecoration(
                labelText: 'Client / donneur d’ordre',
              ),
              onChanged: (v) {
                mission.client = v;
                onChanged();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _BeforeWorksMissionStep extends StatelessWidget {
  const _BeforeWorksMissionStep({
    required this.mission,
    required this.onChanged,
  });

  final MissionData mission;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Mission avant travaux',
    subtitle:
        'Identifiez le donneur d’ordre et décrivez précisément la mission confiée.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            TextFormField(
              initialValue: mission.title,
              decoration: const InputDecoration(labelText: 'Titre du dossier'),
              onChanged: (value) {
                mission.title = value;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.client,
              decoration: const InputDecoration(
                labelText: 'Donneur d’ordre',
                helperText:
                    'Nom, société ou qualité de la personne qui confie la mission.',
                prefixIcon: Icon(Icons.assignment_ind_outlined),
              ),
              onChanged: (value) {
                mission.client = value;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.address,
              decoration: const InputDecoration(
                labelText: 'Adresse du constat',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onChanged: (value) {
                mission.address = value;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: mission.postalCode,
                    decoration: const InputDecoration(labelText: 'Code postal'),
                    onChanged: (value) {
                      mission.postalCode = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: mission.city,
                    decoration: const InputDecoration(labelText: 'Localité'),
                    onChanged: (value) {
                      mission.city = value;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.missionDescription,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Description de la mission',
                alignLabelWithHint: true,
                helperText:
                    'Objet, contexte, étendue des constatations et travaux projetés.',
              ),
              onChanged: (value) {
                mission.missionDescription = value;
                onChanged();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _PreliminaryNotesStep extends StatelessWidget {
  const _PreliminaryNotesStep({required this.mission, required this.onChanged});

  final MissionData mission;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Notes liminaires',
    subtitle:
        'Encodez les précisions méthodologiques et les limites du constat.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: TextFormField(
          initialValue: mission.legalNotes,
          minLines: 14,
          maxLines: 24,
          decoration: const InputDecoration(
            labelText: 'Notes liminaires du rapport',
            alignLabelWithHint: true,
            hintText:
                'Mission, caractère contradictoire ou unilatéral, limites des constatations, parties visibles, conditions de visite…',
          ),
          onChanged: (value) {
            mission.legalNotes = value;
            onChanged();
          },
        ),
      ),
    ),
  );
}

class _ConclusionStep extends StatelessWidget {
  const _ConclusionStep({required this.mission, required this.onChanged});

  final MissionData mission;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Conclusion',
    subtitle:
        'Résumez l’état observé et les points qui devront être surveillés pendant les travaux.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: TextFormField(
          initialValue: mission.conclusion,
          minLines: 12,
          maxLines: 22,
          decoration: const InputDecoration(
            labelText: 'Conclusion du constat',
            alignLabelWithHint: true,
            hintText:
                'État général, désordres préexistants, zones sensibles, réserves et recommandations.',
          ),
          onChanged: (value) {
            mission.conclusion = value;
            onChanged();
          },
        ),
      ),
    ),
  );
}

class _PartiesStep extends StatelessWidget {
  const _PartiesStep({required this.mission, required this.onChanged});
  final MissionData mission;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => _StepBody(
    title: mission.kind == MissionKind.beforeWorks
        ? 'Personnes présentes sur place'
        : 'Parties présentes',
    subtitle: mission.kind == MissionKind.beforeWorks
        ? 'Ajoutez chaque personne présente lors du constat et précisez sa qualité.'
        : 'Ajoutez les propriétaires, locataires, mandataires ou voisins.',
    child: Column(
      children: [
        ...mission.parties.asMap().entries.map(
          (entry) => _PartyCard(
            party: entry.value,
            onDelete: () {
              mission.parties.removeAt(entry.key);
              onChanged();
            },
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              mission.parties.add(
                PartyData(
                  role: mission.kind == MissionKind.beforeWorks
                      ? 'Personne présente'
                      : 'Locataire',
                ),
              );
              onChanged();
            },
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(
              mission.kind == MissionKind.beforeWorks
                  ? 'Ajouter une personne présente'
                  : 'Ajouter une partie',
            ),
          ),
        ),
      ],
    ),
  );
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.party,
    required this.onDelete,
    required this.onChanged,
  });
  final PartyData party;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: party.role,
                    decoration: const InputDecoration(labelText: 'Qualité'),
                    onChanged: (v) {
                      party.role = v;
                      onChanged();
                    },
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: party.name,
              decoration: const InputDecoration(labelText: 'Nom complet'),
              onChanged: (v) {
                party.name = v;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: party.email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    onChanged: (v) {
                      party.email = v;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: party.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    onChanged: (v) {
                      party.phone = v;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoomsStep extends StatelessWidget {
  const _RoomsStep({required this.mission, required this.onChanged});

  final MissionData mission;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      title: mission.kind == MissionKind.beforeWorks
          ? 'Pièces, extérieurs et voirie'
          : 'Composition du bien',
      subtitle: mission.kind == MissionKind.beforeWorks
          ? 'Ajoutez chaque zone à constater, y compris une voirie lorsque la mission le nécessite.'
          : 'Ajoutez, renommez et ordonnez les pièces.',
      child: Column(
        children: [
          ...mission.rooms.asMap().entries.map((entry) {
            final room = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    room.isRoad
                        ? Icons.add_road_rounded
                        : Icons.meeting_room_outlined,
                  ),
                  title: TextFormField(
                    initialValue: room.name,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: room.isRoad
                          ? 'Nom de la voirie'
                          : 'Nom de la pièce',
                    ),
                    onChanged: (value) {
                      room.name = value;
                      onChanged();
                    },
                  ),
                  subtitle: Text('${room.completion}% renseigné'),
                  trailing: IconButton(
                    onPressed: mission.rooms.length <= 1
                        ? null
                        : () {
                            mission.rooms.removeAt(entry.key);
                            onChanged();
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 2),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  mission.rooms.add(RoomData(name: 'Nouvelle pièce'));
                  onChanged();
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter une pièce ou une zone'),
              ),
              if (mission.kind == MissionKind.beforeWorks)
                OutlinedButton.icon(
                  onPressed: () {
                    mission.rooms.add(RoomData(name: 'Voirie', isRoad: true));
                    onChanged();
                  },
                  icon: const Icon(Icons.add_road_rounded),
                  label: const Text('Ajouter une voirie'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitStep extends StatefulWidget {
  const _VisitStep({
    required this.mission,
    required this.picker,
    required this.onChanged,
  });

  final MissionData mission;
  final ImagePicker picker;
  final VoidCallback onChanged;

  @override
  State<_VisitStep> createState() => _VisitStepState();
}

class _VisitStepState extends State<_VisitStep> {
  int _roomIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.mission.rooms.isEmpty) {
      return _StepBody(
        title: 'Mode visite',
        subtitle: 'Ajoutez d’abord une pièce à la composition du bien.',
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              widget.mission.rooms.add(RoomData(name: 'Nouvelle pièce'));
              widget.onChanged();
              setState(() => _roomIndex = 0);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une pièce'),
          ),
        ),
      );
    }

    final safeIndex = _roomIndex.clamp(0, widget.mission.rooms.length - 1);
    final room = widget.mission.rooms[safeIndex];

    return _StepBody(
      title: widget.mission.kind == MissionKind.beforeWorks
          ? 'Description pièce par pièce'
          : 'Mode visite',
      subtitle: widget.mission.kind == MissionKind.beforeWorks
          ? 'Décrivez chaque pièce, zone extérieure ou voirie et joignez les photographies utiles.'
          : 'Décrivez chaque poste et ajoutez les photos sans devoir les affecter à un élément.',
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            initialValue: safeIndex,
            decoration: const InputDecoration(labelText: 'Pièce active'),
            items: widget.mission.rooms.asMap().entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _roomIndex = value ?? 0);
            },
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _field(
                    room.isRoad ? 'Chaussée et revêtement' : 'Sol',
                    room.floor,
                    (value) => room.floor = value,
                  ),
                  _field(
                    room.isRoad ? 'Bordures et accotements' : 'Murs',
                    room.walls,
                    (value) => room.walls = value,
                  ),
                  _field(
                    room.isRoad ? 'Pentes, niveaux et déformations' : 'Plafond',
                    room.ceiling,
                    (value) => room.ceiling = value,
                  ),
                  _field(
                    room.isRoad ? 'Ouvrages et équipements' : 'Menuiseries',
                    room.woodwork,
                    (value) => room.woodwork = value,
                  ),
                  _field(
                    room.isRoad
                        ? 'Éclairage et réseaux visibles'
                        : 'Électricité',
                    room.electricity,
                    (value) => room.electricity = value,
                  ),
                  _field(
                    room.isRoad ? 'Drainage et évacuation' : 'Chauffage',
                    room.heating,
                    (value) => room.heating = value,
                  ),
                  _field(
                    room.isRoad
                        ? 'Mobilier urbain et signalisation'
                        : 'Mobilier',
                    room.furniture,
                    (value) => room.furniture = value,
                  ),
                  _field(
                    room.isRoad
                        ? 'Regards, avaloirs et raccords'
                        : 'Sanitaires',
                    room.sanitary,
                    (value) => room.sanitary = value,
                  ),
                  _field(
                    'Observations',
                    room.observations,
                    (value) => room.observations = value,
                    lines: 4,
                  ),
                  if (widget.mission.kind == MissionKind.exit)
                    CheckboxListTile(
                      value: room.observationsSelectedForDamage,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Reprendre dans le calcul des dégâts'),
                      subtitle: const Text(
                        'L’observation sera liée à une ligne de calcul sans montant prédéfini.',
                      ),
                      onChanged: room.observations.trim().isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                room.observationsSelectedForDamage =
                                    value ?? false;
                              });
                              widget.onChanged();
                            },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Photos (${room.photos.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _addPhotos(room),
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (room.photos.isEmpty)
                    const Text('Aucune photo.')
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: room.photos.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                entry.value.bytes,
                                width: 140,
                                height: 105,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: IconButton.filledTonal(
                                onPressed: () {
                                  room.photos.removeAt(entry.key);
                                  widget.onChanged();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                                iconSize: 18,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhotos(RoomData room) async {
    final files = await widget.picker.pickMultiImage(imageQuality: 85);
    for (final file in files) {
      room.photos.add(
        RoomPhoto(name: file.name, bytes: await file.readAsBytes()),
      );
    }
    widget.onChanged();
    if (mounted) {
      setState(() {});
    }
  }

  Widget _field(
    String label,
    String value,
    ValueChanged<String> setter, {
    int lines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        minLines: lines,
        maxLines: lines + 3,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
        onChanged: (newValue) {
          setter(newValue);
          widget.onChanged();
        },
      ),
    );
  }
}

class _KeysMetersStep extends StatelessWidget {
  const _KeysMetersStep({required this.mission, required this.onChanged});

  final MissionData mission;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      title: 'Clés et compteurs',
      subtitle: 'Encodez les remises de clés et les index.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Clés', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...mission.keys.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item.label,
                              decoration: const InputDecoration(
                                labelText: 'Type de clé',
                              ),
                              onChanged: (value) {
                                item.label = value;
                                onChanged();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 110,
                            child: TextFormField(
                              initialValue: '${item.quantity}',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                              ),
                              onChanged: (value) {
                                item.quantity = int.tryParse(value) ?? 1;
                                onChanged();
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              mission.keys.removeAt(entry.key);
                              onChanged();
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: () {
                      mission.keys.add(KeyItem());
                      onChanged();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une clé'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Compteurs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...mission.meters.asMap().entries.map((entry) {
                    final meter = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: meter.type,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                              ),
                              onChanged: (value) {
                                meter.type = value;
                                onChanged();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: meter.number,
                              decoration: const InputDecoration(
                                labelText: 'N° compteur',
                              ),
                              onChanged: (value) {
                                meter.number = value;
                                onChanged();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: meter.index,
                              decoration: const InputDecoration(
                                labelText: 'Index',
                              ),
                              onChanged: (value) {
                                meter.index = value;
                                onChanged();
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              mission.meters.removeAt(entry.key);
                              onChanged();
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: () {
                      mission.meters.add(MeterReading(type: 'Électricité'));
                      onChanged();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un compteur'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DamagesStep extends StatelessWidget {
  const _DamagesStep({required this.mission, required this.onChanged});
  final MissionData mission;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Indemnités compensatoires',
    subtitle: 'Encodez les manquements et estimez leur coût.',
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: () {
              final result = DamageItemSync.synchronize(mission);
              onChanged();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${result.added} ligne(s) ajoutée(s), ${result.updated} actualisée(s).',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.sync),
            label: const Text('Actualiser depuis la visite'),
          ),
        ),
        const SizedBox(height: 12),
        ...mission.damages.asMap().entries.map(
          (e) => Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: e.value.room.isEmpty
                              ? null
                              : e.value.room,
                          decoration: const InputDecoration(labelText: 'Pièce'),
                          items: mission.rooms
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r.name,
                                  child: Text(r.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            e.value.room = v ?? '';
                            onChanged();
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          mission.damages.removeAt(e.key);
                          onChanged();
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (e.value.sourceRemarkId.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(Icons.link, size: 18),
                        label: Text('Liée à une observation de visite'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextFormField(
                    key: ValueKey(
                      'damage-description-${e.value.sourceRemarkId}-${e.value.sourceDescription}',
                    ),
                    initialValue: e.value.description,
                    decoration: const InputDecoration(
                      labelText: 'Manquement constaté',
                    ),
                    onChanged: (v) {
                      e.value.description = v;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: e.value.work,
                    decoration: const InputDecoration(
                      labelText: 'Travaux / indemnisation',
                    ),
                    onChanged: (v) {
                      e.value.work = v;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: e.value.amountExVat == 0
                              ? ''
                              : e.value.amountExVat.toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Montant HTVA',
                          ),
                          onChanged: (v) {
                            e.value.amountExVat =
                                double.tryParse(v.replaceAll(',', '.')) ?? 0;
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          initialValue: e.value.vatRate,
                          decoration: const InputDecoration(labelText: 'TVA'),
                          items: const [
                            DropdownMenuItem(value: .06, child: Text('6 %')),
                            DropdownMenuItem(value: .21, child: Text('21 %')),
                          ],
                          onChanged: (v) {
                            e.value.vatRate = v ?? .21;
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: (e.value.depreciation * 100)
                              .toStringAsFixed(0),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Part après vétusté',
                            suffixText: '%',
                          ),
                          onChanged: (v) {
                            final percentage =
                                double.tryParse(v.replaceAll(',', '.')) ?? 100;
                            e.value.depreciation = (percentage / 100).clamp(
                              0,
                              1,
                            );
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${e.value.totalIncVat.toStringAsFixed(2)} € TVAC',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              mission.damages.add(DamageItem());
              onChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un manquement'),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Total : ${mission.damagesTotal.toStringAsFixed(2)} € TVAC',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    ),
  );
}

class _NotesStep extends StatelessWidget {
  const _NotesStep({required this.mission, required this.onChanged});
  final MissionData mission;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Observations générales',
    subtitle:
        'Ajoutez les réserves, entretiens et informations complémentaires.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: TextFormField(
          initialValue: mission.generalNotes,
          minLines: 10,
          maxLines: 18,
          decoration: const InputDecoration(
            labelText: 'Observations',
            alignLabelWithHint: true,
          ),
          onChanged: (v) {
            mission.generalNotes = v;
            onChanged();
          },
        ),
      ),
    ),
  );
}

class _SignaturesStep extends StatelessWidget {
  const _SignaturesStep({required this.mission, required this.onChanged});
  final MissionData mission;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => _StepBody(
    title: 'Signatures',
    subtitle:
        'Indiquez les signataires. Le tracé manuscrit sera ajouté dans la version tablette.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextFormField(
              initialValue: mission.signatureExpert,
              decoration: const InputDecoration(labelText: 'Expert signataire'),
              onChanged: (v) {
                mission.signatureExpert = v;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.signatureParty,
              decoration: const InputDecoration(labelText: 'Partie signataire'),
              onChanged: (v) {
                mission.signatureParty = v;
                onChanged();
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: mission.legalNotes,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Mentions ou réserves avant signature',
                alignLabelWithHint: true,
              ),
              onChanged: (v) {
                mission.legalNotes = v;
                onChanged();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.count,
    required this.onBack,
    required this.onNext,
  });
  final int step;
  final int count;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: Row(
        children: [
          OutlinedButton(onPressed: onBack, child: const Text('Précédent')),
          const Spacer(),
          Text('Étape ${step + 1}/$count'),
          const SizedBox(width: 18),
          FilledButton.icon(
            onPressed: onNext,
            icon: Icon(
              step == count - 1
                  ? Icons.check_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(step == count - 1 ? 'Terminer' : 'Continuer'),
          ),
        ],
      ),
    ),
  );
}
