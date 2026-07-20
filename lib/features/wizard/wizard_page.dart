import 'package:flutter/material.dart';

import '../../core/access/access_service.dart';
import '../../core/models/mission_type.dart';
import '../../core/utils/mission_identifier.dart';
import '../commercial/domain/models/discovery_access_state.dart';
import '../commercial/infrastructure/repositories/supabase_discovery_access_repository.dart';
import '../commercial/presentation/pages/discovery_paywall_page.dart';
import 'before_works/models/before_works_data.dart';
import 'before_works/step_before_works_photos.dart';
import 'before_works/step_before_works_visit.dart';
import 'comparison/step_comparative_remarks.dart';
import 'models/wizard_mission_data.dart';
import 'property_composition/models/room_item.dart';
import 'reference/models/reference_report.dart';
import 'reference/reference_pdf_viewer_page.dart';
import 'reference/step_reference_report.dart';
import 'report/models/report_settings.dart';
import 'report/models/visit_report_snapshot.dart';
import 'step_exit_calculations.dart';
import 'step_exit_closure.dart';
import 'step_exit_comparison.dart';
import 'step_exit_mission_order.dart';
import 'step_before_works_info.dart';
import 'step_general_info.dart';
import 'step_keys_meters.dart';
import 'step_property_composition.dart';
import 'step_property_type.dart';
import 'step_report.dart';
import 'step_signatures.dart';
import 'step_visit.dart';

class WizardPage extends StatefulWidget {
  const WizardPage({super.key, required this.missionType});

  final MissionType missionType;

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
  int currentStep = 0;
  late final String _missionId = createMissionIdentifier();

  final List<RoomItem> selectedRooms = <RoomItem>[];
  final StepVisitController _visitController = StepVisitController();
  final StepSignatureController _signatureController =
      StepSignatureController();
  final WizardMissionData _missionData = WizardMissionData();
  SupabaseDiscoveryAccessRepository? _discoveryRepositoryInstance;
  DiscoveryAccessState? _discoveryAccess;

  SupabaseDiscoveryAccessRepository get _discoveryRepository =>
      _discoveryRepositoryInstance ??= SupabaseDiscoveryAccessRepository();

  VisitReportSnapshot _reportSnapshot = const VisitReportSnapshot(
    rooms: <VisitRoomReport>[],
  );

  List<String> get _steps {
    switch (widget.missionType) {
      case MissionType.entry:
        return const <String>[
          'Type de bien',
          'Informations générales',
          'Clés • Compteurs • Documents',
          'Composition du bien',
          "Visite d'entrée",
          'Signatures',
          "Rapport d'entrée",
        ];
      case MissionType.exit:
        return const <String>[
          'Ordre de mission et parties présentes',
          "Composition issue de l'état des lieux d'entrée",
          'Remarques comparatives de sortie',
          'Calcul des indemnités',
          'Clôture contradictoire et signatures',
          'Rapport de sortie',
        ];
      case MissionType.beforeWorks:
        return const <String>[
          'Ordre de mission',
          'Composition du constat',
          'Visite avant travaux',
          'Photos',
          'Signatures',
          'Rapport avant travaux',
        ];
      case MissionType.afterWorks:
        return const <String>[
          'Ordre de mission et parties présentes',
          'Rapport avant travaux de référence',
          'Composition reprise du rapport avant travaux',
          'Remarques comparatives de récolement',
          'Rapport de récolement',
        ];
    }
  }

  bool get _isExit => widget.missionType == MissionType.exit;
  bool get _isBeforeWorks => widget.missionType == MissionType.beforeWorks;
  bool get _isAfterWorks => widget.missionType == MissionType.afterWorks;
  InspectionReportType get _reportType => _isExit
      ? InspectionReportType.exit
      : _isBeforeWorks
      ? InspectionReportType.beforeWorks
      : _isAfterWorks
      ? InspectionReportType.afterWorks
      : InspectionReportType.entry;
  int get _visitStepIndex => _isExit
      ? 2
      : _isBeforeWorks
      ? 2
      : _isAfterWorks
      ? 3
      : 4;
  int get _compositionStepIndex => _isExit
      ? 1
      : _isBeforeWorks
      ? 1
      : _isAfterWorks
      ? 2
      : 3;
  int get _signatureStepIndex => _isExit
      ? 4
      : _isBeforeWorks
      ? 4
      : _isAfterWorks
      ? -1
      : 5;
  int get _reportStepIndex => _steps.length - 1;

