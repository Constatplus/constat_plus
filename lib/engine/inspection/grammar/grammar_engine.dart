import '../language/language_pack.dart';

class GrammarEngine {
  const GrammarEngine();

  String material(String id, String fallback) {
    return LanguagePack.materialSentence[id] ?? 'en ${fallback.toLowerCase()}';
  }

  String covering(String id, String fallback) {
    return LanguagePack.coveringSentence[id] ?? fallback;
  }

  String condition(String id, String fallback) {
    return LanguagePack.conditionSentence[id] ?? fallback;
  }
}
