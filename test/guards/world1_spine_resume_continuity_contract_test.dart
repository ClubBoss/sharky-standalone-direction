import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

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

_SpineContractState _readContract(WidgetTester tester) {
  final handFinder = find.byKey(
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
  final handText = handFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(handFinder.first).data ?? '')
      : '';
  final targetText = targetFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(targetFinder.first).data ?? '')
      : '';
  final continueText = continueFinder.evaluate().isNotEmpty
      ? (tester.widget<Text>(continueFinder.first).data ?? '')
      : '';
  final handMatch = RegExp(r'^i=(\d+)$').firstMatch(handText.trim());
  final targetMatch = RegExp(r'^target=(.+)$').firstMatch(targetText.trim());
  return _SpineContractState(
    handIndex: int.tryParse(handMatch?.group(1) ?? '') ?? 0,
    target: (targetMatch?.group(1) ?? '').trim(),
    requiresContinue: continueText.trim() == 'continue=1',
  );
}

Future<void> _playHands(WidgetTester tester, int count) async {
  var done = 0;
  for (var i = 0; i < 220 && done < count; i++) {
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
      await tester.pump(const Duration(milliseconds: 120));
    }
    final checkFinder = find.byKey(const Key('microtask_check_cta'));
    if (checkFinder.evaluate().isNotEmpty) {
      await tester.tap(checkFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pump(const Duration(milliseconds: 320));
      done += 1;
    }
  }
  expect(done, count, reason: 'Could not complete requested hand count.');
}

Future<void> _playUntilResult(WidgetTester tester) async {
  for (var i = 0; i < 320; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    await _playHands(tester, 1);
  }
  fail('Did not reach SessionResultScreen within budget.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'campaign continuity resumes from saved hand index and resets on completion',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      await seedCampaignInProgressAtWorld1(
        prefs,
        bankroll: 100,
        nextHandIndex: 0,
      );
      await pumpToTodayPlan(tester, prefs: prefs);

      final start = find.byKey(const Key('today_plan_start_cta'));
      expect(start, findsOneWidget);
      expect(find.text('START CAMPAIGN'), findsOneWidget);
      await tester.tap(start, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );

      await _playHands(tester, 3);

      Navigator.of(
        tester.element(find.byType(World1FoundationsMicroTaskRunnerScreen)),
      ).pop();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(find.text('CONTINUE CAMPAIGN'), findsOneWidget);

      final activePack = await ProgressService.getSpineActivePackIdV1();
      final nextIndex = await ProgressService.getSpineNextHandIndexV1();
      expect(activePack, 'world1_spine_campaign_v1');
      expect(nextIndex, 3);

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      final contract = _readContract(tester);
      expect(contract.handIndex, 3);

      await _playUntilResult(tester);
      expect(find.byType(SessionResultScreen), findsOneWidget);

      final backToMap = find.byKey(const Key('session_result_back_to_map_cta'));
      expect(backToMap, findsOneWidget);
      await tester.ensureVisible(backToMap);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(backToMap, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(find.text('START CAMPAIGN'), findsOneWidget);

      final activePackAfter = await ProgressService.getSpineActivePackIdV1();
      final nextIndexAfter = await ProgressService.getSpineNextHandIndexV1();
      expect(activePackAfter, isNull);
      expect(nextIndexAfter, 0);
    },
  );
}
