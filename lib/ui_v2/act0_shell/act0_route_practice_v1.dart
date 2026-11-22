import 'act0_shell_state_v1.dart';

typedef Act0RoutePracticeRepV1 = ({
  String worldId,
  String lessonId,
  String conceptFamilyId,
  Act0LessonTaskV1 task,
});

typedef Act0RoutePracticeStepV1 = ({String id, int beforeLessonIndex});

/// The final authored lesson is the world boundary. W5 and W8 use ordinary
/// lesson titles there, so scheduling does not depend on a display label.
List<Act0RoutePracticeStepV1> act0RoutePracticeStepsV1(Act0WorldCardV1 world) {
  if (world.worldNumber < 1 ||
      world.worldNumber > 12 ||
      world.lessons.length < 3) {
    return const [];
  }
  final preCheckpoint = world.lessons.length - 1;
  final steps = <Act0RoutePracticeStepV1>[];
  for (var before = 0; before < preCheckpoint;) {
    final left = preCheckpoint - before;
    before += left <= 3 ? left : (left == 4 ? 2 : 3);
    steps.add((
      id: '${world.worldId}/${world.lessons[before].lessonId}',
      beforeLessonIndex: before,
    ));
  }
  return steps;
}

Act0RoutePracticeStepV1? act0RequiredRoutePracticeV1(
  Act0WorldCardV1 world,
  Set<String> pathClosedTaskIds,
  Set<String> satisfiedStepIds,
) {
  final next = world.lessons.indexWhere(
    (lesson) => lesson.courseTaskList.any(
      (task) => !pathClosedTaskIds.contains(task.taskId),
    ),
  );
  return act0RoutePracticeStepsV1(world)
      .where(
        (step) =>
            step.beforeLessonIndex == next &&
            !satisfiedStepIds.contains(step.id),
      )
      .firstOrNull;
}

class Act0RoutePracticeRunV1 {
  const Act0RoutePracticeRunV1({
    required this.stepId,
    required this.taskIds,
    this.answered = 0,
    this.choiceId,
  });

  static const minReps = 4;
  static const maxReps = 6;
  final String stepId;
  final List<String> taskIds;
  final int answered;
  final String? choiceId;

  String get taskId => taskIds[answered];
  bool get isLast => answered + 1 == taskIds.length;

  Act0RoutePracticeRunV1 choose(String id) => Act0RoutePracticeRunV1(
    stepId: stepId,
    taskIds: taskIds,
    answered: answered,
    choiceId: id,
  );

  Act0RoutePracticeRunV1 next() => Act0RoutePracticeRunV1(
    stepId: stepId,
    taskIds: taskIds,
    answered: answered + 1,
  );

  Map<String, Object?> toPayload() => {
    'stepId': stepId,
    'taskIds': taskIds,
    'answered': answered,
    if (choiceId != null) 'choiceId': choiceId,
  };

  static Act0RoutePracticeRunV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final step = raw['stepId'];
    final rawIds = raw['taskIds'];
    final answered = raw['answered'];
    final choice = raw['choiceId'];
    if (step is! String ||
        step.isEmpty ||
        rawIds is! List ||
        rawIds.length < minReps ||
        rawIds.length > maxReps ||
        rawIds.any((item) => item is! String || item.isEmpty) ||
        rawIds.toSet().length != rawIds.length ||
        answered is! int ||
        answered < 0 ||
        answered >= rawIds.length ||
        (choice != null && choice is! String)) {
      return null;
    }
    return Act0RoutePracticeRunV1(
      stepId: step,
      taskIds: List<String>.unmodifiable(rawIds.cast<String>()),
      answered: answered,
      choiceId: choice as String?,
    );
  }
}

String? _practiceHandKey(Act0LessonTaskV1 task) {
  final table = task.runner.table;
  if (table.heroCards.length != 2) return null;
  String card(Act0CardStateV1 card) =>
      '${card.rank.toUpperCase()}${card.suit.toLowerCase()}';
  final hand = table.heroCards.map(card).toList()..sort();
  return '${table.heroSeatId}|${hand.join(',')}|${table.boardCards.map(card).join(',')}';
}

final act0RoutePracticeRepsByIdV1 = _practiceReps();

Map<String, Act0RoutePracticeRepV1> _practiceReps() {
  final courseHands = {
    for (final world in Act0ShellStateV1.sample.worlds)
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          if (_practiceHandKey(task) case final key?) key,
  };
  return Map.unmodifiable({
    for (final entry in act0NewReviewTasksV1)
      if (entry.task.runner.options
                  .where((option) => option.isCorrect)
                  .length ==
              1 &&
          !courseHands.contains(_practiceHandKey(entry.task)))
        entry.task.taskId: entry,
  });
}

Set<String> act0RoutePracticeEligibleLessonIdsV1(
  List<Act0WorldCardV1> worlds,
  Set<String> closedTaskIds, {
  required int throughWorld,
  required bool passedW1RulesCheck,
}) => {
  for (final world in worlds)
    if (world.worldNumber <= throughWorld)
      for (final lesson in world.lessons)
        if (world.worldNumber == 1 && passedW1RulesCheck ||
            lesson.courseTaskList.every(
              (task) => closedTaskIds.contains(task.taskId),
            ))
          lesson.lessonId,
};

