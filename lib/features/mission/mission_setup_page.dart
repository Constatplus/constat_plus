import 'package:flutter/material.dart';

enum MissionType { entry, exit, beforeWorks }

extension MissionTypeLabel on MissionType {
  String get title {
    switch (this) {
      case MissionType.entry:
        return 'État des lieux d’entrée';
      case MissionType.exit:
        return 'État des lieux de sortie';
      case MissionType.beforeWorks:
        return 'Constat avant travaux';
    }
  }
}

class MissionSetupPage extends StatefulWidget {
  const MissionSetupPage({required this.type, super.key});

  final MissionType type;

  @override
  State<MissionSetupPage> createState() => _MissionSetupPageState();
}

class _MissionSetupPageState extends State<MissionSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _clientController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _addressController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.type.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Créer le dossier', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Complétez les informations principales avant de commencer la visite.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse du bien',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Indiquez l’adresse du bien.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _clientController,
                        decoration: const InputDecoration(
                          labelText: 'Client ou donneur d’ordre',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text('Date de la mission'),
                        subtitle: Text(
                          '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                        ),
                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dossier créé. Le parcours métier arrive au sprint suivant.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Créer et continuer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
