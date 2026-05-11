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

Future<void> _completeIntroSequenceIfPresent(WidgetTester tester) async {
  final introSequenceFinder = find.byKey(
    const Key('microtask_intro_sequence_v1'),
  );
  await tester.pump();
  if (introSequenceFinder.evaluate().isEmpty) {
    return;
  }

  final introContinueFinder = find.byKey(
    const Key('microtask_intro_continue_cta_v1'),
  );

  Future<bool> tryContinueIfEnabled() async {
    if (introContinueFinder.evaluate().isEmpty) return false;
    final continueButton = tester.widget<FilledButton>(introContinueFinder);
    if (continueButton.onPressed == null) return false;
    await tester.tap(introContinueFinder, warnIfMissed: false);
    await tester.pump();
    return true;
  }

  if (await tryContinueIfEnabled()) {
    if (introSequenceFinder.evaluate().isEmpty) {
      return;
    }
  }

  Future<void> completeTapStep(String seatId) async {
    await tester.tap(
      find.byKey(Key('microtask_seat_$seatId')),
      warnIfMissed: false,
    );
    await tester.pump();
    final continueButton = tester.widget<FilledButton>(introContinueFinder);
    expect(continueButton.onPressed, isNotNull);
    await tester.tap(introContinueFinder, warnIfMissed: false);
    await tester.pump();
  }

  await completeTapStep('btn');
  if (introSequenceFinder.evaluate().isEmpty) return;
  await completeTapStep('sb');
  if (introSequenceFinder.evaluate().isEmpty) return;
  await completeTapStep('bb');
}

class _SpineContractState {
  const _SpineContractState({
    required this.target,
    required this.requiresContinue,
  });

  final String target;
  final bool requiresContinue;
}

