import '../before_works/models/before_works_data.dart';
import '../comparison/models/comparison_remark.dart';
import '../exit/models/exit_damage_line.dart';
import '../property_composition/models/property_element.dart';
import '../reference/models/reference_report.dart';
import '../report/models/visit_report_snapshot.dart';

class WizardMissionData {
  final List<PropertyElement> propertyElements = <PropertyElement>[];
  String? selectedPropertyElementId;
  final Set<String> completedPropertyElementIds = <String>{};

  /// Descriptions communes utilisées par la case
  /// « Conforme aux généralités » pendant la visite.
  final Map<String, String> generalities = <String, String>{};

  final BeforeWorksData beforeWorks = BeforeWorksData();
  final List<ComparisonRemark> comparisonRemarks = <ComparisonRemark>[];
  final List<ExitDamageLine> exitDamageLines = <ExitDamageLine>[];
  final Set<String> dismissedExitRemarkIds = <String>{};
  final List<BeforeWorksArea> recollectionAreas = <BeforeWorksArea>[];
  RecollectionReferenceMode recollectionReferenceMode =
      RecollectionReferenceMode.none;
  ReferenceReport? referenceReport;
  VisitReportSnapshot visitSnapshot = const VisitReportSnapshot(
    rooms: <VisitRoomReport>[],
  );
}
