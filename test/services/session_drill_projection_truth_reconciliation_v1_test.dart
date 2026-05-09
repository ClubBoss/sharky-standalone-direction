import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_reconciliation_v1.dart';

void main() {
  test(
    'hero-villain reconciliation builds canonical seat truth and labels',
    () {
      final reconciledTruth = reconcileSessionDrillTableTruthV1(
        errorPrefix: 'position-thinking truth',
        playerCountV1: 4,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: const <String>['btn', 'bb'],
        foldedSeatsV1: const <String>['co'],
        emptySeatsV1: const <String>['sb'],
        actingSeatV1: 'bb',
        blindLevelV1: const DrillScenarioBlindLevelContextV1(
          smallBlindSeatV1: 'sb',
          bigBlindSeatV1: 'bb',
          smallBlindAmountV1: 50,
          bigBlindAmountV1: 100,
        ),
        seatOrderPolicyV1:
            SessionDrillSeatOrderPolicyV1.heroVillainThenStateBuckets,
      );

      expect(reconciledTruth.seatOrderV1, const <String>[
        'btn',
        'bb',
        'co',
        'sb',
      ]);
      expect(reconciledTruth.seatOccupanciesV1, const <ScenarioSeatOccupancyV1>[
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.folded,
        ScenarioSeatOccupancyV1.empty,
      ]);
      expect(reconciledTruth.roleLabelsV1(), const <int, String>{
        0: 'HERO',
        1: 'VILLAIN',
      });
      expect(
        reconciledTruth.markerLabelsV1(includeSeatIdsV1: false),
        const <int, String>{0: 'BTN', 1: 'BB', 3: 'SB'},
      );
      expect(reconciledTruth.blindLevelStateV1?.smallBlindSeatIndexV1, 3);
      expect(reconciledTruth.blindLevelStateV1?.bigBlindSeatIndexV1, 1);

      final scenario = reconciledTruth.buildScenarioSpec(
        streetV1: Street.flop,
        legalActionsV1: const <String>['hero', 'villain'],
        solutionBestActionV1: 'villain',
      );
      expect(scenario.heroSeat, 0);
      expect(scenario.actingSeatStart, 1);
      expect(scenario.decisionNodeV1.street, Street.flop);
    },
  );

  test(
    'authored active-folded-empty reconciliation preserves authored seat order',
    () {
      final reconciledTruth = reconcileSessionDrillTableTruthV1(
        errorPrefix: 'seat-anchor truth',
        playerCountV1: 6,
        heroSeatV1: 'sb',
        villainSeatV1: 'btn',
        activeSeatsV1: const <String>['sb', 'bb', 'btn', 'co'],
        foldedSeatsV1: const <String>['hj'],
        emptySeatsV1: const <String>['lj'],
        actingSeatV1: 'sb',
        seatOrderPolicyV1:
            SessionDrillSeatOrderPolicyV1.activeFoldedEmptyAuthored,
      );

      expect(reconciledTruth.seatOrderV1, const <String>[
        'sb',
        'bb',
        'btn',
        'co',
        'hj',
        'lj',
      ]);
      expect(reconciledTruth.heroSeatIndexV1, 0);
      expect(reconciledTruth.actingSeatIndexV1, 0);
    },
  );

  test(
    'canonical authored arc reconciliation preserves geometry order while keeping role labels intact',
    () {
      final reconciledTruth = reconcileSessionDrillTableTruthV1(
        errorPrefix: 'geometry-safe truth',
        playerCountV1: 6,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: const <String>['btn', 'co', 'hj', 'bb'],
        foldedSeatsV1: const <String>['sb'],
        emptySeatsV1: const <String>['lj'],
        actingSeatV1: 'bb',
        blindLevelV1: const DrillScenarioBlindLevelContextV1(
          smallBlindSeatV1: 'sb',
          bigBlindSeatV1: 'bb',
          smallBlindAmountV1: 50,
          bigBlindAmountV1: 100,
        ),
        seatOrderPolicyV1:
            SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder,
      );

      expect(reconciledTruth.seatOrderV1, const <String>[
        'btn',
        'co',
        'hj',
        'bb',
        'sb',
        'lj',
      ]);
      expect(reconciledTruth.roleLabelsV1(), const <int, String>{
        0: 'HERO',
        3: 'VILLAIN',
      });
      expect(
        reconciledTruth.markerLabelsV1(includeSeatIdsV1: false),
        const <int, String>{0: 'BTN', 3: 'BB', 4: 'SB'},
      );
      expect(reconciledTruth.blindLevelStateV1?.smallBlindSeatIndexV1, 4);
      expect(reconciledTruth.blindLevelStateV1?.bigBlindSeatIndexV1, 3);
    },
  );

  test(
    'projected street resolution follows board slot before board-card count',
    () {
      expect(
        resolveSessionDrillProjectedStreetV1(
          expectedV1: const DrillExpectedV1(boardSlot: 'turn'),
          boardCardsV1: const <String>['As', 'Kd', '2c'],
        ),
        Street.turn,
      );
      expect(
        resolveSessionDrillProjectedStreetV1(
          expectedV1: const DrillExpectedV1(boardSlot: 'flop_left'),
          boardCardsV1: const <String>['As', 'Kd', '2c', '9h'],
        ),
        Street.flop,
      );
    },
  );
}
