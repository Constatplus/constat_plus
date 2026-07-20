import 'package:flutter/material.dart';

import 'before_works/models/before_works_data.dart';

class StepBeforeWorksInfo extends StatefulWidget {
  const StepBeforeWorksInfo({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final BeforeWorksData data;
  final VoidCallback onChanged;

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
    return ListView(
      children: <Widget>[
        const Text(
          'Ordre de mission avant travaux',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Constituez le rapport de référence technique avant le commencement du chantier.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _dateField('Date de la mission', data.missionDate, false),
            _dateField(
              'Début prévu des travaux',
              data.plannedWorksStartDate,
              true,
            ),
            _field(
              'Adresse du bien ou du chantier',
              data.address,
              (value) => data.address = value,
              520,
            ),
            _field(
              'Mandant',
              data.principal,
              (value) => data.principal = value,
              340,
            ),
            _field(
              'Propriétaire ou occupant',
              data.ownerOrOccupant,
              (value) => data.ownerOrOccupant = value,
              340,
            ),
            _field(
              'Maître d’ouvrage',
              data.projectOwner,
              (value) => data.projectOwner = value,
              340,
            ),
            _field(
              'Entrepreneur',
              data.contractor,
              (value) => data.contractor = value,
              340,
            ),
            _field(
              'Architecte',
              data.architect,
              (value) => data.architect = value,
              340,
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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _partyField(
                      'Nom',
                      data.presentParties[index].name,
                      (value) => data.presentParties[index].name = value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _partyField(
                      'Qualité',
                      data.presentParties[index].quality,
                      (value) => data.presentParties[index].quality = value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _partyField(
                      'Partie représentée',
                      data.presentParties[index].represents,
                      (value) => data.presentParties[index].represents = value,
                    ),
                  ),
                  IconButton(
                    onPressed: data.presentParties.length == 1
                        ? null
                        : () {
                            setState(() => data.presentParties.removeAt(index));
                            widget.onChanged();
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
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

  Widget _dateField(String label, DateTime? date, bool worksStart) => SizedBox(
    width: 260,
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
