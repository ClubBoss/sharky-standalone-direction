// Authored PKR-03 regressions. No synthetic hand completes missing source facts.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons)
    .expand((l) => l.taskList)
    .singleWhere((t) => t.taskId == id);

void main() {
  for (final id in const [
    'button_advantage_button_intro',
    'early_vs_late_w2_position_intro',
    'position_apply_intro',
    'position_checkpoint_position_checkpoint_intro',
  ]) {
    test('$id asks a seat question its seat answers can answer', () {
      final runner = _task(id).runner;
      expect(
        runner.question,
        'Which seat usually has more information before acting?',
      );
      expect(runner.options.map((o) => o.label).toSet(), {'BTN', 'UTG'});
      expect(runner.options.singleWhere((o) => o.isCorrect).label, 'BTN');
    });
  }

  test('showdown_theory asks the foldout condition its answers assess', () {
    final runner = _task('showdown_theory').runner;
    expect(runner.question, 'What happens if everyone folds to you?');
    expect(runner.options.singleWhere((o) => o.isCorrect).id, 'win_now');
    expect(runner.options.map((o) => o.label).toSet(), {
      'Win now',
      'Show cards',
    });
  });

  test('authored missed-draw river description matches the red diamond', () {
    final runner = _task('turn_river_changes_w5_river_misses').runner;
    expect(runner.table.boardCards.last.rank, '2');
    expect(runner.table.boardCards.last.suit, 'd');
    expect(runner.caption, contains('2 of diamonds'));
    expect(runner.caption, isNot(contains('black 2')));
    expect(runner.options.singleWhere((o) => o.isCorrect).id, 'draw_missed');
  });

  for (final entry in const {
    'w6_turn_shift_bucket': 'slide_missed',
    'w6_wet_board_repair': 'respect_wetter_board',
    'w12_bad_call_good_result': 'flag_leak',
  }.entries) {
    test('${entry.key} is a stated premise in every real table projection', () {
      final task = _task(entry.key);
      final runner = task.runner;
      expect(runner.caption.toLowerCase(), contains('suppose'));
      if (entry.key.startsWith('w6_')) {
        expect(
          runner.teachingSteps.map((s) => s.body.toLowerCase()).join(' '),
          anyOf(contains('suppose'), contains('hypothetical')),
        );
      }
      if (entry.key == 'w6_turn_shift_bucket') {
        expect(
          runner.options
              .singleWhere((o) => o.id == 'always_value')
              .feedbackReason,
          isNot(contains('brick')),
        );
      }
      expect(runner.options.singleWhere((o) => o.isCorrect).id, entry.value);
      final tables = <Act0TableStateV1>[
        runner.table,
        for (final step in runner.teachingSteps)
          act0TeachingTableForRunnerV1(runner.table, step),
        for (final option in runner.options)
          act0FeedbackTableForRunnerV1(
            runner: runner.copyWith(
              phase: Act0LessonPhaseV1.review,
              selectedOptionId: option.id,
            ),
            taskFamily: task.resolvedTaskFamily,
          ),
        for (final option in runner.options)
          act0RepairTableForRunnerV1(runner.table, option),
      ];
      for (final table in tables) {
        expect(table.scope, Act0TableScopeV1.explanation);
        expect(table.centerLabel, 'Hypothetical example');
        expect(table.streetLabel, isEmpty);
        expect(table.potLabel, isEmpty);
        expect(table.toCallLabel, isEmpty);
        expect(table.heroCards, isEmpty);
        expect(table.boardCards, isEmpty);
        expect(table.actionTrail, isEmpty);
        expect(table.activeSeatId, anyOf(isNull, isEmpty));
        expect(table.seats.where((s) => s.isActive), isEmpty);
        expect(act0StreetReplayFromTableV1(table), isNull);
        expect(act0TableChoreographyPlanForTableV1(table), isNull);
      }
    });
  }
}
