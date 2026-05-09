import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

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

  testWidgets('world1 flow e2e contract remains non-throwing', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1.0;

    await pumpToMap(tester, seed: seedWorld1CampaignComplete());

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);

    final l1Node = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith('world1_node_'),
      description: 'world1_node_<moduleId>',
    );
    expect(l1Node, findsWidgets);
    await tester.tap(l1Node.first);
    await tester.pumpAndSettle();

    expect(find.byType(ModuleSummaryScreen), findsOneWidget);

    final startTheory = find.byKey(
      const Key('module_summary_start_theory_cta'),
    );
    expect(startTheory, findsOneWidget);
    await tester.tap(startTheory);
    await tester.pumpAndSettle();

    expect(
      find.byType(TheorySessionScreen).evaluate().isNotEmpty ||
          find
              .byKey(const Key('table_first_theory_shell'))
              .evaluate()
              .isNotEmpty,
      isTrue,
    );
    final startPractice = find.byKey(const Key('theory_start_practice_cta'));
    expect(startPractice, findsOneWidget);
    await tester.tap(startPractice);
    await tester.pumpAndSettle();

    if (find
        .byType(World1FoundationsMicroTaskRunnerScreen)
        .evaluate()
        .isNotEmpty) {
      expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);
      expect(
        find.byKey(const Key('table_practice_step_header')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('table_practice_table')), findsOneWidget);
      await _advanceTablePracticeUntilResult(tester);
    } else {
      expect(find.byType(DrillRunnerScreen), findsOneWidget);
      expect(
        find.byKey(const Key('table_first_practice_shell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('table_first_practice_stepper')),
        findsOneWidget,
      );
      await _advanceDrillUntilResult(tester);
    }
    expect(find.byType(SessionResultScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('session_result_back_to_map_cta')));
    await tester.pumpAndSettle();

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    expect(find.byKey(const Key('world1_ladder_progress_bar')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
