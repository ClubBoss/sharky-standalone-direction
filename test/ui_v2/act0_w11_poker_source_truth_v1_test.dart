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

  test('a street ledger proves price only if the stack bound covers it', () {
    const flop = PokerStreet.flop;
    const entries = [
      Act0ContributionV1(flop, 'btn', Act0ContributionKindV1.wager, 2),
      Act0ContributionV1(flop, 'bb', Act0ContributionKindV1.wager, 7),
    ];
    const covers = Act0HandContributionsV1(
      fromStreet: flop,
      throughStreet: flop,
      minimumStartingStackBbBySeat: {'btn': 7},
      entries: entries,
    );
    const ambiguous = Act0HandContributionsV1(
      fromStreet: flop,
      throughStreet: flop,
      minimumStartingStackBbBySeat: {'btn': 6},
      entries: entries,
    );
    expect(covers.amounts(seatIds: {'btn', 'bb'}, actorSeatId: 'btn'), (
      potBb: 9,
      toCallBb: 5,
    ));
    expect(
      ambiguous.amounts(seatIds: {'btn', 'bb'}, actorSeatId: 'btn').toCallBb,
      isNull,
    );
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

  Act0LessonTaskV1 taskById(String id) => Act0ShellStateV1.sample
      .worldById('world_11')
      .lessons
      .expand((lesson) => lesson.taskList)
      .singleWhere((task) => task.taskId == id);

  test('W11 mixed-table checkpoint starts with a legal SB flop lead', () {
    final task = taskById('w11_checkpoint_mixed_table_line');
    final table = task.runner.table;
    expect(table.decisionSeatId, 'sb');
    expect(table.seats.where((seat) => seat.bet != null), isEmpty);
    expect(table.potLabel, 'Pot 19 BB');
    expect(table.toCallLabel, isEmpty);
    expect(table.highlightedSeatIds, isEmpty);
    final answer = task.runner.options.singleWhere(
      (choice) => choice.isCorrect,
    );
    expect(answer.label, 'Bet 7 BB');
  });

  test('W11 price drills use two distinct legal ledger frames', () {
    final flop = taskById('w11_trigger_small_price_continue').runner.table;
    final turn = taskById('w11_trigger_bad_price_fold').runner.table;
    expect(flop.heroSeatId, 'bb');
    expect(flop.heroCards.map((card) => card.label), ['Qs', 'Js']);
    expect(flop.boardCards.map((card) => card.label), ['Jh', '7c', '4d']);
    expect(flop.potLabel, 'Pot 12 BB');
    expect(flop.toCallLabel, 'To call 2 BB');
    expect(turn.heroSeatId, 'sb');
    expect(turn.heroCards.map((card) => card.label), ['Kc', 'Qd']);
    expect(turn.boardCards.map((card) => card.label), ['Ks', '8d', '4c', '2h']);
    expect(turn.potLabel, 'Pot 18 BB');
    expect(turn.toCallLabel, 'To call 8 BB');
  });

  test('W11 turn fold depends on its exact opponent range and call price', () {
    final runner = taskById('w11_trigger_bad_price_fold').runner;
    final fold = runner.options.firstWhere((o) => o.id == 'fold');
    final call = runner.options.firstWhere((o) => o.id == 'call_8_bb');
    expect(fold.isCorrect, isTrue);
    expect(call.isCorrect, isFalse);
    expect(fold.feedbackReason, contains('30.8%'));
    expect(fold.feedbackReason, contains('15%'));
    expect(call.feedbackReason, contains('loses 4.1 BB'));
    expect(8 / (18 + 8), closeTo(.3076923077, 1e-8));
    expect(.15 * 18 - .85 * 8, closeTo(-4.1, 1e-8));
  });
}
