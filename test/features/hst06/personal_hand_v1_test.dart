import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/pokerstars_text_v1.dart';

const source900 =
    r'''PokerStars Hand #900: Hold'em No Limit ($0.01/$0.02 USD) - 2026/01/01
Table 'Synthetic' 2-max Seat #2 is the button
Seat 1: Alpha ($1.00 in chips)
Seat 2: Beta ($0.80 in chips)
*** HOLE CARDS ***
Dealt to Beta [Ah Kh]
Alpha: calls $0.02
Beta: raises $0.04 to $0.06
Alpha: calls $0.04
*** FLOP *** [2s 3d 4c]
Alpha: checks
Beta: bets $0.08
Alpha: folds
*** SUMMARY ***
Total pot $0.20 | Rake $0.00
Beta collected $0.20 from pot''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final importer = Hst06PokerStarsPreview();
  Hst06Preview good() => importer.parse(source900).single;

  test('declares precisely two supported input paths', () {
    expect(hst06Formats, hasLength(2));
    expect(hst06Formats.last, contains('PokerStars'));
  });

  test('PokerStars actors, hero, button and decimals are source-owned', () {
    final preview = good();
    expect(preview.errors, isEmpty);
    final h = preview.hand!;
    expect(h.roomHandId, '900');
    expect(h.players.map((p) => p.seat), [1, 2]);
    expect(h.heroSeat, 2);
    expect(h.buttonSeat, 2);
    expect(h.heroCards, ['Ah', 'Kh']);
    expect(h.players.first.stack, '1');
    expect(h.players.last.stack, '0.8');
    expect(h.unit, 'USD');
    expect(h.totalPot, '0.2');
    expect(h.collectors, [2]);
    expect(h.actions.map((a) => a.street), [0, 0, 0, 1, 1, 1]);
    expect(h.actions.map((a) => a.kind), [
      'call',
      'raise',
      'call',
      'check',
      'bet',
      'fold',
    ]);
    expect(h.actions[1].amount, '0.06');
    expect(h.actions[1].meaning, 'to');
    expect(h.actions[4].amount, '0.08');
    expect(h.boardCards, ['2s', '3d', '4c']);
  });

  test('missing Hero stays unknown, never first seat', () {
    final p = importer
        .parse(source900.replaceFirst('Dealt to Beta [Ah Kh]\n', ''))
        .single;
    expect(p.canSave, isTrue);
    expect(p.hand!.heroSeat, isNull);
    expect(p.hand!.heroCards, isNull);
    expect(p.warnings.join(' '), contains('Hero unknown'));
  });

  test('unreadable stack stays null, distinguish true zero', () {
    final partial = importer
        .parse(
          source900.replaceFirst(r'($0.80 in chips)', '(unknown in chips)'),
        )
        .single;
    expect(partial.canSave, isTrue);
    expect(partial.hand!.players.last.stack, isNull);
    final zero = importer
        .parse(source900.replaceFirst(r'($0.80 in chips)', r'($0.00 in chips)'))
        .single;
    expect(zero.hand!.players.last.stack, '0');
    expect(zero.hand!.players.last.stack, isNotNull);
    final unreadableSeat = importer
        .parse(
          source900.replaceFirst(r'Seat 2: Beta ($0.80 in chips)', 'Seat 2:'),
        )
        .single;
    expect(unreadableSeat.canSave, isFalse);
    expect(unreadableSeat.errors.join(' '), contains('Unreadable player seat'));
    final omitted = importer
        .parse(
          source900.replaceFirst(
            r'Seat 2: Beta ($0.80 in chips)',
            'Seat 2: Beta',
          ),
        )
        .single;
    expect(omitted.canSave, isTrue);
    expect(omitted.hand!.players, hasLength(2));
    expect(omitted.hand!.players.last.stack, isNull);
  });

  test('duplicate physical cards are rejected before confirmation', () {
    final p = importer
        .parse(source900.replaceFirst('[Ah Kh]', '[Ah 2s]'))
        .single;
    expect(p.canSave, isFalse);
    expect(p.errors.join(' '), contains('repeated card'));
  });

  test('bad board street and later card mutation are errors', () {
    final badLength = importer
        .parse(
          source900.replaceFirst(
            '*** FLOP *** [2s 3d 4c]',
            '*** FLOP *** [2s 3d]',
          ),
        )
        .single;
    expect(badLength.canSave, isFalse);
    expect(badLength.errors.join(' '), contains('board length'));
    final altered = importer
        .parse(
          source900.replaceFirst(
            '*** SUMMARY ***',
            '*** TURN *** [2s 5d 4c] [Th]\n*** SUMMARY ***',
          ),
        )
        .single;
    expect(altered.canSave, isFalse);
    expect(altered.errors.join(' '), contains('board cards changed'));
  });

  test(
    'currency mismatch and malformed amounts are not silently converted',
    () {
      final mixed = importer
          .parse(
            source900.replaceFirst(
              r'Alpha: calls $0.02',
              'Alpha: calls \u20AC0.02',
            ),
          )
          .single;
      expect(mixed.canSave, isFalse);
      expect(mixed.errors.join(' '), contains('Currency symbol'));
      final malformed = importer
          .parse(
            source900.replaceFirst(
              r'Alpha: calls $0.02',
              r'Alpha: calls $0,02',
            ),
          )
          .single;
      expect(malformed.canSave, isFalse);
      expect(malformed.errors.join(' '), contains('Invalid amount'));
    },
  );

  test('raise-from amount is validated independently of raise-to', () {
    final corrupted = <String>[
      r'Beta: raises $0,04 to $0.06',
      r'Beta: raises $00.04 to $0.06',
      r'Beta: raises $123,45 to $0.06',
      r'Beta: raises $0.00001 to $0.06',
    ];
    for (final badAction in corrupted) {
      final preview = importer
          .parse(
            source900.replaceFirst(r'Beta: raises $0.04 to $0.06', badAction),
          )
          .single;
      expect(preview.canSave, isFalse, reason: badAction);
      expect(preview.errors.join(' '), contains('Invalid amount'));
      expect(preview.hand!.actions[1].amount, '0.06');
      expect(preview.hand!.actions[1].meaning, 'to');
    }
    expect(good().canSave, isTrue);
    expect(good().hand!.actions[1].amount, '0.06');
  });

  test('explicit negative call, bet and raise-to fail closed', () {
    final corrupted = <List<String>>[
      [r'Alpha: calls $0.02', r'Alpha: calls -$0.02'],
      [r'Alpha: calls $0.02', r'Alpha: calls $-0.02'],
      [r'Beta: bets $0.08', r'Beta: bets -$0.08'],
      [r'Beta: bets $0.08', r'Beta: bets $-0.08'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04 to -$0.06'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04 to $-0.06'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises -$0.04 to $0.06'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $-0.04 to $0.06'],
    ];
    for (final variant in corrupted) {
      final preview = importer
          .parse(source900.replaceFirst(variant[0], variant[1]))
          .single;
      expect(preview.canSave, isFalse, reason: variant[1]);
      expect(preview.errors.join(' '), contains('negative wager'));
    }
    expect(good().canSave, isTrue);
  });

  test('malformed wager suffix never silently becomes a known amount', () {
    final cases = <List<String>>[
      [r'Alpha: calls $0.02', r'Alpha: calls $0.02garbage'],
      [r'Alpha: calls $0.02', r'Alpha: calls $0.02x'],
      [r'Beta: bets $0.08', r'Beta: bets $0.08junk'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04 to $0.06x'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04x to $0.06'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04 to $0.06garbage'],
    ];
    for (final variant in cases) {
      final p = importer
          .parse(source900.replaceFirst(variant[0], variant[1]))
          .single;
      expect(p.canSave, isFalse, reason: variant[1]);
      expect(p.errors.join(' '), contains('Malformed explicit wager'));
    }

    final allIn = importer
        .parse(
          source900.replaceFirst(
            r'Beta: bets $0.08',
            r'Beta: bets $0.08 and is all-in',
          ),
        )
        .single;
    expect(allIn.canSave, isTrue);
    expect(allIn.hand!.actions[4].amount, '0.08');

    final unknown = importer
        .parse(source900.replaceFirst(r'Alpha: calls $0.02', 'Alpha: calls'))
        .single;
    expect(unknown.canSave, isTrue);
    expect(unknown.hand!.actions.first.amount, isNull);
    expect(unknown.warnings.join(' '), contains('amount unknown'));
  });

  test('whitespace-delimited wager tails fail closed', () {
    final cases = <List<String>>[
      [r'Alpha: calls $0.02', r'Alpha: calls $0.02 garbage'],
      [r'Alpha: calls $0.02', r'Alpha: calls $0.02 $0.03'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04 to $0.06 extra'],
      [r'Beta: raises $0.04 to $0.06', r'Beta: raises $0.04 to $0.06 $0.07'],
    ];
    for (final pair in cases) {
      final p = importer.parse(source900.replaceFirst(pair[0], pair[1])).single;
      expect(p.canSave, isFalse, reason: pair[1]);
      expect(p.errors.join(' '), contains('Malformed explicit wager'));
    }
    final legitimate = importer
        .parse(
          source900.replaceFirst(
            r'Beta: raises $0.04 to $0.06',
            r'Beta: raises $0.04 to $0.06 and is all-in',
          ),
        )
        .single;
    expect(legitimate.canSave, isTrue);
    expect(legitimate.hand!.actions[1].amount, '0.06');
  });

  test('check or fold with explicit payload is a blocking error', () {
    final cases = <List<String>>[
      [r'Alpha: checks', r'Alpha: checks $0.02'],
      [r'Alpha: checks', 'Alpha: checks extra'],
      [r'Alpha: folds', 'Alpha: folds while raising'],
      [r'Alpha: folds', r'Alpha: folds $0.08'],
    ];
    for (final pair in cases) {
      final preview = importer
          .parse(source900.replaceFirst(pair[0], pair[1]))
          .single;
      expect(preview.canSave, isFalse, reason: pair[1]);
      expect(
        preview.errors.join(' '),
        contains('Unexpected check/fold payload'),
      );
    }
    expect(good().canSave, isTrue);
  });

  test('explicit action by unseated player fails closed', () {
    final ghost = importer
        .parse(
          source900.replaceFirst(r'Beta: bets $0.08', r'Ghost: bets $0.08'),
        )
        .single;
    expect(ghost.canSave, isFalse);
    expect(ghost.errors.join(' '), contains('Unseated action actor'));
    expect(ghost.hand!.actions.where((a) => a.kind == 'bet'), isEmpty);
    expect(good().canSave, isTrue);
  });

  test('malformed pot suffix is blocked; valid rake is preserved', () {
    for (final altered in [
      r'Total pot $0.20 garbage | Rake $0.00',
      r'Total pot $0.20x | Rake $0.00',
      r'Total pot $0.20 | Rake $0.00 garbage',
      r'Total pot $0.20 | Rake $-0.00',
    ]) {
      final preview = importer
          .parse(
            source900.replaceFirst(r'Total pot $0.20 | Rake $0.00', altered),
          )
          .single;
      expect(preview.canSave, isFalse, reason: altered);
      expect(preview.errors, isNotEmpty);
    }
    expect(good().canSave, isTrue);
    expect(good().hand!.totalPot, '0.2');
  });

  test('street sequence cannot skip, reverse, or repeat', () {
    final broken = <String>[
      source900.replaceFirst(
        '*** FLOP *** [2s 3d 4c]',
        '*** RIVER *** [2s 3d 4c Th 9s]',
      ),
      source900.replaceFirst(
        '*** FLOP *** [2s 3d 4c]',
        '*** TURN *** [2s 3d 4c] [Th]',
      ),
      source900.replaceFirst(
        '*** SUMMARY ***',
        '*** FLOP *** [2s 3d 4c]\n*** SUMMARY ***',
      ),
    ];
    for (final input in broken) {
      final preview = importer.parse(input).single;
      expect(preview.canSave, isFalse);
      expect(
        preview.errors.join(' '),
        contains('Out-of-order or skipped street'),
      );
    }
    final naturalRunout = source900
        .replaceFirst('Alpha: folds', r'Alpha: calls $0.08')
        .replaceFirst(r'Total pot $0.20', r'Total pot $0.28')
        .replaceFirst(r'Beta collected $0.20', r'Beta collected $0.28')
        .replaceFirst(
          '*** SUMMARY ***',
          '*** TURN *** [2s 3d 4c] [Th]\n'
              '*** RIVER *** [2s 3d 4c Th] [9s]\n'
              '*** SUMMARY ***',
        );
    final accepted = importer.parse(naturalRunout).single;
    expect(accepted.canSave, isTrue);
    expect(accepted.hand!.boardCards, ['2s', '3d', '4c', 'Th', '9s']);
  });

  test('collected payouts must be exact seated source facts', () {
    const malformed = [
      r'Beta collected $0.20garbage from pot',
      r'Beta collected $0.20 $9.99 from pot',
      r'Beta collected $-0.20 from pot',
      r'Beta collected -$0.20 from pot',
      r'Beta collected $0,20 from pot',
      r'Beta collected $0.20 from pot extra',
      r'Ghost collected $0.20 from pot',
      r'Seat 1: Beta collected $0.20 from pot',
      'Beta collected \u20AC0.20 from pot',
    ];
    for (final payout in malformed) {
      final raw = source900.replaceFirst(
        r'Beta collected $0.20 from pot',
        payout,
      );
      final preview = importer.parse(raw).single;
      expect(preview.canSave, isFalse, reason: payout);
      expect(preview.errors, isNotEmpty, reason: payout);
    }
    final valid = importer
        .parse(
          source900.replaceFirst(
            r'Beta collected $0.20 from pot',
            r'Seat 2: Beta collected $0.20 from pot',
          ),
        )
        .single;
    expect(valid.canSave, isTrue);
    expect(valid.hand!.collectors, [2]);
  });

  test('cash SUMMARY payout and action payout reconcile without guessing', () {
    const summaries = [
      r'Seat 2: Beta collected ($0.20)',
      r'Seat 2: Beta (button) collected ($0.20)',
      r'Seat 2: Beta (button) (small blind) collected ($0.20)',
    ];
    for (final summary in summaries) {
      final summaryOnly = importer
          .parse(
            source900.replaceFirst(r'Beta collected $0.20 from pot', summary),
          )
          .single;
      expect(summaryOnly.canSave, isTrue, reason: summary);
      expect(summaryOnly.hand!.collectors, [2], reason: summary);
      final both = importer.parse('$source900\n$summary').single;
      expect(both.canSave, isTrue, reason: summary);
      expect(both.hand!.collectors, [2], reason: summary);
    }
    final mismatched = importer
        .parse(source900 + '\n' + r'Seat 2: Beta collected ($0.19)')
        .single;
    expect(mismatched.canSave, isFalse);
    expect(mismatched.errors.join(' '), contains('Conflicting collected'));
  });

  test('malformed cash SUMMARY cannot invent collector or amount', () {
    const broken = [
      r'Seat 2: Beta collected ($-0.20)',
      r'Seat 2: Beta collected ($0.20garbage)',
      r'Seat 1: Beta collected ($0.20)',
      r'Seat 2: Ghost collected ($0.20)',
      r'Seat 2: Beta (button) collected ($0.20extra)',
      r'Seat 2: Beta collected($0.20)',
      r'Seat 2: Ghost collected($0.20)',
      r'Seat 2: Beta collected($-0.20)',
    ];
    for (final summary in broken) {
      final preview = importer
          .parse(
            source900.replaceFirst(r'Beta collected $0.20 from pot', summary),
          )
          .single;
      expect(preview.canSave, isFalse, reason: summary);
      expect(preview.errors, isNotEmpty, reason: summary);
    }
  });

  test('role-labelled payout intent cannot omit its amount', () {
    for (final roles in [
      '(button)',
      '(small blind)',
      '(big blind)',
      '(button) (small blind)',
    ]) {
      for (final tail in ['collected ()', 'collected', 'collected()']) {
        final receipt = 'Seat 2: Beta $roles $tail';
        for (final hand in [
          source900.replaceFirst(r'Beta collected $0.20 from pot', receipt),
          '$source900\n$receipt',
        ]) {
          final preview = importer.parse(hand).single;
          expect(preview.canSave, isFalse, reason: receipt);
          expect(
            preview.errors.join(' '),
            contains('Malformed collected payout'),
            reason: receipt,
          );
        }
      }
    }
  });

  test('payout intent preserves literal and action-word nicknames', () {
    for (final name in ['Beta (button)', 'Beta (club)', 'Calls', 'A+B']) {
      final hand = source900.replaceAll('Beta', name);
      final transaction = '$name collected \$0.20 from pot';
      final receipt = 'Seat 2: $name collected (\$0.20)';
      for (final valid in [
        hand,
        hand.replaceFirst(transaction, receipt),
        '$hand\n$receipt',
      ]) {
        final preview = importer.parse(valid).single;
        expect(preview.canSave, isTrue, reason: name);
        expect(preview.errors, isEmpty, reason: name);
        expect(preview.hand!.collectors, [2], reason: name);
        expect(preview.hand!.actions, hasLength(6), reason: name);
      }
      for (final tail in ['collected ()', 'collected', 'collected()']) {
        final broken = 'Seat 2: $name $tail';
        for (final invalid in [
          hand.replaceFirst(transaction, broken),
          '$hand\n$broken',
        ]) {
          final preview = importer.parse(invalid).single;
          expect(preview.canSave, isFalse, reason: broken);
          expect(
            preview.errors.join(' '),
            contains('Malformed collected payout'),
            reason: broken,
          );
        }
      }
    }
  });

  test('role payout intent cannot promote a prefix or a wrong seat', () {
    for (final receipt in const [
      r'Seat 1: Beta (button) collected ($0.20)',
      r'Seat 2: BetaExtra (button) collected ($0.20)',
      r'Beta (button) collected $0.20 from pot',
    ]) {
      for (final hand in [
        source900.replaceFirst(r'Beta collected $0.20 from pot', receipt),
        '$source900\n$receipt',
      ]) {
        final preview = importer.parse(hand).single;
        expect(preview.canSave, isFalse, reason: receipt);
        expect(
          preview.errors.join(' '),
          contains('mismatched collected actor'),
          reason: receipt,
        );
      }
    }
  });

  test('SUMMARY cannot relabel a known nickname as a seat role', () {
    final withThirdSeat = source900
        .replaceFirst('2-max', '3-max')
        .replaceFirst(
          r'Seat 2: Beta ($0.80 in chips)',
          r'Seat 2: Beta ($0.80 in chips)' +
              '\n' +
              r'Seat 3: Beta (button) ($0.70 in chips)',
        );
    final wrongSeat = importer
        .parse(
          withThirdSeat.replaceFirst(
            r'Beta collected $0.20 from pot',
            r'Seat 2: Beta (button) collected ($0.20)',
          ),
        )
        .single;
    expect(wrongSeat.canSave, isFalse);
    expect(wrongSeat.errors.join(' '), contains('mismatched collected actor'));
    final correctSeat = importer
        .parse(
          withThirdSeat.replaceFirst(
            r'Beta collected $0.20 from pot',
            r'Seat 3: Beta (button) collected ($0.20)',
          ),
        )
        .single;
    expect(correctSeat.canSave, isTrue);
    expect(correctSeat.hand!.collectors, [3]);
  });

  test('player names containing payout and context words are legal', () {
    const names = [
      'Collected',
      'Mr Collected',
      'Dealt to Beta',
      'Uncalled bet',
      'Beta (button)',
    ];
    for (final name in names) {
      final preview = importer.parse(source900.replaceAll('Beta', name)).single;
      expect(preview.canSave, isTrue, reason: name);
      expect(preview.errors, isEmpty, reason: name);
      expect(preview.hand!.collectors, [2], reason: name);
    }
  });

  test('dealt-to and returned-uncalled words are not payout events', () {
    final overlapping = source900
        .replaceAll('Beta', 'Beta collected')
        .replaceAll('Alpha', 'Dealt to Beta');
    final legitimate = importer.parse(overlapping).single;
    expect(legitimate.canSave, isTrue);
    expect(legitimate.errors, isEmpty);
    expect(legitimate.hand!.collectors, [2]);

    final returned = importer
        .parse(
          source900
              .replaceAll('Beta', 'Beta collected')
              .replaceFirst(
                '*** SUMMARY ***',
                'Uncalled bet (\$0.03) returned to Beta collected\n*** SUMMARY ***',
              ),
        )
        .single;
    expect(returned.canSave, isTrue);
    expect(returned.errors, isEmpty);
    expect(returned.hand!.collectors, [2]);
  });

  test('SUMMARY payout collision with a player named Beta collected', () {
    final collision = source900.replaceAll('Alpha', 'Beta collected');
    const summary = r'Seat 2: Beta collected ($0.20)';
    final summaryOnly = importer
        .parse(
          collision.replaceFirst(r'Beta collected $0.20 from pot', summary),
        )
        .single;
    expect(summaryOnly.canSave, isTrue);
    expect(summaryOnly.hand!.collectors, [2]);

    final both = importer.parse('$collision\n$summary').single;
    expect(both.canSave, isTrue);
    expect(both.hand!.collectors, [2]);

    final wrongSeat = importer
        .parse(
          collision.replaceFirst(
            r'Beta collected $0.20 from pot',
            r'Seat 1: Beta collected ($0.20)',
          ),
        )
        .single;
    expect(wrongSeat.canSave, isFalse);
    expect(wrongSeat.errors.join(' '), contains('mismatched collected actor'));

    final conflict = importer
        .parse('$collision\n' + r'Seat 2: Beta collected ($0.19)')
        .single;
    expect(conflict.canSave, isFalse);
    expect(conflict.errors.join(' '), contains('Conflicting collected'));

    final malformed = importer
        .parse(
          collision.replaceFirst(
            r'Beta collected $0.20 from pot',
            r'Seat 2: Beta collected ($-0.20)',
          ),
        )
        .single;
    expect(malformed.canSave, isFalse);
    expect(malformed.errors.join(' '), contains('Malformed collected'));
  });

  test(
    'losing SUMMARY lines use literal seated names, not payout prefixes',
    () {
      final collision = source900.replaceAll('Alpha', 'Beta collected');
      // The original synthetic hand really ends in a flop fold.
      for (final losingLine in const [
        'Seat 1: Beta collected folded on the Flop',
        'Seat 1: Beta collected (big blind) folded on the Flop',
      ]) {
        final preview = importer.parse('$collision\n$losingLine').single;
        expect(preview.canSave, isTrue, reason: losingLine);
        expect(preview.errors, isEmpty, reason: losingLine);
        expect(preview.hand!.collectors, [2], reason: losingLine);
      }

      // A separate coherent showdown: both players contributed $0.14,
      // and Q-high loses to the Hero's A-high on [2s 3d 4c].
      final showdown = collision
          .replaceFirst('Beta collected: folds', r'Beta collected: calls $0.08')
          .replaceFirst(
            r'Total pot $0.20 | Rake $0.00',
            r'Total pot $0.28 | Rake $0.00',
          )
          .replaceFirst(
            r'Beta collected $0.20 from pot',
            r'Beta collected $0.28 from pot',
          );
      for (final losingLine in const [
        'Seat 1: Beta collected mucked [Qc 7s]',
        'Seat 1: Beta collected showed [Qc 7s] and lost',
      ]) {
        final preview = importer.parse('$showdown\n$losingLine').single;
        expect(preview.canSave, isTrue, reason: losingLine);
        expect(preview.errors, isEmpty, reason: losingLine);
        expect(preview.hand!.collectors, [2], reason: losingLine);
      }
      // The wrong seat cannot borrow another player's nickname to skip payout
      // validation. Malformed payout records still fail closed.
      final wrongSeat = importer
          .parse('$collision\nSeat 2: Beta collected folded on the Flop')
          .single;
      expect(wrongSeat.canSave, isFalse);
      expect(wrongSeat.errors.join(' '), contains('Malformed collected'));
      final malformed = importer
          .parse(
            collision.replaceFirst(
              r'Beta collected $0.20 from pot',
              r'Seat 2: Beta collected($-0.20)',
            ),
          )
          .single;
      expect(malformed.canSave, isFalse);
    },
  );

  test('full coherent PokerStars cash showdown describes won/lost hands', () {
    const hand =
        r'''PokerStars Hand #900: Hold'em No Limit ($0.01/$0.02 USD) - 2026/01/01
