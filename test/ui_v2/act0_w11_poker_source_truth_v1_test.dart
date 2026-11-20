import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('antes add to the pot without offsetting a capped call', () {
    const preflop = PokerStreet.preflop;
    const blind = Act0ContributionKindV1.blind;
    const ante = Act0ContributionKindV1.ante;
    const wager = Act0ContributionKindV1.wager;
    const seats = {'sb', 'bb'};
    const entries = [
      Act0ContributionV1(preflop, 'sb', blind, .5),
      Act0ContributionV1(preflop, 'bb', blind, 1),
      Act0ContributionV1(preflop, 'sb', ante, .25),
      Act0ContributionV1(preflop, 'bb', ante, .25),
      Act0ContributionV1(preflop, 'sb', wager, 1.5),
      Act0ContributionV1(preflop, 'bb', wager, 4),
    ];
    const short = Act0HandContributionsV1(
      throughStreet: preflop,
      startingStackBbBySeat: {'sb': 3, 'bb': 5.25},
      entries: entries,
    );
    expect(short.amounts(seatIds: seats, actorSeatId: 'sb'), (
      potBb: 7.5,
      toCallBb: .75,
    ));

    const fullStack = Act0HandContributionsV1(
      throughStreet: preflop,
      startingStackBbBySeat: {'sb': 10},
      entries: entries,
    );
    expect(fullStack.amounts(seatIds: seats, actorSeatId: 'sb').toCallBb, 3);

    const settled = Act0HandContributionsV1(
      throughStreet: preflop,
      startingStackBbBySeat: {'sb': 3, 'bb': 5.25},
      entries: [
        ...entries,
        Act0ContributionV1(preflop, 'sb', wager, .75),
        Act0ContributionV1(
          preflop,
          'bb',
          Act0ContributionKindV1.uncalledReturn,
          2.25,
        ),
      ],
    );
    expect(settled.amounts(seatIds: seats).potBb, 6);
  });

  test('amounts fail closed on an invalid seat or a later street', () {
    const unknownSeat = Act0HandContributionsV1(
      throughStreet: PokerStreet.preflop,
      entries: [
        Act0ContributionV1(
          PokerStreet.preflop,
          'unknown',
          Act0ContributionKindV1.blind,
          1,
        ),
      ],
    );
    const futureStreet = Act0HandContributionsV1(
      throughStreet: PokerStreet.flop,
      entries: [
        Act0ContributionV1(
          PokerStreet.turn,
          'btn',
          Act0ContributionKindV1.wager,
          2,
        ),
      ],
    );
    for (final ledger in [unknownSeat, futureStreet]) {
      expect(() => ledger.amounts(seatIds: {'btn'}), throwsFormatException);
    }
  });

  test('W11 QJs flop-to-turn is one coherent 35 BB effective hand', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere((l) => l.lessonId == 'table_trigger_reads');
    final flop = lesson.taskList.firstWhere(
      (t) => t.taskId == 'w11_trigger_small_price_continue',
    );
    final turn = lesson.taskList.firstWhere(
      (t) => t.taskId == 'w11_trigger_bad_price_fold',
    );

    expect(flop.runner.table.potLabel, 'Pot 10 BB');
    expect(flop.runner.table.toCallLabel, 'To call 2 BB');
    expect(flop.runner.caption, contains('0.25 BB ante each'));
    expect(flop.runner.caption, contains('35 BB behind'));
    expect(turn.runner.table.potLabel, 'Pot 24 BB');
    expect(turn.runner.table.toCallLabel, 'To call 12 BB');
    expect(turn.runner.caption.toLowerCase(), contains('same hand again'));
    expect(turn.runner.caption, contains('33 BB behind'));
    expect(turn.runner.caption, contains('rarely bluffs'));

    // Preflop: 2*2.5 invested + SB/BB 1.5 + 6*0.25 antes = 8.
    expect(2 * 2.5 + 1.5 + 6 * .25, 8);
    // Flop: a 2 BB bet/call brings the 8 BB pot to 12; both lose 2 BB.
    expect(8 + 2 + 2, 12);
    expect(35 - 2, 33);
    expect(flop.runner.table.boardCards.map((c) => c.rank).toList(), <String>[
      'J',
      '7',
      '4',
    ]);
    expect(turn.runner.table.boardCards.map((c) => c.rank).toList(), <String>[
      'J',
      '7',
      '4',
      '2',
    ]);
    expect(
      flop.runner.table.heroCards.map((c) => c.label).toList(),
      turn.runner.table.heroCards.map((c) => c.label).toList(),
    );
  });

  test('W11 turn fold is opponent-conditioned, not universal poker advice', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere((l) => l.lessonId == 'table_trigger_reads');
    final turn = lesson.taskList.firstWhere(
      (t) => t.taskId == 'w11_trigger_bad_price_fold',
    );
    final fold = turn.runner.options.firstWhere((o) => o.id == 'fold_turn');
    final call = turn.runner.options.firstWhere((o) => o.id == 'call_top_pair');

    expect(fold.isCorrect, isTrue);
    expect(call.isCorrect, isFalse);
    expect(fold.feedbackReason, contains('33%'));
    expect(fold.feedbackReason, contains('rarely bluffs'));
    expect(fold.feedbackReason, contains('not an automatic rule'));
    expect(call.feedbackReason, contains('33%'));
    expect(12 / (12 + 12 + 12), closeTo(1 / 3, 1e-8));
  });
}
