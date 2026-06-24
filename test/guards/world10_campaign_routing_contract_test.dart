import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

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
  for (var i = 0; i < 360; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return _WorldRunStats(
        maxHandIndexSeen: maxHandIndexSeen,
        sawPositiveDelta: sawPositiveDelta,
        sawNegativeDelta: sawNegativeDelta,
        distinctConsequences: consequenceSet.length,
      );
    }
    final continueCta = find.byKey(const Key('microtask_continue_cta'));
    if (continueCta.evaluate().isNotEmpty) {
      await tester.tap(continueCta.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      continue;
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
      continue;
    }
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    if (actionBar.evaluate().isNotEmpty) {
      Finder? actionTarget;
      for (final label in const <String>['CHECK', 'CALL', 'FOLD']) {
        final candidate = find.descendant(
          of: actionBar,
          matching: find.widgetWithText(OutlinedButton, label),
        );
        if (candidate.evaluate().isNotEmpty) {
          final enabledCandidate = candidate.evaluate().firstWhere(
            (element) => (element.widget as OutlinedButton).onPressed != null,
            orElse: () => candidate.evaluate().first,
          );
          actionTarget = find.byWidget(enabledCandidate.widget).first;
          final button = enabledCandidate.widget as OutlinedButton;
          if (button.onPressed == null) {
            continue;
          }
          break;
        }
      }
      if (actionTarget != null) {
        await tester.tap(actionTarget, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pump(const Duration(milliseconds: 220));
      }
    }
  }
  fail('World10 session did not reach SessionResultScreen within budget.');
}

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
    await _pumpUntilAny(tester, <Finder>[
      home,
      currentRouteCta,
    ]);
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

  testWidgets('world10 campaign routing starts and emits pack telemetry', (
    tester,
  ) async {
    final events = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(<String, dynamic>{'name': name, 'payload': payload});
    });
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
    });

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

    await tester.pumpWidget(const AppRoot());
    await _pumpBounded(tester);

    await tester.pumpWidget(
      const MaterialApp(home: UniversalIntakePlanScreen()),
    );
    await _pumpBounded(tester);

    await PaymentService.syncCanonicalEntitlementForProductV1(
      PaymentService.productPremiumPack,
    );

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.ensureVisible(start);
    await tester.tap(start, warnIfMissed: false);
    await _pumpBounded(tester);

    final packValue = find.byKey(const Key('spine_campaign_pack_id_value'));
    await _pumpUntilAny(tester, <Finder>[packValue], maxTicks: 240);
    expect(packValue, findsOneWidget);
    final packText = tester.widget<Text>(packValue.first).data ?? '';
    expect(packText, contains('world10_spine_campaign_v1'));

    final runStats = await _driveSessionToResult(tester);
    expect(find.byType(SessionResultScreen), findsOneWidget);

    final packStarts = events
        .where(
          (event) =>
              event['name'] == TelemetryEvents.campaignPackStart &&
              (event['payload'] as Map?)?['pack_id'] ==
                  'world10_spine_campaign_v1',
        )
        .length;
    final packEnds = events
        .where(
          (event) =>
              event['name'] == TelemetryEvents.campaignPackEnd &&
              (event['payload'] as Map?)?['pack_id'] ==
                  'world10_spine_campaign_v1',
        )
        .length;
    final sessionEnds = events
        .where((event) => event['name'] == TelemetryEvents.sessionEnd)
        .length;

    expect(packStarts, greaterThanOrEqualTo(1));
    expect(packEnds, greaterThanOrEqualTo(1));
    expect(runStats.maxHandIndexSeen, greaterThanOrEqualTo(11));
    expect(runStats.distinctConsequences, greaterThanOrEqualTo(1));
    expect(sessionEnds, 1);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 32));
  });
}
