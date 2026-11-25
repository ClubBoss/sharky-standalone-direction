/// A launchable drill; a repair must retain its original Review source.
typedef Act0WarmupDrillV1 = ({
  String worldId,
  String lessonId,
  String taskId,
  String? repairSourceTaskId,
  List<String> skills,
});

typedef Act0WarmupMissV1 = ({
  DateTime? at,
  List<String> skills,
  Act0WarmupDrillV1? repair,
});

enum Act0WarmupEmptyReasonV1 { noMisses, noLaunchableDrills }

typedef Act0WarmupSelectionV1 = ({
  List<Act0WarmupDrillV1> drills,
  Act0WarmupEmptyReasonV1? emptyReason,
});

/// Uses only real open misses and the caller's eligible practice pool.
/// Untimestamped legacy misses sort after dated misses.
Act0WarmupSelectionV1 selectAct0WarmupV1({
  required List<Act0WarmupMissV1> misses,
  required List<Act0WarmupDrillV1> practicePool,
}) {
  if (misses.isEmpty) {
    return (drills: const [], emptyReason: Act0WarmupEmptyReasonV1.noMisses);
  }
  final sorted = misses.indexed.toList()
    ..sort((a, b) {
      final at = a.$2.at;
      final bt = b.$2.at;
      final order = at == null
          ? (bt == null ? 0 : 1)
          : (bt == null ? -1 : bt.compareTo(at));
      return order == 0 ? a.$1.compareTo(b.$1) : order;
    });
  final skills = <String, int>{};
  final result = <Act0WarmupDrillV1>[];
  final seen = <String>{};
  void add(Act0WarmupDrillV1 drill) {
    if (result.length < 5 && seen.add(drill.taskId)) result.add(drill);
  }

  for (final (_, miss) in sorted) {
    if (miss.repair case final repair?) add(repair);
    for (final skill in miss.skills.toSet()) {
      skills.update(skill, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  final ranked = skills.keys.toList()
    ..sort((a, b) {
      final count = skills[b]!.compareTo(skills[a]!);
      return count == 0 ? a.compareTo(b) : count;
    });
  for (final skill in ranked) {
    for (final drill in practicePool) {
      if (drill.skills.contains(skill)) add(drill);
    }
  }
  return (
    drills: List.unmodifiable(result),
    emptyReason: result.isEmpty
        ? Act0WarmupEmptyReasonV1.noLaunchableDrills
        : null,
  );
}
