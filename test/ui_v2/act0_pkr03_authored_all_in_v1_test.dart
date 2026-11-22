// Explicit source all-in is terminal for that actor, not necessarily the hand.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

import '../support/act0_w9_historical_all_in_v1.dart';

void main() {
  test(
    'source BB shove cannot acquire another betting action after a response',
    () {
      final source = act0W9HistoricalAllInV1();
      expect(source.actionTrail.last.label, 'BB all-in 18 BB');
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
    final source = act0W9HistoricalAllInV1();
    expect(
      act0BettingRoundOrderTruthForTableV1(source.copyWith(activeSeatId: 'bb')),
      Act0BettingRoundOrderTruthV1.contradiction,
    );
  });

  test(
    'source BTN still owes a response; one all-in does not end the hand',
    () {
      final source = act0W9HistoricalAllInV1();
      expect(source.activeSeatId, 'btn');
      expect(
        act0BettingRoundOrderTruthForTableV1(source),
        Act0BettingRoundOrderTruthV1.unproved,
      );
      expect(source.potLabel, 'Pot 21 BB');
      expect(source.toCallLabel, isEmpty);
    },
  );

  // The learner word "all-in" and the older "shoves to" grammar read the same
  // hand: price, order, replay and table choreography do not change.
  test('BB all-in reads exactly like BB shoves in every poker reader', () {
    final allIn = act0W9HistoricalAllInV1();
    final shoves = allIn.copyWith(
      actionTrail: [
        for (final a in allIn.actionTrail)
          a.label == 'BB all-in 18 BB'
              ? const Act0ActionTrailItemV1(label: 'BB shoves to 18 BB')
              : a,
      ],
    );
    expect(shoves.actionTrail, isNot(allIn.actionTrail));
    expect(
      act0BettingRoundOrderTruthForTableV1(allIn),
      act0BettingRoundOrderTruthForTableV1(shoves),
    );
    final option = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList)
        .singleWhere((t) => t.taskId == 'w9_bubble_table_risk_transfer')
        .runner
        .options;
    // A numeric call makes the price reader walk the whole history.
    const call = Act0RunnerOptionV1(
      id: 'call_check',
      label: 'Call',
      amountLabel: '18 BB',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'x',
      feedbackReason: 'x',
    );
    String read(Act0BettingPriceResultV1 r) =>
        '${r.truth} ${r.reason} ${r.callCostBb} ${r.amountToMatchBb} '
        '${r.minimumRaiseToBb} ${r.actorCommittedBb}';
    // Hero (BTN) owes the response; name it so the reader walks the history.
    Act0TableStateV1 heroToAct(Act0TableStateV1 t) =>
        t.copyWith(heroSeatId: t.activeSeatId);
    final historyRead = read(
      act0BettingPriceForOptionV1(heroToAct(allIn), call),
    );
    expect(historyRead, isNot(contains('unsupported_history')));
    expect(historyRead, isNot(contains('not_hero_action')));
    expect(
      historyRead,
      read(act0BettingPriceForOptionV1(heroToAct(shoves), call)),
    );
    for (final o in option) {
      expect(
        read(act0BettingPriceForOptionV1(allIn, o)),
        read(act0BettingPriceForOptionV1(shoves, o)),
      );
    }
    final replayA = act0StreetReplayFromTableV1(allIn);
    final replayB = act0StreetReplayFromTableV1(shoves);
    expect(replayA?.isConsumerSafe, replayB?.isConsumerSafe);
    expect(
      act0TableChoreographyPlanForTableV1(allIn) == null,
      act0TableChoreographyPlanForTableV1(shoves) == null,
    );
  });
}
