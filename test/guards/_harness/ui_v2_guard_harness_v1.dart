import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

const String _campaignCompleteSeedCsv =
    'world1_act0_table_literacy,'
    'world1_act0_action_literacy,'
    'world1_act0_street_flow,'
    'world1_spine_campaign_v1,'
    'world1_spine_followup_v1_b2';

class GuardSeedV2 {
  const GuardSeedV2(this.values);

  final Map<String, Object> values;
}

Finder findTodayPlanStartCta() => find.byKey(const Key('today_plan_start_cta'));
Finder findWorldCampaignNextPackCta() =>
    find.byKey(const Key('world_campaign_next_pack_cta'));
Finder findSessionResultBackToMapCta() =>
    find.byKey(const Key('session_result_back_to_map_cta'));
Finder findWorldCampaignBackerCta() =>
    find.byKey(const Key('world_campaign_backer_cta'));
Finder findWorldCampaignBustPanel() =>
    find.byKey(const Key('world_campaign_bust_panel'));

GuardSeedV2 seedWorld1CampaignComplete({
  String completedCsv = _campaignCompleteSeedCsv,
  int bankroll = ProgressService.bankrollCap,
}) {
  return GuardSeedV2(<String, Object>{
    'onboardingCompleted': true,
    'intake_completed_v1': true,
    'training_bankroll_balance_v1': bankroll,
    'campaign_bankroll_balance_v1': bankroll,
    'spine_campaign_completed_packs_v1': completedCsv,
    'spine_campaign_active_pack_id_v1': '',
    'spine_campaign_next_hand_index_v1': 0,
    'spine_calibration_completed_v1': true,
    'spine_calibration_band_v1': ProgressService.spineCalibrationBandAdvanced,
  });
}

GuardSeedV2 seedWorld1CampaignInProgress({
  int bankroll = ProgressService.bankrollCap,
  int campaignBankroll = ProgressService.bankrollCap,
  int nextHandIndex = 0,
  int freeRollRemaining = 0,
  bool onboardingCompleted = false,
  bool intakeCompleted = true,
  bool markWorld1CalibrationComplete = false,
  String completedCsv =
      'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
  String? activePackId,
}) {
  return GuardSeedV2(<String, Object>{
    'onboardingCompleted': onboardingCompleted,
    'intake_completed_v1': intakeCompleted,
    'intake_profile_v1':
        '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
    'free_roll_remaining_v1': freeRollRemaining,
    'training_bankroll_balance_v1': bankroll,
    'campaign_bankroll_balance_v1': campaignBankroll,
    'spine_campaign_completed_packs_v1': completedCsv,
    'spine_campaign_active_pack_id_v1':
        activePackId ??
        (nextHandIndex > 0 ? ProgressService.spineInitialPackIdV1 : ''),
    'spine_campaign_next_hand_index_v1': nextHandIndex,
    'spine_calibration_completed_v1': markWorld1CalibrationComplete,
    'spine_calibration_band_v1': markWorld1CalibrationComplete
        ? ProgressService.spineCalibrationBandBeginner
        : 0,
  });
}

Future<void> seedPrefsForCampaignComplete(SharedPreferences prefs) async {
  await prefs.setBool('onboardingCompleted', true);
  await prefs.setBool('intake_completed_v1', true);
  await prefs.setString(
    'spine_campaign_completed_packs_v1',
    _campaignCompleteSeedCsv,
  );
  await prefs.setString('spine_campaign_active_pack_id_v1', '');
  await prefs.setInt('spine_campaign_next_hand_index_v1', 0);
}

