import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_atlas_practice_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_table_truth_v1.dart' show cardIdentity;

typedef Day7CoverageKeyV1 = (String world, String lesson, String family);
typedef Day7MissSourceV1 = ({Act0LessonTaskV1 task, Act0RunnerOptionV1 miss});

final act0Day7MissSourcesV1 = _day7MissSourcesV1();

Map<Day7CoverageKeyV1, Day7MissSourceV1> _day7MissSourcesV1() {
  final sources = <Day7CoverageKeyV1, Day7MissSourceV1>{};
  for (final row in catalogTasks) {
    final task = row.task;
    if (task.entryPhase == Act0LessonPhaseV1.theory) continue;
    final world = row.world.worldId;
    final lesson = row.lesson.lessonId;
    final concept = act0ConceptErrorDefinitionForTaskV1(
      worldId: world,
      lessonId: lesson,
      taskId: task.taskId,
    );
    for (final miss in task.runner.options.where(
      (option) => !option.isCorrect,
    )) {
      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: task.runner,
        option: miss,
        taskFamily: task.resolvedTaskFamily,
      );
      final family = receipt?.sourceSignalId ?? concept?.id;
      // With neither source, the runner cannot emit a durable skill record.
      if (family == null || family.isEmpty) continue;
      sources.putIfAbsent((
        world,
        lesson,
        family,
      ), () => (task: task, miss: miss));
    }
  }
  for (final entry in act0W1RulesReviewTasksV1) {
    final task = entry.task;
    sources[(entry.worldId, entry.lessonId, entry.conceptFamilyId)] = (
      task: task,
      miss: task.runner.options.firstWhere((option) => !option.isCorrect),
    );
  }
  return sources;
}

bool day7MustBeCoveredV1(Day7CoverageKeyV1 key) => const {
  'world_1',
  'world_2',
  'world_3',
  'world_4',
  'world_5',
  'world_6',
  'world_7',
  'world_8',
  'world_9',
  'world_10',
  'world_11',
  'world_12',
}.contains(key.$1);

final act0Day7CoverageV1 = {
  for (final entry in act0NewReviewTasksV1)
    (entry.worldId, entry.lessonId, entry.conceptFamilyId),
};

String day7HandKeyV1(Act0TableStateV1 t) =>
    '${t.heroSeatId ?? t.heroSeat.seatId}|${(t.heroCards.map(cardIdentity).toList()..sort()).join(',')}|'
    '${t.boardCards.map(cardIdentity).join(',')}';

final _courseHands = {
  for (final row in [...catalogTasks, ...rulesCheckCatalogTasks])
    if (row.task.runner.table.seats.isNotEmpty)
      day7HandKeyV1(row.task.runner.table),
};

final _validDay7Keys = {
  for (final row in act0NewReviewTasksV1)
    if (!_courseHands.contains(day7HandKeyV1(row.task.runner.table)) &&
        atlasDay7SkillMismatchV1(row.conceptFamilyId, row.task) == null &&
        row.task.runner.options.where((option) => option.isCorrect).length == 1)
      (row.worldId, row.lessonId, row.conceptFamilyId),
};

bool atlasDay7CoversV1(Day7CoverageKeyV1 key) => _validDay7Keys.contains(key);
