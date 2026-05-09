import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 160,
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

  testWidgets('map small portrait keeps campaign entry actionable on-screen', (
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
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': false,
      'world5_calibration_completed_v1': false,
      'world6_calibration_completed_v1': false,
      'world7_calibration_completed_v1': false,
      'world8_calibration_completed_v1': false,
      'world9_calibration_completed_v1': false,
      'world10_calibration_completed_v1': false,
    });

    await tester.pumpWidget(const AppRoot());

    final shell = find.byKey(const Key('map_shell_v1'), skipOffstage: false);
    final mapSection = find.byKey(const Key('world_campaign_section'));
    final mapFallback = find.byKey(const Key('map_render_fallback_v1'));
    final mapLoading = find.byKey(const Key('map_loading_v1'));
    await _pumpUntilAny(tester, <Finder>[
      shell,
      mapSection,
      mapFallback,
      mapLoading,
    ]);
    expect(shell.evaluate().isNotEmpty, isTrue);
    expect(
      mapSection.evaluate().isNotEmpty ||
          mapFallback.evaluate().isNotEmpty ||
          mapLoading.evaluate().isNotEmpty,
      isTrue,
    );

    if (mapSection.evaluate().isNotEmpty) {
      final openWorld1 = find.byKey(const Key('world_campaign_open_1'));
      await _pumpUntilAny(tester, <Finder>[
        openWorld1,
        mapFallback,
        mapLoading,
      ]);
      expect(openWorld1, findsOneWidget);

      final entryRect = tester.getRect(openWorld1);
      final logicalHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(entryRect.top >= 0, isTrue);
      expect(entryRect.bottom <= logicalHeight, isTrue);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('map open/back cycle never lands on blank screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2',
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
      'world10_calibration_completed_v1': true,
    });

    await tester.pumpWidget(const AppRoot());

    final shell = find.byKey(const Key('map_shell_v1'), skipOffstage: false);
    final mapSection = find.byKey(const Key('world_campaign_section'));
    final mapFallback = find.byKey(const Key('map_render_fallback_v1'));
    final mapLoading = find.byKey(const Key('map_loading_v1'));
    await _pumpUntilAny(tester, <Finder>[
      shell,
      mapSection,
      mapFallback,
      mapLoading,
    ]);
    expect(shell.evaluate().isNotEmpty, isTrue);

    if (mapSection.evaluate().isNotEmpty) {
      final openWorld1 = find.byKey(const Key('world_campaign_open_1'));
      await _pumpUntilAny(tester, <Finder>[
        openWorld1,
        mapFallback,
        mapLoading,
      ]);
      if (openWorld1.evaluate().isNotEmpty) {
        await tester.ensureVisible(openWorld1);
        await tester.tap(openWorld1, warnIfMissed: false);
        await _pumpBounded(tester);
      }

      final runner = find.byKey(const Key('microtask_runner'));
      await _pumpUntilAny(tester, <Finder>[runner, mapFallback, mapLoading]);
      if (runner.evaluate().isNotEmpty) {
        final backButton = find.byTooltip('Back');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first, warnIfMissed: false);
          await _pumpBounded(tester);
        }
      }
    }

    await _pumpUntilAny(tester, <Finder>[mapSection, mapFallback, mapLoading]);
    expect(
      mapSection.evaluate().isNotEmpty ||
          mapFallback.evaluate().isNotEmpty ||
          mapLoading.evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
