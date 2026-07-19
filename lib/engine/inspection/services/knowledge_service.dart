import '../definition_catalog.dart';
import '../models/element_definition.dart';

class KnowledgeService {
  const KnowledgeService();

  List<ElementDefinition> loadDefinitions() {
    return DefinitionCatalog.all;
  }
}