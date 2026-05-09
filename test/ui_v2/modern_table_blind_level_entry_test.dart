import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  testWidgets(
    'canonical table renders authored blind ownership, blind amounts, and minimal ante indicator',
    (tester) async {
      final spec = ScenarioSpecV1(
        seatCount: 6,
        heroSeat: 0,
        initialStacks: const <int>[1000, 1000, 1000, 1000, 1000, 1000],
        actingSeatStart: 0,
        blindLevelStateV1: const ScenarioBlindLevelStateV1(
          smallBlindSeatIndexV1: 4,
          bigBlindSeatIndexV1: 5,
          smallBlindAmountV1: 50,
          bigBlindAmountV1: 100,
          anteAmountV1: 10,
        ),
        decisionNodeV1: const DecisionNodeV1(
          street: Street.preflop,
          legalActions: <String>['Fold', 'Call', 'Raise'],
          solutionBestAction: 'Call',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('modern_table_seat_marker_4')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_marker_5')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_4')),
          matching: find.text('POST SB 50'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_posted_blind_token_4')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_5')),
          matching: find.text('POST BB 100'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_posted_blind_token_5')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_ante_indicator')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_ante_indicator')),
          matching: find.text('ANTE 10'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('canonical table keeps marker-derived blind posting grammar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ModernTableScreenV1(
          seatCount: 6,
          debugSeatMarkerLabels: <int, String>{4: 'SB', 5: 'BB'},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_seat_forced_bet_4')),
        matching: find.text('POST SB'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('modern_table_seat_posted_blind_token_4')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_seat_forced_bet_5')),
        matching: find.text('POST BB'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('modern_table_seat_posted_blind_token_5')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('modern_table_seat_live_4')), findsNothing);
    expect(find.byKey(const Key('modern_table_seat_live_5')), findsNothing);
  });

  testWidgets(
    'canonical table does not render ante indicator when ante is absent',
    (tester) async {
      final spec = ScenarioSpecV1(
        seatCount: 6,
        heroSeat: 0,
        initialStacks: const <int>[1000, 1000, 1000, 1000, 1000, 1000],
        actingSeatStart: 0,
        blindLevelStateV1: const ScenarioBlindLevelStateV1(
          smallBlindSeatIndexV1: 4,
          bigBlindSeatIndexV1: 5,
          smallBlindAmountV1: 50,
          bigBlindAmountV1: 100,
        ),
        decisionNodeV1: const DecisionNodeV1(
          street: Street.preflop,
          legalActions: <String>['Fold', 'Call', 'Raise'],
          solutionBestAction: 'Call',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('modern_table_ante_indicator')),
        findsNothing,
      );
    },
  );
}