Future<void> seedCampaignInProgressAtWorld1(
  SharedPreferences prefs, {
  required int bankroll,
  required int nextHandIndex,
  bool markWorld1CalibrationComplete = false,
  bool onboardingCompleted = false,
  bool intakeCompleted = true,
  int freeRollRemaining = 0,
  int campaignBankroll = ProgressService.bankrollCap,
  String? activePackId,
}) async {
  await prefs.setBool('onboardingCompleted', onboardingCompleted);
  await prefs.setBool('intake_completed_v1', intakeCompleted);
  await prefs.setString(
    'intake_profile_v1',
    '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
  );
  await prefs.setInt('free_roll_remaining_v1', freeRollRemaining);
  await prefs.setInt('training_bankroll_balance_v1', bankroll);
  await prefs.setInt('campaign_bankroll_balance_v1', campaignBankroll);
  await prefs.setString(
    'spine_campaign_completed_packs_v1',
    'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
  );
  await prefs.setString(
    'spine_campaign_active_pack_id_v1',
    activePackId ??
        (nextHandIndex > 0 ? ProgressService.spineInitialPackIdV1 : ''),
  );
  await prefs.setInt('spine_campaign_next_hand_index_v1', nextHandIndex);
  await prefs.setBool(
    'spine_calibration_completed_v1',
    markWorld1CalibrationComplete,
  );
  await prefs.setInt(
    'spine_calibration_band_v1',
    markWorld1CalibrationComplete
        ? ProgressService.spineCalibrationBandBeginner
        : 0,
  );
}

Future<SharedPreferences> _applySeed(GuardSeedV2 seed) async {
  SharedPreferences.setMockInitialValues(seed.values);
  return SharedPreferences.getInstance();
}

Finder findMap() {
  return find.byType(UiV2ProgressMapScreenV2);
}

Future<void> pumpToTodayPlan(
  WidgetTester tester, {
  GuardSeedV2? seed,
  SharedPreferences? prefs,
}) async {
  if (seed != null) {
    await _applySeed(seed);
  } else if (prefs != null) {
    // Backward-compatible path for older guard harness callers.
  } else {
    throw ArgumentError('pumpToTodayPlan requires either seed or prefs');
  }
  await tester.pumpWidget(const AppRoot());
  for (var i = 0; i < 120; i++) {
    if (find.byKey(const Key('today_plan_screen')).evaluate().isNotEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(UniversalIntakePlanScreen), findsOneWidget);
  expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> pumpToSessionResult(
  WidgetTester tester, {
  required int correctCount,
  required int totalCount,
  required String moduleId,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SessionResultScreen(
        correctCount: correctCount,
        totalCount: totalCount,
        moduleId: moduleId,
      ),
    ),
  );
  for (var i = 0; i < 40; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(SessionResultScreen), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> pumpToMap(
  WidgetTester tester, {
  GuardSeedV2? seed,
  SharedPreferences? prefs,
}) async {
  if (seed != null) {
    await _applySeed(seed);
  } else if (prefs != null) {
    await seedPrefsForCampaignComplete(prefs);
  } else {
    throw ArgumentError('pumpToMap requires either seed or prefs');
  }
  await tester.pumpWidget(const AppRoot());
  for (var i = 0; i < 80; i++) {
    if (findMap().evaluate().isNotEmpty &&
        find
            .byKey(const Key('world1_ladder_progress_bar'))
            .evaluate()
            .isNotEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(findMap(), findsOneWidget);
  expect(find.byKey(const Key('world1_ladder_progress_bar')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> pumpThroughOneTodayRunToResult(WidgetTester tester) async {
  final start = findTodayPlanStartCta();
  expect(start, findsOneWidget);
  await tester.tap(start.first, warnIfMissed: false);
  await tester.pumpAndSettle();
  expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

  for (var i = 0; i < 180; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      break;
    }
    final requiresContinueFinder = find.byKey(
      const Key('spine_contract_requires_continue'),
      skipOffstage: false,
    );
    final targetFinder = find.byKey(
      const Key('spine_contract_expected_target'),
      skipOffstage: false,
    );
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
    var targetToken = '';
    if (targetFinder.evaluate().isNotEmpty) {
      final raw = tester.widget<Text>(targetFinder.first).data ?? '';
      final match = RegExp(r'^target=(.+)$').firstMatch(raw.trim());
      targetToken = (match?.group(1) ?? '').trim();
    }
    if (targetToken.isNotEmpty) {
      final target = find.byKey(Key('spine_contract_target_$targetToken'));
      if (target.evaluate().isNotEmpty) {
        await tester.tap(target.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 60));
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
  expect(find.byType(SessionResultScreen), findsOneWidget);
  expect(tester.takeException(), isNull);
}
