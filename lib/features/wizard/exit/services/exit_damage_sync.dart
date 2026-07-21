import '../../comparison/models/comparison_remark.dart';
import '../models/exit_damage_line.dart';

class ExitDamageSync {
  const ExitDamageSync._();

  static void synchronize({
    required List<ComparisonRemark> remarks,
    required List<ExitDamageLine> lines,
    required Set<String> dismissedSourceIds,
  }) {
    final bySource = <String, ExitDamageLine>{
      for (final line in lines)
        if (line.sourceRemarkId.isNotEmpty) line.sourceRemarkId: line,
    };

    for (final remark in remarks) {
      final text = remark.afterDescription.trim();
      final hasContent = text.isNotEmpty || remark.afterPhotoPaths.isNotEmpty;
      if (!hasContent || dismissedSourceIds.contains(remark.id)) continue;

      final existing = bySource[remark.id];
      if (existing == null) {
        final line = ExitDamageLine(
          id: 'remark-${remark.id}',
          sourceRemarkId: remark.id,
          sourceRemarkText: text,
          room: remark.zone.isEmpty ? null : remark.zone,
          element: remark.post.isEmpty ? null : remark.post,
          remark: text,
          photoPaths: List<String>.from(remark.afterPhotoPaths),
        );
        lines.add(line);
        bySource[remark.id] = line;
        continue;
      }

      existing
        ..room = remark.zone.isEmpty ? existing.room : remark.zone
        ..element = remark.post.isEmpty ? existing.element : remark.post;
      if (existing.remark.trim().isEmpty ||
          existing.remark == existing.sourceRemarkText) {
        existing.remark = text;
      }
      existing.sourceRemarkText = text;
      existing.photoPaths
        ..clear()
        ..addAll(remark.afterPhotoPaths);
    }
  }
}
