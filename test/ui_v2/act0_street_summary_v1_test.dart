import 'dart:io';

import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_summary_v1.dart';
import 'package:test/test.dart';

const _cards = ['As', '2h', '3d', '4s', '5s'];

Act0HandTimelinePrefixV1 _prefix(
  int seats,
  PokerStreet street, {
  bool partial = false,
}) {
  const preflop = PokerStreet.preflop;
  const flop = PokerStreet.flop;
  final actions = <Act0HandDeltaV1>[];
  void add(PokerStreet street, int seat, Act0HandVerbV1 verb, int amount) {
    actions.add((
      street: street,
      seat: '$seat',
      verb: verb,
      chipsAdded: amount,
    ));
  }

  if (!partial) {
    add(preflop, 2, Act0HandVerbV1.smallBlind, 50);
    add(preflop, 3, Act0HandVerbV1.bigBlind, 100);
    for (final seat in [...Iterable.generate(seats - 3, (i) => i + 4), 1]) {
      add(preflop, seat, Act0HandVerbV1.fold, 0);
    }
    add(preflop, 2, Act0HandVerbV1.call, 50);
    add(preflop, 3, Act0HandVerbV1.check, 0);
  }
  if (street.index >= flop.index) {
    add(flop, 2, Act0HandVerbV1.bet, 200);
    add(flop, 3, Act0HandVerbV1.call, 200);
  }

  return Act0HandTimelineV1.fromDeltas(
    coverage: partial
        ? Act0HandHistoryCoverageV1.partialDrill
        : Act0HandHistoryCoverageV1.complete,
    startingStacks: {
      for (var seat = 1; seat <= seats; seat++)
        '$seat': seat == 2 ? 300 : 10000,
    },
    button: '1',
    heroSeat: '3',
    smallBlind: 50,
    bigBlind: 100,
    board: _cards.take(const [0, 3, 4, 5][street.index]).toList(),
    actions: actions,
  ).beforeDecision;
}

void main() {
  for (final seats in [6, 9]) {
    for (final street in PokerStreet.values) {
      test('$seats seats, ${street.name} decision', () {
        final prefix = _prefix(seats, street);
        final summary = Act0StreetSummaryV1(prefix);
        expect(summary.heroSeat, '3');
        expect(summary.decisionStreet, street);
        expect(summary.coverage, Act0HandHistoryCoverageV1.complete);
        expect(
          summary.streets.map((row) => row.name),
          PokerStreet.values.take(street.index),
        );
        expect(summary.frameAt(street), isNull);
        expect(summary.frameAt(PokerStreet.river), isNull);
        for (final row in summary.streets) {
          final frame = summary.frameAt(row.name)!;
          final preflop = row.name == PokerStreet.preflop;
          expect(row.potAfterBb, preflop ? 2 : 6);
          expect(frame.potBb, row.potAfterBb);
          expect(frame.board, _cards.take(const [0, 3, 4, 5][row.name.index]));
          expect(row.boardOnStreet, frame.board);
          expect(frame.stacksBb, hasLength(seats));
          expect(frame.stacksBb!['2'], preflop ? 2 : 0);
          expect(frame.stacksBb!['3'], preflop ? 99 : 97);
          expect(frame.foldedSeats, {
            '1',
            for (var i = 4; i <= seats; i++) '$i',
          });
          if (row.name == PokerStreet.flop) {
            expect(row.actions, [
              (seat: '2', verb: Act0HandVerbV1.bet, amountBb: 2.0, allIn: true),
              (
                seat: '3',
                verb: Act0HandVerbV1.call,
                amountBb: 2.0,
                allIn: false,
              ),
            ]);
          }
        }
      });
    }
  }

  test(
    'completed hand exposes the last frame and round-trips hero identity',
    () {
      final prefix = _prefix(6, PokerStreet.river);
      final restored = Act0HandTimelinePrefixV1.tryParse(prefix.toPayload());
      final summary = Act0StreetSummaryV1(restored, completedHand: true);
      expect(summary.heroSeat, '3');
      expect(summary.streets.last.name, PokerStreet.river);
      expect(summary.frameAt(PokerStreet.river)!.board, _cards);
      expect(summary.frameAt(PokerStreet.river)!.potBb, 6);
    },
  );

  test(
    'partial history keeps observed actions and withholds unknown totals',
    () {
      final summary = Act0StreetSummaryV1(
        _prefix(6, PokerStreet.turn, partial: true),
      );
      expect(summary.coverage, Act0HandHistoryCoverageV1.partialDrill);
      expect(summary.streets.first.actions, isEmpty);
      expect(summary.streets.last.actions.map((action) => action.verb), [
        Act0HandVerbV1.bet,
        Act0HandVerbV1.call,
      ]);
      expect(summary.streets.map((row) => row.potAfterBb), [null, null]);
      final frame = summary.frameAt(PokerStreet.flop)!;
      expect(frame.board, _cards.take(3));
      expect(frame.potBb, isNull);
      expect(frame.stacksBb, isNull);
      expect(frame.foldedSeats, isNull);
      expect(summary.amountsAtDecision(actorSeat: '3'), isNull);
    },
  );

  test('completed own hand accounts for an uncalled return before payouts', () {
    final hand = Act0ImportedHandV1.parsePokerStars(
      File(
        'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
      ).readAsStringSync(),
    );
    final summary = Act0StreetSummaryV1(
      hand.timeline.beforeDecision,
      completedHand: true,
    );
    expect(summary.heroSeat, '1');
    expect(summary.streets, isEmpty);
    final frame = summary.frameAt(PokerStreet.preflop)!;
    expect(frame.potBb, closeTo(hand.potCents / hand.bigBlindCents, 1e-9));
    expect(frame.stacksBb, {'1': 99.0, '2': 99.0});
    expect(frame.foldedSeats, {'2'});
  });

  test('a bounded task ignores undealt future cards and actions', () {
    final full = _prefix(6, PokerStreet.river);
    final decision = _prefix(6, PokerStreet.flop);
    final prefix = Act0HandTimelineV1(
      coverage: full.coverage,
      smallBlind: full.smallBlind,
      bigBlind: full.bigBlind,
      startingStacks: full.startingStacks,
      button: full.button,
      events: full.events,
      decisionIndex: decision.events.length - 1,
    ).beforeDecision;
    final summary = Act0StreetSummaryV1(prefix, heroSeat: '3');
    expect(summary.streets.single.potAfterBb, 2);
    expect(summary.frameAt(PokerStreet.flop), isNull);
    expect(summary.frameAt(PokerStreet.river), isNull);
    expect(summary.amountsAtDecision(actorSeat: '3'), (
      potBb: 4.0,
      toCallBb: 2.0,
    ));
  });

  test('missing timeline leaves the decision context and no history', () {
    final summary = Act0StreetSummaryV1(
      null,
      heroSeat: 'bb',
      decisionStreet: PokerStreet.turn,
    );
    expect(summary.coverage, Act0HandHistoryCoverageV1.missing);
    expect(summary.heroSeat, 'bb');
    expect(summary.decisionStreet, PokerStreet.turn);
    expect(summary.streets, isEmpty);
    expect(summary.frameAt(PokerStreet.preflop), isNull);
    expect(summary.amountsAtDecision(actorSeat: 'bb'), isNull);
  });
}
