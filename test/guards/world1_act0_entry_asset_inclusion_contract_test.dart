import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<void> _runUntilResult(WidgetTester tester) async {
  for (var i = 0; i < 140; i++) {
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

    final targetFinder = find.byKey(
      Key('spine_contract_target_${contract.target}'),
    );
    if (targetFinder.evaluate().isNotEmpty) {
      await tester.tap(targetFinder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 80));
    }
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 260));
    }
  }
  fail('Act0 run did not reach SessionResultScreen in bounded steps.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'cold start launches Act0 entry and completes without asset errors',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': false,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_active_pack_id_v1': '',
        'spine_calibration_completed_v1': false,
        'spine_calibration_band_v1': 0,
      });
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();

      final start = find.byKey(const Key('today_plan_start_cta'));
      expect(start, findsOneWidget);
      await tester.tap(start.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      expect(find.byKey(const Key('microtask_step_header')), findsOneWidget);
      expect(
        find.byKey(const Key('spine_campaign_pack_id_value')),
        findsOneWidget,
      );
      expect(find.textContaining('world1_act0_table_literacy'), findsOneWidget);
      expect(find.textContaining('Could not load content file'), findsNothing);
      expect(find.textContaining('Unable to load asset'), findsNothing);

      await _runUntilResult(tester);
      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
