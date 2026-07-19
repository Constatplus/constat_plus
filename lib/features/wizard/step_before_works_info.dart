import 'package:flutter/material.dart';

class StepBeforeWorksInfo extends StatefulWidget {
  const StepBeforeWorksInfo({super.key});

  @override
  State<StepBeforeWorksInfo> createState() => _StepBeforeWorksInfoState();
}

class _StepBeforeWorksInfoState extends State<StepBeforeWorksInfo> {
  DateTime selectedDate = DateTime.now();

  String get formattedDate => '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

  Future<void> _pickDate() async {
    final value = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (value != null) setState(() => selectedDate = value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations du constat avant travaux', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Identifiez le lieu, le donneur d’ordre, les intervenants et la nature des travaux.', style: TextStyle(fontSize: 17, color: Colors.black54)),
          const SizedBox(height: 28),
          const _Title(Icons.location_on_outlined, 'Lieu du constat'),
          const SizedBox(height: 12),
          const Row(children: [Expanded(flex: 4, child: _Field('Rue')), SizedBox(width: 12), Expanded(child: _Field('N°')), SizedBox(width: 12), Expanded(child: _Field('Boîte'))]),
          const SizedBox(height: 12),
          const Row(children: [Expanded(child: _Field('Code postal')), SizedBox(width: 12), Expanded(flex: 3, child: _Field('Ville'))]),
          const SizedBox(height: 26),
          const _Title(Icons.assignment_ind_outlined, 'Donneur d’ordre'),
          const SizedBox(height: 12),
          const Row(children: [Expanded(flex: 2, child: _Field('Nom / société')), SizedBox(width: 12), Expanded(child: _Field('Téléphone')), SizedBox(width: 12), Expanded(child: _Field('E-mail'))]),
          const SizedBox(height: 26),
          const _Title(Icons.construction_outlined, 'Projet et intervenants'),
          const SizedBox(height: 12),
          const Row(children: [Expanded(child: _Field('Maître d’ouvrage')), SizedBox(width: 12), Expanded(child: _Field('Entreprise de travaux'))]),
          const SizedBox(height: 12),
          const Row(children: [Expanded(child: _Field('Architecte / bureau d’études')), SizedBox(width: 12), Expanded(child: _Field('Occupant éventuel'))]),
          const SizedBox(height: 12),
          const _Field('Nature des travaux', maxLines: 2),
          const SizedBox(height: 12),
          const _Field('Objet et étendue de la mission', maxLines: 3),
          const SizedBox(height: 26),
          const _Title(Icons.calendar_today_outlined, 'Date et présence'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: InkWell(onTap: _pickDate, borderRadius: BorderRadius.circular(16), child: InputDecorator(decoration: _decoration('Date de la mission'), child: Text(formattedDate)))),
            const SizedBox(width: 12),
            const Expanded(child: _Field('Heure')),
          ]),
          const SizedBox(height: 12),
          const _Field('Personnes présentes et qualité', maxLines: 3),
        ],
      ),
    );
  }
}

InputDecoration _decoration(String label) => InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF4F8FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none));

class _Field extends StatelessWidget {
  final String label;
  final int maxLines;
  const _Field(this.label, {this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextFormField(maxLines: maxLines, decoration: _decoration(label));
}

class _Title extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Title(this.icon, this.title);
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 22), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))]);
}
