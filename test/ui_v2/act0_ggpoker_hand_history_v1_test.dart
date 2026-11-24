import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';

const _sixMax =
    r"""Poker Hand #HD900000000102: Hold'em No Limit ($0.05/$0.10) - 2026/11/23 08:13:00
Table 'Invented Shore' 6-max Seat #4 is the button
Seat 1: Finch ($10 in chips)
Seat 2: Wren ($10 in chips)
Seat 3: Lark ($10 in chips)
Seat 4: Hero ($10 in chips)
Seat 5: Kite ($10 in chips)
Seat 6: Tern ($10 in chips)
Kite: posts small blind $0.05
Tern: posts big blind $0.10
*** HOLE CARDS ***
Dealt to Hero [As Qh]
Finch: folds
Wren: folds
Lark: folds
Hero: raises $0.20 to $0.30
Kite: folds
Tern: calls $0.20
*** FLOP *** [Ad 7c 2s]
Tern: checks
Hero: bets $0.40
Tern: calls $0.40
*** TURN *** [Ad 7c 2s] [Kh]
Tern: checks
Hero: checks
*** RIVER *** [Ad 7c 2s Kh] [9d]
Tern: bets $0.50
Hero: calls $0.50
*** SHOWDOWN ***
Tern: shows [Ah Th] (a pair of Aces)
Hero: shows [As Qh] (a pair of Aces)
Hero collected $2.35 from pot
*** SUMMARY ***
Total pot $2.45 | Rake $0.10 | Jackpot $0 | Bingo $0 | Fortune $0 | Tax $0
Board [Ad 7c 2s Kh 9d]
Seat 1: Finch folded before Flop
Seat 2: Wren folded before Flop
Seat 3: Lark folded before Flop
Seat 4: Hero (button) showed [As Qh] and won ($2.35) with a pair of Aces
Seat 5: Kite (small blind) folded before Flop
Seat 6: Tern (big blind) showed [Ah Th] and lost with a pair of Aces
""";

const _nineMax =
    r"""Poker Hand #HD900000000103: Hold'em No Limit ($0.05/$0.10) - 2026/11/23 08:15:00
Table 'Invented Cove' 9-max Seat #7 is the button
Seat 1: Finch ($10 in chips)
Seat 2: Wren ($10 in chips)
Seat 3: Lark ($10 in chips)
Seat 4: Jay ($10 in chips)
Seat 5: Rook ($10 in chips)
Seat 6: Robin ($10 in chips)
Seat 7: Hero ($10 in chips)
Seat 8: Kite ($10 in chips)
Seat 9: Tern ($10 in chips)
Kite: posts small blind $0.05
Tern: posts big blind $0.10
*** HOLE CARDS ***
Dealt to Hero [2s 7d]
Finch: folds
Wren: folds
Lark: folds
Jay: folds
Rook: folds
Robin: folds
Hero: raises $0.20 to $0.30
Kite: folds
Tern: folds
Uncalled bet ($0.20) returned to Hero
*** SHOWDOWN ***
Hero collected $0.25 from pot
*** SUMMARY ***
Total pot $0.25 | Rake $0
Seat 1: Finch folded before Flop
Seat 2: Wren folded before Flop
Seat 3: Lark folded before Flop
Seat 4: Jay folded before Flop
Seat 5: Rook folded before Flop
Seat 6: Robin folded before Flop
Seat 7: Hero (button) won ($0.25)
Seat 8: Kite (small blind) folded before Flop
Seat 9: Tern (big blind) folded before Flop
""";

TypeMatcher<Act0HandImportExceptionV1> _importError(
  Act0HandImportErrorV1 code,
) => isA<Act0HandImportExceptionV1>().having(
  (error) => error.code,
  'code',
  code,
);

int _sum(Iterable<int> amounts) => amounts.fold(0, (a, b) => a + b);

