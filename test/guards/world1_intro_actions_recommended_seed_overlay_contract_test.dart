import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 120));
}

Future<void> _completeIntakeAndPlacement(WidgetTester tester) async {
  await _tap(tester, const Key('intake_skill_band_intermediate'));

  const intakeSeats = <String>['btn', 'sb', 'bb', 'hj', 'co', 'btn', 'bb'];
  for (final seat in intakeSeats) {
    await _tap(tester, Key('intake_seat_$seat'));
    await _tap(tester, const Key('intake_check_cta'));
  }

  expect(find.byKey(const Key('placement_stage_header')), findsOneWidget);
  const placementSeats = <String>['btn', 'sb', 'bb'];
  for (final seat in placementSeats) {
    await _tap(tester, Key('intake_seat_$seat'));
    await _tap(tester, const Key('intake_check_cta'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'recommended intro_actions shows seed overlay and guided scope only on step 1',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.pumpWidget(const AppRoot());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 280));

      expect(find.byKey(const Key('intake_runner')), findsOneWidget);
      await _completeIntakeAndPlacement(tester);
      await tester.pumpAndSettle();

      final start = find.byKey(const Key('today_plan_start_cta'));
      expect(start, findsOneWidget);
      await tester.tap(start, warnIfMissed: false);
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
      }
      if (find.byType(TheorySessionScreen).evaluate().isNotEmpty) {
        final startPractice = find.byKey(
          const Key('theory_start_practice_cta'),
        );
        final startPracticeButton = tester.widget<ElevatedButton>(
          startPractice.first,
        );
        startPracticeButton.onPressed?.call();
        await tester.pumpAndSettle();
      }

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_instruction_overlay')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_guided_scope_seats')),
        findsOneWidget,
      );

      final seatCo = find.byKey(const Key('table_practice_seat_co'));
      final checkCta = find.byKey(const Key('table_practice_check_cta'));
      if (seatCo.evaluate().isNotEmpty && checkCta.evaluate().isNotEmpty) {
        await _tap(tester, const Key('table_practice_seat_co'));
        await _tap(tester, const Key('table_practice_check_cta'));

        expect(find.text('Step 2 of 3'), findsOneWidget);
        expect(
          find.byKey(const Key('microtask_instruction_overlay')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('microtask_guided_scope_seats')),
          findsNothing,
        );
      }

      expect(tester.takeException(), isNull);
    },
  );
}
