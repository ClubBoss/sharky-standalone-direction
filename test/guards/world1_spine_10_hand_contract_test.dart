import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

class _SpineRunStats {
  final Set<String> consequences = <String>{};
  bool sawPositiveDelta = false;
  bool sawNegativeDelta = false;
  int handPromptCount = 0;
}

Future<_SpineRunStats> _advanceCampaignHands(WidgetTester tester) async {
  final stats = _SpineRunStats();
  final forcedWrongHands = <int>{3, 7, 9};
  final forcedWrongApplied = <int>{};
  const wrongTargetToken = 'seat_co';

  for (var i = 0; i < 120; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return stats;
    }
    if (find.byKey(const Key('microtask_step_header')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }

    final handIndexFinder = find.byKey(
      const Key('spine_contract_hand_index'),
      skipOffstage: false,
    );
    final targetFinder = find.byKey(
      const Key('spine_contract_expected_target'),
      skipOffstage: false,
    );
    var handNumber = 0;
    if (handIndexFinder.evaluate().isNotEmpty) {
      final handIndexText =
          tester.widget<Text>(handIndexFinder.first).data ?? '';
      final handMatch = RegExp(r'^i=(\d+)$').firstMatch(handIndexText.trim());
      if (handMatch != null) {
        handNumber = (int.tryParse(handMatch.group(1) ?? '0') ?? 0) + 1;
      }
    }
    if (handNumber > 0) {
      stats.handPromptCount = handNumber;
    }

    final consequenceFinder = find.byKey(const Key('spine_hand_consequence'));
    if (consequenceFinder.evaluate().isNotEmpty) {
      final text = tester.widget<Text>(consequenceFinder.first).data ?? '';
      if (text.isNotEmpty) {
        stats.consequences.add(text);
      }
    }

    var targetToken = '';
    if (targetFinder.evaluate().isNotEmpty) {
      final targetText = tester.widget<Text>(targetFinder.first).data ?? '';
      final targetMatch = RegExp(
        r'^target=(.+)$',
      ).firstMatch(targetText.trim());
      targetToken = (targetMatch?.group(1) ?? '').trim();
    }
    if (targetToken.isEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final useWrongSeat =
        handNumber > 0 &&
        forcedWrongHands.contains(handNumber) &&
        !forcedWrongApplied.contains(handNumber);
    final seatTarget = useWrongSeat ? wrongTargetToken : targetToken;
    if (useWrongSeat) {
      forcedWrongApplied.add(handNumber);
    }
    final seat = find.byKey(Key('spine_contract_target_$seatTarget'));
    if (seat.evaluate().isNotEmpty) {
      await tester.tap(seat.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 40));
    }
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      final deltaFinder = find.byKey(const Key('spine_bankroll_delta'));
      if (deltaFinder.evaluate().isNotEmpty) {
        final deltaText = tester.widget<Text>(deltaFinder.first).data ?? '';
        if (deltaText.startsWith('+')) {
          stats.sawPositiveDelta = true;
        } else if (deltaText.startsWith('-')) {
          stats.sawNegativeDelta = true;
        }
      }
    }
  }
  fail('Campaign spine did not reach SessionResultScreen within step budget.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start completes 12-hand spine in a single runner path', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': false,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'training_bankroll_balance_v1': 100,
      'spine_rank_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
    });
    ProgressService.world1DailyCompletionInSession.value = false;

    final events = <String>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(name);
    });
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.tap(start, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    expect(find.byType(ModuleSummaryScreen), findsNothing);
    expect(find.byType(TheorySessionScreen), findsNothing);
    expect(find.byType(DrillRunnerScreen), findsNothing);

    final stats = await _advanceCampaignHands(tester);
    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(stats.handPromptCount, 12);
    expect(stats.sawPositiveDelta, isTrue);
    expect(stats.sawNegativeDelta, isTrue);
    expect(stats.consequences.length, greaterThanOrEqualTo(6));

    final sessionEndCount = events
        .where((name) => name == 'session_end')
        .length;
    expect(sessionEndCount, 1);
  });
}
