import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

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

Future<void> _runCurrentSessionToResult(WidgetTester tester) async {
  for (var i = 0; i < 180; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
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
      await tester.pump(const Duration(milliseconds: 160));
      continue;
    }
    final targetFinder = find.byKey(
      Key('spine_contract_target_${contract.target}'),
    );
    if (targetFinder.evaluate().isNotEmpty) {
      await tester.tap(targetFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 90));
    }
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 260));
      await tester.pump(const Duration(milliseconds: 260));
    }
  }
  fail('Did not reach SessionResultScreen within deterministic budget.');
}

Future<void> _startAndCompleteSession(
  WidgetTester tester, {
  required String expectedPackId,
}) async {
  if (find.byType(World1FoundationsMicroTaskRunnerScreen).evaluate().isEmpty) {
    final start = find.byKey(const Key('today_plan_start_cta'));
    final nextPack = find.byKey(const Key('world_campaign_next_pack_cta'));
    if (start.evaluate().isNotEmpty) {
      await tester.tap(start.first, warnIfMissed: false);
    } else if (nextPack.evaluate().isNotEmpty) {
      await tester.tap(nextPack.first, warnIfMissed: false);
    } else {
      fail('Expected today plan start or map next-pack CTA.');
    }
  }
  await tester.pumpAndSettle();

  expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
  expect(
    find.textContaining(expectedPackId),
    findsOneWidget,
    reason: 'Unexpected pack launched from Today Plan.',
  );
  expect(find.textContaining('Unable to load asset'), findsNothing);
  expect(find.textContaining('Could not load content file'), findsNothing);

  await _runCurrentSessionToResult(tester);
  expect(find.byType(SessionResultScreen), findsOneWidget);

  final backToMap = find.byKey(const Key('session_result_back_to_map_cta'));
  final nextModule = find.byKey(const Key('session_result_next_module_cta'));
  if (nextModule.evaluate().isNotEmpty) {
    await tester.tap(nextModule.first, warnIfMissed: false);
  } else {
    expect(backToMap, findsOneWidget);
    await tester.ensureVisible(backToMap.first);
    await tester.tap(backToMap.first, warnIfMissed: false);
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Act0 chain transitions into campaign spine deterministically', (
    tester,
  ) async {
    final viewports = <Size>[const Size(800, 600), const Size(900, 700)];

    for (final viewport in viewports) {
      final logged = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        logged.add(<String, dynamic>{'name': name, 'payload': payload});
      });

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': false,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_calibration_completed_v1': false,
        'spine_calibration_band_v1': 0,
      });
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        Telemetry.overrideLogHandler(null);
      });

      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();

      final start = find.byKey(const Key('today_plan_start_cta'));
      if (start.evaluate().isNotEmpty) {
        await tester.ensureVisible(start.first);
      }

      await _startAndCompleteSession(
        tester,
        expectedPackId: 'world1_act0_table_literacy',
      );

      final sessionEnds = logged
          .where((e) => e['name'] == 'session_end')
          .length;
      final sessionAborts = logged
          .where((e) => e['name'] == 'session_abort')
          .length;
      expect(
        sessionEnds,
        greaterThanOrEqualTo(1),
        reason: 'Viewport $viewport',
      );
      expect(sessionAborts, 0, reason: 'Viewport $viewport');
      expect(tester.takeException(), isNull, reason: 'Viewport $viewport');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
