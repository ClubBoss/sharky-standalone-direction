import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_imported_hand_v1.dart';

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
    'enters seats, cards and actions, corrects a payout and opens own replay',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      var archive = const Act0AttemptArchiveV1.empty();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Act0AttemptArchiveScreenV1(
                archive: archive,
                onClose: () {},
                onSelect: (_) {},
                onRemove: (_) {},
                onOwnHandsChanged: (next) => setState(() => archive = next),
              ),
            ),
          ),
        ),
      );

      Future<void> tap(Finder finder) async {
        await t.ensureVisible(finder.first);
        await t.tap(finder.first);
        await t.pumpAndSettle();
      }

      Future<void> enter(String label, String value) async {
        final field = find.widgetWithText(TextFormField, label);
        await t.ensureVisible(field);
        await t.enterText(field, value);
        await t.pumpAndSettle();
      }

      await tap(find.text('Own hands'));
      await tap(find.text('Enter own hand'));
      for (final (label, value) in [
        ('Seat 1 stack', '1000'),
        ('Seat 2 stack', '1000'),
        ('Button seat', '1'),
        ('Your seat', '1'),
        ('Small blind', '5'),
        ('Big blind', '10'),
      ]) {
        await enter(label, value);
      }
      await tap(find.text('Next'));
      await enter('Your cards', '2s 7d');
      await tap(find.text('Next'));
      for (final action in imported.actions) {
        await tap(find.text('Add preflop action'));
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
      await tap(find.text('Next'));
      await enter('Seat 1 collected', '19');
      await enter('Rake', '0');
      await tap(find.text('Save hand'));
      expect(
        find.text('Payouts plus rake must equal the pot.'),
        findsOneWidget,
      );
      expect(archive.importedHands, isEmpty);
      await enter('Seat 1 collected', '20');
      await tap(find.text('Save hand'));
      expect(find.text('Own hand · Manual entry'), findsOneWidget);
      expect(archive.importedHands.single.potCents, 20);
      expect(archive.attempts, isEmpty);
    },
  );
}
