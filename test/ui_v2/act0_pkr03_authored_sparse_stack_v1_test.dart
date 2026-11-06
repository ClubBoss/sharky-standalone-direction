import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

Act0TableStateV1 _w4(String taskId) => <Act0LessonTaskV1>[
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == taskId).runner.table;

void main() {
  test('authored W4 sparse-stack legal BB check remains usable', () {
    final source = _w4('w4_protection_intro');
    expect(source.potLabel, 'Pot 6 BB');
    expect(source.actionTrail.last.label, 'Flop: BB checks');
    expect(source.activeSeatId, 'btn');
    expect(
      source.seats
          .where((seat) => seat.isInHand && !seat.isFolded)
          .every((seat) => seat.stackLabel == null),
      isTrue,
    );
    expect(
      act0BettingRoundOrderTruthForTableV1(source),
      Act0BettingRoundOrderTruthV1.unproved,
    );
    expect(act0StreetReplayFromTableV1(source)?.isConsumerSafe, isTrue);
    expect(act0TableChoreographyPlanForTableV1(source), isNotNull);
  });

  test('source-shaped illegal first BTN flop check is blocked', () {
    final source = _w4('w4_protection_intro');
    final trail = source.actionTrail.toList();
    expect(trail.last.label, 'Flop: BB checks');
    trail[trail.length - 1] = const Act0ActionTrailItemV1(
      label: 'Flop: BTN checks',
    );
    final invalid = source.copyWith(actionTrail: trail);
    expect(invalid.potLabel, 'Pot 6 BB');
    expect(invalid.activeSeatId, 'btn');
    expect(
      act0BettingRoundOrderTruthForTableV1(invalid),
      Act0BettingRoundOrderTruthV1.contradiction,
    );
    expect(
      act0StreetReplayFromTableV1(invalid)?.isConsumerSafe ?? false,
      isFalse,
    );
    expect(act0TableChoreographyPlanForTableV1(invalid), isNull);
  });

  test('source-shaped extra bet after W4 check-check is blocked', () {
    final source = _w4('w4_protection_check');
    expect(source.activeSeatId, anyOf(isNull, isEmpty));
    expect(source.potLabel, 'Pot 6 BB');
    expect(source.actionTrail.last.label, 'BTN checks');
    final invalid = source.copyWith(
      actionTrail: <Act0ActionTrailItemV1>[
        ...source.actionTrail,
        const Act0ActionTrailItemV1(label: 'BB bets 1 BB'),
      ],
      activeSeatId: 'bb',
    );
    expect(
      act0BettingRoundOrderTruthForTableV1(invalid),
      Act0BettingRoundOrderTruthV1.contradiction,
    );
    expect(
      act0StreetReplayFromTableV1(invalid)?.isConsumerSafe ?? false,
      isFalse,
    );
    expect(act0TableChoreographyPlanForTableV1(invalid), isNull);
  });
}
