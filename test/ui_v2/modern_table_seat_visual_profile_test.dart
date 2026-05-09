import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  testWidgets(
    'learner embedded seat profile quiets service labels and preserves primary seat states',
    (tester) async {
      final spec = ScenarioSpecV1(
        seatCount: 6,
        heroSeat: 0,
        initialStacks: const <int>[1200, 900, 800, 700, 600, 0],
        seatOccupancies: const <ScenarioSeatOccupancyV1>[
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.folded,
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.empty,
        ],
        actingSeatStart: 1,
        decisionNodeV1: const DecisionNodeV1(
          street: Street.preflop,
          legalActions: <String>['Fold', 'Call', 'Raise'],
          solutionBestAction: 'Call',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ModernTableScreenV1(
            embeddedV1: true,
            showsActingSeatV1: true,
            seatStateVisualProfileV1:
                ModernTableSeatStateVisualProfileV1.learnerEmbedded,
            scenarioSpec: spec,
            debugSeatRoleLabels: const <int, String>{
              0: 'BTN',
              1: 'UTG',
              2: 'HJ',
              4: 'SB',
            },
            debugSeatMarkerLabels: const <int, String>{0: 'D', 4: 'SB'},
            debugScenePromptLabel: 'Seat-state visual profile proof',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_action_marker_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_acting_ring_1')),
        findsOneWidget,
      );
      expect(find.text('LIVE'), findsNothing);
      expect(find.text('P1'), findsNothing);
      expect(find.text('P2'), findsNothing);
      expect(find.text('P3'), findsNothing);
      expect(find.text('P4'), findsNothing);
      expect(find.text('P5'), findsNothing);
      expect(find.byKey(const Key('modern_table_seat_role_2')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_2')),
          matching: find.text('HJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_stack_pill_P3')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_stack_pill_P4')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('modern_table_seat_folded_slash_3')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_folded_3')), findsNothing);
      expect(
        find.byKey(const Key('modern_table_seat_empty_5')),
        findsOneWidget,
      );
      expect(find.text('EMPTY'), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_posted_blind_token_4')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_4')),
          matching: find.text('POST SB'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
