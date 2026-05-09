import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_seat_context_scenario_state_v1.dart';

void main() {
  test(
    'canonical seat-context scenario state preserves position family facts',
    () {
      final state = resolveSessionDrillCanonicalSeatContextScenarioStateV1(
        const DrillSpecV1(
          id: 'position_drill',
          kind: DrillKindV1.positionThinkingChoice,
          prompt: 'Who acts first?',
          expected: DrillExpectedV1(actionId: 'hero'),
          errorClass: 'position_error',
          streetV1: 'flop',
          playerCountV1: 6,
          heroSeatV1: 'btn',
          villainSeatV1: 'bb',
          activeSeatsV1: <String>['btn', 'co', 'hj', 'utg', 'sb', 'bb'],
          foldedSeatsV1: <String>['co'],
          emptySeatsV1: <String>['utg'],
          availableActionsV1: <String>['hero', 'villain'],
          expectedActionV1: 'hero',
          smallBlindSeatV1: 'sb',
          bigBlindSeatV1: 'bb',
          smallBlindAmountV1: 10,
          bigBlindAmountV1: 20,
        ),
      );

      expect(state, isNotNull);
      expect(
        state!.family,
        SessionDrillCanonicalSeatContextScenarioFamilyV1.position,
      );
      expect(state.streetV1, 'flop');
      expect(state.playerCountV1, 6);
      expect(state.actingSeatV1, 'btn');
      expect(state.foldedSeatsV1, <String>['co']);
      expect(state.emptySeatsV1, <String>['utg']);
      expect(state.blindLevelV1?.smallBlindAmountV1, 10);
      expect(state.blindLevelV1?.bigBlindAmountV1, 20);
    },
  );

  test(
    'canonical seat-context scenario state preserves initiative family facts',
    () {
      final state = resolveSessionDrillCanonicalSeatContextScenarioStateV1(
        const DrillSpecV1(
          id: 'initiative_drill',
          kind: DrillKindV1.initiativeAggressorChoice,
          prompt: 'Who has initiative?',
          expected: DrillExpectedV1(actionId: 'bet'),
          errorClass: 'initiative_error',
          streetV1: 'turn',
          playerCountV1: 3,
          heroSeatV1: 'btn',
          villainSeatV1: 'bb',
          activeSeatsV1: <String>['btn', 'bb', 'sb'],
          lastAggressorV1: 'hero',
          initiativeOwnerV1: 'villain',
          availableActionsV1: <String>['bet', 'check'],
          expectedActionV1: 'bet',
          smallBlindSeatV1: 'sb',
          bigBlindSeatV1: 'bb',
          smallBlindAmountV1: 25,
          bigBlindAmountV1: 50,
        ),
      );

      expect(state, isNotNull);
      expect(
        state!.family,
        SessionDrillCanonicalSeatContextScenarioFamilyV1.initiative,
      );
      expect(state.streetV1, 'turn');
      expect(state.actingSeatV1, 'bb');
      expect(state.lastAggressorV1, 'hero');
      expect(state.initiativeOwnerV1, 'villain');
      expect(state.blindLevelV1?.smallBlindAmountV1, 25);
      expect(state.blindLevelV1?.bigBlindAmountV1, 50);
    },
  );
}
