import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _definitions = <(String, String, String)>[
  (
    'actions_theory',
    'Which action increases what opponents must match?',
    'raise',
  ),
  (
    'actions_fold_drill',
    'Which action ends your participation in the hand?',
    'fold',
  ),
  (
    'actions_call_drill',
    'Which action matches a wager without increasing it?',
    'call',
  ),
  ('actions_raise_drill', 'Which action increases the current wager?', 'raise'),
  ('actions_review', 'Which action adds more than a call?', 'raise'),
];

Act0RunnerOptionV1 _alter(
  Act0RunnerOptionV1 source, {
  String? label,
  String? amount,
  bool? correct,
  Act0FeedbackQualityV1? quality,
}) => Act0RunnerOptionV1(
  id: source.id,
  label: label ?? source.label,
  amountLabel: amount ?? source.amountLabel,
  seatId: source.seatId,
  isCorrect: correct ?? source.isCorrect,
  preferredLabel: source.preferredLabel,
  betterAnswerLabel: source.betterAnswerLabel,
  quality: quality ?? source.quality,
  feedbackTitle: source.feedbackTitle,
  feedbackReason: source.feedbackReason,
);

void main() {
  final tasks = Act0ShellStateV1.sample.worlds
      .expand((world) => world.lessons)
      .expand((lesson) => lesson.taskList)
      .toList();

  test('five original W1 tasks are source-owned definitions, not wagers', () {
    for (final (taskId, question, correctId) in _definitions) {
      final task = tasks.singleWhere((task) => task.taskId == taskId);
      final runner = task.runner;
      expect(runner.question, question, reason: taskId);
      expect(runner.options.length, 3, reason: taskId);
      expect(runner.options.map((option) => option.id).toSet(), {
        'fold',
        'call',
        'raise',
      });
      expect(runner.table.scope, Act0TableScopeV1.playedHand);
      expect(runner.table.potLabel, isEmpty);
      expect(runner.table.toCallLabel, isEmpty);
      expect(runner.table.actionTrail, isEmpty);
      expect(
        runner.table.seats.every(
          (seat) =>
              seat.bet == null &&
              seat.currentBetLabel == null &&
              seat.blindAmountLabel == null,
        ),
        isTrue,
      );
      expect(
        runner.options.where((option) => option.isCorrect).single.id,
        correctId,
      );
      for (final option in runner.options) {
        expect(option.amountLabel, isEmpty);
        expect(option.label, isIn(const ['Fold', 'Call', 'Raise']));
        expect(
          option.quality,
          option.id == correctId
              ? Act0FeedbackQualityV1.correct
              : option.id == 'call' && correctId == 'raise'
              ? Act0FeedbackQualityV1.suboptimal
              : Act0FeedbackQualityV1.wrong,
        );
        final result = act0BettingPriceForOptionV1(
          runner.table,
          option,
          taskId: taskId,
          question: runner.question,
        );
        expect(result.reason, 'source_w1_action_word', reason: taskId);
        expect(result.appliesToWager, isFalse);
        expect(result.sourceReady, isFalse);
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            runner.table,
            option,
            taskId: taskId,
            question: runner.question,
          ),
          isFalse,
        );
      }
    }
  });

  test('changed source cannot inherit action-definition grading', () {
    for (final (taskId, _, correctId) in _definitions) {
      final runner = tasks.singleWhere((task) => task.taskId == taskId).runner;
      final correct = runner.options.singleWhere((o) => o.id == correctId);
      final wrong = runner.options.firstWhere((o) => o.id != correctId);
      final altered = [
        (
          label: 'numeric_wager',
          table: runner.table,
          option: _alter(correct, amount: '3 BB'),
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'label',
          table: runner.table,
          option: _alter(correct, label: 'Bet'),
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'grade',
          table: runner.table,
          option: _alter(
            correct,
            correct: false,
            quality: Act0FeedbackQualityV1.wrong,
          ),
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'false_grade',
          table: runner.table,
          option: _alter(
            wrong,
            correct: true,
            quality: Act0FeedbackQualityV1.correct,
          ),
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'changed_question',
          table: runner.table,
          option: correct,
          question: '${runner.question}?',
          sizingBet: false,
        ),
        (
          label: 'pot',
          table: runner.table.copyWith(potLabel: 'Pot 10 BB'),
          option: correct,
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'priced_choice',
          table: runner.table.copyWith(toCallLabel: 'To call 1 BB'),
          option: correct,
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'changed_scope',
          table: runner.table.copyWith(scope: Act0TableScopeV1.explanation),
          option: correct,
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'fabricated_history',
          table: runner.table.copyWith(
            actionTrail: const <Act0ActionTrailItemV1>[
              Act0ActionTrailItemV1(label: 'Hero raises 4 BB'),
            ],
          ),
          option: correct,
          question: runner.question,
          sizingBet: false,
        ),
        (
          label: 'sizing',
          table: runner.table,
          option: correct,
          question: runner.question,
          sizingBet: true,
        ),
      ];
      for (final changed in altered) {
        final result = act0BettingPriceForOptionV1(
          changed.table,
          changed.option,
          sizingBet: changed.sizingBet,
          taskId: taskId,
          question: changed.question,
        );
        expect(
          result.reason,
          'changed_w1_action_word_source',
          reason: '$taskId/${changed.label}',
        );
        expect(
          result.appliesToWager,
          isTrue,
          reason: '$taskId/${changed.label}',
        );
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            changed.table,
            changed.option,
            taskId: taskId,
            question: changed.question,
            sizingBet: changed.sizingBet,
          ),
          isTrue,
          reason: '$taskId/${changed.label}',
        );
      }
    }
  });
}
