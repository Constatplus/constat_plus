import 'package:flutter/material.dart';

import 'folder_model.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientController = TextEditingController();
  MissionType _missionType = MissionType.entry;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      FolderModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        client: _clientController.text.trim(),
        missionType: _missionType,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau dossier'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nom du dossier'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Champ obligatoire'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse du bien'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Champ obligatoire'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(labelText: 'Client'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Champ obligatoire'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<MissionType>(
                initialValue: _missionType,
                decoration: const InputDecoration(labelText: 'Type de mission'),
                items: const [
                  DropdownMenuItem(
                    value: MissionType.entry,
                    child: Text('État des lieux d’entrée'),
                  ),
                  DropdownMenuItem(
                    value: MissionType.exit,
                    child: Text('État des lieux de sortie'),
                  ),
                  DropdownMenuItem(
                    value: MissionType.beforeWorks,
                    child: Text('Constat avant travaux'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _missionType = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Créer')),
      ],
    );
  }
}
