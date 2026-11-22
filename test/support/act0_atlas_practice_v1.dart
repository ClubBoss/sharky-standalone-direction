import 'package:poker_analyzer/ui_v2/act0_shell/act0_route_practice_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';

/// These checks use mutually exclusive, visible prompts to falsify a family
/// match. A declared due-review family is scheduling metadata. It still needs
/// a matching exercise to count. Ambiguous prompts are left for content review.
String? atlasDay7SkillMismatchV1(String family, Act0LessonTaskV1 task) {
  final prompt = catalogQuestion(task);
  final comboCount = RegExp(
    r'\b(?:combo(?:s| counts?)?|blockers?|distinct .{0,24} hands|combinations?)\b',
    caseSensitive: false,
  );
  final priceCue = RegExp(
    r"\b(?:price|cost|facing|threshold|break[- ]even|to call|odds|bet size)\b|\bhow (?:much|many) .{0,40}\bcall\b",
    caseSensitive: false,
  );
  if (family == 'pot_to_call' &&
      comboCount.hasMatch(prompt) &&
      !priceCue.hasMatch(prompt)) {
    return 'подсчёт комбинаций вместо цены колла';
  }
  if (family == 'pot_to_call' &&
      RegExp(
        r'\b(?:where can you|which tab|which screen)\b',
        caseSensitive: false,
      ).hasMatch(prompt)) {
    return 'навигация вместо цены колла';
  }
  if (family == 'hero_button' &&
      RegExp(
        r'\bwhich (?:two )?cards?\b.{0,30}\bprivate\b',
        caseSensitive: false,
      ).hasMatch(prompt)) {
    return 'личные карты вместо позиции за столом';
  }
  return null;
}

class AtlasPracticeWorldV1 {
  AtlasPracticeWorldV1(this.worldId);

  final String worldId;
  final gaps = <String>[];
  var steps = 0;
  var checkpoints = 0;
}

/// Audit the same schedule and Day 7 deck consumed by the Learn route.
AtlasPracticeWorldV1 auditAtlasPracticeWorldV1(Act0WorldCardV1 world) {
  final report = AtlasPracticeWorldV1(world.worldId);
  final steps = act0RoutePracticeStepsV1(world);
  final checkpoint = act0RoutePracticeBoundaryLessonV1(world);
  if (checkpoint == null) {
    report.gaps.add('нет чекпоинта в маршруте');
    return report;
  }
  report.checkpoints++;
  if (steps.lastOrNull?.beforeLessonIndex != world.lessons.length - 1) {
    report.gaps.add('нет обязательной практики перед ${checkpoint.lessonId}');
  }
  var previousBoundary = 0;
  final earlierLessons = {
    for (final earlier in Act0ShellStateV1.sample.worlds)
      if (earlier.worldNumber < world.worldNumber)
        for (final lesson in earlier.lessons) lesson.lessonId,
  };
  for (final step in steps) {
    report.steps++;
    final boundary = step.beforeLessonIndex;
    final gap = boundary - previousBoundary;
    if (gap < 2 || gap > 3) {
      report.gaps.add('${step.id}: $gap уроков между шагами');
    }
    previousBoundary = boundary;
    final finished = world.lessons.take(boundary);
    final closedTasks = {
      for (final lesson in finished)
        for (final task in lesson.courseTaskList) task.taskId,
    };
    if (act0RequiredRoutePracticeV1(world, closedTasks, {})?.id != step.id ||
        act0RequiredRoutePracticeV1(world, closedTasks, {step.id}) != null) {
      report.gaps.add('${step.id}: граница не закрывается после практики');
    }
    final deck = act0RoutePracticeDeckV1(
      eligibleLessonIds: {
        ...earlierLessons,
        for (final lesson in finished) lesson.lessonId,
      },
      preferredWorldId: world.worldId,
      openMistakeLessonIds: {},
      weakLessonIds: {},
      seenTaskIds: {},
    );
    if (deck.length < 4 ||
        deck.length > 6 ||
        deck.map((rep) => rep.task.taskId).toSet().length != deck.length ||
        deck.any((rep) => closedTasks.contains(rep.task.taskId))) {
      report.gaps.add('${step.id}: нет 4–6 разных заданий');
    }
  }
  return report;
}
