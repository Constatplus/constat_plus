import 'package:flutter/material.dart';

import '../../core/ai/inspection_ai_service.dart';
import '../../core/state/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _signatureController = TextEditingController();
  final _aiPreferences = InspectionAiPreferences();
  InspectionAiMode _aiMode = InspectionAiMode.automatic;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAiMode();
  }

  Future<void> _loadAiMode() async {
    final mode = await _aiPreferences.loadMode();
    if (mounted) setState(() => _aiMode = mode);
  }

  Future<void> _saveAiMode(InspectionAiMode mode) async {
    setState(() => _aiMode = mode);
    await _aiPreferences.saveMode(mode);
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!_loaded) {
      _signatureController.text = state.professionalSignature;
      _loaded = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préférences',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: state.assistantEnabled,
                        onChanged: (value) =>
                            state.updateSettings(assistant: value),
                        title: const Text('Assistant IA'),
                        subtitle: const Text(
                          'Afficher les conseils pendant la visite.',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Mode IA'),
                        subtitle: const Text(
                          'Le mode hors ligne ne transmet aucune photo ni aucun texte.',
                        ),
                        trailing: DropdownButton<InspectionAiMode>(
                          value: _aiMode,
                          onChanged: (mode) {
                            if (mode != null) _saveAiMode(mode);
                          },
                          items: InspectionAiMode.values
                              .map(
                                (mode) => DropdownMenuItem<InspectionAiMode>(
                                  value: mode,
                                  child: Text(mode.label),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: state.autoSaveEnabled,
                        onChanged: (value) =>
                            state.updateSettings(autoSave: value),
                        title: const Text('Sauvegarde automatique'),
                        subtitle: const Text(
                          'Conserver chaque modification dans la session.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Signature professionnelle',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _signatureController,
                          decoration: const InputDecoration(
                            labelText: 'Nom, qualité et matricule',
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: () {
                            state.updateSettings(
                              signature: _signatureController.text.trim(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Réglages enregistrés.'),
                              ),
                            );
                          },
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
