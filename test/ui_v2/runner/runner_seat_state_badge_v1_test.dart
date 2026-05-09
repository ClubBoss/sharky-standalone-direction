import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';

void main() {
  testWidgets('runner seat state badge renders deterministic hero cue', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RunnerSeatStateBadgeV1(
              key: Key('seat_badge'),
              label: 'HERO',
              tone: RunnerSeatStateBadgeToneV1.hero,
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('seat_badge')), findsOneWidget);
    expect(find.text('HERO'), findsOneWidget);

    final badge = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('seat_badge')),
        matching: find.byType(Container),
      ),
    );
    final decoration = badge.decoration as BoxDecoration;
    expect(decoration.gradient, isNotNull);
    expect(decoration.borderRadius, BorderRadius.circular(999));
  });
}
