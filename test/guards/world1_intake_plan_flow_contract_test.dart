import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

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
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start intake plan flow is deterministic and non-duplicating', (
    tester,
  ) async {
    final events = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(<String, dynamic>{'name': name, 'payload': payload ?? {}});
    });
    addTearDown(() {
      Telemetry.overrideLogHandler(null);
    });
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(const AppRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));

    expect(find.byKey(const Key('intake_runner')), findsOneWidget);
    await _completeIntakeWithCorrectAnswers(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
    expect(find.byKey(const Key('today_plan_top_leak_value')), findsOneWidget);
    expect(
      find.byKey(const Key('today_plan_first_session_brief_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today_plan_first_session_sharky_v1')),
      findsOneWidget,
    );
    expect(find.text('Sharky Poker'), findsOneWidget);
    expect(
      find.text(
        'Table-first training so every later poker decision starts from the right seat.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Today you will learn who acts first by locating Button, small blind, and big blind.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Success today: name Button, small blind, and big blind without guessing.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Sharky: Start with the seat map. The rest of the hand builds from there.',
      ),
      findsOneWidget,
    );

    final start = find.byKey(const Key('today_plan_start_cta'));
    expect(start, findsOneWidget);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.tap(start.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));

    final profile = await ProgressService.getIntakeProfile();
    expect(profile, isNotNull);
    expect(profile?['focusLabel'], isNotNull);
    final eventNames = events
        .map((event) => event['name'] as String)
        .toList(growable: false);
    expect(
      eventNames.where(
        (name) => name == TelemetryEvents.firstSessionTrustImpressionV1,
      ),
      hasLength(1),
    );
    expect(
      eventNames.where(
        (name) => name == TelemetryEvents.firstSessionTrustStartedV1,
      ),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });
}
