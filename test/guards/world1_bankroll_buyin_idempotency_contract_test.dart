import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('today plan start charges buy-in once under rapid double tap', (
    tester,
  ) async {
    final harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
      ProgressService.debugNowOverride = null;
    });

    SharedPreferences.setMockInitialValues(<String, Object>{
      'free_roll_remaining_v1': 0,
    });
    final prefs = await SharedPreferences.getInstance();
    ProgressService.debugNowOverride = () => DateTime.utc(2026, 2, 14, 12, 0);
    await seedCampaignInProgressAtWorld1(
      prefs,
      bankroll: 100,
      nextHandIndex: 0,
      freeRollRemaining: 0,
    );
    await pumpToTodayPlan(tester, prefs: prefs);

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    final balance = await ProgressService.getBankrollBalance();
    expect(balance, 100);
    expect(harness.eventsByName(TelemetryEvents.bankrollBuyInCharged), isEmpty);
    expect(tester.takeException(), isNull);
  });
}
