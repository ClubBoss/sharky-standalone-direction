import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';

void main() {
  test('ScenarioSpecV1 derives folded seats from zero stacks by default', () {
    final spec = ScenarioSpecV1(
      seatCount: 3,
      heroSeat: 0,
      initialStacks: const [900, 0, 400],
      actingSeatStart: 0,
      decisionNodeV1: const DecisionNodeV1(
        street: Street.flop,
        legalActions: ['hero', 'villain'],
        solutionBestAction: 'hero',
      ),
    );

    expect(
      spec.resolvedSeatOccupanciesV1,
      equals(const <ScenarioSeatOccupancyV1>[
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.folded,
        ScenarioSeatOccupancyV1.active,
      ]),
    );
  });

  test('ScenarioSpecV1 rejects impossible seat occupancy combinations', () {
    expect(
      () => ScenarioSpecV1(
        seatCount: 2,
        heroSeat: 0,
        initialStacks: const [0, 900],
        actingSeatStart: 1,
        seatOccupancies: const <ScenarioSeatOccupancyV1>[
          ScenarioSeatOccupancyV1.empty,
          ScenarioSeatOccupancyV1.active,
        ],
        decisionNodeV1: const DecisionNodeV1(
          street: Street.flop,
          legalActions: ['hero', 'villain'],
          solutionBestAction: 'villain',
        ),
      ).validate(),
      throwsArgumentError,
    );

    expect(
      () => ScenarioSpecV1(
        seatCount: 2,
        heroSeat: 0,
        initialStacks: const [900, 300],
        seatOccupancies: const <ScenarioSeatOccupancyV1>[
          ScenarioSeatOccupancyV1.active,
          ScenarioSeatOccupancyV1.folded,
        ],
        actingSeatStart: 1,
        decisionNodeV1: const DecisionNodeV1(
          street: Street.flop,
          legalActions: ['hero', 'villain'],
          solutionBestAction: 'hero',
        ),
      ).validate(),
      throwsArgumentError,
    );
  });

  test('ScenarioSpecV1 round-trips optional blind-level authored state', () {
    final spec = ScenarioSpecV1(
      seatCount: 6,
      heroSeat: 0,
      initialStacks: const [1200, 1200, 1200, 1200, 1200, 1200],
      actingSeatStart: 2,
      blindLevelStateV1: const ScenarioBlindLevelStateV1(
        smallBlindSeatIndexV1: 4,
        bigBlindSeatIndexV1: 5,
        smallBlindAmountV1: 50,
        bigBlindAmountV1: 100,
        anteAmountV1: 10,
      ),
      decisionNodeV1: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['fold', 'call', 'raise'],
        solutionBestAction: 'raise',
      ),
    );

    spec.validate();
    final encoded = spec.toJson();
    final decoded = ScenarioSpecV1.fromJson(encoded);

    expect(decoded.blindLevelStateV1, isNotNull);
    expect(decoded.blindLevelStateV1!.smallBlindSeatIndexV1, 4);
    expect(decoded.blindLevelStateV1!.bigBlindSeatIndexV1, 5);
    expect(decoded.blindLevelStateV1!.smallBlindAmountV1, 50);
    expect(decoded.blindLevelStateV1!.bigBlindAmountV1, 100);
    expect(decoded.blindLevelStateV1!.anteAmountV1, 10);
  });

  test('ScenarioSpecV1 rejects impossible blind-level authored state', () {
    expect(
      () => ScenarioSpecV1(
        seatCount: 6,
        heroSeat: 0,
        initialStacks: const [1200, 1200, 1200, 1200, 1200, 1200],
        actingSeatStart: 2,
        blindLevelStateV1: const ScenarioBlindLevelStateV1(
          smallBlindSeatIndexV1: 4,
          bigBlindSeatIndexV1: 4,
          smallBlindAmountV1: 100,
          bigBlindAmountV1: 50,
        ),
        decisionNodeV1: const DecisionNodeV1(
          street: Street.preflop,
          legalActions: ['fold', 'call', 'raise'],
          solutionBestAction: 'raise',
        ),
      ).validate(),
      throwsArgumentError,
    );
  });
}
