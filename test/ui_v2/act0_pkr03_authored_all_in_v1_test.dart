// Explicit source all-in is terminal for that actor, not necessarily the hand.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

Act0TableStateV1 _source() => Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons)
    .expand((l) => l.taskList)
    .singleWhere((t) => t.taskId == 'w9_bubble_table_risk_transfer')
    .runner
    .table;

void main() {
  test(
    'source BB shove cannot acquire another betting action after a response',
    () {
      final source = _source();
      expect(source.actionTrail.last.label, 'BB shoves to 18 BB');
      final invalid = source.copyWith(
        actionTrail: [
          ...source.actionTrail,
          const Act0ActionTrailItemV1(label: 'BTN calls 18 BB'),
          const Act0ActionTrailItemV1(label: 'BB checks'),
        ],
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
    },
  );

  test('source BB shove cannot become the current poker actor', () {
    final source = _source();
    expect(
      act0BettingRoundOrderTruthForTableV1(source.copyWith(activeSeatId: 'bb')),
      Act0BettingRoundOrderTruthV1.contradiction,
    );
  });

  test(
    'source BTN still owes a response; one all-in does not end the hand',
    () {
      final source = _source();
      expect(source.activeSeatId, 'btn');
      expect(
        act0BettingRoundOrderTruthForTableV1(source),
        Act0BettingRoundOrderTruthV1.unproved,
      );
      expect(source.potLabel, 'Pot 21 BB');
      expect(source.toCallLabel, 'To call 15.5 BB');
    },
  );
}
