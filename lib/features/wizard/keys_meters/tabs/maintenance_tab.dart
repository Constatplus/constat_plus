import 'package:flutter/material.dart';

import '../widgets/photo_picker_section.dart';

class MaintenanceTab extends StatefulWidget {
  const MaintenanceTab({super.key});

  @override
  State<MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<MaintenanceTab>
    with AutomaticKeepAliveClientMixin {
  final List<_MaintenanceItem> maintenanceItems = [
    _MaintenanceItem('Entretien chaudière'),
    _MaintenanceItem('Ramonage chaudière'),
    _MaintenanceItem('Ramonage feu ouvert'),
    _MaintenanceItem('Ramonage poêle'),
    _MaintenanceItem('Boiler'),
    _MaintenanceItem('Pompe à chaleur'),
    _MaintenanceItem('Adoucisseur'),
    _MaintenanceItem('VMC'),
    _MaintenanceItem('Ventilation'),
    _MaintenanceItem('Climatisation'),
    _MaintenanceItem('Alarme'),
    _MaintenanceItem('Extincteur'),
    _MaintenanceItem('Détecteurs incendie'),
    _MaintenanceItem('Panneaux photovoltaïques'),
    _MaintenanceItem('Batterie domestique'),
    _MaintenanceItem('Portail'),
    _MaintenanceItem('Porte de garage'),
    _MaintenanceItem('Ascenseur'),
    _MaintenanceItem('Autre'),
  ];

  @override
  bool get wantKeepAlive => true;

  Future<void> _selectDate(_MaintenanceItem item) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: item.date ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      item.date = selectedDate;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner une date';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.separated(
      itemCount: maintenanceItems.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final item = maintenanceItems[index];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: item.selected
                  ? Colors.blue
                  : Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                CheckboxListTile(
                  value: item.selected,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: const Icon(
                    Icons.build_circle_outlined,
                    color: Colors.blue,
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Entretien ou contrôle disponible',
                  ),
                  onChanged: (value) {
                    setState(() {
                      item.selected = value ?? false;
                    });
                  },
                ),
                if (item.selected) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(item),
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                          ),
                          label: Text(_formatDate(item.date)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          initialValue: item.company,
                          decoration: const InputDecoration(
                            labelText: 'Entreprise',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          onChanged: (value) {
                            item.company = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: item.observation,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Observation',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    onChanged: (value) {
                      item.observation = value;
                    },
                  ),
                  const SizedBox(height: 14),
                  PhotoPickerSection(
                    key: ValueKey(
                      'maintenance-photo-${item.id}',
                    ),
                    title: 'Photos de l’entretien',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MaintenanceItem {
  final String id;
  final String name;

  bool selected;
  DateTime? date;
  String company;
  String observation;

  _MaintenanceItem(this.name)
      : selected = false,
        date = null,
        company = '',
        observation = '',
        id = '${DateTime.now().microsecondsSinceEpoch}-$name';
}
