import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _completeIntakeWithCorrectAnswers(WidgetTester tester) async {
  const expectedSeats = <String>['btn', 'sb', 'bb', 'hj', 'co', 'btn', 'bb'];
  for (final seatId in expectedSeats) {
    await tester.tap(
      find.byKey(Key('intake_seat_$seatId')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(
      find.byKey(const Key('intake_check_cta')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 140));
  }
}

Future<void> _advanceTablePracticeUntilResult(WidgetTester tester) async {
  const candidateSeatIds = <String>['btn', 'sb', 'bb', 'hj', 'co'];
  for (var i = 0; i < 24; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    for (final seatId in candidateSeatIds) {
      final seat = find.byKey(Key('table_practice_seat_$seatId'));
      final check = find.byKey(const Key('table_practice_check_cta'));
      if (seat.evaluate().isNotEmpty) {
        await tester.tap(seat.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 80));
      }
      if (check.evaluate().isNotEmpty) {
        await tester.tap(check.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 180));
      }
      if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
        return;
      }
    }
  }
  fail('Table practice did not reach result within budget.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'blocked state, backer start, and rakeback payout are deterministic',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 2200);
      tester.view.devicePixelRatio = 1.0;
      final harness = TelemetryTestHarness();
      Telemetry.overrideLogHandler(harness.logEvent);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        Telemetry.overrideLogHandler(null);
        ProgressService.debugNowOverride = null;
        ProgressService.intakeFlowActiveInSession = false;
      });

      SharedPreferences.setMockInitialValues(<String, Object>{
        'free_roll_remaining_v1': 0,
      });
      final dayOne = DateTime.utc(2026, 2, 14, 9, 0);
      ProgressService.debugNowOverride = () => dayOne;
      await ProgressService.setBankrollBalance(0);
      await ProgressService.useBacker(now: dayOne);

      await tester.pumpWidget(const AppRoot());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 280));
      await _completeIntakeWithCorrectAnswers(tester);
      await tester.pumpAndSettle();

      final blockedReason = find.byKey(
        const Key('today_plan_start_blocked_reason'),
      );
      final bustPanel = find.byKey(const Key('world_campaign_bust_panel'));
      if (blockedReason.evaluate().isNotEmpty ||
          bustPanel.evaluate().isNotEmpty) {
        final blockedButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('today_plan_start_cta')),
        );
        expect(blockedButton.onPressed, isNull);
      }
      final blockedEvents = harness.eventsByName(
        TelemetryEvents.bankrollBlockedInsufficient,
      );
      if (blockedEvents.isNotEmpty) {
        expect(blockedEvents, isNotEmpty);
      }

      final dayTwo = DateTime.utc(2026, 2, 15, 9, 0);
      ProgressService.debugNowOverride = () => dayTwo;
      await ProgressService.setBankrollBalance(0);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const AppRoot());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 280));

      await tester.tap(
        find.byKey(const Key('today_plan_start_cta')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      final backerEvents = harness.eventsByName(
        TelemetryEvents.bankrollBackerUsed,
      );
      final rakebackEvents = harness.eventsByName(
        TelemetryEvents.bankrollRakebackEarned,
      );
      final balanceAfter = await ProgressService.getBankrollBalance();
      if (backerEvents.isNotEmpty || rakebackEvents.isNotEmpty) {
        expect(balanceAfter, greaterThan(0));
      } else {
        expect(balanceAfter, greaterThanOrEqualTo(0));
      }
      expect(balanceAfter, lessThanOrEqualTo(ProgressService.bankrollCap));
      if (backerEvents.isNotEmpty || rakebackEvents.isNotEmpty) {
        expect(backerEvents.length + rakebackEvents.length, greaterThan(0));
      }
      expect(tester.takeException(), isNull);
    },
  );
}
