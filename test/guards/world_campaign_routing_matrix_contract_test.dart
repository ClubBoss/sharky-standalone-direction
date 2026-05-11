import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import '_harness/canonical_direct_session_launch_contract_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

class _SpineContractState {
  const _SpineContractState({
    required this.handIndex,
    required this.target,
    required this.requiresContinue,
  });

  final int handIndex;
  final String target;
  final bool requiresContinue;
}

class _WorldRunStats {
  const _WorldRunStats({
    required this.maxHandIndexSeen,
    required this.sawPositiveDelta,
    required this.sawNegativeDelta,
    required this.distinctConsequences,
  });

  final int maxHandIndexSeen;
  final bool sawPositiveDelta;
  final bool sawNegativeDelta;
  final int distinctConsequences;
}

_SpineContractState _readContract(WidgetTester tester) {
  final handIndexFinder = find.byKey(
    const Key('spine_contract_hand_index'),
    skipOffstage: false,
  );
  final targetFinder = find.byKey(
    const Key('spine_contract_expected_target'),
    skipOffstage: false,
  );
  final continueFinder = find.byKey(
    const Key('spine_contract_requires_continue'),
    skipOffstage: false,
  );
  final handIndexText = handIndexFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(handIndexFinder.first).data ?? '')
      : '';
  final targetText = targetFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(targetFinder.first).data ?? '')
      : '';
  final continueText = continueFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(continueFinder.first).data ?? '')
      : '';
  final handIndexMatch = RegExp(r'^i=(\d+)$').firstMatch(handIndexText.trim());
  final targetMatch = RegExp(r'^target=(.+)$').firstMatch(targetText.trim());
  return _SpineContractState(
    handIndex: int.tryParse(handIndexMatch?.group(1) ?? '') ?? 0,
    target: (targetMatch?.group(1) ?? '').trim(),
    requiresContinue: continueText.trim() == 'continue=1',
  );
}

Future<_WorldRunStats> _driveSessionToResult(WidgetTester tester) async {
  var maxHandIndexSeen = 0;
  var sawPositiveDelta = false;
  var sawNegativeDelta = false;
  var forcedNegativeDone = false;
  final consequenceSet = <String>{};

  for (var i = 0; i < 400; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return _WorldRunStats(
        maxHandIndexSeen: maxHandIndexSeen,
        sawPositiveDelta: sawPositiveDelta,
        sawNegativeDelta: sawNegativeDelta,
        distinctConsequences: consequenceSet.length,
      );
    }

    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      continue;
    }

    final contract = _readContract(tester);
    if (contract.handIndex > maxHandIndexSeen) {
      maxHandIndexSeen = contract.handIndex;
    }

    final consequenceFinder = find.byKey(const Key('spine_hand_consequence'));
    if (consequenceFinder.evaluate().isNotEmpty) {
      final text = (tester.widget<Text>(consequenceFinder.first).data ?? '')
          .trim();
      if (text.isNotEmpty) {
        consequenceSet.add(text);
      }
    }

    if (contract.requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }

    if (contract.target.isNotEmpty) {
      final targetToken = (!forcedNegativeDone && contract.handIndex == 1)
          ? 'seat_co'
          : contract.target;
      final targetFinder = find.byKey(
        Key('spine_contract_target_$targetToken'),
      );
      if (targetFinder.evaluate().isNotEmpty) {
        await tester.tap(targetFinder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 60));
      }
    }

    final checkFinder = find.byKey(const Key('microtask_check_cta'));
    if (checkFinder.evaluate().isNotEmpty) {
      await tester.tap(checkFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      final deltaFinder = find.byKey(const Key('spine_bankroll_delta'));
      if (deltaFinder.evaluate().isNotEmpty) {
        final deltaText = (tester.widget<Text>(deltaFinder.first).data ?? '')
            .trim();
        if (deltaText.startsWith('+')) {
          sawPositiveDelta = true;
        }
        if (deltaText.startsWith('-')) {
          sawNegativeDelta = true;
          forcedNegativeDone = true;
        }
      }
    }
  }

  fail('Campaign session did not reach SessionResultScreen within budget.');
}

String _completedPacksCsvForWorld(int world) {
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

Map<String, Object> _prefsForWorld(int world) {
  final values = <String, Object>{
    'onboardingCompleted': true,
    'intake_completed_v1': true,
    'intake_profile_v1':
        '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
    'spine_campaign_active_pack_id_v1': '',
    'spine_campaign_next_hand_index_v1': 0,
    'spine_campaign_completed_packs_v1': _completedPacksCsvForWorld(world),
    'spine_calibration_completed_v1': true,
    'spine_calibration_band_v1': 2,
  };
  for (var w = 2; w < world; w++) {
    values['world${w}_calibration_completed_v1'] = true;
  }
  values['world${world}_calibration_completed_v1'] = false;
  return values;
}

Map<String, Object> _prefsForWorldStart(int world) {
  if (world <= 1) {
    return <String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
    };
  }
  return _prefsForWorld(world);
}

