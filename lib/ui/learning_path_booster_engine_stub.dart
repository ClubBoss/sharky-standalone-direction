import 'training_pack_template_v2_stub.dart';

abstract class TagMasteryService {
  Future<Map<String, double>> computeMastery({bool force = false});
}

class LearningPathBoosterEngine {
  LearningPathBoosterEngine({List<TrainingPackTemplateV2>? library})
    : _libraryOverride = library;

  final List<TrainingPackTemplateV2>? _libraryOverride;

  Future<List<TrainingPackTemplateV2>> getBoosterPacks({
    required TagMasteryService mastery,
    required int maxPacks,
  }) async {
    final library = _libraryOverride ?? const <TrainingPackTemplateV2>[];
    final masteryScores = await mastery.computeMastery();
    final entries = <MapEntry<TrainingPackTemplateV2, double>>[];

    for (final pack in library) {
      var weaknessScore = 0.0;
      for (final tag in pack.tags) {
        final score = masteryScores[tag.toLowerCase()];
        if (score != null) weaknessScore += 1 - score;
      }
      if (weaknessScore == 0) continue;
      final rank = (pack.meta['rankScore'] as num?)?.toDouble() ?? 1.0;
      entries.add(MapEntry(pack, weaknessScore * rank));
    }

    entries.sort((a, b) => b.value.compareTo(a.value));
    return [for (final entry in entries.take(maxPacks)) entry.key];
  }
}