Table 'Synthetic' 2-max Seat #2 is the button
Seat 1: Beta collected ($1.00 in chips)
Seat 2: Beta ($0.80 in chips)
*** HOLE CARDS ***
Dealt to Beta [Ah Kh]
Beta collected: calls $0.02
Beta: raises $0.04 to $0.06
Beta collected: calls $0.04
*** FLOP *** [2s 3d 4c]
Beta collected: checks
Beta: bets $0.08
Beta collected: calls $0.08
*** TURN *** [2s 3d 4c] [Th]
Beta collected: checks
Beta: checks
*** RIVER *** [2s 3d 4c Th] [9s]
Beta collected: checks
Beta: checks
*** SHOW DOWN ***
Beta collected: shows [Qc Jd] (high card Queen)
Beta: shows [Ah Kh] (high card Ace)
Beta collected $0.28 from pot
*** SUMMARY ***
Total pot $0.28 | Rake $0.00
Board [2s 3d 4c Th 9s]
Seat 1: Beta collected showed [Qc Jd] and lost with high card, Queen
Seat 2: Beta (button) showed [Ah Kh] and won ($0.28) with high card, Ace''';
    final preview = importer.parse(hand).single;
    expect(preview.errors, isEmpty);
    expect(preview.canSave, isTrue);
    expect(preview.hand!.collectors, [2]);
    expect(preview.hand!.heroSeat, 2);
    expect(preview.hand!.totalPot, '0.28');

    final role = importer
        .parse(
          hand.replaceFirst(
            'Seat 1: Beta collected showed',
            'Seat 1: Beta collected (big blind) showed',
          ),
        )
        .single;
    expect(role.errors, isEmpty);
    expect(role.canSave, isTrue);
    expect(role.hand!.collectors, [2]);

    final wrongSeat = importer
        .parse(
          hand.replaceFirst(
            'Seat 1: Beta collected showed',
            'Seat 2: Beta collected showed',
          ),
        )
        .single;
    expect(wrongSeat.canSave, isFalse);
    expect(wrongSeat.errors.join(' '), contains('Malformed collected'));

    final negative = importer
        .parse(
          hand.replaceFirst(
            r'Beta collected $0.28 from pot',
            r'Beta collected $-0.28 from pot',
          ),
        )
        .single;
    expect(negative.canSave, isFalse);
    expect(negative.errors, isNotEmpty);
  });

  test('SUMMARY action-verb nicknames validate collected source facts', () {
    for (final name in ['Calls', 'Checks', 'Raises']) {
      final hand = source900.replaceAll('Beta', name);
      final transaction = '$name collected \$0.20 from pot';
      final receipt = 'Seat 2: $name collected (\$0.20)';
      final summaryOnly = importer
          .parse(hand.replaceFirst(transaction, receipt))
          .single;
      expect(summaryOnly.errors, isEmpty, reason: name);
      expect(summaryOnly.canSave, isTrue, reason: name);
      expect(summaryOnly.hand!.collectors, [2], reason: name);
      expect(summaryOnly.hand!.actions, hasLength(6), reason: name);

      final negative = importer
          .parse(
            hand.replaceFirst(transaction, 'Seat 2: $name collected (\$-0.20)'),
          )
          .single;
      expect(negative.canSave, isFalse, reason: name);
      expect(negative.errors.join(' '), contains('Malformed collected'));

      final malformed = importer
          .parse(
            hand.replaceFirst(transaction, 'Seat 2: $name collected(\$0.20)'),
          )
          .single;
      expect(malformed.canSave, isFalse, reason: name);
      expect(malformed.errors.join(' '), contains('Malformed collected'));

      final conflict = importer
          .parse('$hand\nSeat 2: $name collected (\$0.19)')
          .single;
      expect(conflict.canSave, isFalse, reason: name);
      expect(conflict.errors.join(' '), contains('Conflicting collected'));

      final wrongSeat = importer
          .parse(
            hand.replaceFirst(transaction, 'Seat 1: $name collected (\$0.20)'),
          )
          .single;
      expect(wrongSeat.canSave, isFalse, reason: name);
      expect(
        wrongSeat.errors.join(' '),
        contains('mismatched collected actor'),
      );
    }
  });

  test('negative source stack and pot fail closed', () {
    final negativeStack = importer
        .parse(
          source900.replaceFirst(r'($0.80 in chips)', r'($-1.00 in chips)'),
        )
        .single;
    expect(negativeStack.canSave, isFalse);
    expect(negativeStack.errors.join(' '), contains('Invalid stack'));

    final negativePot = importer
        .parse(source900.replaceFirst(r'Total pot $0.20', r'Total pot $-0.20'))
        .single;
    expect(negativePot.canSave, isFalse);
    expect(negativePot.errors.join(' '), contains('Invalid total pot'));
  });

  test('tournament source and damaged street header never guess a street', () {
    final tournament = importer
        .parse(
          source900.replaceFirst(
            "PokerStars Hand #900: Hold'em No Limit",
            "PokerStars Hand #900: Tournament #42, Hold'em No Limit",
          ),
        )
        .single;
    expect(tournament.canSave, isFalse);
    expect(tournament.errors.join(' '), contains('Tournament'));

    final damaged = importer
        .parse(source900.replaceFirst('*** FLOP ***', '*** FLOP **'))
        .single;
    expect(damaged.canSave, isFalse);
    expect(damaged.errors.join(' '), contains('damaged street'));
  });

  test('unsupported room and damaged text emit visible errors', () {
    for (final text in [
      'GGPoker Hand #123: anything',
      r"PokerStars Hand #123: Tournament #77, Hold'em No Limit",
      'Winamax Poker - Game #123',
      'Hand #123: generic room',
      'garbled hand history',
    ]) {
      final p = importer.parse(text).single;
      expect(p.canSave, isFalse, reason: text);
      expect(p.errors, isNotEmpty);
    }
  });

  test('multi-hand paste gives independent previews', () {
    final previews = importer.parse(
      source900 + '\n' + source900.replaceAll('#900:', '#901:'),
    );
    expect(previews, hasLength(2));
    expect(previews.every((p) => p.canSave), isTrue);
    expect(previews.first.hand!.roomHandId, '900');
    expect(previews.last.hand!.roomHandId, '901');
  });

  test('manual known/unknown fields and explicitly zero stack', () {
    final p = hst06Manual(
      title: 'Live note',
      unit: 'chips',
      players: const [
        Hst06Player(1, 'North', '0'),
        Hst06Player(2, 'South', null),
      ],
      hole: '',
      board: '',
      heroSeat: null,
    );
    expect(p.canSave, isTrue);
    expect(p.hand!.players.first.stack, '0');
    expect(p.hand!.players.last.stack, isNull);
    expect(p.hand!.heroSeat, isNull);
    expect(p.warnings, contains('Hero unknown.'));
  });

  test('explicit BB is a source unit, not a conversion', () {
    final p = hst06Manual(
      title: 'BB-labelled note',
      unit: 'BB',
      players: const [
        Hst06Player(1, 'First', '100'),
        Hst06Player(2, 'Second', '0'),
      ],
      pot: '2.5',
    );
    expect(p.canSave, isTrue);
    expect(p.hand!.unit, 'BB');
    expect(p.hand!.totalPot, '2.5');
    expect(p.hand!.players.last.stack, '0');
  });

  test('manual duplicate seats and missing names cannot save', () {
    final p = hst06Manual(
      title: 'Broken seats',
      players: const [
        Hst06Player(2, 'Player', '50'),
        Hst06Player(2, 'Player', null),
      ],
    );
    expect(p.canSave, isFalse);
    expect(p.errors.join(' '), contains('Repeated or invalid seat'));
    expect(p.errors.join(' '), contains('Repeated or missing player name'));
  });

  test('manual illegal actors, cards, units and wagers fail closed', () {
    final p = hst06Manual(
      title: 'Bad action',
      players: const [Hst06Player(1, 'A', null), Hst06Player(2, 'B', null)],
      hole: 'Ah Ah',
      actions: const [
        Hst06Action(4, 5, 'raise', amount: '1.50', meaning: 'additional'),
      ],
    );
    expect(p.canSave, isFalse);
    expect(p.errors.join(' '), contains('repeated card'));
    expect(p.errors.join(' '), contains('invalid actor'));
    expect(p.errors.join(' '), contains('raise-to'));
  });

  test('confirm is once-only, locally persisted, no automatic spot', () async {
    final store = Hst06PersonalStore();
    final original = good();
    expect(await store.load(), isEmpty);
    final saved = await store.confirm(original);
    expect(saved.kind, Hst06SaveKind.saved);
    expect(saved.stored!.revision, 1);
    expect(saved.stored!.localId, isNotEmpty);
    expect(saved.stored!.sourceDigest, isNotEmpty);
    expect((await store.load()).single.roomHandId, '900');
    // A fresh store instance reads the same local hand, without an XP ledger.
    expect(
      (await Hst06PersonalStore().load()).single.localId,
      saved.stored!.localId,
    );
    final duplicate = await store.confirm(original);
    expect(duplicate.kind, Hst06SaveKind.duplicate);
    expect(await store.load(), hasLength(1));
  });

  test(
    'same room ID conflicting content is withheld, not overwritten',
    () async {
      final store = Hst06PersonalStore();
      await store.confirm(good());
      final changed = importer
          .parse(source900.replaceFirst(r'Total pot $0.20', r'Total pot $0.22'))
          .single;
      final conflict = await store.confirm(changed);
      expect(conflict.kind, Hst06SaveKind.conflict);
      expect((await store.load()).single.totalPot, '0.2');
    },
  );

  test(
    'explicit revision increments with CAS; stale revision rejected',
    () async {
      final store = Hst06PersonalStore();
      final first = await store.confirm(good());
      final changed = importer
          .parse(source900.replaceFirst(r'Total pot $0.20', r'Total pot $0.22'))
          .single;
      final changedResult = await store.revise(
        changed,
        first.stored!.localId,
        1,
      );
      expect(changedResult.kind, Hst06SaveKind.saved);
      expect(changedResult.stored!.revision, 2);
      final stale = await store.revise(changed, first.stored!.localId, 1);
      expect(stale.kind, Hst06SaveKind.conflict);
      expect((await store.load()).single.revision, 2);
    },
  );

  test(
    'corrupt persisted schema refuses save and does not destroy bytes',
    () async {
      SharedPreferences.setMockInitialValues({
        Hst06PersonalStore.storageKey: '{corrupted-json',
      });
      final store = Hst06PersonalStore();
      await expectLater(store.confirm(good()), throwsFormatException);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(Hst06PersonalStore.storageKey), '{corrupted-json');
    },
  );

  test('preview without confirmation has no storage side effect', () async {
    final store = Hst06PersonalStore();
    expect(good().canSave, isTrue);
    expect(await store.load(), isEmpty);
  });
}
