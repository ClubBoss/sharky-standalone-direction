import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0RunnerStateV1 _realPlacementActionRunnerV1() {
  final task = Act0ShellStateV1.sample.worlds
      .expand((world) => world.lessons)
      .expand((lesson) => lesson.taskList)
      .singleWhere(
        (task) => task.taskId == 'what_poker_is_table_read_transfer',
      );
  // This is the actual production placement consumer, not a synthesized
  // decision state or a substitute progress record.
  return placementQuickCheckRunnerV1(
    task.runner,
    signalId: 'action_basics',
    checkIndex: 3,
    checkCount: 3,
  );
}

Act0RunnerOptionV1 _alterOptionV1(
  Act0RunnerOptionV1 source, {
  String? label,
  String? amount,
  bool? correct,
  Act0FeedbackQualityV1? quality,
}) => Act0RunnerOptionV1(
  id: source.id,
  label: label ?? source.label,
  amountLabel: amount ?? source.amountLabel,
  isCorrect: correct ?? source.isCorrect,
  preferredLabel: source.preferredLabel,
  quality: quality ?? source.quality,
  feedbackTitle: source.feedbackTitle,
  feedbackReason: source.feedbackReason,
);

void main() {
  test('actual third Placement question preserves its source Check grade', () {
    final runner = _realPlacementActionRunnerV1();
    expect(runner.question, 'No bet faces Hero. Which action is free?');
    final actionOptions = runner.options.where(
      (option) => <String>{'check', 'call', 'raise'}.contains(option.id),
    );
    expect(actionOptions.length, 3);
    for (final option in actionOptions) {
      final result = act0BettingPriceForOptionV1(
        runner.table,
        option,
        taskId: 'what_poker_is_table_read_transfer',
        question: runner.question,
      );
      expect(result.reason, 'source_placement_action_definition');
      expect(result.appliesToWager, isFalse);
      expect(result.sourceReady, isFalse);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(
          runner.table,
          option,
          taskId: 'what_poker_is_table_read_transfer',
          question: runner.question,
        ),
        isFalse,
        reason: 'An action definition must be answerable on an unproved hand',
      );
      expect(option.isCorrect, option.id == 'check');
      expect(
        option.quality,
        option.id == 'check'
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
      );
    }
  });

  test(
    'placement definition never licenses altered table, amount or grade',
    () {
      final runner = _realPlacementActionRunnerV1();
      final check = runner.options.singleWhere(
        (option) => option.id == 'check',
      );
      final call = runner.options.singleWhere((option) => option.id == 'call');
      final mutations =
          <
            String,
            ({
              Act0TableStateV1 table,
              Act0RunnerOptionV1 option,
              String question,
            })
          >{
            'pot': (
              table: runner.table.copyWith(potLabel: 'Pot 7 BB'),
              option: check,
              question: runner.question,
            ),
            'price': (
              table: runner.table.copyWith(toCallLabel: 'To call 2 BB'),
              option: check,
              question: runner.question,
            ),
            'street': (
              table: runner.table.copyWith(streetLabel: 'Turn'),
              option: check,
              question: runner.question,
            ),
            'scope': (
              table: runner.table.copyWith(scope: Act0TableScopeV1.orientation),
              option: check,
              question: runner.question,
            ),
            'actor': (
              table: runner.table.copyWith(activeSeatId: 'btn'),
              option: check,
              question: runner.question,
            ),
            'board': (
              table: runner.table.copyWith(
                boardCards: const <Act0CardStateV1>[
                  Act0CardStateV1(rank: 'Q', suit: 'h'),
                  Act0CardStateV1(rank: '7', suit: 'c'),
                  Act0CardStateV1(rank: '2', suit: 'd'),
                ],
              ),
              option: check,
              question: runner.question,
            ),
            'hero': (
              table: runner.table.copyWith(
                heroCards: const <Act0CardStateV1>[
                  Act0CardStateV1(rank: 'Q', suit: 's'),
                  Act0CardStateV1(rank: 'K', suit: 'd'),
                ],
              ),
              option: check,
              question: runner.question,
            ),
            'stack': (
              table: runner.table.copyWith(
                seats: <Act0SeatStateV1>[
                  for (final seat in runner.table.seats)
                    if (seat.isHero)
                      Act0SeatStateV1(
                        seatId: seat.seatId,
                        seatLabel: seat.seatLabel,
                        displayName: seat.displayName,
                        isHero: true,
                        isDealerButton: seat.isDealerButton,
                        stackLabel: '1 BB',
                        holeCards: seat.holeCards,
                      )
                    else
                      seat,
                ],
              ),
              option: check,
              question: runner.question,
            ),
            'question': (
              table: runner.table,
              option: check,
              question: 'What should Hero do?',
            ),
            'number': (
              table: runner.table,
              option: _alterOptionV1(call, amount: '2 BB'),
              question: runner.question,
            ),
            'sizing': (
              table: runner.table,
              option: _alterOptionV1(check, label: 'Check 2 BB'),
              question: runner.question,
            ),
            'changed_grade': (
              table: runner.table,
              option: _alterOptionV1(
                check,
                correct: false,
                quality: Act0FeedbackQualityV1.wrong,
              ),
              question: runner.question,
            ),
          };
      for (final entry in mutations.entries) {
        final result = act0BettingPriceForOptionV1(
          entry.value.table,
          entry.value.option,
          taskId: 'what_poker_is_table_read_transfer',
          question: entry.value.question,
        );
        expect(
          result.reason,
          'changed_placement_action_source',
          reason: entry.key,
        );
        expect(result.appliesToWager, isTrue, reason: entry.key);
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            entry.value.table,
            entry.value.option,
            taskId: 'what_poker_is_table_read_transfer',
            question: entry.value.question,
          ),
          isTrue,
          reason: 'Original Check proof cannot transfer: ${entry.key}',
        );
      }
    },
  );

  test('numeric hand bets and disputed Fold grades remain source-blocked', () {
    final runner = _realPlacementActionRunnerV1();
    final check = runner.options.singleWhere((option) => option.id == 'check');
    expect(
      act0BettingPriceBlocksAuthoredSuccessV1(
        runner.table,
        check,
        taskId: 'what_poker_is_table_read_transfer',
        question: runner.question,
        sizingBet: true,
      ),
      isTrue,
    );
    final ordinaryTableReadOption = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'what_poker_is_table_read_transfer',
        )
        .runner
        .options
        .singleWhere((option) => option.id == 'two_three_six');
    expect(ordinaryTableReadOption.isCorrect, isTrue);
    expect(
      act0BettingPriceForOptionV1(
        runner.table,
        ordinaryTableReadOption,
        taskId: 'what_poker_is_table_read_transfer',
        question: 'What is the clean first table read?',
      ).reason,
      isNot('source_placement_action_definition'),
    );
  });
}
