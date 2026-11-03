import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import '../support/act0_table_truth_v1.dart';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons).expand((l) => l.taskList)
    .singleWhere((t) => t.taskId == id);

void main() {
  test('multiple fallback actors never pass source consistency', () {
    final table = _task('w4_value_bet').runner.table.copyWith(
      activeSeatId: '',
      seats: const [
        Act0SeatStateV1(seatId: 'btn', seatLabel: 'BTN', displayName: 'Hero', isHero: true, isActive: true),
        Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'CO', isActive: true),
      ],
    );
    expect(actorFlagsConsistent(table), isFalse);
  });

  test('historical actors are live until their authored fold, never after it', () {
    final source = _task('w4_value_bet').runner.table;
    final plan = act0TableChoreographyPlanForTableV1(source);
    expect(plan, isNotNull);
    var actors = 0;
    for (var i = 0; i < plan!.beats.length; i++) {
      final frame = act0TableChoreographyFrameAfterBeatV1(plan, i);
      final table = act0TableForChoreographyFrameV1(source, frame);
      final actor = table.activeSeatId;
      if (actor != null && actor.isNotEmpty) {
        actors++;
        final seat = table.seats.singleWhere((s) => s.seatId == actor);
        expect(seat.isOccupied && seat.isInHand && !seat.isFolded, isTrue,
            reason: 'beat=$i actor=$actor');
      }
      for (final id in frame.foldedSeatIds) {
        expect(table.seats.singleWhere((s) => s.seatId == id).isInHand, isFalse);
      }
    }
    expect(actors, greaterThan(0));
  });

  test('choreography rejects an actor acting again after folding', () {
    final source = _task('w4_value_bet').runner.table.copyWith(
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'UTG checks'),
        Act0ActionTrailItemV1(label: 'Flop: BB checks'),
        Act0ActionTrailItemV1(label: 'BTN acts'),
      ],
    );
    expect(act0TableChoreographyPlanForTableV1(source), isNull);
  });

  test('W4 observation preserves the declared non-Hero turn through feedback', () {
    final task = _task('w4_checkpoint_table_purpose_price');
    expect(task.runner.table.activeSeatId, 'bb');
    for (final option in task.runner.options) {
      final table = act0FeedbackTableForRunnerV1(
        runner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.review, selectedOptionId: option.id,
        ),
        taskFamily: task.resolvedTaskFamily,
      );
      expect(table.activeSeatId, 'bb');
    }
  });

  test('AQ on K72 has one overcard in the actual correct feedback', () {
    final runner = _task('w6_bluff_candidate').runner;
    expect(runner.options.singleWhere((o) => o.isCorrect).feedbackReason,
        contains('one overcard'));
    expect(runner.options.map((o) => o.feedbackReason).join(' '),
        isNot(contains('two overcards')));
  });
}
