from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected 1 occurrence, found {count}")
    return text.replace(old, new, 1)


wizard_path = Path('lib/features/wizard/wizard_page.dart')
wizard = wizard_path.read_text(encoding='utf-8')

wizard = replace_once(
    wizard,
    "import 'comparison/step_comparative_remarks.dart';\n",
    "import 'comparison/step_comparative_remarks.dart';\nimport 'generalities/step_generalities.dart';\n",
    'wizard import',
)

wizard = replace_once(
    wizard,
    "  final StepVisitController _visitController = StepVisitController();\n",
    "  final StepVisitController _visitController = StepVisitController();\n  final StepVisitController _beforeWorksDescriptionController =\n      StepVisitController();\n",
    'before works controller',
)

wizard = replace_once(
    wizard,
    "          'Composition du bien',\n          \"Visite d'entrée\",\n          'Signatures',\n          \"Rapport d'entrée\",",
    "          'Composition du bien',\n          'Généralités',\n          \"Visite d'entrée\",\n          'Signatures',\n          \"Rapport d'entrée\",",
    'entry steps',
)

wizard = replace_once(
    wizard,
    "          'Composition du constat',\n          'Visite avant travaux',\n          'Photos',\n          'Signatures',\n          'Rapport avant travaux',",
    "          'Composition du constat',\n          'Généralités',\n          'Description des pièces',\n          'Constats techniques',\n          'Photos',\n          'Signatures',\n          'Rapport avant travaux',",
    'before works steps',
)

wizard = replace_once(
    wizard,
    "  int get _visitStepIndex => _isExit\n      ? 3\n      : _isBeforeWorks\n      ? 3\n      : _isAfterWorks\n      ? 4\n      : 4;",
    "  int get _visitStepIndex => _isExit\n      ? 3\n      : _isBeforeWorks\n      ? 4\n      : _isAfterWorks\n      ? 4\n      : 5;",
    'visit index',
)

wizard = replace_once(
    wizard,
    "  int get _signatureStepIndex => _isExit\n      ? 5\n      : _isBeforeWorks\n      ? 5\n      : _isAfterWorks\n      ? -1\n      : 5;",
    "  int get _signatureStepIndex => _isExit\n      ? 5\n      : _isBeforeWorks\n      ? 7\n      : _isAfterWorks\n      ? -1\n      : 6;",
    'signature index',
)

wizard = replace_once(
    wizard,
    "    if (currentStep == _visitStepIndex &&\n        !_isExit &&\n        !_isBeforeWorks &&\n        !_isAfterWorks) {\n      _reportSnapshot = _visitController.read();\n      _missionData.visitSnapshot = _reportSnapshot;\n    }",
    "    if (currentStep == _visitStepIndex && !_isExit && !_isAfterWorks) {\n      _reportSnapshot = _isBeforeWorks\n          ? _beforeWorksDescriptionController.read()\n          : _visitController.read();\n      _missionData.visitSnapshot = _reportSnapshot;\n    }",
    'snapshot capture',
)

old_before = """      case 2:
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
        );"""

new_before = """      case 2:
        return _buildPropertyComposition(technicalMode: true);
      case 3:
        return StepGeneralities(
          values: _missionData.generalities,
          includeFurniture: false,
          technicalMode: true,
          onChanged: () => setState(() {}),
        );
      case 4:
        return StepVisit(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          rooms: selectedRooms,
          propertyElements: _missionData.propertyElements,
          onBuildingCompletionChanged: _setPropertyElementCompleted,
          controller: _beforeWorksDescriptionController,
          initialSnapshot: _reportSnapshot,
          includeFurniture: false,
          generalities: _missionData.generalities,
        );
      case 5:
        return _buildGuidedBuildingStage(
          (_, elementId) => StepBeforeWorksVisit(
            rooms: selectedRooms,
            data: _missionData.beforeWorks,
            propertyElements: _missionData.propertyElements,
            activePropertyElementId: elementId,
            onChanged: () => setState(() {}),
          ),
        );
      case 6:
        return StepBeforeWorksPhotos(
          findings: _missionData.beforeWorks.findings,
          areas: _missionData.beforeWorks.areas,
        );
      case 7:
        return StepSignature(
          controller: _signatureController,
          onContinue: _openReportFromSignatures,
          onPostpone: _openReportFromSignatures,
        );
      case 8:
        return StepReport(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          snapshot: _missionData.visitSnapshot,
          initialReportType: _reportType,
          rooms: selectedRooms,
          beforeWorksData: _missionData.beforeWorks,
        );"""

