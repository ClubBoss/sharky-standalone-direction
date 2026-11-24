import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_manual_hand_screen_v1.dart';

void main() {
  final fixture = File(
    'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
  ).readAsStringSync();
  final imported = Act0ImportedHandV1.parsePokerStars(fixture);
  Act0ImportedHandV1 manual({
    Act0ImportedHandV1? previous,
    List<Act0ImportedActionV1>? actions,
    List<String>? cards,
    int payout = 20,
  }) => Act0ImportedHandV1.manual(
    previous: previous,
    tableSize: imported.tableSize,
    buttonSeat: imported.buttonSeat,
    heroSeat: imported.heroSeat,
    smallBlindCents: imported.smallBlindCents,
    bigBlindCents: imported.bigBlindCents,
    seats: imported.seats,
    heroCards: cards ?? imported.heroCards,
    board: imported.board,
    actions: actions ?? imported.actions,
    shownCards: imported.shownCards,
    payouts: {1: payout},
    rakeCents: imported.rakeCents,
  );

  test(
    'manual and imported actions agree with C1 and keep distinct provenance',
    () {
      final hand = manual();
      expect(hand.actions, imported.actions);
      expect(hand.potCents, imported.potCents);
      expect(hand.practiceLessonId, 'call_price');
      expect(
        hand
            .contributions(PokerStreet.preflop, hand.actions.take(2))
            .amounts(seatIds: hand.seatIds, actorSeatId: '1'),
        (potBb: 1.5, toCallBb: 0.5),
      );
      expect(
        hand
            .contributions(PokerStreet.preflop, hand.actions)
            .amounts(seatIds: hand.seatIds)
            .potBb,
        2,
      );
      final edited = manual(previous: hand, cards: ['Ac', '2s']);
      final archive = const Act0AttemptArchiveV1.empty()
          .importPokerStars(fixture)
          .saveManualHand(hand)
          .saveManualHand(edited);
      final restored = Act0AttemptArchiveV1.restore(archive.toPayload());
      expect(restored.importedHands, hasLength(2));
      expect(restored.importedHands.first.sourceKey, hand.sourceKey);
      expect(restored.importedHands.first.heroCards, ['Ac', '2s']);
      expect(restored.importedHands.first.isManual, isTrue);
      expect(restored.importedHands.last.isManual, isFalse);
      expect(restored.attempts, isEmpty);
    },
  );

  test('the 201st own hand is refused and the oldest hand is retained', () {
    var archive = const Act0AttemptArchiveV1.empty().importPokerStars(fixture);
    final editable = manual();
    archive = archive.saveManualHand(editable);
    for (var count = 2; count < 200; count++) {
      archive = archive.saveManualHand(manual());
    }
    final before = archive.toPayload();
    final full = isA<Act0HandImportExceptionV1>().having(
      (error) => error.code,
      'code',
      Act0HandImportErrorV1.archiveFull,
    );
    expect(() => archive.saveManualHand(manual()), throwsA(full));
    expect(
      () => archive.importPokerStars(
        fixture.replaceFirstMapped(
          RegExp(r'Hand #([0-9]+)'),
          (match) => 'Hand #${int.parse(match[1]!) + 1}',
        ),
      ),
      throwsA(full),
    );
    expect(archive.toPayload(), before);
    expect(archive.importedHands.last.sourceKey, imported.sourceKey);
    expect(archive.importPokerStars(fixture), same(archive));

    final edited = manual(previous: editable, cards: ['Ac', '2s']);
    final updated = archive.saveManualHand(edited);
    expect(updated.importedHands, hasLength(200));
    expect(updated.importedHands, contains(same(edited)));
    expect(updated.importedHands.last.sourceKey, imported.sourceKey);
    expect(
      updated
          .removeImportedHand(imported.sourceKey)
          .saveManualHand(manual())
          .importedHands,
      hasLength(200),
    );
  });

  test('manual entry rejects illegal actions, payouts and duplicate cards', () {
    final invalid = [...imported.actions];
    invalid[2] = (
      street: PokerStreet.preflop,
      seat: 2,
      kind: Act0ImportedActionKindV1.check,
      cents: 0,
    );
    final incomplete = imported.actions.take(4).toList();
    for (final (make, error) in <(Act0ImportedHandV1 Function(), String)>[
      (() => manual(actions: invalid), 'Action 3'),
      (() => manual(actions: incomplete), 'uncalled return'),
      (() => manual(payout: 19), 'Payouts plus rake'),
      (() => manual(cards: ['2s', '2s']), 'duplicate card'),
    ]) {
      expect(
        make,
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains(error),
          ),
        ),
      );
    }
  });

  testWidgets(
    'rejects incomplete betting, saves a manual replay and edits it in place',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      var archive = const Act0AttemptArchiveV1.empty();
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Act0AttemptArchiveScreenV1(
                archive: archive,
                ownHands: true,
                onClose: () {},
                onSelect: (_) {},
                onRemove: (_) {},
                onOwnHandsChanged: (next) => setState(() => archive = next),
              ),
            ),
          ),
        ),
      );

      final wizard = find.byType(Act0ManualHandScreenV1);
      final wizardScrollables = find.descendant(
        of: wizard,
        matching: find.byType(Scrollable),
      );
      final dialog = find.byType(AlertDialog);

      Future<void> reveal(Finder finder, {double scrollDelta = 150}) async {
        if (wizardScrollables.evaluate().isNotEmpty &&
            dialog.evaluate().isEmpty &&
            finder.evaluate().isEmpty) {
          await t.scrollUntilVisible(
            finder,
            scrollDelta,
            maxScrolls: 40,
            scrollable: wizardScrollables.first,
          );
        } else {
          await t.ensureVisible(finder);
        }
        await t.pumpAndSettle();
      }

      Future<void> tap(Finder finder) async {
        await reveal(finder);
        expect(finder.hitTestable(), findsOneWidget, reason: 'Tap $finder');
        await t.tap(finder.hitTestable());
        await t.pumpAndSettle();
      }

      Future<void> enter(
        String label,
        String value, {
        double scrollDelta = 150,
      }) async {
        final field = label == 'Amount in cents'
            ? find.descendant(of: dialog, matching: find.byType(TextFormField))
            : find.byKey(ValueKey(label));
        await reveal(field, scrollDelta: scrollDelta);
        await t.enterText(field, value);
        await t.pumpAndSettle();
      }

      Future<void> addAction(Act0ImportedActionV1 action) async {
        await tap(find.text('Add ${action.street.name} action'));
        await tap(find.widgetWithText(DropdownButtonFormField<int>, 'Seat'));
        await tap(find.text('Seat ${action.seat}').hitTestable().last);
        await tap(
          find.widgetWithText(
            DropdownButtonFormField<Act0ImportedActionKindV1>,
            'Action',
          ),
        );
        await tap(find.text(action.kind.label).hitTestable().last);
        if (action.cents > 0) await enter('Amount in cents', '${action.cents}');
        await tap(find.text('Save action'));
      }

      const preflop = PokerStreet.preflop;
      const flop = PokerStreet.flop;
      const actions = <Act0ImportedActionV1>[
        (
          street: preflop,
          seat: 1,
          kind: Act0ImportedActionKindV1.smallBlind,
          cents: 5,
        ),
        (
          street: preflop,
          seat: 2,
          kind: Act0ImportedActionKindV1.bigBlind,
          cents: 10,
        ),
        (
          street: preflop,
          seat: 1,
          kind: Act0ImportedActionKindV1.call,
          cents: 5,
        ),
        (
          street: preflop,
          seat: 2,
          kind: Act0ImportedActionKindV1.check,
          cents: 0,
        ),
        (street: flop, seat: 2, kind: Act0ImportedActionKindV1.bet, cents: 10),
        (street: flop, seat: 1, kind: Act0ImportedActionKindV1.fold, cents: 0),
        (
          street: flop,
          seat: 2,
          kind: Act0ImportedActionKindV1.uncalledReturn,
          cents: 10,
        ),
      ];

      await tap(find.text('Enter own hand'));
      for (final (label, value) in [
        ('Seat 1 stack', '1000'),
        ('Seat 2 stack', '800'),
        ('Button seat', '1'),
        ('Your seat', '1'),
        ('Small blind', '5'),
        ('Big blind', '10'),
      ]) {
        await enter(label, value);
      }
      await tap(find.text('Next'));
      await enter('Your cards', '2s 7d');
      await enter('Flop', 'Ah Tc 4d');
      await tap(find.text('Next'));
      for (final action in actions.take(actions.length - 1)) {
        await addAction(action);
      }
      await tap(find.text('Next'));
      await enter('Seat 2 collected', '20');
      await enter('Rake', '0');

      await tap(find.text('Save hand'));
      final incomplete = find.text(
        'Finish betting and record any uncalled return.',
      );
      await reveal(incomplete);
      expect(incomplete.hitTestable(), findsOneWidget);
      expect(archive.importedHands, isEmpty);
      expect(find.byType(Act0AttemptReplayScreenV1), findsNothing);

      await tap(find.text('Previous'));
      await addAction(actions.last);
      await tap(find.text('Next'));
      await tap(find.text('Save hand'));

      final saved = archive.importedHands.single;
      expect(saved.isManual, isTrue);
      expect(saved.timeEt, isEmpty);
      expect(saved.seats, [
        (number: 1, stackCents: 1000),
        (number: 2, stackCents: 800),
      ]);
      expect(saved.heroCards, ['2s', '7d']);
      expect(saved.board, ['Ah', 'Tc', '4d']);
      expect(saved.actions, actions);
      expect(saved.payouts, {2: 20});
      expect(saved.potCents, 20);
      expect(archive.attempts, isEmpty);
      final restored = Act0AttemptArchiveV1.restore(archive.toPayload());
      expect(restored.importedHands.single.toPayload(), saved.toPayload());

      final replay = find.byType(Act0AttemptReplayScreenV1);
      expect(t.widget<Act0AttemptReplayScreenV1>(replay).hand, same(saved));
      expect(find.text('Own hand · Manual entry'), findsOneWidget);
      final table = find.byType(Act0TableSceneV1);
      expect(t.widget<Act0TableSceneV1>(table).table.boardCards, isEmpty);
      expect(t.widget<Act0TableSceneV1>(table).table.heroCards, isEmpty);
      await tap(find.byKey(const Key('act0_attempt_replay_next')));
      final event = find.byKey(const Key('act0_attempt_replay_current_event'));
      await reveal(event);
      expect(t.widget<Text>(event).data, contains('Button: seat 1.'));

      await tap(find.text('Flop'));
      expect(
        t
            .widget<Act0TableSceneV1>(table)
            .table
            .boardCards
            .map((card) => card.label),
        ['Ah', 'Tc', '4d'],
      );

      await tap(find.byKey(const Key('act0_attempt_replay_back_to_archive')));
      await tap(find.text('Edit hand'));
      expect(find.text('Edit own hand'), findsOneWidget);
      await tap(find.text('Next'));
      await enter('Your cards', 'Ac 2d');
      await tap(find.text('Next'));
      await tap(find.text('Next'));
      await tap(find.text('Save hand'));

      final edited = archive.importedHands.single;
      expect(edited.sourceKey, saved.sourceKey);
      expect(edited.heroCards, ['Ac', '2d']);
      expect(edited.actions, saved.actions);
      expect(archive.attempts, isEmpty);
      await tap(find.byKey(const Key('act0_attempt_replay_back_to_archive')));
      expect(find.text('Manual entry · Ac 2d'), findsOneWidget);
      await tap(find.text('Replay hand'));
      expect(t.widget<Act0AttemptReplayScreenV1>(replay).hand, same(edited));
    },
    variant: const TargetPlatformVariant({TargetPlatform.iOS}),
  );
}
