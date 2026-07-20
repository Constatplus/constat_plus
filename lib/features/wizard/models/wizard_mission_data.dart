import '../before_works/models/before_works_data.dart';
import '../comparison/models/comparison_remark.dart';
import '../reference/models/reference_report.dart';
import '../report/models/visit_report_snapshot.dart';

class WizardMissionData {
  final BeforeWorksData beforeWorks = BeforeWorksData();
  final List<ComparisonRemark> comparisonRemarks = <ComparisonRemark>[];
  final List<BeforeWorksArea> recollectionAreas = <BeforeWorksArea>[];
  RecollectionReferenceMode recollectionReferenceMode =
      RecollectionReferenceMode.none;
  ReferenceReport? referenceReport;
  VisitReportSnapshot visitSnapshot = const VisitReportSnapshot(
    rooms: <VisitRoomReport>[],
  );
}
