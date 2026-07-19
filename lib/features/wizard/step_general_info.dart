import 'package:flutter/material.dart';

class StepGeneralInfo extends StatefulWidget {
  const StepGeneralInfo({super.key});

  @override
  State<StepGeneralInfo> createState() => _StepGeneralInfoState();
}

class _StepGeneralInfoState extends State<StepGeneralInfo> {
  DateTime selectedDate = DateTime.now();

  bool ownerPresent = true;
  bool tenantPresent = true;
  bool expertPresent = true;
  bool agentPresent = false;

  final List<WitnessEntry> witnesses = [];

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _addWitness() {
    setState(() {
      witnesses.add(WitnessEntry());
    });
  }

  void _removeWitness(int index) {
    setState(() {
      witnesses.removeAt(index);
    });
  }

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations générales',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complétez les informations principales du dossier.',
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
          const SizedBox(height: 30),

          const _SectionTitle(icon: Icons.location_on_outlined, title: 'Bien'),
          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(flex: 4, child: _InputField(label: 'Rue')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'N°')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'Boîte')),
            ],
          ),

          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(child: _InputField(label: 'Code postal')),
              SizedBox(width: 14),
              Expanded(flex: 3, child: _InputField(label: 'Ville')),
            ],
          ),

          const SizedBox(height: 30),

          const _SectionTitle(icon: Icons.person_outline, title: 'Bailleur'),
          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(flex: 2, child: _InputField(label: 'Nom')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'Téléphone')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'E-mail')),
            ],
          ),

          const SizedBox(height: 30),

          const _SectionTitle(icon: Icons.person_outline, title: 'Locataire'),
          const SizedBox(height: 14),

          const Row(
            children: [
              Expanded(flex: 2, child: _InputField(label: 'Nom')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'Téléphone')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'E-mail')),
            ],
          ),

          const SizedBox(height: 30),

          const _SectionTitle(icon: Icons.calendar_today_outlined, title: 'Date'),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date de la mission',
                      filled: true,
                      fillColor: const Color(0xFFF4F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: Text(formattedDate),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: _InputField(label: 'Heure'),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const _SectionTitle(icon: Icons.groups_outlined, title: 'Présences'),
          const SizedBox(height: 10),

          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _PresenceCheck(
                label: 'Bailleur présent',
                value: ownerPresent,
                onChanged: (value) => setState(() => ownerPresent = value),
              ),
              _PresenceCheck(
                label: 'Locataire présent',
                value: tenantPresent,
                onChanged: (value) => setState(() => tenantPresent = value),
              ),
              _PresenceCheck(
                label: 'Expert présent',
                value: expertPresent,
                onChanged: (value) => setState(() => expertPresent = value),
              ),
              _PresenceCheck(
                label: 'Agent immobilier présent',
                value: agentPresent,
                onChanged: (value) => setState(() => agentPresent = value),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              const _SectionTitle(
                icon: Icons.badge_outlined,
                title: 'Témoins / représentants',
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _addWitness,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un témoin'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (witnesses.isEmpty)
            const Text(
              'Aucun témoin ajouté.',
              style: TextStyle(color: Colors.black54),
            ),

          ...witnesses.asMap().entries.map((entry) {
            final index = entry.key;
            final witness = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _WitnessCard(
                witness: witness,
                onChanged: () => setState(() {}),
                onRemove: () => _removeWitness(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class WitnessEntry {
  String represents = 'Bailleur';
}

class _WitnessCard extends StatelessWidget {
  final WitnessEntry witness;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _WitnessCard({
    required this.witness,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(flex: 2, child: _InputField(label: 'Nom du témoin')),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: witness.represents,
                  decoration: InputDecoration(
                    labelText: 'Représente',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Bailleur', child: Text('Bailleur')),
                    DropdownMenuItem(value: 'Locataire', child: Text('Locataire')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      witness.represents = value;
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _InputField(label: 'Téléphone')),
              SizedBox(width: 14),
              Expanded(child: _InputField(label: 'E-mail')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;

  const _InputField({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF4F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PresenceCheck extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PresenceCheck({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: const Color(0xFFEAF8EF),
      checkmarkColor: Colors.green,
    );
  }
}
