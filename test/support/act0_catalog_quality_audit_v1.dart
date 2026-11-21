import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_numeric_copy_v1.dart';
import 'act0_catalog_poker_facts_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_starting_chart_v1.dart';

typedef WorldBtnShareV1 = ({int btnCount, int tableTasks});

class CatalogQualityReportV1 {
  CatalogQualityReportV1({
    required this.btnShareByWorld,
    required this.checks,
    required this.findings,
  });

  final Map<String, WorldBtnShareV1> btnShareByWorld;
  final Map<String, int> checks;
  final Set<String> findings;

  Map<String, Object?> toBaselineJson() {
    final sortedWorlds = btnShareByWorld.keys.toList()..sort();
    final sortedChecks = checks.keys.toList()..sort();
    final sortedFindings = findings.toList()..sort();
    return {
      'btn_share_by_world': {
        for (final worldId in sortedWorlds)
          worldId: {
            'btn_count': btnShareByWorld[worldId]!.btnCount,
            'table_tasks': btnShareByWorld[worldId]!.tableTasks,
          },
      },
      'checks': {for (final key in sortedChecks) key: checks[key]},
      'findings': sortedFindings,
    };
  }
}

final _whitespacePattern = RegExp(r'\s+');
final _jargonPattern = RegExp(
  r'\b(?:exploit(?:s|ed|ing|ative)?|loop|lever|transfer|baseline|villain|hero|heuristic|framework|calibration)\b',
  caseSensitive: false,
);
final catalogExtremeOptionPatternV1 = RegExp(
  r'\b(?:always|never|every|guaranteed|impossible|automatically|all(?!-in(?:s)?\b)|any|only|forever)\b',
  caseSensitive: false,
);
final _actionOptionPattern = RegExp(
  r'^(?:raise|open|fold|call|check|bet|limp|3-bet|all-in)\b',
  caseSensitive: false,
);
final _numericLeadingPattern = RegExp(r'^[~≈<>]?\s*\d');
final _numericUnitPattern = RegExp(
  r'\b\d+(?:\.\d+)?\s*(?:bb|outs?|%|cards?|chips?|times?)\b',
  caseSensitive: false,
);
const _classificationLabels = <String>{
  'dry',
  'wet',
  'semi-wet',
  'monotone',
  'two-tone',
  'rainbow',
  'in position',
  'out of position',
  'preflop',
  'flop',
  'turn',
  'river',
};

int _wordCount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return trimmed.split(_whitespacePattern).where((w) => w.isNotEmpty).length;
}

bool catalogIsHeadsUpAllInCallFoldV1(Act0RunnerStateV1 runner) {
  final labels = runner.options
      .map((o) => o.label.trim().toLowerCase())
      .toSet();
  return labels.length == 2 &&
      labels.containsAll(const {'call', 'fold'}) &&
      runner.table.seats.any(
        (s) => !s.isHero && s.bet?.kind == Act0SeatBetKindV1.allIn,
      );
}

String classifyCatalogScoredFormatV1(Act0LessonTaskV1 task) {
  final r = task.runner;
  final options = r.options;
  if (act0RunnerCompositionFamilyForTaskIdV1(task.taskId) ==
          Act0RunnerCompositionFamilyV1.f1TableNative ||
      options.every((o) => o.seatId != null && o.seatId!.isNotEmpty)) {
    return 'seatTap';
  }
  if (r.sizingConfig.isEnabled) {
    return 'betSize';
  }
  if (options.every(
    (o) =>
        startingChartActions.contains(o.id) ||
        _actionOptionPattern.hasMatch(o.label.trim()),
  )) {
    return 'actionDecision';
  }
  if (options.every(
    (o) =>
        _numericLeadingPattern.hasMatch(o.label.trim()) ||
        _numericUnitPattern.hasMatch(o.label),
  )) {
    return 'numeric';
  }
  if (options.every(
    (o) =>
        startingChartGroups.contains(o.id) ||
        _classificationLabels.contains(o.label.trim().toLowerCase()),
  )) {
    return 'classification';
  }
  return 'statement';
}

Iterable<String> _playerCopyStrings(Act0LessonTaskV1 task) sync* {
  final r = task.runner;
  yield task.title;
  yield r.caption;
  yield catalogQuestion(task);
  yield r.hint;
  yield r.feedbackReason;
  for (final step in r.teachingSteps) {
    yield step.title;
    yield step.body;
  }
  for (final o in r.options) {
    yield o.label;
    yield o.feedbackTitle;
    yield o.feedbackReason;
  }
}

