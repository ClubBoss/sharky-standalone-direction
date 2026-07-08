import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('W10-W12 assessed tasks use authored non-exploitable option order', () {
    final rows = _assessedRows();
    expect(rows, hasLength(42));
    expect(
      rows.map((row) => row.task.taskId).toSet(),
      _expectedCorrectIds.keys,
    );

    final allIndexes = <int>[];
    final byWorld = <String, List<int>>{};
    final checkpointIndexes = <String, List<int>>{};

    for (final row in rows) {
      final taskId = row.task.taskId;
      final options = row.task.runner.options;
      final correctOptions = options.where((option) => option.isCorrect);

      expect(options, hasLength(3), reason: taskId);
      expect(correctOptions, hasLength(1), reason: taskId);
      expect(correctOptions.single.id, _expectedCorrectIds[taskId]);

      final correctIndex = options.indexWhere((option) => option.isCorrect);
      allIndexes.add(correctIndex);
      byWorld.putIfAbsent(row.worldId, () => <int>[]).add(correctIndex);
      if (row.lessonId.contains('checkpoint')) {
        checkpointIndexes
            .putIfAbsent(row.lessonId, () => <int>[])
            .add(correctIndex);
      }
    }

    expect(_distribution(allIndexes), <int, int>{0: 14, 1: 14, 2: 14});
    expect(_longestRun(allIndexes), lessThanOrEqualTo(2));
    expect(allIndexes, isNot(everyElement(0)));

    for (final entry in byWorld.entries) {
      expect(entry.value.toSet(), hasLength(greaterThan(1)), reason: entry.key);
      expect(_longestRun(entry.value), lessThanOrEqualTo(2), reason: entry.key);
    }
    for (final entry in checkpointIndexes.entries) {
      expect(entry.value.toSet(), hasLength(greaterThan(1)), reason: entry.key);
    }
  });

  test('W10-W12 repaired rows remove audit shortcut copy patterns', () {
    expect(
      _taskById('w10_loose_passive_tag').runner.question,
      isNot(_taskById('w10_overaggressive_tag').runner.question),
    );
    expect(
      _taskById('w10_underbluff_fold_more').runner.question,
      isNot(_taskById('w11_plan_avoid_overload').runner.question),
    );

    _expectNoEcho(
      'w11_plan_table_focus_transfer',
      forbiddenFragments: const <String>['session plan', 'one focus'],
    );
    _expectNoEcho(
      'w12_good_fold_bad_result',
      forbiddenFragments: const <String>['process review', 'decision process'],
    );
    _expectNoEcho(
      'w12_checkpoint_review',
      forbiddenFragments: const <String>['stable bridge'],
    );

    for (final taskId in _distractorRepairTaskIds) {
      final labels = _taskById(taskId).runner.options
          .where((option) => !option.isCorrect)
          .map((option) => option.label.toLowerCase())
          .join(' ');
      for (final fragment in _forbiddenDistractorFragments) {
        expect(labels, isNot(contains(fragment)), reason: '$taskId::$fragment');
      }
    }
  });

  test(
    'W10-W12 canonical route, payoff, repair, and terminal contracts stay fixed',
    () {
      final world10 = Act0ShellStateV1.sample.worldById('world_10');
      final world11 = Act0ShellStateV1.sample.worldById('world_11');
      final world12 = Act0ShellStateV1.sample.worldById('world_12');

      expect(world10.title, 'Player Adjustment');
      expect(world11.title, 'Real Play Transfer');
      expect(world12.title, 'Mindset Bridge');

      expect(
        _completionPayoffText(world10),
        contains('tag tendency, adjust one lever'),
      );
      expect(
        _completionPayoffText(world11),
        contains('one plan, one trigger lever, one review repair output'),
      );
      expect(
        _completionPayoffText(world12),
        contains('process, reset, and discipline'),
      );

      expect(
        act0FirstValueSameSignalRepMappingV1(
          nextRepId: 'repeat_table_read',
          skillAtomId: 'table_read',
          sourceSignalId: 'player_tendency',
          sourceTaskId: 'w10_nit_tag',
          receiptOutcome: 'repair_started',
        )?.taskId,
        'w10_loose_passive_tag',
      );
      expect(
        act0FirstValueSameSignalRepMappingV1(
          nextRepId: 'repeat_table_read',
          skillAtomId: 'table_read',
          sourceSignalId: 'session_plan',
          sourceTaskId: 'w11_plan_focus_choice',
          receiptOutcome: 'repair_started',
        )?.taskId,
        'w11_plan_avoid_overload',
      );
      expect(
        act0FirstValueSameSignalRepMappingV1(
          nextRepId: 'repeat_table_read',
          skillAtomId: 'table_read',
          sourceSignalId: 'tilt_reset',
          sourceTaskId: 'w12_after_bad_beat_reset',
          receiptOutcome: 'repair_started',
        )?.taskId,
        'w12_after_mistake_reset',
      );

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world13_')),
        isEmpty,
      );
      expect(kCampaignPackIdsV1, contains('volume_i_terminal_review_v1'));
    },
  );
}

