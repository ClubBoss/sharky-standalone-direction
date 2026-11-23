import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';

String _fixture(String variant) => File(
  'test/fixtures/hand_history/pokerstars_nlhe_usd_$variant.txt',
).readAsStringSync();

TypeMatcher<Act0HandImportExceptionV1> _error(Act0HandImportErrorV1 code) =>
    isA<Act0HandImportExceptionV1>().having(
      (error) => error.code,
      'code',
      code,
    );

void main() {
  final showdown = _fixture('showdown');
  final fold = _fixture('fold');

  test('normalizes PokerStars cash amounts, actors, streets and showdown', () {
    final hand = Act0ImportedHandV1.parsePokerStars(showdown);
    expect(hand.seats.map((seat) => seat.number), [1, 3, 5]);
    expect(hand.heroSeat, 5);
    expect(hand.buttonSeat, 5);
    expect(hand.heroCards, ['As', 'Qh']);
    expect(hand.board, ['Ad', '7c', '2s', 'Kh', '9d']);
    expect(hand.shownCards, {
      3: ['Ah', 'Th'],
      5: ['As', 'Qh'],
    });
    expect(hand.actions[2], (
      street: PokerStreet.preflop,
      seat: 5,
      kind: Act0ImportedActionKindV1.raise,
      cents: 30,
    ));
    expect(hand.actions.last.street, PokerStreet.river);
    expect(hand.potCents, 245);
    expect(hand.rakeCents, 10);
    expect(hand.payouts, {5: 235});
    expect(hand.showdown, isTrue);
    final encoded = jsonEncode(hand.toPayload());
    for (final raw in ['Example', 'Synthetic Shore', '900000000101']) {
      expect(encoded, isNot(contains(raw)));
    }
    expect(
      Act0ImportedHandV1.tryParse(jsonDecode(encoded))!.toPayload(),
      hand.toPayload(),
    );
  });

  test('rejects a showdown payout to a known losing hand', () {
    final loserPaid = showdown
        .replaceFirst('AlexExample collected', 'CaseyExample collected')
        .replaceFirst('lost with', r'won ($2.35) with')
        .replaceFirst(
          r'AlexExample (button) showed [As Qh] and won ($2.35)',
          'AlexExample (button) showed [As Qh] and lost',
        );
    expect(
      () => Act0ImportedHandV1.parsePokerStars(loserPaid),
      throwsA(_error(Act0HandImportErrorV1.malformedHand)),
    );
  });

  test('uses the declared ET time and reconciles uncalled returns exactly', () {
    final hand = Act0ImportedHandV1.parsePokerStars(fold);
    expect(hand.timeEt, '2026/11/23 02:15:00 ET');
    expect(hand.actions.last, (
      street: PokerStreet.preflop,
      seat: 1,
      kind: Act0ImportedActionKindV1.uncalledReturn,
      cents: 20,
    ));
    expect(hand.potCents, 20);
    expect(hand.payouts, {1: 20});
    expect(hand.board, isEmpty);
    expect(hand.showdown, isFalse);
  });

  test(
    'a matched all-in can run out a single pot without inventing actions',
    () {
      final input = showdown
          .replaceAll(
            RegExp(r'(CaseyExample|AlexExample) \(\$10 in chips\)'),
            r'PLACEHOLDER',
          )
          .replaceFirst('PLACEHOLDER', r'CaseyExample ($0.70 in chips)')
          .replaceFirst('PLACEHOLDER', r'AlexExample ($0.70 in chips)')
          .replaceFirst(r'bets $0.40', r'bets $0.40 and is all-in')
          .replaceFirst(r'calls $0.40', r'calls $0.40 and is all-in')
          .replaceFirst('CaseyExample: checks\nAlexExample: checks\n', '')
          .replaceFirst(
            r'CaseyExample: bets $0.50'
                '\n'
                r'AlexExample: calls $0.50'
                '\n',
            '',
          )
          .replaceAll(r'$2.35', r'$1.35')
          .replaceFirst(r'$2.45', r'$1.45');
      final hand = Act0ImportedHandV1.parsePokerStars(input);
      expect(hand.board, hasLength(5));
      expect(hand.potCents, 145);
      expect(hand.actions.last.street, PokerStreet.flop);
    },
  );

  test('a short all-in call requires its uncalled return', () {
    final input = showdown
        .replaceFirst(
          r'CaseyExample ($10 in chips)',
          r'CaseyExample ($0.60 in chips)',
        )
        .replaceFirst(
          r'CaseyExample: calls $0.40',
          r'CaseyExample: calls $0.30 and is all-in'
              '\n'
              r'Uncalled bet ($0.10) returned to AlexExample',
        )
        .replaceFirst('CaseyExample: checks\nAlexExample: checks\n', '')
        .replaceFirst(
          r'CaseyExample: bets $0.50'
              '\n'
              r'AlexExample: calls $0.50'
              '\n',
          '',
        )
        .replaceAll(r'$2.35', r'$1.15')
        .replaceFirst(r'$2.45', r'$1.25');
    final hand = Act0ImportedHandV1.parsePokerStars(input);
    expect(hand.potCents, 125);
    expect(hand.payouts, {5: 115});
    expect(hand.actions.last, (
      street: PokerStreet.flop,
      seat: 5,
      kind: Act0ImportedActionKindV1.uncalledReturn,
      cents: 10,
    ));
    expect(
      Act0ImportedHandV1.tryParse(hand.toPayload())?.toPayload(),
      hand.toPayload(),
    );
    expect(
      () => Act0ImportedHandV1.parsePokerStars(
        input.replaceFirst(
          r'Uncalled bet ($0.10) returned to AlexExample'
              '\n',
          '',
        ),
      ),
      throwsA(_error(Act0HandImportErrorV1.malformedHand)),
    );
  });

  for (final (description, input) in [
    ('unknown room', fold.replaceFirst('PokerStars', 'UnknownRoom')),
    ('another game', fold.replaceFirst("Hold'em", 'Omaha')),
    ('another currency', fold.replaceFirst('USD', 'EUR')),
    ('tournament', fold.replaceFirst("Hold'em", "Tournament #1, Hold'em")),
  ]) {
    test('rejects unsupported source: $description', () {
      expect(
        () => Act0ImportedHandV1.parsePokerStars(input),
        throwsA(_error(Act0HandImportErrorV1.unsupportedFormat)),
      );
    });
  }

  for (final (description, input) in [
    ('unknown actor', fold.replaceFirst('TestBlind: folds', 'Unknown: folds')),
    ('unknown move', fold.replaceFirst('TestBlind: folds', 'TestBlind: jams')),
    ('duplicate seat', fold.replaceFirst('Seat 2:', 'Seat 1:')),
    (
      'duplicate actor',
      fold.replaceFirst('Seat 2: TestBlind', 'Seat 2: TestButton'),
    ),
    ('invalid timestamp', fold.replaceAll('2026/11/23', '2026/11/31')),
    (
      'missing hole cards',
      fold.replaceFirst('Dealt to TestButton [2s 7d]\n', ''),
    ),
    (
      'out of turn',
      fold.replaceFirst('TestButton: raises', 'TestBlind: raises'),
    ),
    ('inconsistent raise', fold.replaceFirst(r'to $0.30', r'to $0.31')),
    ('false all-in', fold.replaceFirst(r'to $0.30', r'to $0.30 and is all-in')),
    ('invalid refund', fold.replaceFirst(r'bet ($0.20)', r'bet ($0.10)')),
    (
      'wrong contribution total',
      fold.replaceFirst(r'Total pot $0.20', r'Total pot $0.25'),
    ),
    ('wrong payout', fold.replaceFirst(r'collected $0.20', r'collected $0.15')),
    ('unknown side pot', fold.replaceFirst('from pot', 'from side pot')),
    ('truncated summary', fold.split('*** SUMMARY ***').first),
    ('missing seat summary', fold.split('Seat 2: TestBlind (big blind)').first),
    (
      'out-of-order street',
      showdown.replaceFirst('*** TURN ***', '*** RIVER ***'),
    ),
    ('board mismatch', showdown.replaceFirst('Board [Ad 7c', 'Board [Ah 7c')),
    ('duplicate card', showdown.replaceAll('Ah Th', 'As Th')),
    (
      'missing response',
      showdown.replaceFirst(
        r'CaseyExample: calls $0.40'
            '\n',
        '',
      ),
    ),
    ('extra hand', '$fold\n$showdown'),
  ]) {
    test('rejects malformed or ambiguous source: $description', () {
      expect(
        () => Act0ImportedHandV1.parsePokerStars(input),
        throwsA(_error(Act0HandImportErrorV1.malformedHand)),
      );
    });
  }

  test('errors carry a line number and omit names and raw source', () {
    final input = fold.replaceFirst('TestBlind: folds', 'SensitiveName: folds');
    expect(
      () => Act0ImportedHandV1.parsePokerStars(input),
      throwsA(
        _error(Act0HandImportErrorV1.malformedHand)
            .having((error) => error.line, 'line', 10)
            .having(
              (error) => error.toString(),
              'description',
              isNot(contains('SensitiveName')),
            ),
      ),
    );
  });

  test('archive stores and dedupes nine-handed cash imports', () {
    final text = _fixture('nine_max_showdown');
    final archive = const Act0AttemptArchiveV1.empty().importPokerStars(text);
    expect(archive.importPokerStars(text), same(archive));
    final restored = Act0AttemptArchiveV1.restore(
      jsonDecode(jsonEncode(archive.toPayload())),
    );
    expect(restored.importedHands.single.seats, hasLength(9));
    expect(
      restored.importedHands.single.timeline.beforeDecision.replayError(),
      isNull,
    );
    expect(restored.attempts, isEmpty);
  });

  test('archive dedupes by source identity and rejects conflicting copies', () {
    final archive = const Act0AttemptArchiveV1.empty().importPokerStars(fold);
    expect(archive.attempts, isEmpty);
    expect(archive.selected, isNull);
    expect(archive.importedHands.single.potCents, 20);
    final equivalent = '\uFEFF${fold.replaceAll('\n', '\r\n')}';
    expect(archive.importPokerStars(equivalent), same(archive));
    final different = fold.replaceFirst('02:15:00 ET', '02:16:00 ET');
    expect(
      () => archive.importPokerStars(different),
      throwsA(_error(Act0HandImportErrorV1.conflictingSource)),
    );
    expect(archive.importPokerStars(showdown).importedHands, hasLength(2));
  });

  test(
    'archive round trip preserves imports separately and skips corrupt rows',
    () {
      final archive = const Act0AttemptArchiveV1.empty()
          .importPokerStars(fold)
          .importPokerStars(showdown);
      final encoded = jsonEncode(archive.toPayload());
      final restored = Act0AttemptArchiveV1.restore(jsonDecode(encoded));
      expect(restored.toPayload(), archive.toPayload());
      final without = restored.removeImportedHand(
        restored.importedHands.first.sourceKey,
      );
      expect(without.importedHands.single.potCents, 20);
      expect(without.attempts, isEmpty);

      final [first, second] = archive.importedHands;
      final corrupt = {...first.toPayload(), 'potCents': 999};
      final payload = {
        ...archive.toPayload(),
        'importedHands': [corrupt, second.toPayload(), second.toPayload()],
      };
      final recovered = Act0AttemptArchiveV1.restore(payload);
      expect(recovered.importedHands.single.sourceKey, second.sourceKey);
      final conflict = {
        ...second.toPayload(),
        'timeEt': '2026/11/23 02:17:00 ET',
      };
      expect(
        Act0AttemptArchiveV1.restore({
          ...payload,
          'importedHands': [second.toPayload(), conflict],
        }).importedHands,
        isEmpty,
      );
      expect(
        Act0AttemptArchiveV1.restore({
          'format': 1,
          'entries': [],
        }).importedHands,
        isEmpty,
      );
    },
  );
}
