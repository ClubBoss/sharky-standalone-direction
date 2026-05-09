import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1.dart';

void main() {
  test(
    'canonical hand-chain scenario state falls back to authored step state',
    () {
      const authoredStep = DrillChainStepV1(
        street: 'flop',
        prompt: 'Authored prompt',
        whyV1: 'Authored why',
        errorClass: 'expected_action_mismatch',
        availableActionsV1: <String>['fold', 'call', 'raise'],
        expectedActionV1: 'raise',
        boardCardsV1: <String>['Ah', 'Kd', '7c'],
        heroHoleCardsV1: <String>['Qs', 'Qd'],
      );

      final resolved = resolveSessionDrillCanonicalHandChainScenarioStateV1(
        authoredStepV1: authoredStep,
      );

      expect(resolved, isNotNull);
      expect(resolved!.coreV1.streetV1, 'flop');
      expect(resolved.coreV1.availableActionsV1, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(resolved.promptV1, 'Authored prompt');
      expect(resolved.whyV1, 'Authored why');
      expect(resolved.tableContextV1?.boardContextV1?.boardCardsV1, <String>[
        'Ah',
        'Kd',
        '7c',
      ]);
    },
  );

  test(
    'canonical hand-chain scenario state prefers factual overrides for runner consumption',
    () {
      const authoredStep = DrillChainStepV1(
        street: 'preflop',
        prompt: 'Authored prompt',
        whyV1: 'Authored why',
        errorClass: 'expected_action_mismatch',
        availableActionsV1: <String>['fold', 'call'],
        expectedActionV1: 'call',
        heroHoleCardsV1: <String>['As', 'Kd'],
      );
      const factualStep = DrillScenarioHandChainStepContextV1(
        coreV1: DrillScenarioCoreV1(
          introV1: 'Factual intro',
          streetV1: 'flop',
          availableActionsV1: <String>['check', 'bet'],
          expectedActionIdV1: 'bet',
          feedbackCorrectV1: 'Correct factual',
          feedbackIncorrectV1: 'Incorrect factual',
        ),
        tableContextV1: DrillScenarioTableContextV1(
          boardContextV1: DrillScenarioBoardContextV1(
            heroHoleCardsV1: <String>['Ah', 'Kh'],
            boardCardsV1: <String>['Qs', 'Jh', '2c'],
          ),
        ),
        promptV1: 'Factual prompt',
        whyV1: 'Factual why',
        expectedPresetIdV1: 'bet_small',
        acceptablePresetIdsV1: <String>['bet_big'],
        rangeBucketV1: 'draw',
      );

      final resolved = resolveSessionDrillCanonicalHandChainScenarioStateV1(
        authoredStepV1: authoredStep,
        factualStepV1: factualStep,
      );

      expect(resolved, isNotNull);
      expect(resolved!.coreV1.streetV1, 'flop');
      expect(resolved.coreV1.availableActionsV1, <String>['check', 'bet']);
      expect(resolved.coreV1.expectedActionIdV1, 'bet');
      expect(resolved.promptV1, 'Factual prompt');
      expect(resolved.whyV1, 'Factual why');
      expect(resolved.expectedPresetIdV1, 'bet_small');
      expect(resolved.acceptablePresetIdsV1, <String>['bet_big']);
      expect(resolved.rangeBucketV1, 'draw');
      expect(resolved.tableContextV1?.boardContextV1?.heroHoleCardsV1, <String>[
        'Ah',
        'Kh',
      ]);
    },
  );
}
