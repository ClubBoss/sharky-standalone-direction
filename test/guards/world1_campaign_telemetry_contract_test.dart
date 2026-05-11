import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

class _SpineContractState {
  const _SpineContractState({
    required this.target,
    required this.requiresContinue,
  });

  final String target;
  final bool requiresContinue;
}

_SpineContractState _readContract(WidgetTester tester) {
  final targetFinder = find.byKey(
    const Key('spine_contract_expected_target'),
    skipOffstage: false,
  );
  final continueFinder = find.byKey(
    const Key('spine_contract_requires_continue'),
    skipOffstage: false,
  );
  final targetText = targetFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(targetFinder.first).data ?? '')
      : '';
  final continueText = continueFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(continueFinder.first).data ?? '')
      : '';
  final targetMatch = RegExp(r'^target=(.+)$').firstMatch(targetText.trim());
  return _SpineContractState(
    target: (targetMatch?.group(1) ?? '').trim(),
    requiresContinue: continueText.trim() == 'continue=1',
  );
}

Future<void> _driveCurrentSessionToResult(WidgetTester tester) async {
  for (var i = 0; i < 220; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    if (find.byKey(const Key('map_shell_v1')).evaluate().isNotEmpty &&
        find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
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
        await tester.pump(const Duration(milliseconds: 60));
      }
    }
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    if (actionBar.evaluate().isNotEmpty) {
      Finder? actionTarget;
      for (final label in const <String>['CHECK', 'CALL', 'FOLD']) {
        final candidate = find.descendant(
          of: actionBar,
          matching: find.widgetWithText(OutlinedButton, label),
        );
        if (candidate.evaluate().isEmpty) {
          continue;
        }
        final enabledCandidate = candidate.evaluate().firstWhere(
          (element) => (element.widget as OutlinedButton).onPressed != null,
          orElse: () => candidate.evaluate().first,
        );
        final button = enabledCandidate.widget as OutlinedButton;
        if (button.onPressed == null) {
          continue;
        }
        actionTarget = find.byWidget(enabledCandidate.widget).first;
        break;
      }
      if (actionTarget != null) {
        await tester.tap(actionTarget, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pump(const Duration(milliseconds: 220));
        continue;
      }
    }
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      continue;
    }
    await tester.pump(const Duration(milliseconds: 120));
  }
  fail('Did not reach SessionResultScreen within deterministic budget.');
}

