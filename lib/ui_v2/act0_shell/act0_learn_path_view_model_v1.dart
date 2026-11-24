import 'act0_shell_state_v1.dart';

/// Map selection, earned progress and journey visibility for the Learn shell.
class Act0LearnPathViewModelV1 {
  Act0LearnPathViewModelV1({
    required this.worlds,
    required this.lessons,
    required String selectedWorldId,
    required String selectedLessonId,
    required String? detailLessonId,
    required String? worldDetailId,
    required Act0LessonCardV1? requiredPractice,
    int requiredPracticeAnswered = 0,
    required Set<String> pathClosedTaskIds,
    required Set<String> completedTaskIds,
    required bool showFullPath,
    required this.catalogFlag,
  }) {
    detailLesson = detailLessonId == null
        ? null
        : lessons.cast<Act0LessonCardV1?>().firstWhere(
            (lesson) => lesson?.lessonId == detailLessonId,
            orElse: () => null,
          );
    detailWorld = worldDetailId == null
        ? null
        : worlds.firstWhere(
            (world) => world.worldId == worldDetailId,
            orElse: () => worlds.first,
          );
    selectedWorld = worlds.firstWhere(
      (world) => world.worldId == selectedWorldId,
      orElse: () => worlds.first,
    );
    currentMissionLesson =
        requiredPractice ??
        lessons.firstWhere(
          (lesson) => lesson.state == Act0LessonStateV1.current,
          orElse: () => lessons.firstWhere(
            (lesson) => lesson.lessonId == selectedLessonId,
            orElse: () => lessons.first,
          ),
        );
    currentMissionTask = requiredPractice == null
        ? act0FirstIncompleteLessonTaskV1(
            currentMissionLesson,
            pathClosedTaskIds,
          )
        : requiredPractice.courseTaskList[requiredPracticeAnswered];
    currentMissionStepIndex = act0LessonStepIndexV1(
      currentMissionLesson,
      currentMissionTask.taskId,
    );
    firstRun =
        currentMissionLesson.lessonId == 'what_poker_is' &&
        currentMissionStepIndex == 1 &&
        detailLessonId == null;
    // Routing may be closed by Placement; the visible progress bar is earned
    // completion only. Keep lesson.state for existing navigation/eligibility.
    progressFraction = lessons.isEmpty
        ? 0.0
        : lessons
                  .where(
                    (lesson) =>
                        lesson.courseTaskList.isNotEmpty &&
                        lesson.courseTaskList.every(
                          (task) => completedTaskIds.contains(task.taskId),
                        ),
                  )
                  .length /
              lessons.length;
    journeyLessonIndexes =
        _missionFirstJourneyPreviewIndexesV5(
              lessons,
              showFullPath: showFullPath,
            )
            .where(
              (index) =>
                  lessons[index].lessonId != currentMissionLesson.lessonId,
            )
            .toList();
    deferredLockedCount = _hiddenLockedLessonCountV5(
      lessons,
      journeyLessonIndexes,
    );
  }

  final List<Act0WorldCardV1> worlds;
  final List<Act0LessonCardV1> lessons;
  final bool catalogFlag;
  late final Act0LessonCardV1? detailLesson;
  late final Act0WorldCardV1? detailWorld;
  late final Act0WorldCardV1 selectedWorld;
  late final Act0LessonCardV1 currentMissionLesson;
  late final Act0LessonTaskV1 currentMissionTask;
  late final int currentMissionStepIndex;
  late final bool firstRun;
  late final double progressFraction;
  late final List<int> journeyLessonIndexes;
  late final int deferredLockedCount;

  List<Act0WorldCardV1> get numberedWorlds =>
      worlds.where((world) => world.worldId != act0LiveRoomModuleIdV1).toList();

  Act0WorldCardV1 get currentWorld => numberedWorlds.firstWhere(
    (world) => world.status == Act0WorldStateV1.current,
    orElse: () => selectedWorld.worldId == act0LiveRoomModuleIdV1
        ? numberedWorlds.last
        : selectedWorld,
  );
  Act0WorldCardV1? get nextWorld =>
      _nextWorldAfterV1(numberedWorlds, currentWorld);

  bool get worldDone => selectedWorld.status == Act0WorldStateV1.completed;
  bool get allDone =>
      worlds.isNotEmpty &&
      numberedWorlds.every(
        (world) =>
            world.status == Act0WorldStateV1.completed ||
            world.status == Act0WorldStateV1.passedByRulesCheck,
      );
  bool get inProgress => !firstRun && !worldDone && !allDone;
}

List<int> _missionFirstJourneyPreviewIndexesV5(
  List<Act0LessonCardV1> lessons, {
  required bool showFullPath,
}) {
  if (showFullPath) {
    return List<int>.generate(lessons.length, (index) => index);
  }
  final currentIndex = lessons.indexWhere(
    (lesson) => lesson.state == Act0LessonStateV1.current,
  );
  if (currentIndex < 0) {
    return _focusedJourneyLessonIndexesV1(lessons);
  }
  final indexes = <int>{};
  final completedIndexes = <int>[
    for (var i = 0; i < lessons.length; i++)
      if (lessons[i].state == Act0LessonStateV1.completed) i,
  ];
  if (completedIndexes.isNotEmpty) {
    indexes.add(completedIndexes.first);
  }
  if (completedIndexes.length > 1) {
    indexes.add(completedIndexes.last);
  }
  indexes.add(currentIndex);
  final nextIndex = currentIndex + 1;
  if (nextIndex < lessons.length) {
    indexes.add(nextIndex);
  }
  return indexes.toList()..sort();
}

int _hiddenLockedLessonCountV5(
  List<Act0LessonCardV1> lessons,
  List<int> visibleIndexes,
) {
  final visible = visibleIndexes.toSet();
  return <int>[
    for (var i = 0; i < lessons.length; i++)
      if (!visible.contains(i) && lessons[i].state == Act0LessonStateV1.locked)
        i,
  ].length;
}

List<int> _focusedJourneyLessonIndexesV1(List<Act0LessonCardV1> lessons) {
  return <int>[
    for (var i = 0; i < lessons.length; i++)
      if (_shouldShowJourneyLessonInWindowV1(lessons, i)) i,
  ];
}

bool _shouldShowJourneyLessonInWindowV1(
  List<Act0LessonCardV1> lessons,
  int index,
) {
  final lesson = lessons[index];
  if (lesson.state != Act0LessonStateV1.locked) {
    return true;
  }
  if (lesson.primaryCtaLabel == 'Clear weak spots') {
    return true;
  }
  return index > 0 && lessons[index - 1].state == Act0LessonStateV1.current;
}

Act0WorldCardV1? _nextWorldAfterV1(
  List<Act0WorldCardV1> worlds,
  Act0WorldCardV1 currentWorld,
) {
  for (final world in worlds) {
    if (world.worldNumber == currentWorld.worldNumber + 1) {
      return world;
    }
  }
  return null;
}
