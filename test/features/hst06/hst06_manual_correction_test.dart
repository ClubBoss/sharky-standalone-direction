// SOURCE-ONLY proposal against PR450 6859e6c3. NOT RUN.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'personal_hand_screen_v1_test.dart' as fixture;

void main() {
  testWidgets(
    'manual invalid name is corrected through visible UI before save',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = fixture.ObservedStore();
      await fixture.openScreen(tester, store);
      await tester.tap(find.text('Manual entry'));
      await tester.pumpAndSettle();
      Future<void> fill(int index, String value) async {
        final field = find.byType(TextField).at(index);
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, value);
        await tester.pump();
      }

      Future<void> tap(String key) async {
        final target = find.byKey(Key(key));
        await tester.scrollUntilVisible(
          target,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await fill(0, 'SYNTHETIC manual correction');
      await fill(1, '1');
      await fill(2, 'Alice');
      await fill(4, '2');
      await fill(5, 'Alice');
      await tap('hst06-preview-button');
      final error = find.textContaining('Repeated or missing player name.');
      await tester.ensureVisible(error);
      await tester.pumpAndSettle();
      expect(error.hitTestable(), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(find.byKey(const Key('hst06-confirm-0')))
            .onPressed,
        isNull,
      );
      expect(await store.load(), isEmpty);
      expect(
        (await SharedPreferences.getInstance()).containsKey(
          Hst06PersonalStore.storageKey,
        ),
        isFalse,
      );
      // Return physically to the exact second-seat card; avoid index drift.
      final secondSeat = find.byKey(const ValueKey('hst06-seat-1'));
      for (var i = 0; i < 10 && secondSeat.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
        await tester.pumpAndSettle();
      }
      expect(secondSeat, findsOneWidget);
      final secondName = find.descendant(
        of: secondSeat,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == 'Name',
        ),
      );
      expect(secondName, findsOneWidget);
      await tester.ensureVisible(secondName);
      await tester.pumpAndSettle();
      expect(secondName.hitTestable(), findsOneWidget);
      await tester.enterText(secondName, 'Bob');
      await tester.pump();
      expect(find.byKey(const Key('hst06-confirm-0')), findsNothing);
      await tap('hst06-preview-button');
      expect(
        find.textContaining('Repeated or missing player name.'),
        findsNothing,
      );
      await tap('hst06-confirm-0');
      expect(store.pending, isNotNull);
      await tester.runAsync(
        () => store.pending!.timeout(const Duration(seconds: 2)),
      );
      await tester.pumpAndSettle();
      final hands = await store.load();
      expect(hands, hasLength(1));
      expect(hands.single.players.map((player) => player.name), [
        'Alice',
        'Bob',
      ]);
      expect(
        hands.single.players.every((player) => player.stack == null),
        isTrue,
      );
      expect(hands.single.actions, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
