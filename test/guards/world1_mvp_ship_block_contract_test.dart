import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

class _SpineContractState {
  const _SpineContractState({
    required this.target,
    required this.requiresContinue,
  });

  final String target;
  final bool requiresContinue;
}

_SpineContractState _readContract(WidgetTester tester) {
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

String _activePackId(WidgetTester tester) {
  final finder = find.byKey(
    const Key('spine_campaign_pack_id_value'),
    skipOffstage: false,
  );
  expect(finder, findsOneWidget);
  final raw = tester.widget<Text>(finder.first).data ?? '';
  final match = RegExp(r'^Pack:\s*(.+)$').firstMatch(raw.trim());
  return (match?.group(1) ?? '').trim();
}

Future<void> _driveCurrentRunnerToResult(WidgetTester tester) async {
  for (var i = 0; i < 240; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final contract = _readContract(tester);
    if (contract.requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 160));
      continue;
    }
    if (contract.target.isNotEmpty) {
      final targetFinder = find.byKey(
        Key('spine_contract_target_${contract.target}'),
      );
      if (targetFinder.evaluate().isNotEmpty) {
        await tester.tap(targetFinder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 70));
      }
    }
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
    }
  }
  fail('Did not reach SessionResultScreen in deterministic budget.');
}

Future<void> _startAndFinishOneSession(
  WidgetTester tester, {
  required String expectedPackId,
}) async {
  final start = find.byKey(const Key('today_plan_start_cta'));
  expect(start, findsOneWidget);
  await tester.ensureVisible(start.first);
  await tester.tap(start.first, warnIfMissed: false);
  await tester.pumpAndSettle();

  expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
  expect(_activePackId(tester), expectedPackId);
  expect(find.byType(ModuleSummaryScreen), findsNothing);
  expect(find.byType(TheorySessionScreen), findsNothing);
  expect(find.byType(DrillRunnerScreen), findsNothing);

  await _driveCurrentRunnerToResult(tester);
  expect(find.byType(SessionResultScreen), findsOneWidget);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'MVP ship block path stays campaign-first and unlocks map after completion',
    (tester) async {
      final telemetryNames = <String>[];
      Telemetry.overrideLogHandler((name, payload) async {
        telemetryNames.add(name);
      });
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
      });

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': false,
        'spine_calibration_band_v1': 0,
      });
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('world1_state_current')),
        findsNothing,
      );

      const expectedPacks = <String>[
        'world1_act0_table_literacy',
        'world1_act0_action_literacy',
        'world1_act0_street_flow',
        'world1_spine_campaign_v1',
        'world1_spine_followup_v1_b2',
      ];

      for (var i = 0; i < expectedPacks.length; i++) {
        await _startAndFinishOneSession(
          tester,
          expectedPackId: expectedPacks[i],
        );
        final backCta = find.byKey(const Key('session_result_back_to_map_cta'));
        expect(backCta, findsOneWidget);
        await tester.ensureVisible(backCta.first);
        await tester.tap(backCta.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      await ProgressService.markSpinePackCompletedV1(
        'world1_spine_followup_v1_b2',
      );
      expect(await ProgressService.isCampaignCompleteV1(), isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byType(ModuleSummaryScreen), findsNothing);
      expect(find.byType(TheorySessionScreen), findsNothing);
      expect(find.byType(DrillRunnerScreen), findsNothing);

      final sessionEnds = telemetryNames
          .where((name) => name == 'session_end')
          .length;
      final sessionAborts = telemetryNames
          .where((name) => name == 'session_abort')
          .length;
      expect(sessionEnds, expectedPacks.length);
      expect(sessionAborts, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
