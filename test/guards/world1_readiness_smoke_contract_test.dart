import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/module_launcher_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Widget _hostWithWidth(double width) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 900)),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const UiV2ProgressMapScreenV2(),
    ),
  );
}

Future<bool> _tapIfVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) return false;
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first, warnIfMissed: false);
  return true;
}

Future<void> _advanceDrillUntilResult(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    final finish = find.text('FINISH');
    if (await _tapIfVisible(tester, finish)) {
      await tester.pumpAndSettle();
      continue;
    }
    final nextDrill = find.text('NEXT DRILL');
    if (await _tapIfVisible(tester, nextDrill)) {
      await tester.pumpAndSettle();
      continue;
    }
    final reveal = find.text('REVEAL ANSWER');
    if (await _tapIfVisible(tester, reveal)) {
      await tester.pump(const Duration(milliseconds: 200));
      continue;
    }
    final option0 = find.byKey(const ValueKey<String>('drill_option_0'));
    if (await _tapIfVisible(tester, option0)) {
      await tester.pumpAndSettle();
      continue;
    }
    final gotIt = find.text('Got it');
    if (await _tapIfVisible(tester, gotIt)) {
      await tester.pump(const Duration(milliseconds: 200));
      continue;
    }
    final missedIt = find.text('Missed it');
    if (await _tapIfVisible(tester, missedIt)) {
      await tester.pump(const Duration(milliseconds: 200));
      continue;
    }
    await tester.pump(const Duration(milliseconds: 120));
  }
  fail('Drill did not reach SessionResultScreen within step budget.');
}

Future<void> _advanceTablePracticeUntilResult(WidgetTester tester) async {
  const candidateSeatIds = <String>['btn', 'sb', 'bb', 'hj', 'co'];
  for (var i = 0; i < 24; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    for (final seatId in candidateSeatIds) {
      final seat = find.byKey(Key('table_practice_seat_$seatId'));
      final check = find.byKey(const Key('table_practice_check_cta'));
      if (await _tapIfVisible(tester, seat)) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      if (await _tapIfVisible(tester, check)) {
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pump(const Duration(milliseconds: 220));
      }
      if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
        return;
      }
    }
  }
  fail('Table practice did not reach SessionResultScreen within step budget.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'readiness smoke covers widths, flow, daily, branch lock/unlock',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1366, 900);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{});
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.pumpWidget(_hostWithWidth(1366));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));

      final firstModuleId = kWorld1CanonicalModuleOrder.first;
      expect(
        find.byKey(ValueKey<String>('world1_node_$firstModuleId')),
        findsOneWidget,
      );
      final l1Node = find.byKey(ValueKey<String>('world1_node_$firstModuleId'));
      await tester.ensureVisible(l1Node.first);
      await tester.tap(l1Node.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      if (find.byType(ModuleSummaryScreen).evaluate().isNotEmpty) {
        final startTheory = find.byKey(
          const Key('module_summary_start_theory_cta'),
        );
        expect(startTheory, findsOneWidget);
        final startTheoryButton = tester.widget<ElevatedButton>(
          startTheory.first,
        );
        startTheoryButton.onPressed?.call();
        await tester.pumpAndSettle();

        expect(find.byType(TheorySessionScreen), findsOneWidget);
        final startPractice = find.byKey(
          const Key('theory_start_practice_cta'),
        );
        expect(startPractice, findsOneWidget);
        final startPracticeButton = tester.widget<ElevatedButton>(
          startPractice.first,
        );
        startPracticeButton.onPressed?.call();
        await tester.pumpAndSettle();
      }

      if (find
          .byType(World1FoundationsMicroTaskRunnerScreen)
          .evaluate()
          .isNotEmpty) {
        await _advanceTablePracticeUntilResult(tester);
      } else {
        expect(find.byType(DrillRunnerScreen), findsOneWidget);
        await _advanceDrillUntilResult(tester);
      }

      expect(find.byType(SessionResultScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('session_result_back_to_map_cta')));
      await tester.pumpAndSettle();

      expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('world1_state_current')),
        findsOneWidget,
      );

      expect(find.byKey(const Key('world1_branch_cash_locked')), findsNothing);
      expect(find.byKey(const Key('world1_branch_mtt_locked')), findsNothing);
      expect(
        find.byKey(const Key('world1_branch_cash_unlocked')),
        findsNothing,
      );
      expect(find.byKey(const Key('world1_branch_mtt_unlocked')), findsNothing);

      Finder? dailyRunCta;
      for (final moduleId in kWorld1CanonicalModuleOrder) {
        final candidate = find.byKey(Key('world1_daily_run_cta_$moduleId'));
        if (candidate.evaluate().isNotEmpty) {
          dailyRunCta = candidate;
          break;
        }
      }
      expect(dailyRunCta, isNotNull);
      await tester.tap(dailyRunCta!.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
      var returnedToMap = false;
      for (final seatId in <String>['btn', 'sb', 'bb', 'hj', 'co']) {
        final seat = find.byKey(Key('microtask_seat_$seatId'));
        if (seat.evaluate().isEmpty) {
          continue;
        }
        await tester.tap(seat.first, warnIfMissed: false);
        await tester.pump();
        await tester.tap(find.byKey(const Key('microtask_check_cta')));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        if (find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
          returnedToMap = true;
          break;
        }
      }
      expect(returnedToMap, isTrue);

      expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
      expect(find.text('Completed Today'), findsOneWidget);

      for (final moduleId in kWorld1CanonicalModuleOrder) {
        await ProgressService.markModuleCompleted(moduleId);
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      expect(
        find.byKey(const Key('world1_branch_cash_unlocked')),
        findsNothing,
      );
      expect(find.byKey(const Key('world1_branch_mtt_unlocked')), findsNothing);

      for (final width in <double>[390, 820, 1600]) {
        await tester.pumpWidget(_hostWithWidth(width));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 240));

        expect(
          find.byKey(
            ValueKey<String>(
              'world1_node_${kWorld1CanonicalModuleOrder.first}',
            ),
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('readiness smoke includes telemetry contract presence', (
    tester,
  ) async {
    final logged = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      logged.add(<String, dynamic>{'name': name, 'payload': payload});
    });
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
          isDailyRun: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pumpAndSettle();

    final eventNames = logged.map((event) => event['name'] as String).toSet();
    expect(eventNames, contains('session_start'));
    expect(eventNames, contains('user_choice'));
    expect(eventNames, contains('correct'));
    expect(eventNames, contains('time_to_decision'));
    expect(eventNames, contains('session_end'));
  });
}
