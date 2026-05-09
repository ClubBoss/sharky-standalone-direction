import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/headless_scenario_validation_v1.dart';

void main() {
  test(
    'headless validator reuses reconciled seat truth for single-step table scenarios',
    () {
      const validator = HeadlessScenarioValidatorV1();
      const spec = DrillSpecV1(
        id: 'w2_projection_truth_inline',
        kind: DrillKindV1.positionThinkingChoice,
        prompt: 'Who acts from this seat arrangement?',
        expected: DrillExpectedV1(actionId: 'villain'),
        errorClass: 'position_thinking_choice_mismatch',
        streetV1: 'flop',
        availableActionsV1: <String>['hero', 'villain'],
        playerCountV1: 4,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'bb', 'sb'],
        foldedSeatsV1: <String>['co'],
        smallBlindSeatV1: 'sb',
        bigBlindSeatV1: 'bb',
        smallBlindAmountV1: 50,
        bigBlindAmountV1: 100,
        feedbackCorrectV1: 'Correct.',
        feedbackIncorrectV1: 'Incorrect.',
      );

      final result = validator.validateWorld2SingleStepTableScenarioV1(spec);
      final scenario = result.scenarioSpecs.single;

      expect(scenario.heroSeat, 0);
      expect(scenario.actingSeatStart, 1);
      expect(
        scenario.seatOccupancies,
        const <ScenarioSeatOccupancyV1>[
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.folded,
        ],
      );
      expect(scenario.blindLevelStateV1?.smallBlindSeatIndexV1, 2);
      expect(scenario.blindLevelStateV1?.bigBlindSeatIndexV1, 1);
    },
  );
}
