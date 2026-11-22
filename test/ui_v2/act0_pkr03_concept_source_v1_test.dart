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
  for (final entry in const {
    'button_advantage_button_intro':
        'Which seat gets to see CO act on the first pass after the flop?',
    'early_vs_late_w2_position_intro':
        'Which of UTG, HJ and BTN usually gets the most information before acting?',
    'position_apply_intro':
        'Which of these seats has fewer players still to act behind it before the flop?',
    'position_checkpoint_position_checkpoint_intro':
        'Which of these seats sees HJ act before making its own first decision before the flop?',
  }.entries) {
    test('${entry.key} asks a seat question its seat answers can answer', () {
      final runner = _task(entry.key).runner;
      expect(runner.question, entry.value);
      final third = switch (entry.key) {
        'button_advantage_button_intro' || 'position_apply_intro' => 'CO',
        _ => 'HJ',
      };
      expect(runner.options.map((o) => o.label).toSet(), {'BTN', 'UTG', third});
      expect(runner.table.selectableSeatIds.toSet(), {
        'btn',
        'utg',
        third.toLowerCase(),
      });
      expect(runner.options.singleWhere((o) => o.isCorrect).label, 'BTN');
    });
  }

  test('showdown_theory asks the foldout condition its answers assess', () {
    final runner = _task('showdown_theory').runner;
    expect(runner.question, 'What happens if everyone else folds to you?');
    expect(runner.options.singleWhere((o) => o.isCorrect).id, 'win_now');
    expect(runner.options.map((o) => o.label).toSet(), {
      'Win now',
      'Show cards',
      'Wait for the next card',
    });
    final wait = runner.options.singleWhere((o) => o.id == 'another_round');
    expect(wait.isCorrect, isFalse);
    expect(
      wait.feedbackReason,
      contains('no one is left to contest the 5 BB pot'),
    );
  });

  test('missed-draw feedback identifies the diamond shown on the river', () {
    final runner = _task('turn_river_changes_w5_river_misses').runner;
    expect(runner.table.boardCards.last.rank, 'Q');
    expect(runner.table.boardCards.last.suit, 'd');
    final correct = runner.options.singleWhere((option) => option.isCorrect);
    expect(correct.id, 'draw_missed');
    expect(correct.feedbackReason, contains('river queen is a diamond'));
    expect(runner.caption, isNot(contains('diamond')));
  });

  for (final entry in const {
    'w6_turn_shift_bucket': 'slide_missed',
    'w6_wet_board_repair': 'respect_wetter_board',
    'w12_bad_call_good_result': 'fold',
    'w12_decision_quality_intro': 'the_price_and_range_you_faced',
  }.entries) {
    test('${entry.key} preserves its evidence in each table projection', () {
      final task = _task(entry.key);
      final runner = task.runner;
      if (entry.key == 'w6_turn_shift_bucket') {
        expect(
          runner.caption,
          contains('BB calls with every hand that beats J9'),
        );
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
        if (entry.key.startsWith('w6_')) {
          expect(table.scope, Act0TableScopeV1.playedHand);
          expect(table.streetLabel, 'Turn');
          expect(table.boardCards, runner.table.boardCards);
          expect(table.heroCards, runner.table.heroCards);
          expect(table.toCallLabel, isEmpty);
          expect(table.actionTrail.last.label, 'Turn: BB checks');
          expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isTrue);
          continue;
        }
        if (entry.key == 'w12_bad_call_good_result') {
          expect(
            runner.caption,
            contains('Last hand you called a costly draw'),
          );
          expect(table.scope, Act0TableScopeV1.playedHand);
          expect(table.streetLabel, 'Turn');
          expect(table.heroSeatId, 'co');
          expect(table.heroCards.map((card) => card.label), ['Ah', 'Th']);
          expect(table.boardCards.map((card) => card.label), [
            'Kh',
            '7h',
            '2c',
            '4d',
          ]);
          expect(table.potLabel, 'Pot 22 BB');
          expect(table.toCallLabel, 'To call 12 BB');
          expect(table.actionTrail.last.label, 'Turn: BB bets 12 BB');
          expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe, isTrue);
          continue;
        }
        expect(runner.caption, contains('A poor choice can win'));
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
