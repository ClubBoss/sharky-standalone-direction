import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_harness/canonical_direct_session_launch_contract_harness_v1.dart';
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

  testWidgets('world4 entry remains actionable on small portrait', (
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
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': false,
    });

    await tester.pumpWidget(const AppRoot());
    final home = find.byKey(const Key('act0_shell_home_screen'));
    final learn = find.byKey(const Key('act0_shell_learn_screen'));
    final bottomNav = find.byKey(const Key('act0_shell_bottom_nav'));
    final learnTab = find.descendant(
      of: bottomNav,
      matching: find.text('Learn'),
    );
    await _pumpUntilAny(tester, <Finder>[home, bottomNav]);

    expect(home, findsOneWidget);
    expect(bottomNav, findsOneWidget);
    expect(learnTab, findsOneWidget);

    final logicalHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final navRect = tester.getRect(bottomNav);
    expect(navRect.top, greaterThanOrEqualTo(0));
    expect(navRect.bottom, lessThanOrEqualTo(logicalHeight));

    await tester.tap(learnTab);
    await tester.pumpAndSettle();
    expect(learn, findsOneWidget);

    final missionCard = find.byKey(
      const Key('act0_shell_current_mission_card'),
    );
    final missionCta = find.byKey(const Key('act0_shell_current_mission_cta'));
    await _pumpUntilAny(tester, <Finder>[missionCard, missionCta]);
    expect(missionCard, findsOneWidget);
    expect(missionCta, findsOneWidget);

    await tester.ensureVisible(missionCta);
    await tester.pumpAndSettle();
    final ctaRect = tester.getRect(missionCta);
    expect(ctaRect.top, greaterThanOrEqualTo(0));
    expect(ctaRect.bottom, lessThanOrEqualTo(logicalHeight));
    final ctaWidget = tester.widget<FilledButton>(missionCta);
    expect(ctaWidget.onPressed, isNotNull);

    expect(tester.takeException(), isNull);
  });

  testWidgets('world4 compact action path clears bottom safe-area chin', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewPadding();
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': false,
    });

    await tester.pumpWidget(const AppRoot());
    final bottomNav = find.byKey(const Key('act0_shell_bottom_nav'));
    final learnTab = find.descendant(
      of: bottomNav,
      matching: find.text('Learn'),
    );
    await _pumpUntilAny(tester, <Finder>[bottomNav, learnTab]);
    expect(learnTab, findsOneWidget);

    await tester.tap(learnTab);
    await tester.pumpAndSettle();

    final missionCta = find.byKey(const Key('act0_shell_current_mission_cta'));
    await _pumpUntilAny(tester, <Finder>[missionCta]);
    expect(missionCta, findsOneWidget);
    await tester.ensureVisible(missionCta);
    await tester.pumpAndSettle();

    final logicalHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final safeBottom =
        logicalHeight -
        tester.view.viewPadding.bottom / tester.view.devicePixelRatio;
    final ctaRect = tester.getRect(missionCta);
    expect(ctaRect.top, greaterThanOrEqualTo(0));
    expect(ctaRect.bottom, lessThanOrEqualTo(safeBottom));
    final ctaWidget = tester.widget<FilledButton>(missionCta);
    expect(ctaWidget.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('world4 campaign routing starts on direct session entry', (
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
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': false,
    });

    await tester.pumpWidget(const AppRoot());
    await _pumpBounded(tester);

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await _pumpBounded(tester);

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.ensureVisible(start);
    await tester.tap(start, warnIfMissed: false);
    await _pumpUntilAny(tester, <Finder>[
      findCanonicalDirectSessionSurfaceV1(),
    ], maxTicks: 240);

    expectCanonicalDirectSessionLaunchV1(tester, 'w4.s01');
    expect(find.byKey(const Key('spine_campaign_pack_id_value')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'world4 campaign routing advances into the promoted follow-on session slice',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': false,
        'module_completedw4.s01': true,
        'module_completedw4.s02': true,
        'module_completedw4.s03': true,
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpBounded(tester);

      final start = find.byKey(const Key('today_plan_start_cta'));
      expect(start, findsOneWidget);
      await tester.ensureVisible(start);
      await tester.tap(start, warnIfMissed: false);
      await _pumpUntilAny(tester, <Finder>[
        findCanonicalDirectSessionSurfaceV1(),
      ], maxTicks: 240);

      expectCanonicalDirectSessionLaunchV1(tester, 'w4.s04');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world4 campaign routing advances into the final promoted tail after w4.s06',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': false,
        'module_completedw4.s01': true,
        'module_completedw4.s02': true,
        'module_completedw4.s03': true,
        'module_completedw4.s04': true,
        'module_completedw4.s05': true,
        'module_completedw4.s06': true,
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpBounded(tester);

      final start = find.byKey(const Key('today_plan_start_cta'));
      expect(start, findsOneWidget);
      await tester.ensureVisible(start);
      await tester.tap(start, warnIfMissed: false);
      await _pumpUntilAny(tester, <Finder>[
        findCanonicalDirectSessionSurfaceV1(),
      ], maxTicks: 240);

      expectCanonicalDirectSessionLaunchV1(tester, 'w4.s07');
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'world4 authored session slice completion resolves calibration',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'world4_calibration_completed_v1': false,
      });

      await ProgressService.markModuleCompleted('w4.s01');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s02');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s03');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s04');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s05');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s06');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s07');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s08');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s09');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isFalse);

      await ProgressService.markModuleCompleted('w4.s10');
      expect(await ProgressService.isWorld4CalibrationCompletedV1(), isTrue);
    },
  );
}
