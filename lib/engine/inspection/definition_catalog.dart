import 'definitions/wall_definition.dart';
import 'models/element_definition.dart';

abstract final class DefinitionCatalog {
  const DefinitionCatalog._();

  static const all = <ElementDefinition>[wallDefinition];
}