CatalogQualityReportV1 runCatalogQualityAudit({List<CatalogTask>? rows}) {
  final targetRows = rows ?? catalogTasks;
  final checks = <String, int>{};
  final findings = <String>{};
  void count(String rule) =>
      checks.update(rule, (n) => n + 1, ifAbsent: () => 1);

  final btnCounts = <String, int>{};
  final tableCounts = <String, int>{};
  final qqCountsByWorld = <String, int>{};
  final seenTheoryByLesson = <String, Set<String>>{};
  final lessonScoredFormats = <String, List<String>>{};
  final lessonWordTotals = <String, int>{};
  final lessonScoredTotals = <String, int>{};
  final worldScoredSequence =
      <String, List<({String taskId, String format})>>{};

  for (final row in targetRows) {
    final worldId = row.world.worldId;
    final lessonId = row.lesson.lessonId;
    final task = row.task;
    final r = task.runner;
    final table = r.table;

    // Track per-lesson volume for T1/T2/T3 corridor.
    var taskWords =
        _wordCount(task.title) +
        _wordCount(r.caption) +
        _wordCount(catalogQuestion(task));
    for (final step in r.teachingSteps) {
      taskWords += _wordCount(step.title) + _wordCount(step.body);
    }
    for (final o in r.options) {
      taskWords += _wordCount(o.label);
    }
    lessonWordTotals.update(
      lessonId,
      (n) => n + taskWords,
      ifAbsent: () => taskWords,
    );
    lessonScoredTotals.putIfAbsent(lessonId, () => 0);

    // G1.11: Button share per world.
    if (table.seats.isNotEmpty) {
      tableCounts.update(worldId, (n) => n + 1, ifAbsent: () => 1);
      final heroId =
          table.heroSeatId ??
          table.seats.where((s) => s.isHero).firstOrNull?.seatId ??
          '';
      if (heroId == 'btn') {
        btnCounts.update(worldId, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    // G1.12: Two-option scored tasks in W1-W5.
    if (row.world.worldNumber <= 5 && r.options.isNotEmpty) {
      count('12.two_option_w1_w5');
      if (r.options.length == 2 && !catalogIsHeadsUpAllInCallFoldV1(r)) {
        findings.add('12.two_option_w1_w5|${task.taskId}');
      }
    }

    // G1.13: Intro / theory tasks over 100 words.
    if (r.teachingSteps.isNotEmpty &&
        (task.phase == Act0LessonPhaseV1.theory || r.options.isEmpty)) {
      count('13.intro_over_100_words');
      var introWords = 0;
      for (final step in r.teachingSteps) {
        introWords += _wordCount(step.title) + _wordCount(step.body);
      }
      if (introWords > 100) {
        findings.add('13.intro_over_100_words|${task.taskId}');
      }
    }

    // G1.14: Duplicate theory bodies inside the same lesson.
    if (r.teachingSteps.isNotEmpty) {
      count('14.duplicate_theory_in_lesson');
      final seen = seenTheoryByLesson.putIfAbsent(lessonId, () => <String>{});
      var duplicateInTask = false;
      for (final step in r.teachingSteps) {
        final norm = step.body.trim().toLowerCase().replaceAll(
          _whitespacePattern,
          ' ',
        );
        if (norm.length >= 20 && !seen.add(norm)) {
          duplicateInTask = true;
        }
      }
      if (duplicateInTask) {
        findings.add('14.duplicate_theory_in_lesson|$lessonId|${task.taskId}');
      }
    }

    // G1.15: Internal jargon leaked into player-facing text.
    count('15.internal_jargon');
    final jargonMatches = <String>{};
    for (final copy in _playerCopyStrings(task)) {
      for (final match in _jargonPattern.allMatches(copy)) {
        jargonMatches.add(match.group(0)!.toLowerCase());
      }
    }
    for (final word in jargonMatches) {
      findings.add('15.internal_jargon|${task.taskId}|$word');
    }

    // G1.16: Extreme qualifier words in wrong options (absent from correct).
    if (r.options.length >= 2) {
      count('16.extreme_wrong_option');
      final correctHasExtreme = r.options
          .where(act0RunnerOptionIsAuthoredCorrectV1)
          .any((o) => catalogExtremeOptionPatternV1.hasMatch(o.label));
      if (!correctHasExtreme) {
        for (final o in r.options.where((o) => !o.isCorrect)) {
          if (catalogExtremeOptionPatternV1.hasMatch(o.label)) {
            findings.add('16.extreme_wrong_option|${task.taskId}|${o.id}');
          }
        }
      }
    }

    // G1.17 & G1.18: Format diversity and consecutive streaks.
    if (r.options.isNotEmpty) {
      final format = classifyCatalogScoredFormatV1(task);
      lessonScoredTotals.update(lessonId, (n) => n + 1, ifAbsent: () => 1);
      lessonScoredFormats.putIfAbsent(lessonId, () => []).add(format);
      worldScoredSequence.putIfAbsent(worldId, () => []).add((
        taskId: task.taskId,
        format: format,
      ));
    }

    // G1.19 (rule 20): QQ overuse per world.
    if (CatalogPokerFacts(table).code == 'QQ') {
      count('20.hero_qq_per_world');
      final seenQq = qqCountsByWorld.update(
        worldId,
        (n) => n + 1,
        ifAbsent: () => 1,
      );
      if (seenQq >= 2) {
        findings.add('20.hero_qq_per_world|$worldId|${task.taskId}');
      }
    }
  }

  // Keep the original course ordering and anchor. Day 7 can reuse neither
  // a course reason nor a reason from another review task. A review also
  // needs distinct feedback per choice, including binary reviews.
  auditDuplicateWrongReasonsV1(
    course: targetRows,
    day7: rows == null ? day7CatalogTasks : const [],
    count: count,
    findings: findings,
  );

  for (final row
      in rows ??
          [...catalogTasks, ...rulesCheckCatalogTasks, ...day7CatalogTasks]) {
    auditCatalogNumericCopy(row, count: count, findings: findings);
  }

  // Finalize G1.11 per world.
  final btnShareByWorld = <String, WorldBtnShareV1>{};
  for (final worldId in tableCounts.keys) {
    count('11.btn_share_per_world');
    final tableTasks = tableCounts[worldId] ?? 0;
    final btnCount = btnCounts[worldId] ?? 0;
    if (tableTasks > 0 && btnCount * 2 > tableTasks) {
      btnShareByWorld[worldId] = (btnCount: btnCount, tableTasks: tableTasks);
      findings.add('11.btn_share_per_world|$worldId');
    }
  }

  // Finalize G1.17 single-format lessons (with >= 4 scored tasks).
  for (final entry in lessonScoredFormats.entries) {
    if (entry.value.length >= 4) {
      count('17.single_format_lesson');
      final formats = entry.value.toSet();
      if (formats.length == 1) {
        findings.add('17.single_format_lesson|${entry.key}|${formats.single}');
      }
    }
  }

  // Finalize G1.18 same-format streaks (> 5 consecutive scored tasks per world).
  for (final entry in worldScoredSequence.entries) {
    final worldId = entry.key;
    count('18.same_format_streak');
    String? activeFormat;
    var streakLen = 0;
    var streakStartTaskId = '';
    for (final item in entry.value) {
      if (item.format == activeFormat) {
        streakLen += 1;
        if (streakLen == 6) {
          findings.add(
            '18.same_format_streak|$worldId|$streakStartTaskId|${item.format}',
          );
        }
      } else {
        activeFormat = item.format;
        streakLen = 1;
        streakStartTaskId = item.taskId;
      }
    }
  }

  // Finalize G1.18 (rule 19) lesson duration corridor [2.0, 6.0] minutes.
  for (final lessonId in lessonWordTotals.keys) {
    count('19.lesson_length_corridor');
    final words = lessonWordTotals[lessonId] ?? 0;
    final scored = lessonScoredTotals[lessonId] ?? 0;
    final minutes = words / 160.0 + scored * 0.45;
    if (minutes > 6.0) {
      findings.add('19.lesson_length_corridor|$lessonId|too_long');
    } else if (minutes < 2.0) {
      findings.add('19.lesson_length_corridor|$lessonId|too_short');
    }
  }

  return CatalogQualityReportV1(
    btnShareByWorld: btnShareByWorld,
    checks: checks,
    findings: findings,
  );
}

void auditDuplicateWrongReasonsV1({
  required Iterable<CatalogTask> course,
  required Iterable<CatalogTask> day7,
  required void Function(String) count,
  required Set<String> findings,
}) {
  const rule = '21.duplicate_wrong_reason';
  final firstTaskByReason = <String, String>{};
  void scan(CatalogTask row, {required bool review}) {
    final task = row.task;
    if (task.repairOnly) return;
    final reasons = {
      for (final option in task.runner.options)
        option.id: option.feedbackReason.trim().toLowerCase().replaceAll(
          _whitespacePattern,
          ' ',
        ),
    };
    final occurrences = <String, int>{};
    for (final reason in reasons.values) {
      occurrences.update(reason, (n) => n + 1, ifAbsent: () => 1);
    }
    for (final option in task.runner.options.where((o) => !o.isCorrect)) {
      count(rule);
      final reason = reasons[option.id]!;
      final repeatedInTask =
          review && reason.isNotEmpty && occurrences[reason]! > 1;
      final repeatedAcrossTasks =
          reason.length >= 20 &&
          firstTaskByReason.putIfAbsent(reason, () => task.taskId) !=
              task.taskId;
      if (repeatedInTask || repeatedAcrossTasks) {
        findings.add('$rule|${task.taskId}|${option.id}');
      }
    }
  }

  for (final row in course) {
    scan(row, review: false);
  }
  for (final row in day7) {
    scan(row, review: true);
  }
}
