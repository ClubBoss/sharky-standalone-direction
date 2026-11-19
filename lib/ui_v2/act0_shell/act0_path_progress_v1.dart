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
    );
    worlds.add(progressed);
    if (progressed.status == Act0WorldStateV1.locked) {
      lockedWorldSeen = true;
    }
    previousWorldComplete = progressed.status == Act0WorldStateV1.completed;
  }
  return worlds;
}

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
  final currentLessonId = available && !allComplete
      ? world.lessons
            .firstWhere(
              (lesson) =>
                  !act0LessonCompleteWithTaskIdsV1(lesson, progressTaskIds),
            )
            .lessonId
      : null;
  final lessons = [
    for (final lesson in world.lessons)
      _progressLessonV1(
        lesson,
        worldAvailable: available,
        currentLessonId: currentLessonId,
        completedTaskIds: progressTaskIds,
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
  Act0LessonCardV1 lesson, {
  required bool worldAvailable,
  required String? currentLessonId,
  required Set<String> completedTaskIds,
}) {
  final completed = act0LessonCompleteWithTaskIdsV1(lesson, completedTaskIds);
  final current = lesson.lessonId == currentLessonId;
  final state = completed
      ? Act0LessonStateV1.completed
      : current
      ? Act0LessonStateV1.current
      : Act0LessonStateV1.locked;
  return lesson.copyWith(
    state: state,
    primaryCtaLabel: completed
        ? 'Replay'
        : current
        ? 'Start'
        : 'Locked',
    isSelectable: worldAvailable && (completed || current),
    isLocked: !worldAvailable || state == Act0LessonStateV1.locked,
  );
}
