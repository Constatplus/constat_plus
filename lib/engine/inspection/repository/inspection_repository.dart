import '../models/element_definition.dart';
import '../models/inspection_element.dart';
import '../services/knowledge_service.dart';

class InspectionRepository {
  const InspectionRepository();

  final KnowledgeService _knowledge = const KnowledgeService();

  List<ElementDefinition> getAllDefinitions() {
    return _knowledge.loadDefinitions();
  }

  ElementDefinition? getDefinition(InspectionElement element) {
    try {
      return _knowledge.loadDefinitions().firstWhere(
        (definition) => definition.element == element,
      );
    } catch (_) {
      return null;
    }
  }
}
