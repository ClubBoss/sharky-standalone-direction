import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_betting_ledger_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_seat_order_v1.dart';
import 'package:test/test.dart';

void main() {
  test('dealt-in seats determine positions and both street orders', () {
    const positionsByCount = {
      2: 'BTN BB',
      3: 'BTN SB BB',
      4: 'CO BTN SB BB',
      5: 'HJ CO BTN SB BB',
      6: 'UTG HJ CO BTN SB BB',
      7: 'UTG LJ HJ CO BTN SB BB',
      8: 'UTG MP LJ HJ CO BTN SB BB',
      9: 'UTG UTG+1 MP LJ HJ CO BTN SB BB',
    };
    for (final entry in positionsByCount.entries) {
      final occupied = List.generate(entry.key, (index) => index + 1);
      final ring = Act0SeatOrderV1(occupied, occupied.last);
      final preflop = ring.actionOrder(PokerStreet.preflop);
      final postflop = ring.actionOrder(PokerStreet.flop);
      expect(
        preflop.map((seat) => ring.positions[seat]).join(' '),
        entry.value,
      );
      expect(preflop.last, ring.bigBlind);
      expect(postflop.last, ring.button);
      expect(postflop.first, entry.key == 2 ? ring.bigBlind : ring.smallBlind);
      expect(ring.smallBlind, entry.key == 2 ? ring.button : 1);
    }

    final sparse = Act0SeatOrderV1([2, 6, 9], 6);
    expect(sparse.actionOrder(PokerStreet.preflop), [6, 9, 2]);
    expect(sparse.nextAfter(9, eligible: {6, 9}), 6);
    expect(sparse.nextAfter(9, eligible: {}), isNull);
    expect(() => Act0SeatOrderV1([2, 6, 9], 1), throwsFormatException);
  });

  test('a nine-seat ledger splits three all-in levels after the return', () {
    const stacks = [100, 200, 250, 400, 1000, 1000, 1000, 1000, 1000];
    final ledger = Act0HandBettingLedgerV1(
      [
        for (final (index, stack) in stacks.indexed)
          (number: index + 1, stackCents: stack),
      ],
      9,
      7,
      5,
      10,
      allowShortRaises: true,
    );
    final deltas = <Act0HandDeltaV1>[];
    void add(int seat, Act0HandVerbV1 verb, int cents) {
      expect(
        ledger.add((
          street: PokerStreet.preflop,
          seat: seat,
          kind: verb,
          cents: cents,
        )),
        isTrue,
        reason: 'Seat $seat, ${verb.name}',
      );
      deltas.add((
        street: PokerStreet.preflop,
        seat: '$seat',
        verb: verb,
        chipsAdded: verb == Act0HandVerbV1.uncalledReturn ? -cents : cents,
      ));
    }

    add(8, Act0HandVerbV1.smallBlind, 5);
    add(9, Act0HandVerbV1.bigBlind, 10);
    expect(ledger.nextActor, 1);
    add(1, Act0HandVerbV1.raise, 100);
    add(2, Act0HandVerbV1.raise, 200);
    add(3, Act0HandVerbV1.raise, 250);
    add(4, Act0HandVerbV1.raise, 400);
    for (var seat = 5; seat <= 9; seat++) {
      expect(ledger.nextActor, seat);
      add(seat, Act0HandVerbV1.fold, 0);
    }

    expect(ledger.nextActor, isNull);
    expect(ledger.complete, isFalse);
    expect(ledger.potCents, 965);
    expect(ledger.advance(), isFalse);
    add(4, Act0HandVerbV1.uncalledReturn, 150);
    expect(ledger.complete, isTrue);
    expect(ledger.remaining[4], 150);
    expect(ledger.potCents, 815);
    expect(ledger.pots.map((pot) => pot.amountCents), [415, 300, 100]);
    expect(ledger.pots.map((pot) => pot.eligibleSeats), [
      {1, 2, 3, 4},
      {2, 3, 4},
      {3, 4},
    ]);
    expect(ledger.advance(), isTrue);
    expect(ledger.nextActor, isNull);

    final timeline = Act0HandTimelineV1.fromDeltas(
      coverage: Act0HandHistoryCoverageV1.complete,
      startingStacks: {
        for (final (index, stack) in stacks.indexed) '${index + 1}': stack,
      },
      button: '7',
      smallBlind: 5,
      bigBlind: 10,
      board: ['Ad', '7c', '2s', 'Kh', '9d'],
      actions: deltas,
    ).beforeDecision;
    final restored = Act0HandTimelinePrefixV1.tryParse(
      jsonDecode(jsonEncode(timeline.toPayload())),
    )!;
    expect(restored.replayError(), isNull);
    expect(restored.contestablePots!.map((pot) => pot.chips), [415, 300, 100]);
    final c1 = restored.contributions;
    expect(
      c1.amounts(seatIds: restored.startingStacks.keys.toSet()).potBb,
      81.5,
    );
    final pots = c1.contestablePots(activeSeatIds: {'1', '2', '3', '4'})!;
    expect(pots.map((pot) => pot.amountBb), [41.5, 30, 10]);
    expect(pots.map((pot) => pot.eligibleSeatIds), [
      {'1', '2', '3', '4'},
      {'2', '3', '4'},
      {'3', '4'},
    ]);
  });

  test('nine-handed PokerStars survives restoration and timeline replay', () {
    final text = _fixture('nine_max_showdown');
    final hand = Act0ImportedHandV1.parsePokerStars(text);
    expect(hand.tableSize, 9);
    expect(hand.seats.map((seat) => seat.number), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(hand.actions.take(5).map((action) => action.seat), [9, 1, 2, 3, 4]);
    expect(hand.buttonSeat, 8);
    expect(hand.potCents, 245);
    expect(hand.payouts, {3: 235});
    expect(hand.practiceLessonId, 'call_price');
    final payload = jsonEncode(hand.toPayload());
    expect(payload, isNot(contains('PlayerThree')));
    expect(payload, isNot(contains('900000000109')));
    expect(Act0ImportedHandV1.parsePokerStars(text).sourceKey, hand.sourceKey);
    final restored = Act0ImportedHandV1.tryParse(jsonDecode(payload))!;
    expect(restored.toPayload(), hand.toPayload());
    final replay = restored.timeline.beforeDecision;
    expect(replay.replayError(), isNull);
    expect(replay.board, ['Ad', '7c', '2s', 'Kh', '9d']);
    expect(replay.contestablePots!.single.chips, 245);
  });

  test('nine-handed PokerStars rejects an out-of-turn raise', () {
    expect(
      () => Act0ImportedHandV1.parsePokerStars(_fixture('nine_max_bad_order')),
      throwsA(
        isA<Act0HandImportExceptionV1>().having(
          (error) => error.code,
          'code',
          Act0HandImportErrorV1.malformedHand,
        ),
      ),
    );
  });

  test('the existing sparse six-max and heads-up sources still replay', () {
    for (final (variant, amount) in [('showdown', 245), ('fold', 20)]) {
      final hand = Act0ImportedHandV1.parsePokerStars(_fixture(variant));
      expect(hand.potCents, amount);
      expect(hand.timeline.beforeDecision.replayError(), isNull);
      expect(
        hand.timeline.beforeDecision.contestablePots!.single.chips,
        amount,
      );
    }
  });
}

String _fixture(String variant) => File(
  'test/fixtures/hand_history/pokerstars_nlhe_usd_$variant.txt',
).readAsStringSync();
