import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

Future<void> _pumpBounded(
  WidgetTester tester, {
  int ticks = 30,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < ticks; i++) {
    await tester.pump(step);
  }
}

Future<void> _waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 4),
  Duration step = const Duration(milliseconds: 16),
}) async {
  final maxTicks = (timeout.inMicroseconds / step.inMicroseconds).ceil();
  for (var i = 0; i < maxTicks; i++) {
    if (finders.any((finder) => finder.evaluate().isNotEmpty)) {
      return;
    }
    await tester.pump(step);
  }
  fail(
    'Timed out waiting for any of: ${finders.map((f) => f.description).join(', ')}',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> expectMapSurfaceVisible(WidgetTester tester) async {
    final shell = find.byKey(const Key('map_shell_v1'), skipOffstage: false);
    final section = find.byKey(const Key('world_campaign_section'));
    final loading = find.byKey(const Key('map_loading_v1'));
    final fallback = find.byKey(const Key('map_render_fallback_v1'));
    await _waitForAny(tester, <Finder>[shell, section, loading, fallback]);
    expect(shell.evaluate().isNotEmpty, isTrue);
    expect(find.text('Learning Path', skipOffstage: false), findsWidgets);
    expect(find.text('Progress Map V2', skipOffstage: false), findsNothing);
    expect(
      section.evaluate().isNotEmpty ||
          loading.evaluate().isNotEmpty ||
          fallback.evaluate().isNotEmpty,
      isTrue,
    );
  }

  testWidgets('today plan OPEN MAP returns to non-blank map shell', (
    tester,
  ) async {
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

    await tester.pumpWidget(const MaterialApp(home: UiV2ProgressMapScreenV2()));

    await expectMapSurfaceVisible(tester);

    final mapContext = tester.element(find.byType(UiV2ProgressMapScreenV2));
    Navigator.of(mapContext).push(
      MaterialPageRoute<void>(
        builder: (_) => const UniversalIntakePlanScreen(),
      ),
    );
    await _waitForAny(tester, <Finder>[
      find.byType(UniversalIntakePlanScreen),
      find.byKey(const Key('today_plan_open_map_cta')),
    ]);
    await _pumpBounded(tester);

    final openMap = find.byKey(const Key('today_plan_open_map_cta'));
    expect(openMap, findsOneWidget);

    await tester.tap(openMap, warnIfMissed: false);
    await _pumpBounded(tester);

    await expectMapSurfaceVisible(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('today plan OPEN MAP pushes map when no map route under stack', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
    });

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await _pumpBounded(tester);

    final openMap = find.byKey(const Key('today_plan_open_map_cta'));
    expect(openMap, findsOneWidget);

    await tester.tap(openMap, warnIfMissed: false);
    await _pumpBounded(tester);

    await expectMapSurfaceVisible(tester);
    expect(tester.takeException(), isNull);
  });
}
