import 'package:poker_analyzer/ui_v2/act0_shell/act0_path_progress_v1.dart';
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

/// Check the actual ordered course path. Daily Practice and the optional Home
/// prompt do not produce a mandatory between-lesson step in the path projection.
/// Checkpoint identity is the same predicate used by Act0 progress.
AtlasPracticeWorldV1 auditAtlasPracticeWorldV1(Act0WorldCardV1 world) {
  final report = AtlasPracticeWorldV1(world.worldId);
  var lessonsSincePractice = 0;
  var practicedSinceLesson = false;
  for (final (index, lesson) in world.lessons.indexed) {
    if (act0LessonIsWorldCheckpointV1(world, lesson)) {
      report.checkpoints++;
      if (!practicedSinceLesson) {
        report.gaps.add('нет обязательной практики перед ${lesson.lessonId}');
      }
      continue;
    }
    // A lesson whose phase label is Practice is a path step only if it owns
    // mandatory tasks. Ordinary lesson-level drills have the same task-level
    // practice enum, so that enum alone cannot count.
    if (lesson.phaseLabel.trim().toLowerCase() == 'practice' &&
        lesson.courseTaskList.isNotEmpty) {
      report.steps++;
      final next = world.lessons.skip(index + 1).firstOrNull;
      final beforeCheckpoint =
          next != null && act0LessonIsWorldCheckpointV1(world, next);
      if (lessonsSincePractice < 2 && !beforeCheckpoint) {
        report.gaps.add('практика раньше двух уроков: ${lesson.lessonId}');
      }
      practicedSinceLesson = true;
      lessonsSincePractice = 0;
      continue;
    }
    practicedSinceLesson = false;
    lessonsSincePractice++;
    if (lessonsSincePractice == 4) {
      report.gaps.add('больше трёх уроков без практики до ${lesson.lessonId}');
      lessonsSincePractice = 1;
    }
  }
  if (report.checkpoints == 0) report.gaps.add('нет чекпоинта в маршруте');
  return report;
}
