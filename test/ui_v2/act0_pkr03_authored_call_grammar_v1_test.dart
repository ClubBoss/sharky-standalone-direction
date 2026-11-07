// Source-backed negative controls over the unchanged declared first hand.
// Mutations are counterexamples, never replacement catalog history.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

Act0TableStateV1 _source(String id) => Act0ShellStateV1.sample
    .lessonById('your_first_hand')
    .taskList
    .singleWhere((task) => task.taskId == id)
    .runner
    .table;

void _reject(Act0TableStateV1 table) {
  expect(
    act0BettingRoundOrderTruthForTableV1(table),
    Act0BettingRoundOrderTruthV1.contradiction,
  );
  expect(act0StreetReplayFromTableV1(table)?.isConsumerSafe ?? false, isFalse);
  expect(act0TableChoreographyPlanForTableV1(table), isNull);
}

void main() {
  test('source raise-to and additional call do not hide a closed river', () {
    final source = _source('your_first_hand_showdown');
    expect(
      source.actionTrail.any((a) => a.label == 'BTN raises to 3 BB'),
      isTrue,
    );
    expect(
      source.actionTrail.any((a) => a.label == 'BB calls 2 BB more'),
      isTrue,
    );
    expect(source.potLabel, 'Pot 7.5 BB');
    _reject(
      source.copyWith(
        actionTrail: [
          ...source.actionTrail,
          const Act0ActionTrailItemV1(label: 'River: BB bets 1 BB'),
        ],
        activeSeatId: 'bb',
      ),
    );
  });

  test('source raise-to and additional call do not hide an extra flop bet', () {
    final source = _source('your_first_hand_turn');
    final trail = source.actionTrail.toList();
    final turn = trail.indexWhere((a) => a.label == 'Turn: BB checks');
    expect(turn, greaterThan(0));
    trail.insert(
      turn,
      const Act0ActionTrailItemV1(label: 'Flop: BB bets 1 BB'),
    );
    _reject(source.copyWith(actionTrail: trail));
  });

  test(
    'call-more means additional chips and cannot leave a live responder out',
    () {
      final source = _source('your_first_hand_flop');
      final trail = source.actionTrail
          .where((a) => a.label != 'BB calls 2 BB more')
          .toList();
      // BB's source-recorded flop check rules out an earlier silent all-in.
      _reject(source.copyWith(actionTrail: trail));
    },
  );

  test('unchanged source remains unproved rather than inventing stacks', () {
    for (final task
        in Act0ShellStateV1.sample.lessonById('your_first_hand').taskList) {
      expect(
        act0BettingRoundOrderTruthForTableV1(task.runner.table),
        Act0BettingRoundOrderTruthV1.unproved,
        reason: task.taskId,
      );
    }
  });
}
