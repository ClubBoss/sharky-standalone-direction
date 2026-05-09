import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily run exposes a tappable legacy microtask seat surface', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
          mode: kWorld1RunnerModeDailyRun,
        ),
      ),
    );
    await tester.pump();

    const seatIds = <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'];
    final seatFinders = <String, Finder>{
      for (final seatId in seatIds)
        seatId: find.byKey(Key('microtask_seat_$seatId')),
    };
    for (final finder in seatFinders.values) {
      expect(finder, findsOneWidget);
    }

    final rects = <String, Rect>{
      for (final entry in seatFinders.entries)
        entry.key: tester.getRect(entry.value),
    };
    final tableCenter = tester
        .getRect(find.byKey(const Key('microtask_table')))
        .center;
    expect(rects['btn']!.center.dy, greaterThan(rects['sb']!.center.dy));
    expect(rects['btn']!.center.dy, greaterThan(rects['co']!.center.dy));
    expect(rects['sb']!.center.dx, greaterThan(tableCenter.dx));
    expect(rects['bb']!.center.dx, greaterThan(tableCenter.dx));
    expect(rects['co']!.center.dx, lessThan(tableCenter.dx));
    expect(rects['hj']!.center.dx, lessThan(tableCenter.dx));
    expect(rects['bb']!.center.dy, lessThan(rects['sb']!.center.dy));
    expect(rects['utg']!.center.dy, lessThan(rects['bb']!.center.dy));
    expect(rects['hj']!.center.dy, lessThan(rects['co']!.center.dy));
    const seatOrderBadges = <String, String>{
      'btn': '1 Button',
      'sb': '2 Small Blind',
      'bb': '3 Big Blind',
      'utg': '4 UTG',
      'hj': '5 Hijack',
      'co': '6 Cutoff',
    };
    for (final entry in seatOrderBadges.entries) {
      final badgeFinder = find.byKey(
        Key('microtask_seat_order_badge_${entry.key}_v1'),
      );
      expect(badgeFinder, findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      final badgeRect = tester.getRect(badgeFinder);
      expect(badgeRect.left >= 0, isTrue);
      expect(badgeRect.top >= 0, isTrue);
      expect(
        badgeRect.right <=
            tester.view.physicalSize.width / tester.view.devicePixelRatio,
        isTrue,
      );
      expect(
        badgeRect.bottom <=
            tester.view.physicalSize.height / tester.view.devicePixelRatio,
        isTrue,
      );
    }

    final instructionSurface = find.byKey(
      const Key('microtask_seat_quiz_table_instruction_v1'),
    );
    final instructionOrderHint = find.byKey(
      const Key('microtask_seat_quiz_order_hint_v1'),
    );
    expect(instructionSurface, findsOneWidget);
    expect(instructionOrderHint, findsOneWidget);
    expect(find.text('Tap Button (Dealer).'), findsOneWidget);
    expect(
      find.text(
        'Order: Button -> Small Blind -> Big Blind -> UTG -> Hijack -> Cutoff.',
      ),
      findsOneWidget,
    );

    final instructionRect = tester.getRect(instructionSurface);
    expect(instructionRect.left >= 4, isTrue);
    expect(instructionRect.top >= 4, isTrue);
    expect(instructionRect.center.dy < tableCenter.dy, isTrue);
    expect(
      instructionRect.right <=
          tester.view.physicalSize.width / tester.view.devicePixelRatio - 4,
      isTrue,
    );
    expect(
      instructionRect.bottom <=
          tester.view.physicalSize.height / tester.view.devicePixelRatio - 4,
      isTrue,
    );
    final promptText = tester.widget<Text>(
      find.byKey(const Key('microtask_step_prompt')),
    );
    final orderHintText = tester.widget<Text>(
      find.byKey(const Key('microtask_seat_quiz_order_hint_v1')),
    );
    expect(
      (promptText.style?.fontSize ?? 0) > (orderHintText.style?.fontSize ?? 0),
      isTrue,
    );
    expect(promptText.style?.fontWeight, FontWeight.w900);

    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'table practice exposes a tappable legacy table-practice seat surface',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'intro_welcome',
            moduleTitle: 'Welcome to Poker',
            mode: kWorld1RunnerModeTablePractice,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('table_practice_seat_btn')), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_seat_order_badge_btn_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_seat_quiz_order_hint_v1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('table_practice_seat_btn')));
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