  bool get _isSignatureStep => currentStep == _signatureStepIndex;
  bool get _isLastStep => currentStep == _reportStepIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDiscoveryMode();
    });
  }

  Future<void> _initializeDiscoveryMode() async {
    if (AccessService.instance.isDemo) return;
    try {
      final state = await _discoveryRepository.registerMission(
        missionId: _missionId,
        missionType: widget.missionType.databaseValue,
      );
      if (!mounted) return;
      setState(() => _discoveryAccess = state);
      AccessService.instance.setDiscoveryAccess(state);
      if (!state.activeMissionIds.contains(_missionId) &&
          !state.hasPaidAccessFor(_missionId)) {
        final unlocked = await showDiscoveryPaywall(
          context,
          missionId: _missionId,
          roomsUsed: selectedRooms.length,
          roomLimit: state.policy.maxFullyDescribedRooms,
        );
        if (!mounted) return;
        if (!unlocked) {
          Navigator.pop(context);
          return;
        }
        await _refreshDiscoveryAccess(registerMission: true);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mode Découverte hors ligne indisponible avant une première synchronisation : $error',
          ),
        ),
      );
    }
  }

  Future<void> _refreshDiscoveryAccess({
    bool registerMission = false,
    bool allowOffline = true,
  }) async {
    final state = registerMission
        ? await _discoveryRepository.registerMission(
            missionId: _missionId,
            missionType: widget.missionType.databaseValue,
            allowOffline: allowOffline,
          )
        : await _discoveryRepository.getState(forceRefresh: true);
    if (!mounted) return;
    setState(() => _discoveryAccess = state);
    AccessService.instance.setDiscoveryAccess(state);
  }

  Future<bool> _openDiscoveryPaywall(int roomsUsed, int roomLimit) async {
    try {
      await _refreshDiscoveryAccess(registerMission: true, allowOffline: false);
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synchronisez le brouillon avant de lancer le paiement : $error',
          ),
        ),
      );
      return false;
    }
    if (!mounted) return false;
    final unlocked = await showDiscoveryPaywall(
      context,
      missionId: _missionId,
      roomsUsed: roomsUsed,
      roomLimit: roomLimit,
    );
    if (!mounted || !unlocked) return false;
    await _refreshDiscoveryAccess();
    return _discoveryAccess?.hasPaidAccessFor(_missionId) ?? false;
  }

  void _nextStep() {
    if (currentStep == _compositionStepIndex && selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une pièce avant de continuer.'),
        ),
      );
      return;
    }

    if (currentStep == _visitStepIndex &&
        !_isExit &&
        !_isBeforeWorks &&
        !_isAfterWorks) {
      _reportSnapshot = _visitController.read();
      _missionData.visitSnapshot = _reportSnapshot;
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
      currentStep = _reportStepIndex;
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
    if (_isExit) {
      return _buildExitStepContent();
    }
    if (_isBeforeWorks) return _buildBeforeWorksStepContent();
    if (_isAfterWorks) return _buildAfterWorksStepContent();

    return _buildStandardStepContent();
  }

  Widget _buildBeforeWorksStepContent() {
    switch (currentStep) {
      case 0:
        return StepBeforeWorksInfo(
          data: _missionData.beforeWorks,
          onChanged: () => setState(() {}),
        );
      case 1:
        return StepPropertyComposition(
          rooms: selectedRooms,
          missionId: _missionId,
          discoveryAccess: _discoveryAccess,
          onDiscoveryLimitReached: _openDiscoveryPaywall,
          technicalMode: true,
          onRoomsChanged: () => setState(() {}),
        );
      case 2:
        return StepBeforeWorksVisit(
          rooms: selectedRooms,
          data: _missionData.beforeWorks,
          onChanged: () => setState(() {}),
        );
      case 3:
        return StepBeforeWorksPhotos(
          findings: _missionData.beforeWorks.findings,
          areas: _missionData.beforeWorks.areas,
        );
      case 4:
        return StepSignature(
          controller: _signatureController,
          onContinue: _openReportFromSignatures,
          onPostpone: _openReportFromSignatures,
        );
      case 5:
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot: _missionData.visitSnapshot,
          initialReportType: _reportType,
          rooms: selectedRooms,
          beforeWorksData: _missionData.beforeWorks,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAfterWorksStepContent() {
    switch (currentStep) {
      case 0:
        return const StepExitMissionOrder();
      case 1:
        return StepReferenceReport(
          selected: _missionData.referenceReport,
          mode: _missionData.recollectionReferenceMode,
          onSelected: _selectReference,
          onNoReference: _selectNoReference,
        );
      case 2:
        return StepPropertyComposition(
          rooms: selectedRooms,
          missionId: _missionId,
          discoveryAccess: _discoveryAccess,
          onDiscoveryLimitReached: _openDiscoveryPaywall,
          technicalMode: true,
          onRoomsChanged: () => setState(() {}),
        );
      case 3:
        return StepComparativeRemarks(
          rooms: selectedRooms,
          remarks: _missionData.comparisonRemarks,
          referenceFindings: _missionData.referenceReport?.findings ?? const [],
          afterWorks: true,
          onOpenReference: _missionData.referenceReport == null
              ? null
              : _openReference,
        );
      case 4:
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot:
              _missionData.referenceReport?.snapshot ??
              const VisitReportSnapshot(rooms: <VisitRoomReport>[]),
          initialReportType: _reportType,
          rooms: selectedRooms,
          referenceReport: _missionData.referenceReport,
          comparisonRemarks: _missionData.comparisonRemarks,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _selectReference(ReferenceReport report) {
    setState(() {
      _missionData.referenceReport = report;
      _missionData.recollectionReferenceMode = report.external
          ? RecollectionReferenceMode.externalPdf
          : RecollectionReferenceMode.constatPlus;
      _missionData.recollectionAreas
        ..clear()
        ..addAll(
          report.areas.map(
            (area) => BeforeWorksArea(
              id: area.id,
              name: area.name,
              type: area.type,
              parentId: area.parentId,
            ),
          ),
        );
      if (report.zones.isNotEmpty) {
        selectedRooms
          ..clear()
          ..addAll(
            report.zones.map(
              (room) =>
                  RoomItem(type: room.type, name: room.name, level: room.level),
            ),
          );
      } else if (report.areas.isNotEmpty) {
        selectedRooms
          ..clear()
          ..addAll(
            report.areas
                .where((area) => !area.type.isContainer)
                .map(
                  (area) => RoomItem(
                    type: area.type.label,
                    name: area.name,
                    level: '',
                  ),
                ),
          );
      }
    });
  }

  void _selectNoReference() {
    setState(() {
      _missionData.referenceReport = null;
      _missionData.recollectionReferenceMode = RecollectionReferenceMode.none;
      _missionData.recollectionAreas.clear();
    });
  }

  void _openReference() {
    final report = _missionData.referenceReport;
    if (report == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReferencePdfViewerPage(
          title: report.title,
          backLabel: 'Retour au récolement',
          pdfBytes: report.pdfBytes,
          pdfPath: report.pdfPath,
        ),
      ),
    );
  }

  Widget _buildStandardStepContent() {
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
          missionId: _missionId,
          discoveryAccess: _discoveryAccess,
          onDiscoveryLimitReached: _openDiscoveryPaywall,
          onRoomsChanged: () => setState(() {}),
        );
      case 4:
        return StepVisit(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
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
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot: _reportSnapshot,
          initialReportType: _reportType,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildExitStepContent() {
    switch (currentStep) {
      case 0:
        return const StepExitMissionOrder();
      case 1:
        return StepPropertyComposition(
          rooms: selectedRooms,
          missionId: _missionId,
          discoveryAccess: _discoveryAccess,
          onDiscoveryLimitReached: _openDiscoveryPaywall,
          onRoomsChanged: () => setState(() {}),
        );
      case 2:
        return StepExitComparison(rooms: selectedRooms);
      case 3:
        return StepExitCalculations(rooms: selectedRooms);
      case 4:
        return StepExitClosure();
      case 5:
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot: _reportSnapshot,
          initialReportType: _reportType,
        );
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
        if (_isExit && _isSignatureStep)
          FilledButton.icon(
            onPressed: _nextStep,
            icon: const Icon(Icons.description_outlined),
            label: const Text('Générer le rapport de sortie'),
          ),
        if (_isBeforeWorks && _isSignatureStep)
          FilledButton.icon(
            onPressed: _openReportFromSignatures,
            icon: const Icon(Icons.description_outlined),
            label: const Text('Ouvrir le rapport avant travaux'),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  if (_discoveryAccess != null &&
                      !_discoveryAccess!.hasPaidAccessFor(_missionId)) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Mode Découverte : ${selectedRooms.length} / ${_discoveryAccess!.policy.maxFullyDescribedRooms} pièces',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  color: _isExit ? const Color(0xFFDC2626) : Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _steps[currentStep],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: _isExit ? FontWeight.w700 : FontWeight.normal,
                    color: _isExit ? const Color(0xFFB91C1C) : Colors.black54,
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
                    border: _isExit
                        ? Border.all(color: const Color(0xFFFECACA))
                        : null,
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
