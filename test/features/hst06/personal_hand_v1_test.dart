import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/pokerstars_text_v1.dart';

const source900 = r'''PokerStars Hand #900: Hold'em No Limit ($0.01/$0.02 USD) - 2026/01/01
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
    expect(h.actions.map((a) => a.kind),
        ['call', 'raise', 'call', 'check', 'bet', 'fold']);
    expect(h.actions[1].amount, '0.06');
    expect(h.actions[1].meaning, 'to');
    expect(h.actions[4].amount, '0.08');
    expect(h.boardCards, ['2s', '3d', '4c']);
  });

  test('missing Hero stays unknown, never first seat', () {
    final p = importer.parse(source900.replaceFirst(
      'Dealt to Beta [Ah Kh]\n', '',
    )).single;
    expect(p.canSave, isTrue);
    expect(p.hand!.heroSeat, isNull);
    expect(p.hand!.heroCards, isNull);
    expect(p.warnings.join(' '), contains('Hero unknown'));
  });

  test('unreadable stack stays null, distinguish true zero', () {
    final partial = importer.parse(source900.replaceFirst(
      r'($0.80 in chips)', '(unknown in chips)',
    )).single;
    expect(partial.canSave, isTrue);
    expect(partial.hand!.players.last.stack, isNull);
    final zero = importer.parse(source900.replaceFirst(
      r'($0.80 in chips)', r'($0.00 in chips)',
    )).single;
    expect(zero.hand!.players.last.stack, '0');
    expect(zero.hand!.players.last.stack, isNotNull);
    final unreadableSeat = importer.parse(source900.replaceFirst(
      r'Seat 2: Beta ($0.80 in chips)', 'Seat 2:',
    )).single;
    expect(unreadableSeat.canSave, isFalse);
    expect(unreadableSeat.errors.join(' '), contains('Unreadable player seat'));
    final omitted = importer.parse(source900.replaceFirst(
      r'Seat 2: Beta ($0.80 in chips)', 'Seat 2: Beta',
    )).single;
    expect(omitted.canSave, isTrue);
    expect(omitted.hand!.players, hasLength(2));
    expect(omitted.hand!.players.last.stack, isNull);
  });

  test('duplicate physical cards are rejected before confirmation', () {
    final p = importer.parse(source900.replaceFirst(
      '[Ah Kh]', '[Ah 2s]',
    )).single;
    expect(p.canSave, isFalse);
    expect(p.errors.join(' '), contains('repeated card'));
  });

  test('bad board street and later card mutation are errors', () {
    final badLength = importer.parse(source900.replaceFirst(
      '*** FLOP *** [2s 3d 4c]', '*** FLOP *** [2s 3d]',
    )).single;
    expect(badLength.canSave, isFalse);
    expect(badLength.errors.join(' '), contains('board length'));
    final altered = importer.parse(source900.replaceFirst(
      '*** SUMMARY ***',
      '*** TURN *** [2s 5d 4c] [Th]\n*** SUMMARY ***',
    )).single;
    expect(altered.canSave, isFalse);
    expect(altered.errors.join(' '), contains('board cards changed'));
  });

  test('currency mismatch and malformed amounts are not silently converted', () {
    final mixed = importer.parse(source900.replaceFirst(
      r'Alpha: calls $0.02', 'Alpha: calls \u20AC0.02',
    )).single;
    expect(mixed.canSave, isFalse);
    expect(mixed.errors.join(' '), contains('Currency symbol'));
    final malformed = importer.parse(source900.replaceFirst(
      r'Alpha: calls $0.02', r'Alpha: calls $0,02',
    )).single;
    expect(malformed.canSave, isFalse);
    expect(malformed.errors.join(' '), contains('Invalid amount'));
  });

  test('negative source stack and pot fail closed', () {
    final negativeStack = importer.parse(source900.replaceFirst(
      r'($0.80 in chips)', r'($-1.00 in chips)',
    )).single;
    expect(negativeStack.canSave, isFalse);
    expect(negativeStack.errors.join(' '), contains('Invalid stack'));

    final negativePot = importer.parse(source900.replaceFirst(
      r'Total pot $0.20', r'Total pot $-0.20',
    )).single;
    expect(negativePot.canSave, isFalse);
    expect(negativePot.errors.join(' '), contains('Invalid total pot'));
  });

  test('tournament source and damaged street header never guess a street', () {
    final tournament = importer.parse(source900.replaceFirst(
      "PokerStars Hand #900: Hold'em No Limit",
      "PokerStars Hand #900: Tournament #42, Hold'em No Limit",
    )).single;
    expect(tournament.canSave, isFalse);
    expect(tournament.errors.join(' '), contains('Tournament'));

    final damaged = importer.parse(source900.replaceFirst(
      '*** FLOP ***', '*** FLOP **',
    )).single;
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
      title: 'Live note', unit: 'chips',
      players: const [
        Hst06Player(1, 'North', '0'),
        Hst06Player(2, 'South', null),
      ],
      hole: '', board: '', heroSeat: null,
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
      title: 'Bad action', players: const [
        Hst06Player(1, 'A', null), Hst06Player(2, 'B', null),
      ],
      hole: 'Ah Ah',
      actions: const [Hst06Action(4, 5, 'raise',
        amount: '1.50', meaning: 'additional')],
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
    expect((await Hst06PersonalStore().load()).single.localId,
        saved.stored!.localId);
    final duplicate = await store.confirm(original);
    expect(duplicate.kind, Hst06SaveKind.duplicate);
    expect(await store.load(), hasLength(1));
  });

  test('same room ID conflicting content is withheld, not overwritten', () async {
    final store = Hst06PersonalStore();
    await store.confirm(good());
    final changed = importer.parse(source900.replaceFirst(
      r'Total pot $0.20', r'Total pot $0.22',
    )).single;
    final conflict = await store.confirm(changed);
    expect(conflict.kind, Hst06SaveKind.conflict);
    expect((await store.load()).single.totalPot, '0.2');
  });

  test('explicit revision increments with CAS; stale revision rejected', () async {
    final store = Hst06PersonalStore();
    final first = await store.confirm(good());
    final changed = importer.parse(source900.replaceFirst(
      r'Total pot $0.20', r'Total pot $0.22',
    )).single;
    final changedResult = await store.revise(
      changed, first.stored!.localId, 1,
    );
    expect(changedResult.kind, Hst06SaveKind.saved);
    expect(changedResult.stored!.revision, 2);
    final stale = await store.revise(changed, first.stored!.localId, 1);
    expect(stale.kind, Hst06SaveKind.conflict);
    expect((await store.load()).single.revision, 2);
  });

  test('corrupt persisted schema refuses save and does not destroy bytes', () async {
    SharedPreferences.setMockInitialValues({
      Hst06PersonalStore.storageKey: '{corrupted-json',
    });
    final store = Hst06PersonalStore();
    await expectLater(store.confirm(good()), throwsFormatException);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(Hst06PersonalStore.storageKey), '{corrupted-json');
  });

  test('preview without confirmation has no storage side effect', () async {
    final store = Hst06PersonalStore();
    expect(good().canSave, isTrue);
    expect(await store.load(), isEmpty);
  });
}
