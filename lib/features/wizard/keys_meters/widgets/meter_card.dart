import 'package:flutter/material.dart';

import '../models/meter_item.dart';
import 'photo_picker_section.dart';

class MeterCard extends StatefulWidget {
  final MeterItem meter;
  final VoidCallback onDelete;

  const MeterCard({
    super.key,
    required this.meter,
    required this.onDelete,
  });

  @override
  State<MeterCard> createState() => _MeterCardState();
}

class _MeterCardState extends State<MeterCard> {
  MeterItem get meter => widget.meter;

  bool get _isCalorimeter => meter.type == 'Calorimètre';

  bool get _isElectricity => meter.type == 'Electricité';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEAF2FF),
                  child: Icon(
                    meter.icon,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    meter.type,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: meter.name,
              decoration: const InputDecoration(
                labelText: 'Nom du compteur',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              onChanged: (value) {
                meter.name = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: meter.number,
              decoration: const InputDecoration(
                labelText: 'Numéro du compteur',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              onChanged: (value) {
                meter.number = value;
              },
            ),
            const SizedBox(height: 18),
            if (_isElectricity) ...[
              const Text(
                'Consommation électrique',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: meter.dayIndex,
                      decoration: const InputDecoration(
                        labelText: 'Index jour',
                        prefixIcon: Icon(Icons.light_mode_outlined),
                      ),
                      onChanged: (value) {
                        meter.dayIndex = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: meter.nightIndex,
                      decoration: const InputDecoration(
                        labelText: 'Index nuit',
                        prefixIcon: Icon(Icons.dark_mode_outlined),
                      ),
                      onChanged: (value) {
                        meter.nightIndex = value;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                value: meter.hasPhotovoltaic,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Installation photovoltaïque',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Les index photovoltaïques sont liés au compteur électrique.',
                ),
                onChanged: (value) {
                  setState(() {
                    meter.hasPhotovoltaic = value ?? false;
                  });
                },
              ),
              if (meter.hasPhotovoltaic) ...[
                const SizedBox(height: 10),
                const Text(
                  'Production photovoltaïque',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: meter.solarDayIndex,
                        decoration: const InputDecoration(
                          labelText: 'Index jour photovoltaïque',
                          prefixIcon: Icon(Icons.solar_power_outlined),
                        ),
                        onChanged: (value) {
                          meter.solarDayIndex = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: meter.solarNightIndex,
                        decoration: const InputDecoration(
                          labelText: 'Index nuit photovoltaïque',
                          prefixIcon: Icon(Icons.solar_power),
                        ),
                        onChanged: (value) {
                          meter.solarNightIndex = value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ] else if (_isCalorimeter) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: meter.startIndex,
                      decoration: const InputDecoration(
                        labelText: 'Index début',
                        prefixIcon: Icon(Icons.login),
                      ),
                      onChanged: (value) {
                        meter.startIndex = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: meter.endIndex,
                      decoration: const InputDecoration(
                        labelText: 'Index fin',
                        prefixIcon: Icon(Icons.logout),
                      ),
                      onChanged: (value) {
                        meter.endIndex = value;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextFormField(
                initialValue: meter.index,
                decoration: const InputDecoration(
                  labelText: 'Index',
                  prefixIcon: Icon(Icons.speed_outlined),
                ),
                onChanged: (value) {
                  meter.index = value;
                },
              ),
            ],
            const SizedBox(height: 18),
            TextFormField(
              initialValue: meter.observation,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observation',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              onChanged: (value) {
                meter.observation = value;
              },
            ),
            const SizedBox(height: 18),
            PhotoPickerSection(
              key: ValueKey('meter-photo-${meter.hashCode}'),
              title: 'Photos du compteur',
            ),
          ],
        ),
      ),
    );
  }
}