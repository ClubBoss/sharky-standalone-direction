import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/headless_scenario_validation_v1.dart';

void main() {
  const validator = HeadlessScenarioValidatorV1();
  const adapter = DrillRuntimeAdapterV1();
  const singleStepSessions = <String>['w2.s02', 'w2.s03'];
  const threeStepSessions = <String>['w2.s09', 'w2.s10', 'w2.s11'];

  test(
    'generic scenario-backed contract helper requires explicit feedback pair and target',
    () {
      const core = DrillScenarioCoreV1(
        streetV1: 'flop',
        availableActionsV1: <String>['hero', 'villain'],
        expectedActionIdV1: 'hero',
      );
      const seatContext = DrillScenarioSeatContextV1(
        playerCountV1: 4,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'bb'],
        foldedSeatsV1: <String>['co'],
        emptySeatsV1: <String>['sb'],
      );

      expect(
        () => validateScenarioBackedDeterministicActionContractV1(
          core: core,
          seatContext: seatContext,
          requireInitiative: false,
          errorPrefix: 'generic scenario-backed contract',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'requires explicit feedback_correct_v1 and feedback_incorrect_v1',
            ),
          ),
        ),
      );
    },
  );

  test(
    'generic scenario-backed contract helper rejects partial initiative payload',
    () {
      const core = DrillScenarioCoreV1(
        streetV1: 'flop',
        availableActionsV1: <String>['hero', 'villain'],
        expectedActionIdV1: 'hero',
        feedbackCorrectV1: 'Correct.',
        feedbackIncorrectV1: 'Incorrect.',
      );
      const seatContext = DrillScenarioSeatContextV1(
        playerCountV1: 4,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'bb'],
        foldedSeatsV1: <String>['co'],
        emptySeatsV1: <String>['sb'],
        lastAggressorV1: 'hero',
      );

      expect(
        () => validateScenarioBackedDeterministicActionContractV1(
          core: core,
          seatContext: seatContext,
          requireInitiative: false,
          errorPrefix: 'generic scenario-backed contract',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'requires both last_aggressor_v1 and initiative_owner_v1 together',
            ),
          ),
        ),
      );
    },
  );

  test(
    'generic scenario-backed contract helper accepts complete deterministic payload',
    () {
      const core = DrillScenarioCoreV1(
        streetV1: 'flop',
        availableActionsV1: <String>['hero', 'villain'],
        expectedActionIdV1: 'hero',
        feedbackCorrectV1: 'Correct.',
        feedbackIncorrectV1: 'Incorrect.',
      );
      const seatContext = DrillScenarioSeatContextV1(
        playerCountV1: 4,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'bb'],
        foldedSeatsV1: <String>['co'],
        emptySeatsV1: <String>['sb'],
        lastAggressorV1: 'hero',
        initiativeOwnerV1: 'hero',
      );

      expect(
        () => validateScenarioBackedDeterministicActionContractV1(
          core: core,
          seatContext: seatContext,
          requireInitiative: true,
          errorPrefix: 'generic scenario-backed contract',
        ),
        returnsNormally,
      );
    },
  );

  test(
    'generic deterministic chain helper rejects step missing explicit feedback pair',
    () {
      final spec = DrillSpecV1(
        id: 'chain_missing_feedback_v1',
        kind: DrillKindV1.handChain,
        prompt: 'Play this short chain.',
        expected: const DrillExpectedV1(),
        errorClass: 'unused',
        chainIdV1: 'chain_missing_feedback_v1',
        chainStepsV1: const <DrillChainStepV1>[
          DrillChainStepV1(
            street: 'flop',
            prompt: 'Step 1',
            errorClass: 'expected_action_mismatch',
            availableActionsV1: <String>['call', 'raise'],
            expectedActionV1: 'raise',
            feedbackCorrectV1: 'Correct.',
          ),
          DrillChainStepV1(
            street: 'flop',
            prompt: 'Step 2',
            errorClass: 'expected_action_mismatch',
            availableActionsV1: <String>['call', 'raise'],
            expectedActionV1: 'call',
            feedbackCorrectV1: 'Correct.',
            feedbackIncorrectV1: 'Incorrect.',
          ),
        ],
      );

      expect(
        () => validateDeterministicMultiStepChainShapeContractV1(
          spec: spec,
          minSteps: 2,
          maxSteps: 4,
          errorPrefix: 'generic deterministic chain contract',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'requires explicit feedback_correct_v1 and feedback_incorrect_v1',
            ),
          ),
        ),
      );
    },
  );

  test(
    'generic deterministic chain helper accepts valid multi-step shape',
    () {
      final spec = DrillSpecV1(
        id: 'chain_valid_shape_v1',
        kind: DrillKindV1.handChain,
        prompt: 'Play this short chain.',
        expected: const DrillExpectedV1(),
        errorClass: 'unused',
        chainIdV1: 'chain_valid_shape_v1',
        chainStepsV1: const <DrillChainStepV1>[
          DrillChainStepV1(
            street: 'flop',
            prompt: 'Step 1',
            errorClass: 'expected_action_mismatch',
            availableActionsV1: <String>['call', 'raise'],
            expectedActionV1: 'raise',
            feedbackCorrectV1: 'Correct.',
            feedbackIncorrectV1: 'Incorrect.',
          ),
          DrillChainStepV1(
            street: 'turn',
            prompt: 'Step 2',
            errorClass: 'range_bucket_mismatch',
            rangeBucketV1: 'draw',
            feedbackCorrectV1: 'Correct.',
            feedbackIncorrectV1: 'Incorrect.',
          ),
        ],
      );

      expect(
        () => validateDeterministicMultiStepChainShapeContractV1(
          spec: spec,
          minSteps: 2,
          maxSteps: 4,
          errorPrefix: 'generic deterministic chain contract',
        ),
        returnsNormally,
      );
    },
  );

  test(
    'all proven World 2 single-step table-state scenarios validate and execute headlessly',
    () async {
      var validatedDrillCount = 0;
      for (final sessionId in singleStepSessions) {
        final drills = await adapter.loadSessionDrills(sessionId);
        expect(drills, isNotEmpty, reason: '$sessionId should contain drills');
        for (final drill in drills) {
          final result = validator.validateWorld2SingleStepTableScenarioV1(
            drill.spec,
          );
          expect(result.stepCount, 1, reason: drill.drillId);
          expect(result.scenarioSpecs, hasLength(1), reason: drill.drillId);
          expect(
            result.scenarioSpecs.single.decisionNodeV1.legalActions,
            <String>['hero', 'villain'],
            reason: drill.drillId,
          );
          validatedDrillCount += 1;
        }
      }
      expect(validatedDrillCount, 6);
    },
  );

  test(
    'all proven World 2 three-step hand-chain scenarios validate and execute headlessly',
    () async {
      var validatedDrillCount = 0;
      for (final sessionId in threeStepSessions) {
        final drills = await adapter.loadSessionDrills(sessionId);
        expect(drills, hasLength(1), reason: '$sessionId should contain one chain');
        final result = validator.validateWorld2ThreeStepHandChainV1(
          drills.single.spec,
        );
        expect(result.stepCount, 3, reason: sessionId);
        expect(result.scenarioSpecs, hasLength(3), reason: sessionId);
        validatedDrillCount += 1;
      }
      expect(validatedDrillCount, 3);
    },
  );

  test(
    'inventory coverage still preserves authored shape expectations for representative sessions',
    () async {
      final positionDrill = (await adapter.loadSessionDrills('w2.s02')).first;
      final positionResult = validator.validateWorld2SingleStepTableScenarioV1(
        positionDrill.spec,
      );
      expect(positionResult.scenarioSpecs.single.decisionNodeV1.street, Street.flop);
      expect(positionResult.scenarioSpecs.single.decisionNodeV1.solutionBestAction, 'hero');
      expect(
        positionResult.scenarioSpecs.single.resolvedSeatOccupanciesV1,
        const <ScenarioSeatOccupancyV1>[
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.folded,
          ScenarioSeatOccupancyV1.empty,
        ],
      );

      final chainDrill = (await adapter.loadSessionDrills('w2.s10')).single;
      final chainResult = validator.validateWorld2ThreeStepHandChainV1(
        chainDrill.spec,
      );
      expect(chainResult.scenarioSpecs[0].decisionNodeV1.street, Street.flop);
      expect(
        chainResult.scenarioSpecs[1].decisionNodeV1.legalActions,
        <String>['4', '8', '9', '15'],
      );
      expect(chainResult.scenarioSpecs[2].decisionNodeV1.solutionBestAction, 'raise');
    },
  );

  test(
    'malformed three-step hand-chain hero seat fails fast in headless validation',
    () async {
      final sessionPath = adapter.debugSessionPathForIdV1('w2.s09');
      final drillPath =
          '$sessionPath/drills/d.chain_position_initiative_texture_v1.json';
      final rawJson = jsonDecode(await File(drillPath).readAsString())
          as Map<String, dynamic>;
      final steps = (rawJson['steps'] as List).cast<Map<String, dynamic>>();
      steps[0]['hero_seat_v1'] = 'utg';
      final malformed = DrillSpecV1.fromJson(rawJson);

      expect(
        () => validator.validateWorld2ThreeStepHandChainV1(malformed),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('hero/villain seats inside authored seat state'),
          ),
        ),
      );
    },
  );

  test(
    'malformed single-step table scenario missing initiative pair fails fast',
    () async {
      final sessionPath = adapter.debugSessionPathForIdV1('w2.s03');
      final drillPath =
          '$sessionPath/drills/d.choose_hero_has_initiative_open_vs_call.json';
      final rawJson = jsonDecode(await File(drillPath).readAsString())
          as Map<String, dynamic>;
      rawJson.remove('initiative_owner_v1');
      final malformed = DrillSpecV1.fromJson(rawJson);

      expect(
        () => validator.validateWorld2SingleStepTableScenarioV1(malformed),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'requires both last_aggressor_v1 and initiative_owner_v1 together',
            ),
          ),
        ),
      );
    },
  );
}
