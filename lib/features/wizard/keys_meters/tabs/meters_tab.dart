import 'package:flutter/material.dart';

import '../models/meter_item.dart';
import '../widgets/meter_card.dart';

class MetersTab extends StatefulWidget {
  const MetersTab({super.key});

  @override
  State<MetersTab> createState() => _MetersTabState();
}

class _MetersTabState extends State<MetersTab> {
  final List<MeterItem> meters = [];

  void _addMeter(String type, IconData icon, String defaultName) {
    setState(() {
      meters.add(MeterItem(type: type, icon: icon, name: defaultName));
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: const Text("Ajouter un compteur"),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width < 460
                ? MediaQuery.sizeOf(context).width - 80
                : 380,
            child: ListView(
              shrinkWrap: true,
              children: [
                _tile(
                  Icons.water_drop,
                  "Compteur d'eau",
                  () => _addMeter("Eau", Icons.water_drop, "Compteur d'eau"),
                ),
                _tile(
                  Icons.flash_on,
                  "Compteur électrique",
                  () => _addMeter(
                    "Electricité",
                    Icons.flash_on,
                    "Compteur principal",
                  ),
                ),
                _tile(
                  Icons.local_fire_department,
                  "Compteur gaz",
                  () => _addMeter(
                    "Gaz",
                    Icons.local_fire_department,
                    "Compteur gaz",
                  ),
                ),
                _tile(
                  Icons.thermostat,
                  "Calorimètre",
                  () =>
                      _addMeter("Calorimètre", Icons.thermostat, "Calorimètre"),
                ),
                _tile(
                  Icons.heat_pump,
                  "Compteur chauffage",
                  () => _addMeter(
                    "Chauffage",
                    Icons.heat_pump,
                    "Compteur chauffage",
                  ),
                ),
                _tile(
                  Icons.solar_power,
                  "Photovoltaïque",
                  () => _addMeter(
                    "Photovoltaïque",
                    Icons.solar_power,
                    "Onduleur",
                  ),
                ),
                _tile(
                  Icons.battery_charging_full,
                  "Batterie",
                  () => _addMeter(
                    "Batterie",
                    Icons.battery_charging_full,
                    "Batterie",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text("Ajouter un compteur"),
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: meters.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun compteur ajouté.",
                    style: TextStyle(fontSize: 18, color: Colors.black45),
                  ),
                )
              : ListView.builder(
                  itemCount: meters.length,
                  itemBuilder: (context, index) {
                    return MeterCard(
                      meter: meters[index],
                      onDelete: () {
                        setState(() {
                          meters.removeAt(index);
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
