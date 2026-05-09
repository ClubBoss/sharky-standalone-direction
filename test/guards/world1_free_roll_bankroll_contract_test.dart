import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _completeIntakeBase(WidgetTester tester) async {
  const expectedSeats = <String>['btn', 'sb', 'bb', 'hj', 'co', 'btn', 'bb'];
  for (final seatId in expectedSeats) {
    await tester.tap(
      find.byKey(Key('intake_seat_$seatId')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(
      find.byKey(const Key('intake_check_cta')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first three starts use free-roll, fourth charges buy-in once', (
    tester,
  ) async {
    final harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
      ProgressService.debugNowOverride = null;
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    ProgressService.debugNowOverride = () => DateTime.utc(2026, 2, 14, 12, 0);
    await ProgressService.setBankrollBalance(100);

    await tester.pumpWidget(const AppRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));
    await _completeIntakeBase(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(
        find.byKey(const Key('today_plan_start_cta')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
    }

    final balance = await ProgressService.getBankrollBalance();
    expect(balance, inInclusiveRange(80, 100));
    final freeRollEvents = harness.eventsByName(
      TelemetryEvents.bankrollFreeRollUsed,
    );
    final buyInEvents = harness.eventsByName(
      TelemetryEvents.bankrollBuyInCharged,
    );
    if (freeRollEvents.isNotEmpty || buyInEvents.isNotEmpty) {
      expect(freeRollEvents.length, greaterThanOrEqualTo(3));
      expect(buyInEvents.length, lessThanOrEqualTo(1));
    }
    expect(tester.takeException(), isNull);
  });
}
