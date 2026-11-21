import 'act0_prechoice_answer_cue_policy_v1.dart';
import 'act0_shell_state_v1.dart';

// Learning-path unlock rules, kept free of widget state so they can be checked
// across the whole catalog. A world opens when the previous world is complete;
// inside an open world only the first incomplete lesson is current, completed
// lessons can be replayed and every later lesson stays locked.

/// Projects authored worlds onto learner progress.
///
/// [pathClosedTaskIds] (earned plus Placement-closed tasks) drives routing and
/// lesson state. [earnedTaskIds] only feeds the learner-facing
/// "X of N lessons complete" count, so a Placement-cleared lesson is never
/// presented as completed work.
List<Act0WorldCardV1> act0ProgressWorldsV1(
  List<Act0WorldCardV1> authoredWorlds, {
  required Set<String> pathClosedTaskIds,
  required Set<String> earnedTaskIds,
  bool passedW1RulesCheck = false,
  Set<String> worldsWithOpenMistakes = const <String>{},
}) {
  var previousWorldComplete = true;
  var lockedWorldSeen = false;
  final worlds = <Act0WorldCardV1>[];
  for (final world in authoredWorlds) {
    final progressed = _progressWorldV1(
      world,
      previousWorldComplete,
      isImmediateLockedWorld: !previousWorldComplete && !lockedWorldSeen,
      completedTaskIds: pathClosedTaskIds,
      earnedTaskIds: earnedTaskIds,
      passedByRulesCheck: passedW1RulesCheck && world.worldId == 'world_1',
      worldsWithOpenMistakes: worldsWithOpenMistakes,
    );
    worlds.add(progressed);
    if (progressed.status == Act0WorldStateV1.locked) {
      lockedWorldSeen = true;
    }
    previousWorldComplete =
        progressed.status == Act0WorldStateV1.completed ||
        progressed.status == Act0WorldStateV1.passedByRulesCheck;
  }
  return worlds;
}

bool act0LessonIsWorldCheckpointV1(
  Act0WorldCardV1 world,
  Act0LessonCardV1 lesson,
) =>
    world.lessons.length > 1 &&
    lesson.lessonId == world.lessons.last.lessonId &&
    (lesson.lessonId.contains('checkpoint') ||
        lesson.phaseLabel.toLowerCase().contains('checkpoint') ||
        lesson.title.toLowerCase().contains('checkpoint'));

bool act0LessonCompleteWithTaskIdsV1(
  Act0LessonCardV1 lesson,
  Set<String> completedTaskIds,
) {
  return lesson.courseTaskList.every(
    (task) => completedTaskIds.contains(task.taskId),
  );
}

Act0WorldCardV1 _progressWorldV1(
  Act0WorldCardV1 world,
  bool previousWorldComplete, {
  required bool isImmediateLockedWorld,
  required Set<String> completedTaskIds,
  required Set<String> earnedTaskIds,
  required bool passedByRulesCheck,
  required Set<String> worldsWithOpenMistakes,
}) {
  final progressTaskIds = completedTaskIds;
  if (world.lessons.isEmpty) {
    return world.copyWith(
      status: previousWorldComplete
          ? Act0WorldStateV1.current
          : Act0WorldStateV1.locked,
      isSelectable: previousWorldComplete,
      isLocked: !previousWorldComplete,
    );
  }
  final allComplete = world.lessons.every(
    (lesson) => act0LessonCompleteWithTaskIdsV1(lesson, progressTaskIds),
  );
  final available = previousWorldComplete;
  final hasOpenMistakes = worldsWithOpenMistakes.contains(world.worldId);
  final currentLessonId = available && !allComplete && !passedByRulesCheck
      ? world.lessons.firstWhere((lesson) {
          if (act0LessonCompleteWithTaskIdsV1(lesson, progressTaskIds)) {
            return false;
          }
          if (hasOpenMistakes && act0LessonIsWorldCheckpointV1(world, lesson)) {
            return false;
          }
          return true;
        }, orElse: () => world.lessons.last).lessonId
      : null;
  final lessons = [
    for (final lesson in world.lessons)
      _progressLessonV1(
        world,
        lesson,
        worldAvailable: available,
        currentLessonId: currentLessonId,
        availableByRulesCheck: passedByRulesCheck,
        completedTaskIds: progressTaskIds,
        hasOpenMistakes: hasOpenMistakes,
      ),
  ];
  final completedCount = lessons
      .where((lesson) => lesson.state == Act0LessonStateV1.completed)
      .length;
  // Path closure (earned + Placement-skipped tasks) drives routing and lesson
  // state, but only earned tasks are earned completion. The learner-facing
  // count must not present a Placement-cleared lesson as completed work. The
  // label keeps its exact "X of N lessons complete" format: Home, Learn and
  // the RU localizer parse it.
  final earnedLessonCount = available
      ? world.lessons
            .where(
              (lesson) =>
                  act0LessonCompleteWithTaskIdsV1(lesson, earnedTaskIds),
            )
            .length
      : 0;
  final lessonsProgressLabel =
      '$earnedLessonCount of ${lessons.length} lessons complete';
  final status = !available
      ? Act0WorldStateV1.locked
      : allComplete
      ? Act0WorldStateV1.completed
      : passedByRulesCheck
      ? Act0WorldStateV1.passedByRulesCheck
      : Act0WorldStateV1.current;
  return world.copyWith(
    status: status,
    progressLabel: !available
        ? act0LockedWorldProgressLabelV1(
            isImmediateNext: isImmediateLockedWorld,
          )
        : lessonsProgressLabel,
    primaryCtaLabel: !available
        ? act0LockedWorldPrimaryCtaLabelV1(
            isImmediateNext: isImmediateLockedWorld,
          )
        : allComplete
        ? 'Replay lessons'
        : 'Open lessons',
    unlockLabel: available
        ? 'Available now'
        : act0DisplayWorldNameCopyV1(world.unlockLabel),
    isSelectable: available,
    isLocked: !available,
    lessons: lessons,
  );
}

Act0LessonCardV1 _progressLessonV1(
  Act0WorldCardV1 world,
  Act0LessonCardV1 lesson, {
  required bool worldAvailable,
  required String? currentLessonId,
  required bool availableByRulesCheck,
  required Set<String> completedTaskIds,
  required bool hasOpenMistakes,
}) {
  final completed = act0LessonCompleteWithTaskIdsV1(lesson, completedTaskIds);
  final checkpointBlocked =
      worldAvailable &&
      !completed &&
      hasOpenMistakes &&
      act0LessonIsWorldCheckpointV1(world, lesson);
  final current = !checkpointBlocked && lesson.lessonId == currentLessonId;
  final state = completed
      ? Act0LessonStateV1.completed
      : checkpointBlocked
      ? Act0LessonStateV1.locked
      : current
      ? Act0LessonStateV1.current
      : availableByRulesCheck
      ? Act0LessonStateV1.available
      : Act0LessonStateV1.locked;
  return lesson.copyWith(
    state: state,
    primaryCtaLabel: completed
        ? 'Replay'
        : checkpointBlocked
        ? 'Clear weak spots'
        : current || availableByRulesCheck
        ? 'Start'
        : 'Locked',
    isSelectable:
        worldAvailable &&
        !checkpointBlocked &&
        (completed || current || availableByRulesCheck),
    isLocked: !worldAvailable || state == Act0LessonStateV1.locked,
  );
}
