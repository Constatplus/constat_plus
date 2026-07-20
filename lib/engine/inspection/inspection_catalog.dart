import 'models/condition.dart';
import 'models/condition_level.dart';

abstract final class ConditionCatalog {
  const ConditionCatalog._();

  static const perfect = Condition(
    level: ConditionLevel.perfect,
    id: 'perfect',
    name: 'Excellent état',
  );

  static const good = Condition(
    level: ConditionLevel.good,
    id: 'good',
    name: 'Bon état',
  );

  static const fair = Condition(
    level: ConditionLevel.fair,
    id: 'fair',
    name: 'État d’usage',
  );

  static const poor = Condition(
    level: ConditionLevel.poor,
    id: 'poor',
    name: 'Mauvais état',
  );

  static const all = <Condition>[perfect, good, fair, poor];
}