List<Act0RoutePracticeRepV1> act0RoutePracticeDeckV1({
  required Set<String> eligibleLessonIds,
  required String preferredWorldId,
  required Set<String> openMistakeLessonIds,
  required Set<String> weakLessonIds,
  required Set<String> seenTaskIds,
  Set<String> openMistakeFamilies = const {},
}) {
  int priority(Act0RoutePracticeRepV1 entry) {
    if (openMistakeFamilies.contains(entry.conceptFamilyId) &&
        openMistakeLessonIds.contains(entry.lessonId)) {
      return 0;
    }
    if (openMistakeLessonIds.contains(entry.lessonId)) return 1;
    if (weakLessonIds.contains(entry.lessonId)) return 2;
    return entry.worldId == preferredWorldId ? 3 : 4;
  }

  final candidates = act0RoutePracticeRepsByIdV1.values
      .where((entry) => eligibleLessonIds.contains(entry.lessonId))
      .toList();
  final indexed = candidates.indexed.toList();
  indexed.sort((a, b) {
    final aPriority = priority(a.$2);
    final bPriority = priority(b.$2);
    final byPriority = aPriority.compareTo(bPriority);
    if (byPriority != 0 && (aPriority < 3 || bPriority < 3)) return byPriority;
    final byExposure = (seenTaskIds.contains(a.$2.task.taskId) ? 1 : 0)
        .compareTo(seenTaskIds.contains(b.$2.task.taskId) ? 1 : 0);
    if (byExposure != 0) return byExposure;
    return byPriority == 0 ? a.$1.compareTo(b.$1) : byPriority;
  });
  final hands = <String>{};
  return indexed
      .where((entry) {
        final key = _practiceHandKey(entry.$2.task);
        return key == null || hands.add(key);
      })
      .take(Act0RoutePracticeRunV1.minReps)
      .map((entry) => entry.$2)
      .toList(growable: false);
}

class Act0RoutePracticeProgressV1 {
  const Act0RoutePracticeProgressV1({
    this.finished = const {},
    this.waived = const {},
    this.seen = const {},
    this.run,
    this.inRunner = false,
  });

  final Set<String> finished;
  final Set<String> waived;
  final Set<String> seen;
  final Act0RoutePracticeRunV1? run;
  final bool inRunner;

  Act0RoutePracticeProgressV1 update(
    Act0RoutePracticeRunV1? nextRun, {
    required bool inRunner,
    String? finishedStepId,
    String? seenTaskId,
  }) => Act0RoutePracticeProgressV1(
    finished: {...finished, if (finishedStepId != null) finishedStepId},
    waived: waived,
    seen: {...seen, if (seenTaskId != null) seenTaskId},
    run: nextRun,
    inRunner: inRunner,
  );

  Map<String, Object?> toPayload() => {
    'finished': finished.toList()..sort(),
    'waived': waived.toList()..sort(),
    'seen': seen.toList()..sort(),
    if (run != null) 'run': run!.toPayload(),
    if (inRunner) 'inRunner': true,
  };

  static Act0RoutePracticeProgressV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    Set<String> ids(Object? value) =>
        value is List ? value.whereType<String>().toSet() : {};
    final run = Act0RoutePracticeRunV1.tryParse(raw['run']);
    final validRun =
        run != null &&
            run.taskIds.every(act0RoutePracticeRepsByIdV1.containsKey) &&
            (run.choiceId == null ||
                act0RoutePracticeRepsByIdV1[run.taskId]!.task.runner.options
                    .any((option) => option.id == run.choiceId))
        ? run
        : null;
    return Act0RoutePracticeProgressV1(
      finished: ids(raw['finished']),
      waived: ids(raw['waived']),
      seen: ids(raw['seen']),
      run: validRun,
      inRunner: raw['inRunner'] == true && validRun != null,
    );
  }

  factory Act0RoutePracticeProgressV1.fromLegacy(
    List<Act0WorldCardV1> worlds,
    Set<String> pathClosedTaskIds, {
    String? resumedLessonId,
  }) => Act0RoutePracticeProgressV1(
    waived: {
      for (final world in worlds)
        for (final step in act0RoutePracticeStepsV1(world))
          if (world.lessons
                  .take(step.beforeLessonIndex)
                  .every(
                    (lesson) => lesson.courseTaskList.every(
                      (task) => pathClosedTaskIds.contains(task.taskId),
                    ),
                  ) ||
              world.lessons
                  .skip(step.beforeLessonIndex)
                  .any(
                    (lesson) =>
                        lesson.lessonId == resumedLessonId ||
                        lesson.courseTaskList.any(
                          (task) => pathClosedTaskIds.contains(task.taskId),
                        ),
                  ))
            step.id,
    },
  );
}
