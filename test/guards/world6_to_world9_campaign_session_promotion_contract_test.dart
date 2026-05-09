import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import '_harness/canonical_direct_session_launch_contract_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 240,
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

String _completedPacksBeforeWorld(int world) {
  final packs = <String>[
    'world1_act0_table_literacy',
    'world1_act0_action_literacy',
    'world1_act0_street_flow',
    'world1_spine_campaign_v1',
    'world1_spine_followup_v1_b2',
  ];
  for (var w = 2; w < world; w++) {
    packs.add('world${w}_spine_followup_v1_b2');
  }
  return packs.join(',');
}

Map<String, Object> _basePrefsForWorld(int world) {
  final prefs = <String, Object>{
    'onboardingCompleted': true,
    'intake_completed_v1': true,
    'intake_profile_v1':
        '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
    'spine_campaign_active_pack_id_v1': '',
    'spine_campaign_next_hand_index_v1': 0,
    'spine_campaign_completed_packs_v1': _completedPacksBeforeWorld(world),
    'spine_calibration_completed_v1': true,
    'spine_calibration_band_v1': 2,
    'world2_calibration_completed_v1': true,
    'world3_calibration_completed_v1': true,
    'world4_calibration_completed_v1': true,
    'world5_calibration_completed_v1': true,
    'world6_calibration_completed_v1': world > 6,
    'world7_calibration_completed_v1': world > 7,
    'world8_calibration_completed_v1': world > 8,
    'world9_calibration_completed_v1': world > 9,
    'world10_calibration_completed_v1': false,
  };
  prefs['world${world}_calibration_completed_v1'] = false;
  return prefs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('today plan promotes worlds 6-9 into canonical session hosts', (
    tester,
  ) async {
    for (final world in <int>[6, 7, 8, 9]) {
      SharedPreferences.setMockInitialValues(_basePrefsForWorld(world));

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntilAny(tester, <Finder>[
        find.byKey(const Key('today_plan_start_cta')),
      ]);
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);

      await PaymentService.syncCanonicalEntitlementForProductV1(
        PaymentService.productPremiumPack,
      );

      await tester.tap(
        find.byKey(const Key('today_plan_start_cta')),
        warnIfMissed: false,
      );
      await tester.pump();
      await _pumpUntilAny(tester, <Finder>[
        findCanonicalDirectSessionSurfaceV1(),
      ]);

      expectCanonicalDirectSessionLaunchV1(tester, 'w$world.s01');
      expect(
        readCanonicalDirectSessionStatusLineV1(tester),
        'Campaign route -> World $world sessions',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'today plan uses next incomplete canonical session for worlds 6-9',
    (tester) async {
      for (final world in <int>[6, 7, 8, 9]) {
        final prefs = _basePrefsForWorld(world);
        prefs['module_completedw$world.s01'] = true;
        prefs['module_completedw$world.s02'] = true;
        SharedPreferences.setMockInitialValues(prefs);

        await tester.pumpWidget(
          const MaterialApp(home: UniversalIntakePlanScreen()),
        );
        await _pumpUntilAny(tester, <Finder>[
          find.byKey(const Key('today_plan_start_cta')),
        ]);
        expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);

        await PaymentService.syncCanonicalEntitlementForProductV1(
          PaymentService.productPremiumPack,
        );

        await tester.tap(
          find.byKey(const Key('today_plan_start_cta')),
          warnIfMissed: false,
        );
        await tester.pump();
        await _pumpUntilAny(tester, <Finder>[
          findCanonicalDirectSessionSurfaceV1(),
        ]);

        expectCanonicalDirectSessionLaunchV1(tester, 'w$world.s03');
        expect(
          readCanonicalDirectSessionStatusLineV1(tester),
          'Campaign route -> World $world sessions',
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'campaign map resolves worlds 6-9 through canonical session hosts',
    (tester) async {
      for (final world in <int>[6, 7, 8, 9]) {
        final prefs = _basePrefsForWorld(world);
        prefs['module_completedw$world.s01'] = true;
        prefs['module_completedw$world.s02'] = true;
        SharedPreferences.setMockInitialValues(prefs);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UiV2ProgressMapScreenV2(),
          ),
        );
        await _pumpUntilAny(tester, <Finder>[
          find.byType(UiV2ProgressMapScreenV2),
        ]);

        await PaymentService.syncCanonicalEntitlementForProductV1(
          PaymentService.productPremiumPack,
        );

        final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
        (state as dynamic).debugLaunchCampaignPackForTestV1(
          'world${world}_spine_campaign_v1',
        );
        await tester.pump();
        await _pumpUntilAny(tester, <Finder>[
          findCanonicalDirectSessionSurfaceV1(),
        ]);

        expectCanonicalDirectSessionLaunchV1(tester, 'w$world.s03');
        expect(
          find.byType(World1FoundationsMicroTaskRunnerScreen),
          findsNothing,
        );
        expect(
          readCanonicalDirectSessionStatusLineV1(tester),
          'Campaign route -> World $world sessions',
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
    },
  );
}
