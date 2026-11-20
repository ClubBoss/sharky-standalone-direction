const act0DailyPracticeLastWorldV1 = 12;

/// A finite short set, separate from the day's activity goal and repair debt.
class Act0DailyPracticeQueueV1 {
  const Act0DailyPracticeQueueV1({
    this.taskIds = const [],
    this.answeredTaskIds = const {},
    this.cleanTaskIds = const {},
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
    if (tasks == null ||
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
      answeredTaskIds: Set.unmodifiable(answered),
      cleanTaskIds: Set.unmodifiable(clean),
    );
  }
}
