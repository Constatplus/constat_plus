import 'package:flutter/material.dart';

import 'before_works/models/before_works_data.dart';

class StepBeforeWorksInfo extends StatefulWidget {
  const StepBeforeWorksInfo({
    super.key,
    required this.data,
    required this.onChanged,
    this.afterWorks = false,
  });

  final BeforeWorksData data;
  final VoidCallback onChanged;
  final bool afterWorks;

  @override
  State<StepBeforeWorksInfo> createState() => _StepBeforeWorksInfoState();
}

class _StepBeforeWorksInfoState extends State<StepBeforeWorksInfo> {
  Future<void> _pickDate({required bool worksStart}) async {
    final initial = worksStart
        ? widget.data.plannedWorksStartDate ?? DateTime.now()
        : widget.data.missionDate;
    final value = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (value == null) return;
    setState(() {
      if (worksStart) {
        widget.data.plannedWorksStartDate = value;
      } else {
        widget.data.missionDate = value;
      }
    });
    widget.onChanged();
  }

  String _date(DateTime? value) => value == null
      ? 'À définir'
      : '${value.day.toString().padLeft(2, '0')}/'
            '${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final compact = MediaQuery.sizeOf(context).width < 700;
    return ListView(
      children: <Widget>[
        Text(
          widget.afterWorks
              ? 'Ordre de mission de récolement'
              : 'Ordre de mission avant travaux',
          style: TextStyle(
            fontSize: compact ? 24 : 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.afterWorks
              ? 'Identifiez les intervenants avec la même terminologie que le constat avant travaux.'
              : 'Constituez le rapport de référence technique avant le commencement du chantier.',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _dateField(
              'Date de la mission',
              data.missionDate,
              false,
              compact: compact,
            ),
            _dateField(
              'Début prévu des travaux',
              data.plannedWorksStartDate,
              true,
              compact: compact,
            ),
            _field(
              'Adresse du bien ou du chantier',
              data.address,
              (value) => data.address = value,
              compact ? double.infinity : 520,
            ),
            _field(
              'Mandant',
              data.principal,
              (value) => data.principal = value,
              compact ? double.infinity : 340,
            ),
            _field(
              'Propriétaire ou occupant',
              data.ownerOrOccupant,
              (value) => data.ownerOrOccupant = value,
              compact ? double.infinity : 340,
            ),
            _field(
              'Maître d’ouvrage',
              data.projectOwner,
              (value) => data.projectOwner = value,
              compact ? double.infinity : 340,
            ),
            _field(
              'Entrepreneur',
              data.contractor,
              (value) => data.contractor = value,
              compact ? double.infinity : 340,
            ),
            _field(
              'Architecte',
              data.architect,
              (value) => data.architect = value,
              compact ? double.infinity : 340,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _longField(
          'Nature des travaux',
          data.worksNature,
          (value) => data.worksNature = value,
        ),
        const SizedBox(height: 12),
        _longField(
          'Observations générales',
          data.generalObservations,
          (value) => data.generalObservations = value,
        ),
        const SizedBox(height: 24),
        const Text(
          'Parties présentes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (
          var index = 0;
          index < data.presentParties.length;
          index++
        ) ...<Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _partyEditor(index, compact),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() => data.presentParties.add(PresentParty()));
              widget.onChanged();
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Ajouter une partie présente'),
          ),
        ),
      ],
    );
  }

  Widget _partyEditor(int index, bool compact) {
    final party = widget.data.presentParties[index];
    final removeButton = IconButton(
      onPressed: widget.data.presentParties.length == 1
          ? null
          : () {
              setState(() => widget.data.presentParties.removeAt(index));
              widget.onChanged();
            },
      icon: const Icon(Icons.delete_outline),
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _partyField('Nom', party.name, (value) => party.name = value),
          const SizedBox(height: 10),
          _partyField(
            'Qualité',
            party.quality,
            (value) => party.quality = value,
          ),
          const SizedBox(height: 10),
          _partyField(
            'Partie représentée',
            party.represents,
            (value) => party.represents = value,
          ),
          Align(alignment: Alignment.centerRight, child: removeButton),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _partyField('Nom', party.name, (value) => party.name = value),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _partyField(
            'Qualité',
            party.quality,
            (value) => party.quality = value,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _partyField(
            'Partie représentée',
            party.represents,
            (value) => party.represents = value,
          ),
        ),
        removeButton,
      ],
    );
  }

  Widget _dateField(
    String label,
    DateTime? date,
    bool worksStart, {
    required bool compact,
  }) => SizedBox(
    width: compact ? double.infinity : 260,
    child: InkWell(
      onTap: () => _pickDate(worksStart: worksStart),
      child: InputDecorator(
        decoration: _decoration(label),
        child: Text(_date(date)),
      ),
    ),
  );

  Widget _field(
    String label,
    String value,
    ValueChanged<String> setter,
    double width,
  ) => SizedBox(
    width: width,
    child: TextFormField(
      initialValue: value,
      decoration: _decoration(label),
      onChanged: (text) {
        setter(text);
        widget.onChanged();
      },
    ),
  );

  Widget _partyField(String label, String value, ValueChanged<String> setter) =>
      TextFormField(
        initialValue: value,
        decoration: _decoration(label),
        onChanged: (text) {
          setter(text);
          widget.onChanged();
        },
      );

  Widget _longField(String label, String value, ValueChanged<String> setter) =>
      TextFormField(
        initialValue: value,
        minLines: 3,
        maxLines: 7,
        decoration: _decoration(label),
        onChanged: (text) {
          setter(text);
          widget.onChanged();
        },
      );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}
