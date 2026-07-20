import 'technical_finding.dart';

class PresentParty {
  PresentParty({this.name = '', this.quality = '', this.represents = ''});

  String name;
  String quality;
  String represents;
}

class BeforeWorksData {
  DateTime missionDate = DateTime.now();
  DateTime? plannedWorksStartDate;
  String address = '';
  String principal = '';
  String ownerOrOccupant = '';
  String projectOwner = '';
  String contractor = '';
  String architect = '';
  String worksNature = '';
  String generalObservations = '';
  final List<PresentParty> presentParties = <PresentParty>[PresentParty()];
  final List<TechnicalFinding> findings = <TechnicalFinding>[];
}
