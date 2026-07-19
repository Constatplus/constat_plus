import '../grammar/grammar_engine.dart';
import '../models/observation.dart';

class SentenceGenerator {
  const SentenceGenerator();

  static const GrammarEngine _grammar = GrammarEngine();

  String generate(Observation observation) {
    final buffer = StringBuffer();

    buffer.write(observation.element.name);

    if (observation.material != null) {
      buffer.write(
        ' ${_grammar.material(
          observation.material!.id,
          observation.material!.name,
        )}',
      );
    }

    if (observation.covering != null) {
      buffer.write(
        ' ${_grammar.covering(
          observation.covering!.id,
          observation.covering!.name,
        )}',
      );
    }

    if (observation.condition != null) {
      buffer.write(
        ', ${_grammar.condition(
          observation.condition!.id,
          observation.condition!.name,
        )}',
      );
    }

    buffer.write('.');

    if (observation.defects.isNotEmpty) {
      buffer.write(' Présence de ');

      for (int i = 0; i < observation.defects.length; i++) {
        if (i > 0) {
          buffer.write(', ');
        }

        buffer.write(observation.defects[i].name.toLowerCase());
      }

      buffer.write('.');
    }

    return buffer.toString();
  }
}