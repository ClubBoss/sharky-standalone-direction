import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 180,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    await tester.pump(step);
  }
}

Future<void> _pumpBounded(
  WidgetTester tester, {
  int ticks = 24,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < ticks; i++) {
    await tester.pump(step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('world10 canonical entry remains actionable on small portrait', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_followup_v1_b2,world7_spine_followup_v1_b2,world8_spine_followup_v1_b2,world9_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': true,
      'world8_calibration_completed_v1': true,
      'world9_calibration_completed_v1': true,
      'world10_calibration_completed_v1': false,
    });

    await tester.pumpWidget(const AppRoot());
    final home = find.byKey(const Key('act0_shell_home_screen'));
    final currentRouteCta = find.byKey(const Key('act0_shell_main_cta'));
    await _pumpUntilAny(tester, <Finder>[home, currentRouteCta]);
    expect(home, findsOneWidget);
    expect(currentRouteCta, findsOneWidget);

    final ctaRect = tester.getRect(currentRouteCta);
    final logicalHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(ctaRect.top >= 0, isTrue);
    expect(ctaRect.bottom <= logicalHeight, isTrue);
    final ctaWidget = tester.widget<FilledButton>(currentRouteCta);
    expect(ctaWidget.onPressed != null, isTrue);

    expect(tester.takeException(), isNull);
  });

  testWidgets('world10 routing is admitted by active learner route gate', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_followup_v1_b2,world7_spine_followup_v1_b2,world8_spine_followup_v1_b2,world9_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': true,
      'world8_calibration_completed_v1': true,
      'world9_calibration_completed_v1': true,
      'world10_calibration_completed_v1': false,
    });
    final expectedPackId = await ProgressService.getNextSpinePackToRunV1();
    expect(expectedPackId, 'world10_spine_campaign_v1');

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await _pumpBounded(tester);
    expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
    expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
    expect(find.byKey(const Key('spine_campaign_pack_id_value')), findsNothing);
    expect(find.textContaining('world6_spine_followup_v1_b2'), findsNothing);
    expect(find.textContaining('world10_spine_campaign_v1'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