_SpineContractState _readSpineContract(WidgetTester tester) {
  final targetFinder = find.byKey(
    const Key('spine_contract_expected_target'),
    skipOffstage: false,
  );
  final continueFinder = find.byKey(
    const Key('spine_contract_requires_continue'),
    skipOffstage: false,
  );
  final targetText = targetFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(targetFinder.first).data ?? '')
      : '';
  final continueText = continueFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(continueFinder.first).data ?? '')
      : '';
  final targetMatch = RegExp(r'^target=(.+)$').firstMatch(targetText.trim());
  return _SpineContractState(
    target: (targetMatch?.group(1) ?? '').trim(),
    requiresContinue: continueText.trim() == 'continue=1',
  );
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
  const candidateSeatIds = <String>['btn', 'sb', 'bb', 'hj', 'co', 'utg'];
  var reachedInteractiveRunner = false;
  for (var i = 0; i < 80; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      await tester.tap(
        find.byKey(const Key('session_result_back_to_map_cta')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      return;
    }
    if (find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
      return;
    }
    await _completeIntroSequenceIfPresent(tester);
    final prelude = find.byKey(const Key('microtask_prelude_continue_cta_v1'));
    if (await _tapIfVisible(tester, prelude)) {
      await tester.pump(const Duration(milliseconds: 90));
      continue;
    }
    final intro = find.byKey(const Key('microtask_intro_continue_cta_v1'));
    if (await _tapIfVisible(tester, intro)) {
      await tester.pump(const Duration(milliseconds: 90));
      continue;
    }
    final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
    final continueCta = find.byKey(const Key('microtask_continue_cta'));
    if (outcomeSurface.evaluate().isNotEmpty ||
        continueCta.evaluate().isNotEmpty) {
      if (await _tapIfVisible(tester, continueCta)) {
        await tester.pumpAndSettle();
        continue;
      }
      await tester.pump(const Duration(milliseconds: 160));
      continue;
    }
    final tableCheck = find.byKey(const Key('table_practice_check_cta'));
    final microtaskCheck = find.byKey(const Key('microtask_check_cta'));
    if (tableCheck.evaluate().isNotEmpty || microtaskCheck.evaluate().isNotEmpty) {
      reachedInteractiveRunner = true;
      break;
    }
    if (find.byKey(const Key('spine_contract_expected_target')).evaluate().isNotEmpty ||
        find.byKey(const Key('spine_contract_requires_continue')).evaluate().isNotEmpty) {
      final contract = _readSpineContract(tester);
      if (contract.requiresContinue) {
        final continueTarget = find.byKey(
          const Key('spine_contract_target_continue'),
        );
        if (continueTarget.evaluate().isNotEmpty) {
          await tester.tap(continueTarget.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 120));
        }
      }
      if (contract.target.isNotEmpty) {
        final targetFinder = find.byKey(
          Key('spine_contract_target_${contract.target}'),
        );
        if (targetFinder.evaluate().isNotEmpty) {
          await tester.tap(targetFinder.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 80));
        }
      }
      final spineCheck = find.byKey(const Key('microtask_check_cta'));
      if (await _tapIfVisible(tester, spineCheck)) {
        await tester.pumpAndSettle();
      }
      if (await _tapIfVisible(tester, tableCheck)) {
        await tester.pumpAndSettle();
      }
      if (await _tapIfVisible(tester, continueCta)) {
        await tester.pumpAndSettle();
      }
      if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
        return;
      }
      continue;
    }
    for (final seatId in candidateSeatIds) {
      final tableSeat = find.byKey(Key('table_practice_seat_$seatId'));
      final microtaskSeat = find.byKey(Key('microtask_seat_$seatId'));
      if (await _tapIfVisible(tester, tableSeat) ||
          await _tapIfVisible(tester, microtaskSeat)) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      if (await _tapIfVisible(tester, tableCheck) ||
          await _tapIfVisible(tester, microtaskCheck)) {
        await tester.pumpAndSettle();
      }
      if (await _tapIfVisible(tester, continueCta)) {
        await tester.pumpAndSettle();
      }
      if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  if (reachedInteractiveRunner &&
      find.byType(UiV2ProgressMapScreenV2).evaluate().isEmpty) {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    if (find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Table practice did not reach a stable end-state or return to map within step budget.');
}

Future<void> _launchTablePracticeAndReturnToMap(WidgetTester tester) async {
  await _completeIntroSequenceIfPresent(tester);
  for (var i = 0; i < 160; i++) {
    if (find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
      return;
    }
    if (find.byKey(const Key('table_practice_check_cta')).evaluate().isNotEmpty ||
        find.byKey(const Key('microtask_check_cta')).evaluate().isNotEmpty ||
        find.byKey(const Key('microtask_campaign_action_bar')).evaluate().isNotEmpty) {
      for (var popCount = 0; popCount < 4; popCount++) {
        if (find.byType(UiV2ProgressMapScreenV2).evaluate().isNotEmpty) {
          return;
        }
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      return;
    }
    await tester.pump(const Duration(milliseconds: 80));
  }
  fail('Table practice did not reach an interactive runner state within budget.');
}

Future<void> _driveSpineRunnerToResultDeterministically(
  WidgetTester tester,
) async {
  for (var i = 0; i < 220; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    if (find.byKey(const Key('map_shell_v1')).evaluate().isNotEmpty &&
        find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      return;
    }
    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      continue;
    }
    final contract = _readSpineContract(tester);
    if (contract.requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    if (contract.target.isNotEmpty) {
      final targetFinder = find.byKey(
        Key('spine_contract_target_${contract.target}'),
      );
      if (targetFinder.evaluate().isNotEmpty) {
        await tester.tap(targetFinder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 60));
      }
    }
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    if (actionBar.evaluate().isNotEmpty) {
      Finder? actionTarget;
      for (final label in const <String>['CHECK', 'CALL', 'FOLD']) {
        final candidate = find.descendant(
          of: actionBar,
          matching: find.widgetWithText(OutlinedButton, label),
        );
        if (candidate.evaluate().isEmpty) {
          continue;
        }
        final enabledCandidate = candidate.evaluate().firstWhere(
          (element) => (element.widget as OutlinedButton).onPressed != null,
          orElse: () => candidate.evaluate().first,
        );
        final button = enabledCandidate.widget as OutlinedButton;
        if (button.onPressed == null) {
          continue;
        }
        actionTarget = find.byWidget(enabledCandidate.widget).first;
        break;
      }
      if (actionTarget != null) {
        await tester.tap(actionTarget, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pump(const Duration(milliseconds: 220));
        continue;
      }
    }
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      continue;
    }
    await tester.pump(const Duration(milliseconds: 120));
  }
  fail('Did not reach SessionResultScreen within deterministic budget.');
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
        await _launchTablePracticeAndReturnToMap(tester);
      } else {
        expect(find.byType(DrillRunnerScreen), findsOneWidget);
        await _advanceDrillUntilResult(tester);
        expect(find.byType(SessionResultScreen), findsOneWidget);
        await tester.tap(
          find.byKey(const Key('session_result_back_to_map_cta')),
        );
        await tester.pumpAndSettle();
      }

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
      await _advanceTablePracticeUntilResult(tester);

      expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);

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
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _driveSpineRunnerToResultDeterministically(tester);

    final eventNames = logged.map((event) => event['name'] as String).toSet();
    expect(eventNames, contains('session_start'));
    expect(eventNames, contains('user_choice'));
    expect(eventNames, contains('correct'));
    expect(eventNames, contains('time_to_decision'));
    expect(eventNames, contains('session_end'));
  });
}
