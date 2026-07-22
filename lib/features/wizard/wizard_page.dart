import 'package:flutter/material.dart';

import '../../core/access/access_service.dart';
import '../../core/models/mission_type.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/mission_identifier.dart';
import '../commercial/domain/models/discovery_access_state.dart';
import '../commercial/infrastructure/repositories/supabase_discovery_access_repository.dart';
import '../commercial/presentation/pages/discovery_paywall_page.dart';
import 'before_works/models/before_works_data.dart';
import 'before_works/step_before_works_photos.dart';
import 'before_works/step_before_works_visit.dart';
import 'comparison/step_comparative_remarks.dart';
import 'generalities/step_generalities.dart';
import 'models/wizard_mission_data.dart';
import 'property_composition/models/property_element.dart';
import 'property_composition/models/room_item.dart';
import 'property_composition/widgets/building_workflow_shell.dart';
import 'reference/models/reference_report.dart';
import 'reference/reference_pdf_viewer_page.dart';
import 'reference/reference_report_repository.dart';
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
          'Généralités',
          "Visite d'entrée",
          'Signatures',
          "Rapport d'entrée",
        ];
      case MissionType.exit:
        return const <String>[
          'Ordre de mission et parties présentes',
          'Éléments principaux de la mission',
          "Composition issue de l'état des lieux d'entrée",
          'Remarques comparatives de sortie',
          'Calcul des indemnités',
          'Clôture contradictoire et signatures',
          'Rapport de sortie',
        ];
      case MissionType.beforeWorks:
        return const <String>[
          'Ordre de mission',
          'Éléments principaux de la mission',
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
          'Éléments principaux de la mission',
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
      ? 3
      : _isBeforeWorks
      ? 3
      : _isAfterWorks
      ? 4
      : 5;
  int get _compositionStepIndex => _isExit
      ? 2
      : _isBeforeWorks
      ? 2
      : _isAfterWorks
      ? 3
      : 3;
  int get _propertyStructureStepIndex => _isExit || _isBeforeWorks
      ? 1
      : _isAfterWorks
      ? 2
      : 0;
  int get _signatureStepIndex => _isExit
      ? 5
      : _isBeforeWorks
      ? 5
      : _isAfterWorks
      ? -1
      : 6;
  int get _reportStepIndex => _steps.length - 1;

  bool get _isSignatureStep => currentStep == _signatureStepIndex;
  bool get _isLastStep => currentStep == _reportStepIndex;

  void _selectPropertyElement(String id) {
    setState(() {
      _missionData.selectedPropertyElementId = id;
    });
  }

  void _selectPropertyElementAndContinue(String id) {
    setState(() {
      _missionData.selectedPropertyElementId = id;

      // Passage automatique à l’étape suivante uniquement
      // pour l’état des lieux d’entrée et de sortie.
      if (!_isBeforeWorks &&
          !_isAfterWorks &&
          currentStep == _propertyStructureStepIndex &&
          currentStep < _steps.length - 1) {
        currentStep++;
      }
    });
  }

  void _attachRoomsToDefaultElement({String name = 'Habitation principale'}) {
    var element = _missionData.propertyElements.isEmpty
        ? null
        : _missionData.propertyElements.first;
    final createdDefault = element == null;
    if (element == null) {
      element = PropertyElement.create(PropertyElementType.housing, name: name);
      _missionData.propertyElements.add(element);
    }
    _missionData.selectedPropertyElementId ??= element.id;
    for (final room in selectedRooms) {
      if (createdDefault || room.propertyElementId.isEmpty) {
        room.propertyElementId = element.id;
      }
    }
  }

  Widget _buildPropertyStructure() {
    final technicalMode = _isBeforeWorks || _isAfterWorks;

    return StepPropertyType(
      elements: _missionData.propertyElements,
      selectedElementId: _missionData.selectedPropertyElementId,
      onSelected: technicalMode
          ? _selectPropertyElement
          : _selectPropertyElementAndContinue,
      onChanged: () => setState(() {}),
      technicalMode: technicalMode,
    );
  }

  Widget _buildPropertyComposition({bool technicalMode = false}) {
    final selectedId = _missionData.selectedPropertyElementId;
    if (selectedId == null) {
      return const Center(
        child: Text('Sélectionnez d’abord un élément principal.'),
      );
    }
    return StepPropertyComposition(
      rooms: selectedRooms,
      missionId: _missionId,
      discoveryAccess: _discoveryAccess,
      onDiscoveryLimitReached: _openDiscoveryPaywall,
      propertyElements: _missionData.propertyElements,
      selectedPropertyElementId: selectedId,
      onPropertyElementSelected: _selectPropertyElement,
      technicalMode: technicalMode,
      onRoomsChanged: () => setState(() {}),
    );
  }

  void _setPropertyElementCompleted(String id, bool completed) {
    setState(() {
      if (completed) {
        _missionData.completedPropertyElementIds.add(id);
      } else {
        _missionData.completedPropertyElementIds.remove(id);
      }
    });
  }

  List<String> get _requiredPropertyElementIds => _missionData.propertyElements
      .where(
        (element) =>
            selectedRooms.any((room) => room.propertyElementId == element.id),
      )
      .map((element) => element.id)
      .toList(growable: false);

  Widget _buildGuidedBuildingStage(
    Widget Function(List<RoomItem> rooms, String elementId) builder,
  ) {
    final selectedId = _missionData.selectedPropertyElementId;
    if (selectedId == null || _missionData.propertyElements.isEmpty) {
      return const Center(child: Text('Aucun bâtiment sélectionné.'));
    }
    final rooms = selectedRooms
        .where((room) => room.propertyElementId == selectedId)
        .toList(growable: false);
    return BuildingWorkflowShell(
      elements: _missionData.propertyElements,
      rooms: selectedRooms,
      selectedElementId: selectedId,
      completedElementIds: _missionData.completedPropertyElementIds,
      onSelected: _selectPropertyElement,
      onCompletionChanged: _setPropertyElementCompleted,
      child: builder(rooms, selectedId),
    );
  }

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

  Future<void> _openPreviousEntryReport() async {
    await ReferenceReportRepository.instance.load();
    if (!mounted) return;
    final reports = ReferenceReportRepository.instance.reports
        .where(
          (report) =>
              report.source == ReferenceReportSource.constatPlus &&
              report.missionType == 'entry',
        )
        .toList(growable: false);
    if (reports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucun ancien état des lieux d’entrée Constat+ n’est disponible.',
          ),
        ),
      );
      return;
    }

    final selected = await showDialog<ReferenceReport>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ouvrir un ancien rapport Constat+'),
        content: SizedBox(
          width: 560,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(report.title),
                subtitle: Text(
                  '${report.createdAt.day.toString().padLeft(2, '0')}/'
                  '${report.createdAt.month.toString().padLeft(2, '0')}/'
                  '${report.createdAt.year}',
                ),
                onTap: () => Navigator.pop(dialogContext, report),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    if (selected == null || !mounted) return;

    final sourceRooms = selected.zones.isNotEmpty
        ? selected.zones
        : selected.snapshot.rooms
              .map(
                (room) => RoomItem(
                  type: room.type,
                  name: room.name,
                  level: room.level,
                  propertyElementId: room.propertyElementId,
                ),
              )
              .toList(growable: false);
    setState(() {
      _missionData.propertyElements
        ..clear()
        ..addAll(selected.snapshot.propertyElements.map((item) => item.copy()));
      _missionData.selectedPropertyElementId =
          _missionData.propertyElements.isEmpty
          ? null
          : _missionData.propertyElements.first.id;
      selectedRooms
        ..clear()
        ..addAll(
          sourceRooms.map(
            (room) => RoomItem(
              type: room.type,
              name: room.name,
              level: room.level,
              propertyElementId: room.propertyElementId,
            ),
          ),
        );
      _attachRoomsToDefaultElement();
      _reportSnapshot = selected.snapshot;
      _missionData.visitSnapshot = selected.snapshot;
      currentStep = 3;
    });
  }

  bool get _hasIncompleteExitComparison => selectedRooms.any(
    (room) => !_missionData.comparisonRemarks.any(
      (remark) =>
          remark.zone == room.name && remark.afterDescription.trim().isNotEmpty,
    ),
  );

  Future<void> _nextStep() async {
    if (currentStep == _propertyStructureStepIndex &&
        _missionData.propertyElements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un élément principal.')),
      );
      return;
    }
    if (currentStep == _compositionStepIndex && selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une pièce avant de continuer.'),
        ),
      );
      return;
    }

    if (currentStep == _visitStepIndex &&
        _isExit &&
        _hasIncompleteExitComparison) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Remarques comparatives incomplètes'),
          content: const Text(
            'Certaines pièces ne comportent pas encore de remarque comparative.\n\n'
            'Vous pourrez toujours compléter ces remarques ultérieurement.\n\n'
            'Souhaitez-vous poursuivre vers le calcul des indemnités ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Retour'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    if (currentStep == _visitStepIndex && !_isExit) {
      final missing = _requiredPropertyElementIds.where(
        (id) => !_missionData.completedPropertyElementIds.contains(id),
      );
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Terminez chaque bâtiment contenant des pièces avant de continuer.',
            ),
          ),
        );
        return;
      }
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
        return _buildPropertyStructure();
      case 2:
        return _buildPropertyComposition(technicalMode: true);
      case 3:
        return _buildGuidedBuildingStage(
          (_, elementId) => StepBeforeWorksVisit(
            rooms: selectedRooms,
            data: _missionData.beforeWorks,
            propertyElements: _missionData.propertyElements,
            activePropertyElementId: elementId,
            onChanged: () => setState(() {}),
          ),
        );
      case 4:
        return StepBeforeWorksPhotos(
          findings: _missionData.beforeWorks.findings,
          areas: _missionData.beforeWorks.areas,
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
          snapshot: _missionData.visitSnapshot,
          initialReportType: _reportType,
          rooms: selectedRooms,
          beforeWorksData: _missionData.beforeWorks,
          generalities: _missionData.generalities,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAfterWorksStepContent() {
    switch (currentStep) {
      case 0:
        return StepBeforeWorksInfo(
          data: _missionData.beforeWorks,
          afterWorks: true,
          onChanged: () => setState(() {}),
        );
      case 1:
        return StepReferenceReport(
          selected: _missionData.referenceReport,
          mode: _missionData.recollectionReferenceMode,
          onSelected: _selectReference,
          onNoReference: _selectNoReference,
        );
      case 2:
        return _buildPropertyStructure();
      case 3:
        return _buildPropertyComposition(technicalMode: true);
      case 4:
        return _buildGuidedBuildingStage(
          (rooms, _) => StepComparativeRemarks(
            rooms: rooms,
            remarks: _missionData.comparisonRemarks,
            referenceFindings:
                _missionData.referenceReport?.findings ?? const [],
            afterWorks: true,
            onOpenReference: _missionData.referenceReport == null
                ? null
                : _openReference,
          ),
        );
      case 5:
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
          generalities: _missionData.generalities,
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
      _missionData.propertyElements
        ..clear()
        ..addAll(report.snapshot.propertyElements.map((item) => item.copy()));
      _missionData.selectedPropertyElementId =
          _missionData.propertyElements.isEmpty
          ? null
          : _missionData.propertyElements.first.id;
      if (report.zones.isNotEmpty) {
        selectedRooms
          ..clear()
          ..addAll(
            report.zones.map(
              (room) => RoomItem(
                type: room.type,
                name: room.name,
                level: room.level,
                propertyElementId: room.propertyElementId,
              ),
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
      _attachRoomsToDefaultElement(name: 'Bâtiment de référence');
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
        return _buildPropertyStructure();
      case 1:
        return const StepGeneralInfo();
      case 2:
        return const StepKeysMeters();
      case 3:
        return _buildPropertyComposition();
      case 4:
        return StepGeneralities(
          values: _missionData.generalities,
          onChanged: () => setState(() {}),
        );
      case 5:
        return StepVisit(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          rooms: selectedRooms,
          propertyElements: _missionData.propertyElements,
          generalities: _missionData.generalities,
          onBuildingCompletionChanged: _setPropertyElementCompleted,
          controller: _visitController,
          initialSnapshot: _reportSnapshot,
        );
      case 6:
        return StepSignature(
          controller: _signatureController,
          onContinue: _openReportFromSignatures,
          onPostpone: _openReportFromSignatures,
        );
      case 7:
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot: _reportSnapshot,
          initialReportType: _reportType,
          generalities: _missionData.generalities,
          rooms: selectedRooms,
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
        return _buildPropertyStructure();
      case 2:
        return _buildPropertyComposition();
      case 3:
        return _buildGuidedBuildingStage(
          (rooms, _) => StepExitComparison(
            rooms: rooms,
            remarks: _missionData.comparisonRemarks,
          ),
        );
      case 4:
        return StepExitCalculations(
          rooms: selectedRooms,
          remarks: _missionData.comparisonRemarks,
          lines: _missionData.exitDamageLines,
          dismissedSourceIds: _missionData.dismissedExitRemarkIds,
        );
      case 5:
        return StepExitClosure();
      case 6:
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot: _reportSnapshot,
          initialReportType: _reportType,
          generalities: _missionData.generalities,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation() {
    final isMobile = Responsive.isMobile(context);

    final previousButton = OutlinedButton.icon(
      onPressed: _previousStep,
      icon: const Icon(Icons.arrow_back),
      label: const Text('Précédent'),
    );

    Widget? actionButton;
    if (!_isSignatureStep && !_isLastStep) {
      actionButton = FilledButton.icon(
        onPressed: _nextStep,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continuer'),
      );
    } else if (_isExit && _isSignatureStep) {
      actionButton = FilledButton.icon(
        onPressed: _nextStep,
        icon: const Icon(Icons.description_outlined),
        label: const Text('Générer le rapport de sortie'),
      );
    } else if (_isBeforeWorks && _isSignatureStep) {
      actionButton = FilledButton.icon(
        onPressed: _openReportFromSignatures,
        icon: const Icon(Icons.description_outlined),
        label: const Text('Ouvrir le rapport avant travaux'),
      );
    }

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (actionButton != null) SizedBox(height: 48, child: actionButton),
          if (actionButton != null) const SizedBox(height: 10),
          SizedBox(height: 48, child: previousButton),
        ],
      );
    }

    return Row(
      children: [
        previousButton,
        const Spacer(),
        if (actionButton != null) actionButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / _steps.length;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final pagePadding = Responsive.pagePadding(context);
    final contentPadding = EdgeInsets.all(
      Responsive.value<double>(
        context: context,
        mobile: 14,
        tablet: 22,
        desktop: 32,
      ),
    );
    final titleSize = Responsive.value<double>(
      context: context,
      mobile: 24,
      tablet: 29,
      desktop: 34,
    );
    final cardRadius = Responsive.value<double>(
      context: context,
      mobile: 20,
      tablet: 24,
      desktop: 30,
    );

    final stepInformation = Text(
      '${widget.missionType.shortLabel} • Étape ${currentStep + 1} / ${_steps.length}',
      style: TextStyle(
        fontSize: isMobile ? 14 : 16,
        color: Colors.black54,
        fontWeight: FontWeight.w600,
      ),
    );

    final openPreviousReportButton = widget.missionType == MissionType.entry
        ? OutlinedButton.icon(
            onPressed: _openPreviousEntryReport,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(
              isMobile ? 'Ancien rapport' : 'Ouvrir un ancien rapport',
            ),
          )
        : null;

    final discoveryBadge =
        _discoveryAccess != null &&
            !_discoveryAccess!.hasPaidAccessFor(_missionId)
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Mode Découverte : ${selectedRooms.length} / '
              '${_discoveryAccess!.policy.maxFullyDescribedRooms} pièces',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        : null;

    Widget header;
    if (isMobile) {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.missionType.label,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          stepInformation,
          if (openPreviousReportButton != null || discoveryBadge != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (openPreviousReportButton != null) openPreviousReportButton,
                if (discoveryBadge != null) discoveryBadge,
              ],
            ),
          ],
        ],
      );
    } else {
      header = Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 440 : 620),
            child: Text(
              widget.missionType.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              stepInformation,
              if (openPreviousReportButton != null) openPreviousReportButton,
              if (discoveryBadge != null) discoveryBadge,
            ],
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: Padding(
              padding: pagePadding,
              child: Column(
                children: [
                  header,
                  SizedBox(height: isMobile ? 14 : 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: isMobile ? 8 : 10,
                      backgroundColor: Colors.white,
                      color: _isExit ? const Color(0xFFDC2626) : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _steps[currentStep],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: _isExit ? FontWeight.w700 : FontWeight.w600,
                        color: _isExit
                            ? const Color(0xFFB91C1C)
                            : Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: contentPadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
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
                      clipBehavior: Clip.antiAlias,
                      child: _buildStepContent(),
                    ),
                  ),
                  SizedBox(height: isMobile ? 14 : 20),
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
