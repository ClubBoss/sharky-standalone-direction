import '../core/training/engine/training_type_engine.dart';
import '../models/v2/training_pack_template.dart';
import 'training_pack_stats_service.dart';

class TrainingTypeStatsService {
  TrainingTypeStatsService();

  Future<Map<TrainingType, double>> calculateCompletionPercent(
    List<TrainingPackTemplate> packs,
  ) async {
    final totals = <TrainingType, int>{};
    final completed = <TrainingType, int>{};

    for (final pack in packs) {
      final type = _detectTrainingType(pack);
      final total = pack.spots.isNotEmpty ? pack.spots.length : pack.spotCount;
      if (total == 0) continue;
      totals.update(type, (v) => v + total, ifAbsent: () => total);
      final done = await TrainingPackStatsService.getHandsCompleted(pack);
      completed.update(type, (v) => v + done, ifAbsent: () => done);
    }

    final result = <TrainingType, double>{};
    for (final type in TrainingType.values) {
      final tot = totals[type] ?? 0;
      final done = completed[type] ?? 0;
      result[type] = tot > 0 ? (done * 100 / tot).clamp(0, 100).toDouble() : 0;
    }
    return result;
  }

  TrainingType _detectTrainingType(TrainingPackTemplate pack) {
    final tags = {
      ...pack.tags.map((e) => e.toLowerCase()),
      if (pack.meta['tags'] is List)
        ...List.from(
          pack.meta['tags'] as Iterable<dynamic>,
        ).map((e) => e.toString().toLowerCase()),
    };
    if (tags.contains('quiz')) return TrainingType.quiz;
    if (tags.contains('bounty')) return TrainingType.bounty;
    if (tags.contains('icm')) return TrainingType.icm;
    if (tags.contains('jam') || tags.contains('jamdecision')) {
      return TrainingType.postflopJamDecision;
    }
    final hasPostflop = pack.spots.any((s) {
      if (s.hand.board.isNotEmpty) return true;
      return s.hand.actions.entries.any((e) => e.key > 0 && e.value.isNotEmpty);
    });
    if (hasPostflop) return TrainingType.postflop;
    final allPfNoActions =
        pack.spots.isNotEmpty &&
        pack.spots.every((s) {
          final noActions = s.hand.actions.values.every((l) => l.isEmpty);
          final preflopOnly =
              s.hand.board.isEmpty && s.hand.actions.keys.every((k) => k == 0);
          return preflopOnly && noActions;
        });
    if (allPfNoActions) return TrainingType.pushFold;
    return TrainingType.custom;
  }
}
