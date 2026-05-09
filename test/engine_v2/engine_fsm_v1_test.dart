import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:test/test.dart';

void main() {
  EngineFsmV1 _fsmWithToCall10() {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    return EngineFsmV1(
      initialSnapshot: base.copyWith(
        currentBet: const ChipsV1(10),
        actingPlayer: const PlayerIdV1('p1'),
      ),
    );
  }

  test('check allowed when toCall is zero', () {
    final fsm = EngineFsmV1();
    fsm.apply(const StartHandEventV1());

    final result = fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
      ),
    );

    expect(result.isValid, isTrue);
    final state = result.state as StreetActiveEngineStateV1;
    expect(state.phase, StreetPhaseV1.resolving);
  });

  test('check rejected when toCall is positive', () {
    final fsm = _fsmWithToCall10();
    fsm.apply(const StartHandEventV1());

    final result = fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
      ),
    );

    expect(result.isValid, isFalse);
    expect(result.violations.single.code, 'check_requires_zero_to_call');
  });

  test('call updates stack and committed correctly', () {
    final fsm = _fsmWithToCall10();
    fsm.apply(const StartHandEventV1());

    final result = fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.call),
      ),
    );

    expect(result.isValid, isTrue);
    final snapshot = result.state.snapshot;
    expect(snapshot.stacksState.stackFor(const PlayerIdV1('p1')).value, 90);
    expect(snapshot.stacksState.committedFor(const PlayerIdV1('p1')).value, 10);
  });

  test('bet sets currentBet and committed correctly', () {
    final fsm = EngineFsmV1();
    fsm.apply(const StartHandEventV1());

    final result = fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.bet, amount: 15),
      ),
    );

    expect(result.isValid, isTrue);
    final snapshot = result.state.snapshot;
    expect(snapshot.currentBet.value, 15);
    expect(snapshot.lastBetSize.value, 15);
    expect(snapshot.stacksState.committedFor(const PlayerIdV1('p1')).value, 15);
  });

  test('raise rejected if raiseTo is not above currentBet', () {
    final fsm = _fsmWithToCall10();
    fsm.apply(const StartHandEventV1());

    final before = fsm.state;
    final result = fsm.apply(
      const PlayerActionEventV1(
        ActionV1(
          actorId: PlayerIdV1('p1'),
          kind: ActionKindV1.raise,
          amount: 10,
        ),
      ),
    );

    expect(result.isValid, isFalse);
    expect(result.violations.single.code, 'raise_to_not_above_current_bet');
    expect(fsm.state, before);
  });

  test('bet rejected if bet exceeds stack', () {
    final fsm = EngineFsmV1();
    fsm.apply(const StartHandEventV1());

    final before = fsm.state;
    final result = fsm.apply(
      const PlayerActionEventV1(
        ActionV1(
          actorId: PlayerIdV1('p1'),
          kind: ActionKindV1.bet,
          amount: 101,
        ),
      ),
    );

    expect(result.isValid, isFalse);
    expect(result.violations.single.code, 'bet_exceeds_stack');
    expect(fsm.state, before);
  });

  test('advance moves committed to pot and resets committed', () {
    final fsm = EngineFsmV1();
    fsm.apply(const StartHandEventV1());
    fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.bet, amount: 12),
      ),
    );

    final result = fsm.apply(const AdvanceEventV1());

    expect(result.isValid, isTrue);
    final snapshot = result.state.snapshot;
    expect(snapshot.stacksState.pot.value, 12);
    expect(snapshot.stacksState.committedFor(const PlayerIdV1('p1')).value, 0);
    expect(snapshot.currentBet.value, 0);
  });

  test(
    'deterministic replay yields identical final snapshot with stacks and pot',
    () {
      EngineSnapshotV1 runSequence() {
        final fsm = EngineFsmV1();
        fsm.apply(const StartHandEventV1());
        fsm.apply(
          const PlayerActionEventV1(
            ActionV1(
              actorId: PlayerIdV1('p1'),
              kind: ActionKindV1.bet,
              amount: 10,
            ),
          ),
        );
        fsm.apply(const AdvanceEventV1());
        fsm.apply(
          const PlayerActionEventV1(
            ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
          ),
        );
        fsm.apply(const AdvanceEventV1());
        return fsm.state.snapshot;
      }

      final first = runSequence();
      final second = runSequence();

      expect(first, second);
      expect(first.stacksState.pot.value, 10);
      expect(first.stacksState.stackFor(const PlayerIdV1('p1')).value, 90);
      expect(first.stacksState.stackFor(const PlayerIdV1('p2')).value, 100);
    },
  );

  test('evaluation to outcome on finish remains valid', () {
    final fsm = EngineFsmV1();

    fsm.apply(const StartHandEventV1());
    fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
      ),
    );
    fsm.apply(const AdvanceEventV1());
    fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
    );
    fsm.apply(const AdvanceEventV1());
    fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
      ),
    );
    fsm.apply(const AdvanceEventV1());
    fsm.apply(
      const PlayerActionEventV1(
        ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
      ),
    );
    fsm.apply(const AdvanceEventV1());

    expect(fsm.state, isA<EvaluationEngineStateV1>());

    final result = fsm.apply(const FinishEventV1());
    expect(result.isValid, isTrue);
    expect(result.state, isA<OutcomeEngineStateV1>());
  });

  ScenarioV1 _minimalScenario({String scenarioId = 's-min'}) {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    return ScenarioV1(
      scenarioId: scenarioId,
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

  test('validator rejects missing startHand', () {
    final scenario = ScenarioV1(
      scenarioId: 'missing-start',
      initialSnapshot: EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
        startingStack: const ChipsV1(100),
      ),
      steps: const <StepV1>[
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
        ),
      ],
    );
    final violations = const ScenarioValidatorV1().validateScenario(scenario);
    expect(violations, isNotEmpty);
    expect(violations.first.code, 'scenario_must_start_with_start_hand');
  });

  test('validator rejects finish not last', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    final scenario = ScenarioV1(
      scenarioId: 'finish-not-last',
      initialSnapshot: base,
      steps: const <StepV1>[StartHandStepV1(), FinishStepV1(), AdvanceStepV1()],
    );
    final violations = const ScenarioValidatorV1().validateScenario(scenario);
    expect(violations, isNotEmpty);
    expect(violations.first.code, 'scenario_finish_not_last');
  });

  test('validator rejects unknown playerId in step', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    final scenario = ScenarioV1(
      scenarioId: 'unknown-player',
      initialSnapshot: base,
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p3'),
          action: ActionV1(actorId: PlayerIdV1('p3'), kind: ActionKindV1.check),
        ),
      ],
    );
    final violations = const ScenarioValidatorV1().validateScenario(scenario);
    expect(violations, isNotEmpty);
    expect(violations.first.code, 'scenario_unknown_player');
  });

  test('replay driver runs minimal valid scenario to outcome', () {
    final scenario = _minimalScenario();
    final trace = const ScenarioReplayDriverV1().runScenario(scenario);
    expect(trace.isSuccess, isTrue);
    expect(trace.entries, isNotEmpty);
    expect(trace.entries.last.result.state, isA<OutcomeEngineStateV1>());
  });

  test('replay stops on violation and state remains last valid', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    final scenario = ScenarioV1(
      scenarioId: 'stop-on-violation',
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
        PlayerActionStepV1(
          playerId: PlayerIdV1('p2'),
          action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
        ),
      ],
    );
    final trace = const ScenarioReplayDriverV1().runScenario(scenario);
    expect(trace.isSuccess, isFalse);
    expect(trace.stoppedAtStep, 2);
    final previousState = trace.entries[1].result.state;
    final violationState = trace.entries[2].result.state;
    expect(violationState, previousState);
  });

  test('replay deterministic trace equality', () {
    final first = const ScenarioReplayDriverV1().runScenario(
      _minimalScenario(scenarioId: 'deterministic'),
    );
    final second = const ScenarioReplayDriverV1().runScenario(
      _minimalScenario(scenarioId: 'deterministic'),
    );
    expect(first, second);
  });

  test('advance moves committed to pot within replay', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    final scenario = ScenarioV1(
      scenarioId: 'pot-move',
      initialSnapshot: base,
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(
            actorId: PlayerIdV1('p1'),
            kind: ActionKindV1.bet,
            amount: 8,
          ),
        ),
        AdvanceStepV1(),
      ],
    );
    final trace = const ScenarioReplayDriverV1().runScenario(scenario);
    expect(trace.isSuccess, isTrue);
    expect(trace.entries[2].result.state.snapshot.stacksState.pot.value, 8);
  });

  test('river advance leads to evaluation and finish leads to outcome', () {
    final scenario = _minimalScenario(scenarioId: 'river-finish');
    final trace = const ScenarioReplayDriverV1().runScenario(scenario);
    expect(trace.isSuccess, isTrue);
    expect(trace.entries[8].result.state, isA<EvaluationEngineStateV1>());
    expect(trace.entries[9].result.state, isA<OutcomeEngineStateV1>());
  });

  test('valid scenario without expectations yields correct verdict', () {
    final scenario = _minimalScenario(scenarioId: 'eval-correct');
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.trace.isSuccess, isTrue);
    expect(result.outcome.verdict, DecisionVerdictV1.correct);
    expect(result.outcome.error, isNull);
  });

  test('scenario invalid yields logic error', () {
    final scenario = ScenarioV1(
      scenarioId: 'eval-invalid',
      initialSnapshot: EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
        startingStack: const ChipsV1(100),
      ),
      steps: const <StepV1>[
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
        ),
      ],
    );
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error, isNotNull);
    expect(result.outcome.error!.type, ErrorTypeV1.logic);
  });

  test('violation during replay yields logic error and trace stops', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    );
    final scenario = ScenarioV1(
      scenarioId: 'eval-violation-logic',
      initialSnapshot: base,
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p2'),
          action: ActionV1(actorId: PlayerIdV1('p2'), kind: ActionKindV1.check),
        ),
      ],
    );
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.trace.isSuccess, isFalse);
    expect(result.trace.stoppedAtStep, isNotNull);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error!.type, ErrorTypeV1.logic);
  });

  test('check when toCall > 0 classified as timing error', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    ).copyWith(currentBet: const ChipsV1(10));
    final scenario = ScenarioV1(
      scenarioId: 'eval-timing-check',
      initialSnapshot: base,
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
        ),
      ],
    );
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error!.type, ErrorTypeV1.timing);
  });

  test('call when toCall == 0 classified as timing error', () {
    final scenario = ScenarioV1(
      scenarioId: 'eval-timing-call',
      initialSnapshot: EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
        startingStack: const ChipsV1(100),
      ),
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.call),
        ),
      ],
    );
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error!.type, ErrorTypeV1.timing);
  });

  test('bet > stack classified as sizing error', () {
    final scenario = ScenarioV1(
      scenarioId: 'eval-sizing-bet',
      initialSnapshot: EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
        startingStack: const ChipsV1(100),
      ),
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(
            actorId: PlayerIdV1('p1'),
            kind: ActionKindV1.bet,
            amount: 200,
          ),
        ),
      ],
    );
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error!.type, ErrorTypeV1.sizing);
  });

  test('raiseTo <= currentBet classified as sizing error', () {
    final base = EngineSnapshotV1.initial(
      players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
      startingStack: const ChipsV1(100),
    ).copyWith(currentBet: const ChipsV1(10));
    final scenario = ScenarioV1(
      scenarioId: 'eval-sizing-raise',
      initialSnapshot: base,
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(
            actorId: PlayerIdV1('p1'),
            kind: ActionKindV1.raise,
            amount: 10,
          ),
        ),
      ],
    );
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error!.type, ErrorTypeV1.sizing);
  });

  test('expectation mismatch on valid action classified as range error', () {
    final scenario = ScenarioV1(
      scenarioId: 'eval-range-mismatch',
      initialSnapshot: EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
        startingStack: const ChipsV1(100),
      ),
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
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.incorrect);
    expect(result.outcome.error!.type, ErrorTypeV1.range);
  });

  test('expectation match yields correct verdict', () {
    final scenario = ScenarioV1(
      scenarioId: 'eval-range-match',
      initialSnapshot: EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
        startingStack: const ChipsV1(100),
      ),
      steps: const <StepV1>[
        StartHandStepV1(),
        PlayerActionStepV1(
          playerId: PlayerIdV1('p1'),
          action: ActionV1(actorId: PlayerIdV1('p1'), kind: ActionKindV1.check),
          expectation: StepExpectationV1(
            expectedAction: ActionV1(
              actorId: PlayerIdV1('p1'),
              kind: ActionKindV1.check,
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
    final result = const EngineV2().runScenarioWithEvaluation(scenario);
    expect(result.outcome.verdict, DecisionVerdictV1.correct);
  });

  test('deterministic outcome equality on repeated runs', () {
    final scenario = _minimalScenario(scenarioId: 'eval-deterministic');
    final engine = const EngineV2();
    final first = engine.runScenarioWithEvaluation(scenario);
    final second = engine.runScenarioWithEvaluation(scenario);
    expect(first, second);
  });
}
