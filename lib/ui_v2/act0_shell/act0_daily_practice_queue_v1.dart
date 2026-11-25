import 'act0_curriculum_pilot_v1.dart';
import 'act0_daily_practice_coverage_v1.dart';

const act0DailyPracticeLastWorldV1 = act0LastCurriculumWorldV1;

/// A finite short set, separate from the day's activity goal and repair debt.
class Act0DailyPracticeQueueV1 {
  const Act0DailyPracticeQueueV1({
    this.taskIds = const [],
    this.answeredTaskIds = const {},
    this.cleanTaskIds = const {},
    this.poolStatus = Act0DailyPracticeExhaustionStatusV1.fresh,
  });

  factory Act0DailyPracticeQueueV1.start(
    Iterable<String> eligible, {
    Set<String> practicedToday = const {},
  }) {
    final ids = eligible.toSet().toList();
    return Act0DailyPracticeQueueV1(
      taskIds: List.unmodifiable(
        [
          ...ids.where((id) => !practicedToday.contains(id)),
          ...ids.where(practicedToday.contains),
        ].take(3),
      ),
    );
  }

  /// Build the next set without changing the usual ordering of fresh spots.
  factory Act0DailyPracticeQueueV1.startCovered(
    Map<String, Iterable<String>> pool, {
    required Map<String, DateTime> recentHistory,
    required DateTime todayStartedAt,
    required Set<String> practicedToday,
  }) {
    final history = Map<String, DateTime>.of(recentHistory);
    // Legacy snapshots and the bounded journal may lack an exact timestamp
    // for a spot known to have been practiced today.
    for (final id in practicedToday) {
      if (history[id]?.isBefore(todayStartedAt) ?? true) {
        history[id] = todayStartedAt;
      }
    }
    final exhaustion = exhaustionV1(
      pool.keys,
      history,
      todayStartedAt: todayStartedAt,
    );
    if (exhaustion.status == Act0DailyPracticeExhaustionStatusV1.exhausted) {
      return Act0DailyPracticeQueueV1(
        taskIds: List.unmodifiable(exhaustion.recommendedDrillIds),
        poolStatus: exhaustion.status,
      );
    }
    final fresh = pool.keys.where((id) {
      return history[id]?.isBefore(todayStartedAt) ?? true;
    }).toList();
    if (fresh.length >= 3 || fresh.length == pool.length) {
      if (exhaustion.status == Act0DailyPracticeExhaustionStatusV1.fresh) {
        return Act0DailyPracticeQueueV1.start(fresh);
      }
      return Act0DailyPracticeQueueV1(
        taskIds: List.unmodifiable(exhaustion.recommendedDrillIds),
        poolStatus: exhaustion.status,
      );
    }

    // Keep the fresh prefix, then cover skills absent from that prefix.
    // Within equally useful candidates use B60's oldest-seen ordering.
    final selected = [...fresh];
    final keySkills = pool.values.expand((skills) => skills).toSet();
    while (selected.length < 3 && selected.length < pool.length) {
      final coverage = dailyPracticeCoverageV1(
        {for (final id in selected) id: pool[id]!},
        history,
        keySkills,
      );
      final candidates = pool.keys.where((id) => !selected.contains(id));
      int missingSkills(String id) => pool[id]!.toSet().where((skill) {
        return coverage[skill]?.status ==
            Act0DailyPracticeCoverageStatusV1.missing;
      }).length;
      final bestCoverage = candidates
          .map(missingSkills)
          .reduce((left, right) => left > right ? left : right);
      final fill = exhaustionV1(
        candidates.where((id) => missingSkills(id) == bestCoverage),
        history,
        todayStartedAt: todayStartedAt,
      );
      selected.add(fill.recommendedDrillIds.first);
    }
    return Act0DailyPracticeQueueV1(
      taskIds: List.unmodifiable(selected),
      poolStatus: Act0DailyPracticeExhaustionStatusV1.recycling,
    );
  }

  final Act0DailyPracticeExhaustionStatusV1 poolStatus;
  bool get includesRepeats =>
      poolStatus != Act0DailyPracticeExhaustionStatusV1.fresh;
  bool get isExhausted =>
      poolStatus == Act0DailyPracticeExhaustionStatusV1.exhausted;

  final List<String> taskIds;
  final Set<String> answeredTaskIds;
  final Set<String> cleanTaskIds;

  String? get nextTaskId {
    for (final id in taskIds) {
      if (!answeredTaskIds.contains(id)) return id;
    }
    return null;
  }

  bool isValidFor(Set<String> eligible) =>
      taskIds.isNotEmpty && taskIds.every(eligible.contains);

  Act0DailyPracticeQueueV1 answer(
    String taskId, {
    required bool independentCorrect,
  }) {
    if (taskId != nextTaskId) return this;
    return Act0DailyPracticeQueueV1(
      taskIds: taskIds,
      poolStatus: poolStatus,
      answeredTaskIds: Set.unmodifiable({...answeredTaskIds, taskId}),
      cleanTaskIds: Set.unmodifiable({
        ...cleanTaskIds,
        if (independentCorrect) taskId,
      }),
    );
  }

  Map<String, Object?> toPayload() => {
    'taskIds': taskIds,
    'answeredTaskIds': answeredTaskIds.toList(),
    'cleanTaskIds': cleanTaskIds.toList(),
    if (includesRepeats) 'poolStatus': poolStatus.name,
  };

  static Act0DailyPracticeQueueV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    List<String>? ids(Object? value) {
      if (value is! List ||
          value.any((id) => id is! String || id.trim().isEmpty))
        return null;
      final result = value.cast<String>();
      return result.length == result.toSet().length ? result : null;
    }

    final tasks = ids(raw['taskIds']);
    final answered = ids(raw['answeredTaskIds']);
    final clean = ids(raw['cleanTaskIds']);
    final status = raw['poolStatus'];
    final poolStatus = status == null
        ? Act0DailyPracticeExhaustionStatusV1.fresh
        : Act0DailyPracticeExhaustionStatusV1.values
              .where((value) => value.name == status)
              .firstOrNull;
    if (poolStatus == null ||
        tasks == null ||
        answered == null ||
        clean == null ||
        tasks.length > 3 ||
        answered.length > tasks.length ||
        !answered.toSet().containsAll(clean) ||
        !tasks.toSet().containsAll(answered) ||
        !tasks.take(answered.length).toSet().containsAll(answered))
      return null;
    return Act0DailyPracticeQueueV1(
      taskIds: List.unmodifiable(tasks),
      poolStatus: poolStatus,
      answeredTaskIds: Set.unmodifiable(answered),
      cleanTaskIds: Set.unmodifiable(clean),
    );
  }
}
