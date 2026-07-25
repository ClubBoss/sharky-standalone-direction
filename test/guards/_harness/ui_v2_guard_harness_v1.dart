import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

class GuardSeedV2 {
  const GuardSeedV2(this.values);

  final Map<String, Object> values;
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
