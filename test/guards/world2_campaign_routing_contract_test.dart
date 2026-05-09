import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_harness/canonical_direct_session_launch_contract_harness_v1.dart';
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

  testWidgets('world2 entry remains actionable on small portrait', (
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
      'world2_calibration_completed_v1': false,
    });

    await tester.pumpWidget(const AppRoot());
    final mapFallback = find.byKey(const Key('map_render_fallback_v1'));
    final world2Entry = find.byKey(const Key('world_campaign_open_2'));
    final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
    await _pumpUntilAny(tester, <Finder>[
      world2Entry,
      nextPackCta,
      mapFallback,
    ]);
    expect(
      world2Entry.evaluate().isNotEmpty ||
          nextPackCta.evaluate().isNotEmpty ||
          mapFallback.evaluate().isNotEmpty,
      isTrue,
    );

    if (nextPackCta.evaluate().isNotEmpty) {
      final ctaRect = tester.getRect(nextPackCta);
      final logicalHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(ctaRect.top >= 0, isTrue);
      expect(ctaRect.bottom <= logicalHeight, isTrue);
      final ctaWidget = tester.widget<ElevatedButton>(nextPackCta);
      expect(ctaWidget.onPressed != null, isTrue);
    } else if (world2Entry.evaluate().isNotEmpty) {
      final entryRect = tester.getRect(world2Entry);
      final logicalHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(entryRect.top >= 0, isTrue);
      expect(entryRect.bottom <= logicalHeight, isTrue);
    }
  });

  testWidgets('world2 campaign routing starts on direct session entry', (
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
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': false,
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
    await _pumpBounded(tester);

    await _pumpUntilAny(tester, <Finder>[
      findCanonicalDirectSessionSurfaceV1(),
      find.byKey(const Key('session_drill_player_table_viewport')),
      find.byKey(const Key('session_drill_player_load_error')),
    ], maxTicks: 240);
    await _pumpBounded(tester, ticks: 48);

    expectCanonicalDirectSessionLaunchV1(tester, 'w2.s01');
    expect(
      find.byKey(const Key('session_drill_player_load_error')),
      findsNothing,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world2_showdown_intro_card_v1'),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('spine_campaign_pack_id_value')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
