import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_spatial_scenario_state_v1.dart';

void main() {
  test(
    'canonical spatial scenario state preserves seat-tap projected state',
    () {
      final state = resolveSessionDrillCanonicalSpatialScenarioStateV1(
        const DrillSpecV1(
          id: 'find_btn',
          kind: DrillKindV1.seatTap,
          prompt: 'Tap BTN.',
          expected: DrillExpectedV1(role: 'btn'),
          errorClass: 'mismatch',
          playerCountV1: 6,
          heroSeatV1: 'sb',
          villainSeatV1: 'btn',
          activeSeatsV1: <String>['sb', 'bb', 'btn', 'co', 'hj', 'lj'],
          foldedSeatsV1: <String>['utg'],
        ),
      );

      expect(state, isNotNull);
      expect(
        state!.family,
        SessionDrillCanonicalSpatialScenarioFamilyV1.seatTap,
      );
      expect(state.projectedStreetV1, Street.preflop);
      expect(state.playerCountV1, 6);
      expect(state.heroSeatV1, 'sb');
      expect(state.villainSeatV1, 'btn');
      expect(state.activeSeatsV1, <String>[
        'sb',
        'bb',
        'btn',
        'co',
        'hj',
        'lj',
      ]);
      expect(state.foldedSeatsV1, <String>['utg']);
    },
  );

  test(
    'canonical spatial scenario state preserves board-tap and hole-cards payload',
    () {
      final state = resolveSessionDrillCanonicalSpatialScenarioStateV1(
        const DrillSpecV1(
          id: 'tap_flop_left',
          kind: DrillKindV1.boardTap,
          prompt: 'Tap flop left.',
          expected: DrillExpectedV1(boardSlot: 'flop_left'),
          errorClass: 'mismatch',
          boardCardsV1: <String>['Ah', '7d', '2c'],
          heroHoleCardsV1: <String>['Ks', 'Qs'],
        ),
      );

      expect(state, isNotNull);
      expect(
        state!.family,
        SessionDrillCanonicalSpatialScenarioFamilyV1.boardTap,
      );
      expect(state.projectedStreetV1, Street.flop);
      expect(state.boardCardsV1, <String>['Ah', '7d', '2c']);
      expect(state.heroHoleCardsV1, <String>['Ks', 'Qs']);
    },
  );

  test(
    'canonical spatial scenario state preserves action-bearing authored table payload',
    () {
      final state = resolveSessionDrillCanonicalSpatialScenarioStateV1(
        const DrillSpecV1(
          id: 'choose_call_position_control',
          kind: DrillKindV1.actionChoice,
          prompt: 'Choose call.',
          expected: DrillExpectedV1(actionId: 'call'),
          errorClass: 'expected_action_mismatch',
          streetV1: 'river',
          playerCountV1: 8,
          heroSeatV1: 'utg1',
          villainSeatV1: 'bb',
          activeSeatsV1: <String>[
            'btn',
            'co',
            'hj',
            'lj',
            'utg',
            'utg1',
            'sb',
            'bb',
          ],
          boardCardsV1: <String>['Kh', '9s', '4c', '2d', '7h'],
          heroHoleCardsV1: <String>['Jc', 'Qs'],
        ),
      );

      expect(state, isNotNull);
      expect(
        state!.family,
        SessionDrillCanonicalSpatialScenarioFamilyV1.actionChoice,
      );
      expect(state.projectedStreetV1, Street.river);
      expect(state.playerCountV1, 8);
      expect(state.heroSeatV1, 'utg1');
      expect(state.villainSeatV1, 'bb');
      expect(state.activeSeatsV1, <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'utg1',
        'sb',
        'bb',
      ]);
      expect(state.boardCardsV1, <String>['Kh', '9s', '4c', '2d', '7h']);
      expect(state.heroHoleCardsV1, <String>['Jc', 'Qs']);
    },
  );
}