wizard = replace_once(wizard, old_before, new_before, 'before works switch')

old_standard = """      case 3:
        return _buildPropertyComposition();
      case 4:
        return StepVisit(
          missionId: _missionId,
          missionType: widget.missionType.databaseValue,
          rooms: selectedRooms,
          propertyElements: _missionData.propertyElements,
          onBuildingCompletionChanged: _setPropertyElementCompleted,
          controller: _visitController,
          initialSnapshot: _reportSnapshot,
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
          rooms: selectedRooms,
        );"""

new_standard = """      case 3:
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
          onBuildingCompletionChanged: _setPropertyElementCompleted,
          controller: _visitController,
          initialSnapshot: _reportSnapshot,
          generalities: _missionData.generalities,
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
          rooms: selectedRooms,
        );"""

wizard = replace_once(wizard, old_standard, new_standard, 'standard switch')
wizard_path.write_text(wizard, encoding='utf-8')

visit_path = Path('lib/features/wizard/step_visit.dart')
visit = visit_path.read_text(encoding='utf-8')

visit = replace_once(
    visit,
    "  final VisitReportSnapshot initialSnapshot;\n  final void Function(String elementId, bool completed)?",
    "  final VisitReportSnapshot initialSnapshot;\n  final bool includeFurniture;\n  final Map<String, String> generalities;\n  final void Function(String elementId, bool completed)?",
    'visit fields',
)

visit = replace_once(
    visit,
    "    this.onBuildingCompletionChanged,\n    this.initialSnapshot = const VisitReportSnapshot(\n      rooms: <VisitRoomReport>[],\n    ),",
    "    this.onBuildingCompletionChanged,\n    this.initialSnapshot = const VisitReportSnapshot(\n      rooms: <VisitRoomReport>[],\n    ),\n    this.includeFurniture = true,\n    this.generalities = const <String, String>{},",
    'visit constructor',
)

visit = replace_once(
    visit,
    "  void initState() {\n    super.initState();\n\n    if (widget.propertyElements.isNotEmpty) {",
    "  void initState() {\n    super.initState();\n\n    if (!widget.includeFurniture) {\n      _sections.remove('Mobilier');\n    }\n\n    if (widget.propertyElements.isNotEmpty) {",
    'visit furniture removal',
)

visit = visit.replace(
    "value: _conformToGeneralities[key] ?? false,",
    "value: _conformToGeneralities[key] ?? false,",
)

# Make the generality text visible immediately when the checkbox is used.
needle = "_conformToGeneralities[key] = value ?? false;"
if needle in visit and "widget.generalities" not in visit[visit.index(needle):visit.index(needle) + 500]:
    visit = replace_once(
        visit,
        needle,
        "_conformToGeneralities[key] = value ?? false;\n"
        "                            if (value == true) {\n"
        "                              final sectionName = _sections[_selectedSectionIndex];\n"
        "                              final generalityKey = sectionName.startsWith('Mur')\n"
        "                                  ? 'Murs'\n"
        "                                  : sectionName;\n"
        "                              final generality =\n"
        "                                  widget.generalities[generalityKey]?.trim();\n"
        "                              if (generality != null && generality.isNotEmpty) {\n"
        "                                _controllerFor(\n"
        "                                  _selectedRoomIndex,\n"
        "                                  _selectedSectionIndex,\n"
        "                                ).text = generality;\n"
        "                              }\n"
        "                            }",
        'generalities checkbox',
    )

visit_path.write_text(visit, encoding='utf-8')
