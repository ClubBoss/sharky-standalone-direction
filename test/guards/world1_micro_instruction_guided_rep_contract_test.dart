import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _tap(WidgetTester tester, Key key) async {
    final finder = find.byKey(key);
    await tester.ensureVisible(finder);
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
  }

  testWidgets(
    'seed step shows instruction+guided once, iso reps do not, telemetry terminal stays single',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'intro_welcome',
            moduleTitle: 'Welcome to Poker',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('microtask_instruction_overlay')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_guided_scope_seats')),
        findsOneWidget,
      );

      final harness = TelemetryTestHarness();
      Telemetry.overrideLogHandler(harness.logEvent);
      addTearDown(() => Telemetry.overrideLogHandler(null));

      await _tap(tester, const Key('microtask_seat_btn'));
      await _tap(tester, const Key('microtask_check_cta'));
      await tester.pump();

      expect(
        find.byKey(const Key('microtask_guided_scope_seats')),
        findsNothing,
      );
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_instruction_overlay')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('microtask_guided_scope_seats')),
        findsNothing,
      );

      await _tap(tester, const Key('microtask_seat_sb'));
      await _tap(tester, const Key('microtask_check_cta'));
      await tester.pump();

      await _tap(tester, const Key('microtask_seat_bb'));
      await _tap(tester, const Key('microtask_check_cta'));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(harness.eventsByName(TelemetryEvents.sessionEnd), hasLength(1));
      expect(harness.eventsByName(TelemetryEvents.sessionAbort), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
