import '../engine_v2.dart';

ScenarioV1 buildEngineV2FixtureScenarioV1() {
  final base = EngineSnapshotV1.initial(
    players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
    startingStack: const ChipsV1(100),
  );
  return ScenarioV1(
    scenarioId: 'engine_v2_mvp_fixture_v1',
    initialSnapshot: base,
    steps: const <StepV1>[
      StartHandStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p1'),
        action: ActionV1(
          actorId: PlayerIdV1('p1'),
          kind: ActionKindV1.bet,
          amount: 10,
        ),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p2'),
        action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p1'),
        action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p2'),
        action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      FinishStepV1(),
    ],
  );
}

ScenarioV1 buildEngineV2FixtureScenarioRangeMismatchV1() {
  final base = EngineSnapshotV1.initial(
    players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
    startingStack: const ChipsV1(100),
  );
  return ScenarioV1(
    scenarioId: 'engine_v2_mvp_fixture_range_mismatch_v1',
    initialSnapshot: base,
    steps: const <StepV1>[
      StartHandStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p1'),
        action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
        expectation: StepExpectationV1(
          expectedAction: ActionV1(
            actorId: PlayerIdV1('p1'),
            kind: ActionKindV1.bet,
            amount: 10,
          ),
        ),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p2'),
        action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p1'),
        action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p2'),
        action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      FinishStepV1(),
    ],
  );
}
