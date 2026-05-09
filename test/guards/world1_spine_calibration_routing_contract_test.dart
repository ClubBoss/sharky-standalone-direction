import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _runInitialSpineToBand2(WidgetTester tester) async {
  for (var i = 0; i < 240; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }

    final requiresContinueFinder = find.byKey(
      const Key('spine_contract_requires_continue'),
      skipOffstage: false,
    );
    final headerFinder = find.byKey(const Key('microtask_step_header'));
    if (headerFinder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final requiresContinue =
        requiresContinueFinder.evaluate().isNotEmpty &&
        (tester.widget<Text>(requiresContinueFinder.first).data ?? '').trim() ==
            'continue=1';
    if (requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 140));
      continue;
    }

    final targetFinder = find.byKey(
      const Key('spine_contract_expected_target'),
      skipOffstage: false,
    );
    if (targetFinder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final targetText = tester.widget<Text>(targetFinder.first).data ?? '';
    final targetMatch = RegExp(r'^target=(.+)$').firstMatch(targetText.trim());
    final target = (targetMatch?.group(1) ?? '').trim();
    if (target.isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }

    final seatFinder = find.byKey(Key('spine_contract_target_$target'));
    if (seatFinder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    await tester.tap(seatFinder.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 40));

    final checkFinder = find.byKey(const Key('microtask_check_cta'));
    if (checkFinder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    await tester.tap(checkFinder.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 220));
  }

  fail('Initial spine run did not reach SessionResultScreen within budget.');
}

Future<Map<String, Object>> _runFollowupAndCollect(WidgetTester tester) async {
  final consequenceSet = <String>{};
  var handCount = 0;
  for (var i = 0; i < 240; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return <String, Object>{
        'handCount': handCount,
        'consequenceCount': consequenceSet.length,
      };
    }
    final requiresContinueFinder = find.byKey(
      const Key('spine_contract_requires_continue'),
      skipOffstage: false,
    );
    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final requiresContinue =
        requiresContinueFinder.evaluate().isNotEmpty &&
        (tester.widget<Text>(requiresContinueFinder.first).data ?? '').trim() ==
            'continue=1';
    if (requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 140));
      continue;
    }

    final handIndexFinder = find.byKey(
      const Key('spine_contract_hand_index'),
      skipOffstage: false,
    );
    if (handIndexFinder.evaluate().isNotEmpty) {
      final text = tester.widget<Text>(handIndexFinder.first).data ?? '';
      final match = RegExp(r'^i=(\d+)$').firstMatch(text.trim());
      if (match != null) {
        handCount = (int.tryParse(match.group(1) ?? '0') ?? 0) + 1;
      }
    }

    final consequenceFinder = find.byKey(const Key('spine_hand_consequence'));
    if (consequenceFinder.evaluate().isNotEmpty) {
      final text = tester.widget<Text>(consequenceFinder.first).data ?? '';
      if (text.isNotEmpty) {
        consequenceSet.add(text);
      }
    }

    final targetFinder = find.byKey(
      const Key('spine_contract_expected_target'),
      skipOffstage: false,
    );
    if (targetFinder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final targetText = tester.widget<Text>(targetFinder.first).data ?? '';
    final targetMatch = RegExp(r'^target=(.+)$').firstMatch(targetText.trim());
    final target = (targetMatch?.group(1) ?? '').trim();
    if (target.isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }

    final seatFinder = find.byKey(Key('spine_contract_target_$target'));
    if (seatFinder.evaluate().isNotEmpty) {
      await tester.tap(seatFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 40));
    }
    final checkFinder = find.byKey(const Key('microtask_check_cta'));
    if (checkFinder.evaluate().isNotEmpty) {
      await tester.tap(checkFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
    }
  }
  fail('Followup run did not reach SessionResultScreen within budget.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('spine calibration stores band and routes continue campaign pack', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': false,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'training_bankroll_balance_v1': 100,
      'spine_rank_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
    });
    ProgressService.world1DailyCompletionInSession.value = false;

    final events = <String>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(name);
    });
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    final firstStart = find.byKey(const Key('today_plan_start_cta'));
    expect(firstStart, findsOneWidget);
    expect(find.text('START CAMPAIGN'), findsOneWidget);

    await tester.tap(firstStart, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

    await _runInitialSpineToBand2(tester);
    expect(find.byType(SessionResultScreen), findsOneWidget);

    final sessionEndCount = events
        .where((name) => name == 'session_end')
        .length;
    expect(sessionEndCount, 1);

    final savedBand = await ProgressService.getSpineCalibrationBandV1();
    expect(savedBand, 2);

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await tester.pumpAndSettle();

    final continueStart = find.byKey(const Key('today_plan_start_cta'));
    expect(continueStart, findsOneWidget);
    expect(find.text('START CAMPAIGN'), findsOneWidget);

    await tester.tap(continueStart, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    final expectedFollowupPackId = await ProgressService.getNextSpinePackToRunV1();
    final followupRunner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
      find.byType(World1FoundationsMicroTaskRunnerScreen),
    );
    expect(followupRunner.moduleId, expectedFollowupPackId);

    final followup = await _runFollowupAndCollect(tester);
    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(followup['handCount'], 12);
    expect(followup['consequenceCount'], greaterThanOrEqualTo(6));
  });
}