void main() {
  test(
    'normalizes a complete six-seat GGPoker showdown and balances chips',
    () {
      final hand = Act0ImportedHandV1.parseHandHistory(_sixMax);
      expect(hand.room, 'ggpoker');
      expect(hand.isManual, isFalse);
      expect(hand.timeEt, '2026/11/23 08:13:00');
      expect(hand.tableSize, 6);
      expect(hand.seats, [
        for (var seat = 1; seat <= 6; seat++) (number: seat, stackCents: 1000),
      ]);
      expect(hand.heroSeat, 4);
      expect(hand.heroCards, ['As', 'Qh']);
      expect(hand.board, ['Ad', '7c', '2s', 'Kh', '9d']);
      expect(hand.actions.map((action) => action.street).toSet(), {
        PokerStreet.preflop,
        PokerStreet.flop,
        PokerStreet.turn,
        PokerStreet.river,
      });
      expect(hand.showdown, isTrue);
      expect(hand.payouts, {4: 235});
      expect(hand.potCents, 245);
      expect(hand.rakeCents, 10);
      final endingStacks = {
        for (final seat in hand.seats) seat.number: seat.stackCents,
      };
      for (final action in hand.actions) {
        final delta = action.kind == Act0ImportedActionKindV1.uncalledReturn
            ? action.cents
            : -action.cents;
        endingStacks.update(action.seat, (stack) => stack + delta);
      }
      for (final payout in hand.payouts.entries) {
        endingStacks.update(payout.key, (stack) => stack + payout.value);
      }
      expect(
        _sum(hand.seats.map((seat) => seat.stackCents)),
        _sum(endingStacks.values) + hand.rakeCents,
      );
      final restored = Act0ImportedHandV1.tryParse(hand.toPayload());
      expect(restored?.room, 'ggpoker');
      expect(restored?.hasSameRecord(hand), isTrue);
    },
  );

  test('normalizes a nine-seat fold-out and uncalled return', () {
    final hand = Act0ImportedHandV1.parseHandHistory(_nineMax);
    expect(hand.tableSize, 9);
    expect(hand.seats, hasLength(9));
    expect(hand.showdown, isFalse);
    expect(hand.board, isEmpty);
    expect(hand.actions.last.kind, Act0ImportedActionKindV1.uncalledReturn);
    expect(hand.actions.last.cents, 20);
    expect(hand.payouts, {7: 25});
  });

  test('rejects a real side pot before settlement', () {
    final sidePot = _sixMax
        .replaceFirst(r'Kite ($10 in chips)', r'Kite ($0.20 in chips)')
        .replaceFirst(r'Kite: folds', r'Kite: calls $0.15 and is all-in');
    expect(
      () => Act0ImportedHandV1.parseHandHistory(sidePot),
      throwsA(_importError(Act0HandImportErrorV1.sidePot)),
    );
  });

  for (final (label, source) in [
    ('tournament', _sixMax.replaceFirst('Hand #HD', 'Hand #TM')),
    ('non-USD', _sixMax.replaceFirst(r'$0.10)', r'$0.10 CAD)')),
    ('Rush & Cash', _sixMax.replaceFirst('Hand #HD', 'Hand #RC')),
    (
      'insurance',
      _sixMax.replaceFirst(
        '*** SUMMARY ***',
        'Hero: All-in Insurance accepted\n*** SUMMARY ***',
      ),
    ),
    ('missing summary', _sixMax.split('*** SUMMARY ***').first),
  ]) {
    test('rejects $label with an unsupported reason', () {
      expect(
        () => Act0ImportedHandV1.parseHandHistory(source),
        throwsA(
          _importError(
            Act0HandImportErrorV1.unsupportedFormat,
          ).having((error) => error.reason, 'reason', isNotEmpty),
        ),
      );
    });
  }

  test('rejects a settlement that fails chip conservation', () {
    final unbalanced = _sixMax.replaceAll(r'$2.35', r'$2.34');
    expect(
      () => Act0ImportedHandV1.parseHandHistory(unbalanced),
      throwsA(_importError(Act0HandImportErrorV1.malformedHand)),
    );
  });

  test('keeps same-number hands from both rooms and dedupes GG reimports', () {
    final ps = File(
      'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
    ).readAsStringSync();
    final archive = const Act0AttemptArchiveV1.empty()
        .importPokerStars(ps)
        .importPokerStars(_sixMax);
    expect(archive.importedHands.map((hand) => hand.room), [
      'ggpoker',
      'pokerstars',
    ]);
    expect(
      archive.importedHands.map((hand) => hand.sourceKey).toSet(),
      hasLength(2),
    );
    expect(archive.importHandHistory(_sixMax), same(archive));
    final restored = Act0AttemptArchiveV1.restore(archive.toPayload());
    expect(restored.importedHands.map((hand) => hand.room), [
      'ggpoker',
      'pokerstars',
    ]);
    expect(restored.importHandHistory(_sixMax), same(restored));
    expect(
      Act0ImportedHandV1.parseHandHistory(ps).toPayload(),
      Act0ImportedHandV1.parsePokerStars(ps).toPayload(),
    );
    final unknown = ps.replaceFirst('PokerStars', 'UnknownRoom');
    expect(
      () => Act0ImportedHandV1.parseHandHistory(unknown),
      throwsA(
        _importError(
          Act0HandImportErrorV1.unsupportedFormat,
        ).having((error) => error.reason, 'reason', isNull),
      ),
    );
  });
}
