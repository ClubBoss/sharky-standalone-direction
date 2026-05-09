import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:poker_analyzer/engine_v2/interop/action_sizing_v1.dart';
import 'package:test/test.dart';

ScenarioV1 _scenarioForIteration(int index) {
  final players = const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')];
  final base = EngineSnapshotV1.initial(
    players: players,
    startingStack: const ChipsV1(100),
  );

  final mode = index % 3;
  if (mode == 0) {
    // CHECK line.
    return ScenarioV1(
      scenarioId: 'stress_check_$index',
      initialSnapshot: base,
      steps: const <StepV1>[
        StartHandStepV1(),
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

  if (mode == 1) {
    // CALL line (force toCall > 0 on first action).
    return ScenarioV1(
      scenarioId: 'stress_call_$index',
      initialSnapshot: base.copyWith(currentBet: const ChipsV1(10)),
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.call),
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

  // FOLD line.
  return ScenarioV1(
    scenarioId: 'stress_fold_$index',
    initialSnapshot: base,
    steps: const <StepV1>[
      StartHandStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p1'),
        action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.fold),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p2'),
        action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('p2'),
        action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
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

void main() {
  test('deterministic BET/RAISE sizing rules are stable', () {
    expect(
      ActionSizingV1.deterministicBet(pot: 0, stack: 50),
      1,
      reason: 'bet min must be 1 chip',
    );
    expect(
      ActionSizingV1.deterministicBet(pot: 30, stack: 50),
      10,
      reason: 'bet should be 1/3 pot rounded',
    );
    expect(
      ActionSizingV1.deterministicBet(pot: 90, stack: 20),
      20,
      reason: 'bet must be capped by stack',
    );
    expect(
      ActionSizingV1.deterministicRaiseTo(
        minRaiseTo: 24,
        currentBet: 10,
        toCall: 10,
        stack: 100,
        committed: 0,
      ),
      24,
      reason: 'raiseTo must honor minRaiseTo when larger',
    );
    expect(
      ActionSizingV1.deterministicRaiseTo(
        minRaiseTo: 12,
        currentBet: 10,
        toCall: 10,
        stack: 8,
        committed: 2,
      ),
      10,
      reason: 'raiseTo must cap at stack+committed when no legal raise room',
    );
  });

  test('engine v2 hand loop stress v1 deterministic across 100 iterations', () {
    const engine = EngineV2();

    for (var i = 0; i < 100; i++) {
      final scenario = _scenarioForIteration(i);
      final runA = engine.runScenarioWithEvaluation(scenario);
      final runB = engine.runScenarioWithEvaluation(scenario);

      expect(
        runA.trace.entries,
        isNotEmpty,
        reason: 'trace empty for iteration $i',
      );
      expect(
        runA.trace.isSuccess,
        isTrue,
        reason: 'trace invalid for iteration $i',
      );
      expect(
        runA.outcome,
        equals(runB.outcome),
        reason: 'non-deterministic outcome for iteration $i',
      );

      final linesA = const OutcomeAdapterV1().toSummaryLines(runA.outcome);
      final linesB = const OutcomeAdapterV1().toSummaryLines(runB.outcome);
      expect(
        linesA,
        equals(linesB),
        reason: 'non-deterministic summary lines for iteration $i',
      );
    }
  });
}
