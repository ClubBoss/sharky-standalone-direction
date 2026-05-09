import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _completeIntake(WidgetTester tester) async {
  const expectedSeats = <String>['btn', 'sb', 'bb', 'hj', 'co', 'btn', 'bb'];
  for (final seatId in expectedSeats) {
    await tester.tap(
      find.byKey(Key('intake_seat_$seatId')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(
      find.byKey(const Key('intake_check_cta')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 140));
  }
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 80));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('intake start reaches seed-only instruction ladder behavior', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(const AppRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));

    expect(find.byKey(const Key('intake_runner')), findsOneWidget);
    await _completeIntake(tester);
    await tester.pumpAndSettle();

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    if (find.byType(ModuleSummaryScreen).evaluate().isNotEmpty) {
      final startTheory = find.byKey(
        const Key('module_summary_start_theory_cta'),
      );
      final startTheoryButton = tester.widget<ElevatedButton>(
        startTheory.first,
      );
      startTheoryButton.onPressed?.call();
      await tester.pumpAndSettle();
      expect(find.byType(TheorySessionScreen), findsOneWidget);

      final startPractice = find.byKey(const Key('theory_start_practice_cta'));
      final startPracticeButton = tester.widget<ElevatedButton>(
        startPractice.first,
      );
      startPracticeButton.onPressed?.call();
      await tester.pumpAndSettle();
    }

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    expect(
      find.byKey(const Key('microtask_instruction_overlay')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('microtask_guided_scope_seats')),
      findsOneWidget,
    );

    final contractSeatBtn = find.byKey(
      const Key('spine_contract_target_seat_btn'),
    );
    if (contractSeatBtn.evaluate().isNotEmpty) {
      await tester.tap(contractSeatBtn.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 80));
      await _tap(tester, const Key('microtask_check_cta'));
    } else {
      await _tap(tester, const Key('table_practice_seat_bb'));
      await _tap(tester, const Key('table_practice_check_cta'));
    }
    expect(find.byKey(const Key('microtask_guided_scope_seats')), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
          isTablePracticeV1: false,
        ),
      ),
    );
    await tester.pump();
    await _tap(tester, const Key('microtask_seat_btn'));
    await _tap(tester, const Key('microtask_check_cta'));
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(
      find.byKey(const Key('microtask_instruction_overlay')),
      findsNothing,
    );

    await _tap(tester, const Key('microtask_seat_sb'));
    await _tap(tester, const Key('microtask_check_cta'));
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(
      find.byKey(const Key('microtask_instruction_overlay')),
      findsNothing,
    );

    expect(tester.takeException(), isNull);
  });
}