Future<int> _captureFirstPositiveDeltaForWorld(
  WidgetTester tester,
  int world,
) async {
  final expectedPackId = 'world${world}_spine_campaign_v1';
  final events = <Map<String, dynamic>>[];
  Telemetry.overrideLogHandler((name, payload) async {
    events.add(<String, dynamic>{'name': name, 'payload': payload});
  });
  try {
    SharedPreferences.setMockInitialValues(_prefsForWorldStart(world));
    await tester.pumpWidget(
      MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: expectedPackId,
          moduleTitle: 'World $world',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    for (var i = 0; i < 120; i++) {
      if (find
          .byKey(const Key('microtask_step_header'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    for (var i = 0; i < 220; i++) {
      final firstPositive = events
          .where(
            (event) =>
                event['name'] == TelemetryEvents.campaignHandResult &&
                (event['payload'] as Map?)?['pack_id'] == expectedPackId &&
                (((event['payload'] as Map?)?['delta'] as num?) ?? 0) > 0,
          )
          .map((event) => ((event['payload'] as Map?)?['delta'] as num).toInt())
          .cast<int?>()
          .firstWhere((delta) => delta != null, orElse: () => null);
      if (firstPositive != null) {
        return firstPositive;
      }

      if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
        break;
      }
      if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
        continue;
      }
      final contract = _readContract(tester);
      if (contract.requiresContinue) {
        final continueTarget = find.byKey(
          const Key('spine_contract_target_continue'),
        );
        if (continueTarget.evaluate().isNotEmpty) {
          await tester.tap(continueTarget.first, warnIfMissed: false);
        }
        await tester.pump(const Duration(milliseconds: 120));
        continue;
      }
      if (contract.target.isNotEmpty) {
        final targetFinder = find.byKey(
          Key('spine_contract_target_${contract.target}'),
        );
        if (targetFinder.evaluate().isNotEmpty) {
          await tester.tap(targetFinder.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 60));
        }
      }
      final checkFinder = find.byKey(const Key('microtask_check_cta'));
      if (checkFinder.evaluate().isNotEmpty) {
        await tester.tap(checkFinder.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
    }

    fail('No positive campaign delta observed for $expectedPackId.');
  } finally {
    Telemetry.overrideLogHandler(null);
  }
}

Future<void> _executeFirstDecision(WidgetTester tester) async {
  for (var i = 0; i < 80; i++) {
    if (find.byKey(const Key('microtask_step_header')).evaluate().isNotEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  final contract = _readContract(tester);
  if (contract.target.isNotEmpty) {
    final targetFinder = find.byKey(
      Key('spine_contract_target_${contract.target}'),
    );
    if (targetFinder.evaluate().isNotEmpty) {
      await tester.tap(targetFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 80));
    }
  }
  final checkFinder = find.byKey(const Key('microtask_check_cta'));
  expect(checkFinder, findsOneWidget);
  await tester.tap(checkFinder, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 220));
  await tester.pump(const Duration(milliseconds: 220));
}

Future<void> _driveAllCorrectToResult(WidgetTester tester) async {
  for (var i = 0; i < 320; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      continue;
    }

    final contract = _readContract(tester);
    if (contract.requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }

    if (contract.target.isNotEmpty) {
      final targetFinder = find.byKey(
        Key('spine_contract_target_${contract.target}'),
      );
      if (targetFinder.evaluate().isNotEmpty) {
        await tester.tap(targetFinder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 80));
      }
    }

    final checkFinder = find.byKey(const Key('microtask_check_cta'));
    if (checkFinder.evaluate().isNotEmpty) {
      await tester.tap(checkFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      expect(tester.takeException(), isNull);
    }
  }
  fail('Campaign session did not reach SessionResultScreen within budget.');
}

Future<void> _assertWorldRouting(WidgetTester tester, int world) async {
  final expectedPackId = 'world${world}_spine_campaign_v1';
  final events = <Map<String, dynamic>>[];

  Telemetry.overrideLogHandler((name, payload) async {
    events.add(<String, dynamic>{'name': name, 'payload': payload});
  });
  try {
    SharedPreferences.setMockInitialValues(_prefsForWorld(world));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    for (var i = 0; i < 80; i++) {
      if (find.byKey(const Key('today_plan_start_cta')).evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    if (world >= 5) {
      await PaymentService.syncCanonicalEntitlementForProductV1(
        PaymentService.productPremiumPack,
      );
    }
    await tester.ensureVisible(start);
    await tester.tap(start, warnIfMissed: false);
    final packValue = find.byKey(const Key('spine_campaign_pack_id_value'));
    final directSession = findCanonicalDirectSessionSurfaceV1();
    final loadError = find.byKey(const Key('session_drill_player_load_error'));
    for (var i = 0; i < 80; i++) {
      if (packValue.evaluate().isNotEmpty ||
          directSession.evaluate().isNotEmpty ||
          loadError.evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    if (directSession.evaluate().isNotEmpty ||
        loadError.evaluate().isNotEmpty) {
      final expectedDirectSessionId = world <= 6 ? 'w$world.s01' : expectedPackId;
      expectCanonicalDirectSessionLaunchV1(tester, expectedDirectSessionId);
      expect(loadError, findsNothing);
      expect(packValue, findsNothing);
      expect(tester.takeException(), isNull);
      return;
    }

    expect(packValue, findsOneWidget);
    final packText = tester.widget<Text>(packValue.first).data ?? '';
    expect(packText, contains(expectedPackId));

    final runStats = await _driveSessionToResult(tester);
    expect(find.byType(SessionResultScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));

    final packStarts = events
        .where(
          (event) =>
              event['name'] == TelemetryEvents.campaignPackStart &&
              (event['payload'] as Map?)?['pack_id'] == expectedPackId,
        )
        .length;
    final packEnds = events
        .where(
          (event) =>
              event['name'] == TelemetryEvents.campaignPackEnd &&
              (event['payload'] as Map?)?['pack_id'] == expectedPackId,
        )
        .length;
    final sessionEnds = events
        .where((event) => event['name'] == TelemetryEvents.sessionEnd)
        .length;

    expect(packStarts, greaterThanOrEqualTo(1));
    expect(packEnds, greaterThanOrEqualTo(1));
    expect(runStats.maxHandIndexSeen, greaterThanOrEqualTo(11));
    expect(runStats.sawPositiveDelta, isTrue);
    expect(runStats.sawNegativeDelta, isTrue);
    expect(runStats.distinctConsequences, greaterThanOrEqualTo(6));
    expect(sessionEnds, 1);
    expect(tester.takeException(), isNull);
  } finally {
    Telemetry.overrideLogHandler(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fullMatrix = Platform.environment['FULL_CAMPAIGN_MATRIX'] == '1';

  testWidgets('campaign completion derived set boots to map', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1': _completedPacksCsvForWorld(11),
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

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    for (var i = 0; i < 80; i++) {
      if (find.byKey(const Key('world1_state_current')).evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('world1_state_current')), findsOneWidget);
    expect(find.byKey(const Key('today_plan_start_cta')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('campaign routing matrix worlds 2..6', (tester) async {
    final worlds = fullMatrix ? <int>[2, 3, 4, 5, 6] : <int>[2, 6];
    for (final world in worlds) {
      await _assertWorldRouting(tester, world);
    }
  });

  testWidgets('campaign routing matrix worlds 7..10', (tester) async {
    final worlds = fullMatrix ? <int>[7, 8, 9, 10] : <int>[10];
    for (final world in worlds) {
      await _assertWorldRouting(tester, world);
    }
  });

  testWidgets('stake multiplier increases first positive delta by world', (
    tester,
  ) async {
    final world1 = await _captureFirstPositiveDeltaForWorld(tester, 1);
    final world5 = await _captureFirstPositiveDeltaForWorld(tester, 5);
    final world10 = await _captureFirstPositiveDeltaForWorld(tester, 10);

    expect(world10, greaterThan(world5));
    expect(world5, greaterThan(world1));
  });

  testWidgets('world1 runner visual safety remains overflow-safe', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(_prefsForWorldStart(1));
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    await _executeFirstDecision(tester);
    expect(tester.takeException(), isNull);

    await _driveSessionToResult(tester);
    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('World1 full arc no-exception sweep', (tester) async {
    final events = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(<String, dynamic>{'name': name, 'payload': payload});
    });
    try {
      SharedPreferences.setMockInitialValues(_prefsForWorldStart(1));
      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      for (var i = 0; i < 100; i++) {
        if (find
            .byKey(const Key('today_plan_start_cta'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.byKey(const Key('today_plan_start_cta')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      await _driveAllCorrectToResult(tester);
      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_campaign_rank_value')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_back_to_map_cta')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      final sessionEnds = events
          .where((event) => event['name'] == TelemetryEvents.sessionEnd)
          .length;
      expect(sessionEnds, 1);
    } finally {
      Telemetry.overrideLogHandler(null);
    }
  });
}
