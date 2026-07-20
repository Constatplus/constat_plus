import 'package:flutter/material.dart';

import 'models/entry_mission_data.dart';
import 'models/room_inspection.dart';
import 'room_visit/room_visit_page.dart';
import 'widgets/entry_step_card.dart';

class EntryMissionPage extends StatefulWidget {
  const EntryMissionPage({super.key});

  @override
  State<EntryMissionPage> createState() => _EntryMissionPageState();
}

class _EntryMissionPageState extends State<EntryMissionPage> {
  final EntryMissionData _data = EntryMissionData();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _missionFormKey = GlobalKey<FormState>();
  int _currentStep = 0;

  static const List<String> _stepTitles = [
    'Mission',
    'Parties',
    'Pièces',
    'Observations',
    'Validation',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0 &&
        !(_missionFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_currentStep >= _stepTitles.length - 1) {
      _finish();
      return;
    }
    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentStep--);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _finish() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mission enregistrée'),
        content: const Text(
          'La structure de l’état des lieux d’entrée est enregistrée. Les photos, signatures et exports seront ajoutés dans les prochains sprints.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pop();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVisitDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _data.visitDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _data.visitDate = date);
    }
  }

  Future<void> _openRoomVisit(String room) async {
    final inspection = _data.roomInspections.putIfAbsent(
      room,
      () => RoomInspection(roomName: room),
    );
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RoomVisitPage(inspection: inspection),
      ),
    );
    if (mounted) setState(() {});
  }

  void _addRoom() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une pièce'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom de la pièce'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() => _data.rooms.add(value));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('État des lieux d’entrée')),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMissionStep(),
                _buildPartiesStep(),
                _buildRoomsStep(),
                _buildObservationsStep(),
                _buildValidationStep(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: Column(
          children: [
            Row(
              children: List.generate(_stepTitles.length, (index) {
                final active = index <= _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: active
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFE4E7EC),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : const Color(0xFF667085),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (index < _stepTitles.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index < _currentStep
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFE4E7EC),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _stepTitles[_currentStep],
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageShell(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMissionStep() {
    return _pageShell(
      Form(
        key: _missionFormKey,
        child: EntryStepCard(
          title: 'Informations du bien',
          subtitle: 'Identifiez le bien et fixez la date de la visite.',
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Adresse complète du bien',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Indiquez l’adresse du bien.'
                    : null,
                onChanged: (value) => _data.propertyAddress = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _data.propertyType,
                decoration: const InputDecoration(
                  labelText: 'Type de bien',
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Appartement',
                    child: Text('Appartement'),
                  ),
                  DropdownMenuItem(value: 'Maison', child: Text('Maison')),
                  DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                  DropdownMenuItem(value: 'Commerce', child: Text('Commerce')),
                  DropdownMenuItem(value: 'Bureau', child: Text('Bureau')),
                ],
                onChanged: (value) {
                  if (value != null) _data.propertyType = value;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Date de visite'),
                subtitle: Text(
                  '${_data.visitDate.day.toString().padLeft(2, '0')}/'
                  '${_data.visitDate.month.toString().padLeft(2, '0')}/'
                  '${_data.visitDate.year}',
                ),
                trailing: OutlinedButton(
                  onPressed: _pickVisitDate,
                  child: const Text('Modifier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartiesStep() {
    return _pageShell(
      EntryStepCard(
        title: 'Parties présentes',
        subtitle:
            'Ajoutez le bailleur et le locataire concernés par la mission.',
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bailleur ou représentant',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (value) => _data.landlordName = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Locataire ou occupant',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              onChanged: (value) => _data.tenantName = value,
            ),
            const SizedBox(height: 18),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text('Signatures'),
              subtitle: Text(
                'Les signatures manuscrites des parties seront ajoutées à l’étape de clôture.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsStep() {
    return _pageShell(
      EntryStepCard(
        title: 'Composition du bien',
        subtitle:
            'Ajoutez les pièces puis ouvrez chacune d’elles pour réaliser la visite complète.',
        child: Column(
          children: [
            for (final room in _data.rooms)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.meeting_room_outlined),
                  title: Text(room),
                  subtitle: Text(
                    _data.roomInspections[room]?.hasContent == true
                        ? 'Visite complétée'
                        : 'À compléter',
                  ),
                  onTap: () => _openRoomVisit(room),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Ouvrir la visite',
                        onPressed: () => _openRoomVisit(room),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        onPressed: () => setState(() {
                          _data.rooms.remove(room);
                          _data.roomNotes.remove(room);
                          _data.roomInspections.remove(room);
                        }),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addRoom,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter une pièce'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsStep() {
    return _pageShell(
      EntryStepCard(
        title: 'Observations par pièce',
        subtitle: 'Saisissez une première description pour chaque pièce.',
        child: Column(
          children: [
            if (_data.rooms.isEmpty)
              const Text('Ajoutez au moins une pièce à l’étape précédente.'),
            for (final room in _data.rooms) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  room,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText:
                      'Sol, murs, plafond, menuiseries, électricité, équipements…',
                  alignLabelWithHint: true,
                ),
                onChanged: (value) => _data.roomNotes[room] = value,
              ),
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidationStep() {
    return _pageShell(
      EntryStepCard(
        title: 'Validation de la mission',
        subtitle: 'Contrôlez les informations avant l’enregistrement.',
        child: Column(
          children: [
            _summaryRow(
              'Adresse',
              _data.propertyAddress.isEmpty
                  ? 'Non renseignée'
                  : _data.propertyAddress,
            ),
            _summaryRow('Type de bien', _data.propertyType),
            _summaryRow(
              'Bailleur',
              _data.landlordName.isEmpty ? 'Non renseigné' : _data.landlordName,
            ),
            _summaryRow(
              'Locataire',
              _data.tenantName.isEmpty ? 'Non renseigné' : _data.tenantName,
            ),
            _summaryRow('Nombre de pièces', '${_data.rooms.length}'),
            const SizedBox(height: 20),
            TextField(
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Observations générales',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => _data.generalNotes = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _previous,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(_currentStep == 0 ? 'Quitter' : 'Précédent'),
              ),
              const Spacer(),
              Text('${_currentStep + 1} / ${_stepTitles.length}'),
              const SizedBox(width: 18),
              FilledButton.icon(
                onPressed: _next,
                icon: Icon(
                  _currentStep == _stepTitles.length - 1
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Text(
                  _currentStep == _stepTitles.length - 1
                      ? 'Enregistrer'
                      : 'Suivant',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
