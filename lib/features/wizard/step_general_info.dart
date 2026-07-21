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

  final List<WitnessEntry> witnesses = <WitnessEntry>[];

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  void _addWitness() {
    setState(() => witnesses.add(WitnessEntry()));
  }

  void _removeWitness(int index) {
    setState(() => witnesses.removeAt(index));
  }

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isCompact = constraints.maxWidth < 980;
        final titleSize = isMobile ? 24.0 : 30.0;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations générales',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complétez les informations principales du dossier.',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: isMobile ? 24 : 30),
              const _SectionTitle(
                icon: Icons.location_on_outlined,
                title: 'Bien',
              ),
              const SizedBox(height: 14),
              _ResponsiveFields(
                compact: isMobile,
                children: const [
                  _ResponsiveField(flex: 4, child: _InputField(label: 'Rue')),
                  _ResponsiveField(child: _InputField(label: 'N°')),
                  _ResponsiveField(child: _InputField(label: 'Boîte')),
                ],
              ),
              const SizedBox(height: 14),
              _ResponsiveFields(
                compact: isMobile,
                children: const [
                  _ResponsiveField(child: _InputField(label: 'Code postal')),
                  _ResponsiveField(
                    flex: 3,
                    child: _InputField(label: 'Ville'),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 30),
              const _SectionTitle(
                icon: Icons.person_outline,
                title: 'Bailleur',
              ),
              const SizedBox(height: 14),
              _ResponsiveFields(
                compact: isCompact,
                children: const [
                  _ResponsiveField(
                    flex: 2,
                    child: _InputField(label: 'Nom'),
                  ),
                  _ResponsiveField(child: _InputField(label: 'Téléphone')),
                  _ResponsiveField(child: _InputField(label: 'E-mail')),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 30),
              const _SectionTitle(
                icon: Icons.person_outline,
                title: 'Locataire',
              ),
              const SizedBox(height: 14),
              _ResponsiveFields(
                compact: isCompact,
                children: const [
                  _ResponsiveField(
                    flex: 2,
                    child: _InputField(label: 'Nom'),
                  ),
                  _ResponsiveField(child: _InputField(label: 'Téléphone')),
                  _ResponsiveField(child: _InputField(label: 'E-mail')),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 30),
              const _SectionTitle(
                icon: Icons.calendar_today_outlined,
                title: 'Date',
              ),
              const SizedBox(height: 14),
              _ResponsiveFields(
                compact: isMobile,
                children: [
                  _ResponsiveField(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: _fieldDecoration('Date de la mission'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedDate),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const _ResponsiveField(
                    child: _InputField(label: 'Heure'),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 30),
              const _SectionTitle(
                icon: Icons.groups_outlined,
                title: 'Présences',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _PresenceCheck(
                    label: 'Bailleur présent',
                    value: ownerPresent,
                    onChanged: (value) =>
                        setState(() => ownerPresent = value),
                  ),
                  _PresenceCheck(
                    label: 'Locataire présent',
                    value: tenantPresent,
                    onChanged: (value) =>
                        setState(() => tenantPresent = value),
                  ),
                  _PresenceCheck(
                    label: 'Expert présent',
                    value: expertPresent,
                    onChanged: (value) =>
                        setState(() => expertPresent = value),
                  ),
                  _PresenceCheck(
                    label: 'Agent immobilier présent',
                    value: agentPresent,
                    onChanged: (value) =>
                        setState(() => agentPresent = value),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 30),
              if (isMobile) ...[
                const _SectionTitle(
                  icon: Icons.badge_outlined,
                  title: 'Témoins / représentants',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addWitness,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un témoin'),
                  ),
                ),
              ] else
                Row(
                  children: [
                    const Expanded(
                      child: _SectionTitle(
                        icon: Icons.badge_outlined,
                        title: 'Témoins / représentants',
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _addWitness,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un témoin'),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              if (witnesses.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'Aucun témoin ajouté.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ...witnesses.asMap().entries.map((entry) {
                final index = entry.key;
                final witness = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _WitnessCard(
                    witness: witness,
                    compact: isCompact,
                    onChanged: () => setState(() {}),
                    onRemove: () => _removeWitness(index),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

InputDecoration _fieldDecoration(String label, {Color? fillColor}) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: fillColor ?? const Color(0xFFF4F8FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

class WitnessEntry {
  String represents = 'Bailleur';
}

class _WitnessCard extends StatelessWidget {
  const _WitnessCard({
    required this.witness,
    required this.compact,
    required this.onChanged,
    required this.onRemove,
  });

  final WitnessEntry witness;
  final bool compact;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (compact) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Témoin / représentant',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _InputField(label: 'Nom du témoin', fillColor: Colors.white),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: witness.represents,
              isExpanded: true,
              decoration: _fieldDecoration('Représente', fillColor: Colors.white),
              items: const [
                DropdownMenuItem(value: 'Bailleur', child: Text('Bailleur')),
                DropdownMenuItem(value: 'Locataire', child: Text('Locataire')),
              ],
              onChanged: (value) {
                if (value == null) return;
                witness.represents = value;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            const _InputField(label: 'Téléphone', fillColor: Colors.white),
            const SizedBox(height: 12),
            const _InputField(label: 'E-mail', fillColor: Colors.white),
          ] else ...[
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: _InputField(
                    label: 'Nom du témoin',
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: witness.represents,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      'Représente',
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Bailleur',
                        child: Text('Bailleur'),
                      ),
                      DropdownMenuItem(
                        value: 'Locataire',
                        child: Text('Locataire'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      witness.represents = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Supprimer',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Téléphone',
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _InputField(
                    label: 'E-mail',
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.compact, required this.children});

  final bool compact;
  final List<_ResponsiveField> children;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            SizedBox(width: double.infinity, child: children[i].child),
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(flex: children[i].flex, child: children[i].child),
          if (i != children.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _ResponsiveField {
  const _ResponsiveField({this.flex = 1, required this.child});

  final int flex;
  final Widget child;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.label, this.fillColor});

  final String label;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: _fieldDecoration(label, fillColor: fillColor));
  }
}

class _PresenceCheck extends StatelessWidget {
  const _PresenceCheck({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: const Color(0xFFEAF8EF),
      checkmarkColor: Colors.green,
      side: BorderSide(
        color: value ? const Color(0xFF86C99A) : const Color(0xFFDCE5F0),
      ),
    );
  }
}
