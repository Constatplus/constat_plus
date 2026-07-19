import 'package:flutter/material.dart';

import '../../core/models/mission_type.dart';
import 'property_composition/models/room_item.dart';
import 'report/models/visit_report_snapshot.dart';
import 'step_general_info.dart';
import 'step_keys_meters.dart';
import 'step_property_composition.dart';
import 'step_property_type.dart';
import 'step_report.dart';
import 'step_signatures.dart';
import 'step_visit.dart';

class WizardPage extends StatefulWidget {
  const WizardPage({
    super.key,
    required this.missionType,
  });

  final MissionType missionType;

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
  int currentStep = 0;

  final List<RoomItem> selectedRooms = <RoomItem>[];
  final StepVisitController _visitController = StepVisitController();
  final StepSignatureController _signatureController =
      StepSignatureController();

  VisitReportSnapshot _reportSnapshot =
      const VisitReportSnapshot(rooms: <VisitRoomReport>[]);

  static const List<String> _steps = <String>[
    'Type de bien',
    'Informations générales',
    'Clés • Compteurs • Documents',
    'Composition du bien',
    'Visite',
    'Signatures',
    'Rapport',
  ];

  bool get _isSignatureStep => currentStep == 5;
  bool get _isLastStep => currentStep == _steps.length - 1;

  void _nextStep() {
    if (currentStep == 3 && selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une pièce avant de continuer.'),
        ),
      );
      return;
    }

    if (currentStep == 4) {
      _reportSnapshot = _visitController.read();
    }

    if (!_isLastStep) {
      setState(() {
        currentStep++;
      });
    }
  }

  void _openReportFromSignatures() {
    if (!mounted) return;

    setState(() {
      currentStep = 6;
    });
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      return;
    }

    Navigator.pop(context);
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return const StepPropertyType();
      case 1:
        return const StepGeneralInfo();
      case 2:
        return const StepKeysMeters();
      case 3:
        return StepPropertyComposition(
          rooms: selectedRooms,
          onRoomsChanged: () => setState(() {}),
        );
      case 4:
        return StepVisit(
          rooms: selectedRooms,
          controller: _visitController,
        );
      case 5:
        return StepSignature(
          controller: _signatureController,
          onContinue: _openReportFromSignatures,
          onPostpone: _openReportFromSignatures,
        );
      case 6:
        return StepReport(snapshot: _reportSnapshot);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Précédent'),
        ),
        const Spacer(),
        if (!_isSignatureStep && !_isLastStep)
          FilledButton.icon(
            onPressed: _nextStep,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuer'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.missionType.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${widget.missionType.shortLabel} • '
                    'Étape ${currentStep + 1} / ${_steps.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _steps[currentStep],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 24),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}
