import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_screen_v1.dart';

const synthetic = r'''PokerStars Hand #42: Hold'em No Limit ($0.01/$0.02 USD) - 2026/01/01
Table 'Synthetic' 2-max Seat #1 is the button
Seat 1: Alice ($1.00 in chips)
Seat 2: Bob ($2.00 in chips)
*** HOLE CARDS ***
Dealt to Alice [Ah Kd]
Alice: calls $0.02
Bob: checks
*** SUMMARY ***
Total pot $0.04 | Rake $0.00''';

Future<void> openScreen(WidgetTester tester, Hst06PersonalStore store) async {
  await tester.pumpWidget(
    MaterialApp(home: Hst06PersonalHandScreen(store: store)),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('import: cancel after real preview creates no personal record',
      (tester) async {
    final store = Hst06PersonalStore();
    await openScreen(tester, store);
    await tester.enterText(find.byType(TextField).first, synthetic);
    await tester.tap(find.byKey(const Key('hst06-preview-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hero cards: Ah Kd'), findsOneWidget);
    final cancel = find.byKey(const Key('hst06-cancel-0'));
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(await store.load(), isEmpty);
    expect(find.byKey(const Key('hst06-preview-0')), findsNothing);
  });

  testWidgets('import: explicit confirmation persists private hand only',
      (tester) async {
    final store = Hst06PersonalStore();
    await openScreen(tester, store);
    await tester.enterText(find.byType(TextField).first, synthetic);
    await tester.tap(find.byKey(const Key('hst06-preview-button')));
    await tester.pumpAndSettle();
    final confirm = find.byKey(const Key('hst06-confirm-0'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    final hands = await store.load();
    expect(hands, hasLength(1));
    expect(hands.single.origin, 'pokerstars');
    expect(hands.single.heroSeat, 1);
    expect(hands.single.revision, 1);
    expect(find.text('Saved personal hands: 1'), findsOneWidget);
  });

  testWidgets('repeat import shows duplicate before confirmation',
      (tester) async {
    final store = Hst06PersonalStore();
    await openScreen(tester, store);
    await tester.enterText(find.byType(TextField).first, synthetic);
    final previewButton = find.byKey(const Key('hst06-preview-button'));
    await tester.tap(previewButton);
    await tester.pumpAndSettle();
    final confirm = find.byKey(const Key('hst06-confirm-0'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(await store.load(), hasLength(1));

    await tester.ensureVisible(previewButton);
    await tester.tap(previewButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('Already saved:'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(
      find.byKey(const Key('hst06-confirm-0')),
    ).onPressed, isNull);
    expect(await store.load(), hasLength(1));
  });

  testWidgets('changing source invalidates review and prevents stale save',
      (tester) async {
    final store = Hst06PersonalStore();
    await openScreen(tester, store);
    final source = find.byType(TextField).first;
    await tester.enterText(source, synthetic);
    await tester.tap(find.byKey(const Key('hst06-preview-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hst06-preview-0')), findsOneWidget);
    await tester.enterText(source, 'New unsupported text');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hst06-preview-0')), findsNothing);
    expect(await store.load(), isEmpty);
  });

  testWidgets('unsupported import cannot confirm', (tester) async {
    final store = Hst06PersonalStore();
    await openScreen(tester, store);
    await tester.enterText(
      find.byType(TextField).first, 'GGPoker Hand #42: unsupported',
    );
    await tester.tap(find.byKey(const Key('hst06-preview-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unsupported format'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(
      find.byKey(const Key('hst06-confirm-0')),
    ).onPressed, isNull);
    expect(await store.load(), isEmpty);
  });

  testWidgets('manual: blank stacks remain unknown and can be confirmed',
      (tester) async {
    final store = Hst06PersonalStore();
    await openScreen(tester, store);
    await tester.tap(find.text('Manual entry'));
    await tester.pumpAndSettle();
    // Title, seat 1, name 1, stack 1, seat 2, name 2, stack 2.
    final textFields = find.byType(TextField);
    Future<void> fill(int index, String value) async {
      await tester.ensureVisible(textFields.at(index));
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(index), value);
      await tester.pump();
    }
    await fill(0, 'Synthetic manual');
    await fill(1, '1');
    await fill(2, 'Alice');
    await fill(4, '2');
    await fill(5, 'Bob');
    final previewButton = find.byKey(const Key('hst06-preview-button'));
    await tester.ensureVisible(previewButton);
    await tester.tap(previewButton);
    await tester.pumpAndSettle();
    final confirm = find.byKey(const Key('hst06-confirm-0'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    final hands = await store.load();
    expect(hands, hasLength(1));
    expect(hands.single.heroSeat, isNull);
    expect(hands.single.players.every((p) => p.stack == null), isTrue);
    expect(hands.single.actions, isEmpty);
  });
}
