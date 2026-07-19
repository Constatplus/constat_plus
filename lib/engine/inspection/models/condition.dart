import 'package:flutter/foundation.dart';

import 'condition_level.dart';

@immutable
class Condition {
  final ConditionLevel level;

  final String id;

  final String name;

  const Condition({
    required this.level,
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      other is Condition &&
      other.level == level;

  @override
  int get hashCode => level.hashCode;
}