const _expectedCorrectIds = <String, String>{
  'w10_nit_tag': 'nit',
  'w10_loose_passive_tag': 'loose_passive',
  'w10_overaggressive_tag': 'overaggressive',
  'w10_vs_nit_open_wider': 'open_wider',
  'w10_vs_caller_value_heavier': 'value_heavier',
  'w10_vs_sticky_defender_tighten_steals': 'tighten_steals',
  'w10_table_value_vs_caller_transfer': 'lean_value',
  'w10_overbluff_punish': 'bluffcatch_more',
  'w10_underbluff_fold_more': 'fold_more',
  'w10_guardrail_sample_size': 'small_probe',
  'w10_checkpoint_tag_line': 'primary_tag',
  'w10_checkpoint_lever_line': 'widen_steal',
  'w10_checkpoint_guardrail_line': 'small_adjust',
  'w10_checkpoint_table_notice': 'widen_late_steals_small',
  'w10_checkpoint_review': 'structured_exploit',
  'w11_plan_focus_choice': 'one_focus',
  'w11_plan_avoid_overload': 'narrow_goal',
  'w11_plan_table_focus_transfer': 'one_focus_loop',
  'w11_trigger_overfold_blinds': 'widen_late_steal',
  'w11_trigger_overcall_flop': 'value_heavier',
  'w11_trigger_small_price_continue': 'call_once',
  'w11_trigger_bad_price_fold': 'fold_turn',
  'w11_review_pick_leak': 'pick_priority',
  'w11_review_define_fix': 'if_then_fix',
  'w11_checkpoint_plan_line': 'simple_focus',
  'w11_checkpoint_trigger_line': 'one_trigger_action',
  'w11_checkpoint_review_line': 'one_repair_output',
  'w11_checkpoint_mixed_table_line': 'call_in_position',
  'w11_checkpoint_review': 'repeatable_loop',
  'w12_good_fold_bad_result': 'process_review',
  'w12_bad_call_good_result': 'flag_leak',
  'w12_after_bad_beat_reset': 'reset_protocol',
  'w12_after_mistake_reset': 'note_and_reset',
  'w12_assertive_not_ego': 'stick_process',
  'w12_discipline_under_pressure': 'critical_pause',
  'w12_pretty_hand_bad_price_fold': 'fold_river',
  'w12_revenge_raise_trap': 'call_once',
  'w12_checkpoint_process_line': 'process_first',
  'w12_checkpoint_reset_line': 'run_reset',
  'w12_checkpoint_discipline_line': 'evidence_line',
  'w12_checkpoint_full_loop_line': 'call_clean',
  'w12_checkpoint_review': 'stable_bridge',
};

const _distractorRepairTaskIds = <String>{
  'w10_nit_tag',
  'w10_loose_passive_tag',
  'w10_vs_nit_open_wider',
  'w10_overbluff_punish',
  'w10_guardrail_sample_size',
  'w10_checkpoint_tag_line',
  'w10_checkpoint_guardrail_line',
  'w10_checkpoint_table_notice',
  'w10_checkpoint_review',
  'w11_trigger_overfold_blinds',
  'w11_trigger_overcall_flop',
  'w11_checkpoint_trigger_line',
  'w11_checkpoint_review',
  'w12_good_fold_bad_result',
  'w12_after_bad_beat_reset',
  'w12_after_mistake_reset',
  'w12_assertive_not_ego',
  'w12_discipline_under_pressure',
  'w12_pretty_hand_bad_price_fold',
  'w12_checkpoint_reset_line',
};

const _forbiddenDistractorFragments = <String>{
  'always',
  'auto-quit',
  'every bluff',
  'every hand',
  'everything',
  'force action',
  'ignore emotion',
  'ignore it',
  'ignore read',
  'ignore the trigger',
  'jam for control',
  'never adjust',
  'no read yet, ignore',
  'only shove',
  'pretend mistake',
  'revenge',
  'self attack',
  'self-attack',
  'tank every',
  'triple-barrel every',
};

List<_AssessedRow> _assessedRows() {
  return Act0ShellStateV1.sample.worlds
      .where(
        (world) =>
            const {'world_10', 'world_11', 'world_12'}.contains(world.worldId),
      )
      .expand(
        (world) => world.lessons.expand(
          (lesson) => lesson.taskList.map((task) {
            return _AssessedRow(
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              task: task,
            );
          }),
        ),
      )
      .where((row) => _expectedCorrectIds.containsKey(row.task.taskId))
      .toList(growable: false);
}

Act0LessonTaskV1 _taskById(String taskId) {
  return Act0ShellStateV1.sample.worlds
      .expand((world) => world.lessons)
      .expand((lesson) => lesson.taskList)
      .firstWhere((task) => task.taskId == taskId);
}

Map<int, int> _distribution(List<int> indexes) {
  final result = <int, int>{0: 0, 1: 0, 2: 0};
  for (final index in indexes) {
    result[index] = (result[index] ?? 0) + 1;
  }
  return result;
}

int _longestRun(List<int> indexes) {
  var longest = 0;
  var current = 0;
  int? previous;
  for (final index in indexes) {
    current = index == previous ? current + 1 : 1;
    if (current > longest) longest = current;
    previous = index;
  }
  return longest;
}

void _expectNoEcho(String taskId, {required List<String> forbiddenFragments}) {
  final task = _taskById(taskId);
  final prompt = task.runner.question.toLowerCase();
  final correctLabel = task.runner.options
      .singleWhere((option) => option.isCorrect)
      .label
      .toLowerCase();
  for (final fragment in forbiddenFragments) {
    expect(prompt, isNot(contains(fragment)), reason: taskId);
    expect(correctLabel, isNot(contains(fragment)), reason: taskId);
  }
}

String _completionPayoffText(Act0WorldCardV1 world) {
  final finalLesson = world.lessons.last;
  return <String>[
    finalLesson.runner.caption,
    finalLesson.runner.hint,
    finalLesson.runner.question,
    finalLesson.runner.feedbackReason,
  ].join(' ');
}

class _AssessedRow {
  const _AssessedRow({
    required this.worldId,
    required this.lessonId,
    required this.task,
  });

  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
}