Future<void> _startAndCompletePack(
  WidgetTester tester, {
  required String expectedPackId,
}) async {
  Finder? start;
  for (var i = 0; i < 30; i++) {
    if (find.byKey(const Key('microtask_step_header')).evaluate().isNotEmpty) {
      await _driveCurrentSessionToResult(tester);
      final backFromResult = find.byKey(
        const Key('session_result_back_to_map_cta'),
      );
      if (backFromResult.evaluate().isNotEmpty) {
        await tester.tap(backFromResult.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
      continue;
    }
    final levelNext = find.byKey(const Key('map_level_complete_next_cta_v1'));
    if (levelNext.evaluate().isNotEmpty) {
      await tester.tap(levelNext.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final continueFromResult = find.byKey(
      const Key('session_result_next_module_cta'),
    );
    if (continueFromResult.evaluate().isNotEmpty) {
      await tester.ensureVisible(continueFromResult.first);
      await tester.tap(continueFromResult.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final backToMap = find.byKey(const Key('session_result_back_to_map_cta'));
    if (backToMap.evaluate().isNotEmpty) {
      await tester.ensureVisible(backToMap.first);
      await tester.tap(backToMap.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final backToMapText = find.text('BACK TO MAP');
    if (backToMapText.evaluate().isNotEmpty) {
      await tester.tap(backToMapText.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final levelReplay = find.byKey(
      const Key('map_level_complete_replay_cta_v1'),
    );
    if (levelReplay.evaluate().isNotEmpty) {
      await tester.tap(levelReplay.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final todayPlanStart = find.byKey(const Key('today_plan_start_cta'));
    if (todayPlanStart.evaluate().isNotEmpty) {
      start = todayPlanStart;
      break;
    }
    final campaignStart = find.byKey(const Key('world_campaign_next_pack_cta'));
    if (campaignStart.evaluate().isNotEmpty) {
      start = campaignStart;
      break;
    }
    final openMap = find.byKey(const Key('today_plan_open_map_cta'));
    if (openMap.evaluate().isNotEmpty) {
      await tester.tap(openMap.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final worldOpen = find.byKey(const Key('world_campaign_open_1'));
    if (worldOpen.evaluate().isNotEmpty) {
      await tester.tap(worldOpen.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      final worldDetailStart = find.byKey(
        const Key('world_detail_primary_cta_v1'),
      );
      if (worldDetailStart.evaluate().isNotEmpty) {
        start = worldDetailStart;
        break;
      }
    }
    final startTheory = find.text('START THEORY');
    if (startTheory.evaluate().isNotEmpty) {
      start = startTheory;
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (start == null) {
    final sampleTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => (widget.data ?? '').trim())
        .where((text) => text.isNotEmpty)
        .take(20)
        .toList(growable: false);
    fail('No campaign start CTA found. textSample=$sampleTexts');
  }
  await tester.ensureVisible(start.first);
  await tester.tap(start.first, warnIfMissed: false);
  await tester.pumpAndSettle();

  final packFinder = find.byKey(
    const Key('spine_campaign_pack_id_value'),
    skipOffstage: false,
  );
  expect(packFinder, findsOneWidget);
  final packText = tester.widget<Text>(packFinder.first).data ?? '';
  expect(
    packText.startsWith('Pack:'),
    isTrue,
    reason: 'Missing campaign pack identity in runner harness',
  );

  await _driveCurrentSessionToResult(tester);
  final sessionResult = find.byType(SessionResultScreen);
  final mapShell = find.byKey(const Key('map_shell_v1'));
  expect(
    sessionResult.evaluate().isNotEmpty || mapShell.evaluate().isNotEmpty,
    isTrue,
    reason: 'Expected SessionResultScreen or map shell after completion',
  );
  if (sessionResult.evaluate().isNotEmpty) {
    final back = find.byKey(const Key('session_result_back_to_map_cta'));
    expect(back, findsOneWidget);
    await tester.ensureVisible(back.first);
    await tester.tap(back.first, warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'campaign telemetry events are present and completion is idempotent',
    (tester) async {
      final events = <String>[];
      final sfx = <String>[];
      Telemetry.overrideLogHandler((name, payload) async {
        events.add(name);
      });
      AudioService.onTestPlayUiSfx = sfx.add;
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
        AudioService.onTestPlayUiSfx = null;
      });

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
        'spine_calibration_completed_v1': false,
        'spine_calibration_band_v1': 0,
      });
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pumpAndSettle();

      await _startAndCompletePack(
        tester,
        expectedPackId: 'world1_act0_table_literacy',
      );

      await ProgressService.markSpinePackCompletedV1(
        'world1_spine_followup_v1_b0',
      );
      await ProgressService.markSpinePackCompletedV1(
        'world1_spine_followup_v1_b0',
      );
      await tester.pump(const Duration(milliseconds: 80));

      expect(events, contains(TelemetryEvents.campaignPackStart));
      expect(events, contains(TelemetryEvents.campaignPackEnd));
      expect(
        events
            .where((name) => name == TelemetryEvents.campaignHandResult)
            .length,
        greaterThanOrEqualTo(3),
      );
      expect(
        events.where((name) => name == TelemetryEvents.campaignComplete).length,
        lessThanOrEqualTo(1),
      );
      expect(sfx.where((name) => name == 'click_start').length, greaterThan(0));
      expect(
        sfx.any((name) => name == 'chip_win' || name == 'chip_lose'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
