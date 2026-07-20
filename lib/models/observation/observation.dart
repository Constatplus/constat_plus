import '../shared/enums.dart';

class Observation {
  final String text;
  final ObservationSeverity severity;

  const Observation({this.text = '', this.severity = ObservationSeverity.info});

  Observation copyWith({String? text, ObservationSeverity? severity}) {
    return Observation(
      text: text ?? this.text,
      severity: severity ?? this.severity,
    );
  }
}
