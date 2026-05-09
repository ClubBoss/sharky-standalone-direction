import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';

Future<void> _pumpBounded(
  WidgetTester tester, {
  int ticks = 24,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < ticks; i++) {
    await tester.pump(step);
  }
}

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 120,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finders.any((finder) => finder.evaluate().isNotEmpty)) {
      return;
    }
    await tester.pump(step);
  }
}

Future<void> _expectMapNonBlank(WidgetTester tester) async {
  final shell = find.byKey(const Key('map_shell_v1'), skipOffstage: false);
  final section = find.byKey(const Key('world_campaign_section'));
  final loading = find.byKey(const Key('map_loading_v1'));
  final fallback = find.byKey(const Key('map_render_fallback_v1'));
  final globalFallback = find.byKey(const Key('non_blank_fallback_surface_v1'));

  await _pumpUntilAny(tester, <Finder>[shell, section, loading, fallback]);

  expect(shell.evaluate().isNotEmpty, isTrue);
  expect(
    section.evaluate().isNotEmpty ||
        loading.evaluate().isNotEmpty ||
        fallback.evaluate().isNotEmpty,
    isTrue,
  );
  expect(globalFallback, findsNothing);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map stays non-blank across paused/resumed lifecycle', (
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

    await tester.pumpWidget(const AppRoot());
    await _expectMapNonBlank(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await _pumpBounded(
      tester,
      ticks: 6,
      step: const Duration(milliseconds: 40),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _pumpBounded(
      tester,
      ticks: 12,
      step: const Duration(milliseconds: 40),
    );
    await _expectMapNonBlank(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await _pumpBounded(
      tester,
      ticks: 4,
      step: const Duration(milliseconds: 40),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _pumpBounded(
      tester,
      ticks: 8,
      step: const Duration(milliseconds: 40),
    );
    await _expectMapNonBlank(tester);

    expect(tester.takeException(), isNull);
  });
}
