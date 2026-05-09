import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_invariant_spine_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_reconciliation_v1.dart';

void main() {
  SessionDrillReconciledTableTruthV1 _baseTruth() {
    return reconcileSessionDrillTableTruthV1(
      errorPrefix: 'projection spine',
      playerCountV1: 4,
      heroSeatV1: 'btn',
      villainSeatV1: 'bb',
      activeSeatsV1: const <String>['btn', 'bb'],
      foldedSeatsV1: const <String>['co'],
      emptySeatsV1: const <String>['sb'],
      actingSeatV1: 'btn',
      seatOrderPolicyV1: SessionDrillSeatOrderPolicyV1.heroVillainThenStateBuckets,
    );
  }

  test('shared invariant spine accepts coherent reconciled truth', () {
    final scenario = buildValidatedSessionDrillProjectedScenarioV1(
      errorPrefix: 'projection spine',
      reconciledTruthV1: _baseTruth(),
      streetV1: Street.flop,
      legalActionsV1: const <String>['hero', 'villain'],
      solutionBestActionV1: 'hero',
    );

    expect(scenario.heroSeat, 0);
    expect(scenario.actingSeatStart, 0);
  });

  test('shared invariant spine rejects villain seat projected as empty', () {
    final invalidTruth = reconcileSessionDrillTableTruthV1(
      errorPrefix: 'projection spine',
      playerCountV1: 4,
      heroSeatV1: 'btn',
      villainSeatV1: 'sb',
      activeSeatsV1: const <String>['btn', 'bb'],
      foldedSeatsV1: const <String>['co'],
      emptySeatsV1: const <String>['sb'],
      actingSeatV1: 'btn',
      seatOrderPolicyV1: SessionDrillSeatOrderPolicyV1.heroVillainThenStateBuckets,
    );

    expect(
      () => buildValidatedSessionDrillProjectedScenarioV1(
        errorPrefix: 'projection spine',
        reconciledTruthV1: invalidTruth,
        streetV1: Street.flop,
        legalActionsV1: const <String>['hero', 'villain'],
        solutionBestActionV1: 'hero',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('requires villain seat to be non-empty'),
        ),
      ),
    );
  });

  test('shared invariant spine rejects empty blind seats', () {
    final invalidTruth = SessionDrillReconciledTableTruthV1(
      playerCountV1: 4,
      heroSeatV1: 'btn',
      villainSeatV1: 'bb',
      seatOrderV1: const <String>['btn', 'bb', 'co', 'sb'],
      seatOccupanciesV1: const <ScenarioSeatOccupancyV1>[
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.folded,
        ScenarioSeatOccupancyV1.empty,
      ],
      heroSeatIndexV1: 0,
      actingSeatIndexV1: 0,
      blindLevelStateV1: const ScenarioBlindLevelStateV1(
        smallBlindSeatIndexV1: 3,
        bigBlindSeatIndexV1: 1,
        smallBlindAmountV1: 50,
        bigBlindAmountV1: 100,
      ),
    );

    expect(
      () => buildValidatedSessionDrillProjectedScenarioV1(
        errorPrefix: 'projection spine',
        reconciledTruthV1: invalidTruth,
        streetV1: Street.flop,
        legalActionsV1: const <String>['hero', 'villain'],
        solutionBestActionV1: 'hero',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('requires small blind seat to be non-empty'),
        ),
      ),
    );
  });
}
