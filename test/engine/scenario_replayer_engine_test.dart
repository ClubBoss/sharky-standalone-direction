import 'package:test/test.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_events.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_replayer_engine.dart';

ScenarioReplayerSpec _spec() {
  return ScenarioReplayerSpec(
    initialSnapshot: const ReplayerSnapshot(
      heroStack: 100,
      villainStack: 100,
      pot: 10,
      toCall: 10,
      street: ReplayerStreet.preflop,
      actingSeat: ReplayerSeat.hero,
      minRaiseTo: 20,
    ),
    steps: const <ReplayerStep>[
      ReplayerStep(
        actingSeat: ReplayerSeat.hero,
        legalActions: <ReplayerActionSpec>[
          ReplayerActionSpec(kind: ReplayerActionKind.fold),
          ReplayerActionSpec(kind: ReplayerActionKind.callCheck),
          ReplayerActionSpec(kind: ReplayerActionKind.betRaise, minAmount: 20),
        ],
      ),
    ],
  );
}

void main() {
  test('FSM happy path Setup->Acting->Resolving->Evaluation->Outcome', () {
    final engine = ScenarioReplayerEngine(_spec());
    expect(engine.currentState.kind, ReplayerFsmStateKind.setup);

    engine.dispatch(const StartHandEvent());
    final state1 = engine.currentState as StreetActiveReplayerState;
    expect(state1.phase, StreetActivePhase.acting);

    engine.dispatch(
      const SubmitActionEvent(
        seat: ReplayerSeat.hero,
        kind: ReplayerActionKind.callCheck,
      ),
    );
    final state2 = engine.currentState as StreetActiveReplayerState;
    expect(state2.phase, StreetActivePhase.resolving);

    engine.dispatch(const ResolveStreetEvent());
    expect(engine.currentState.kind, ReplayerFsmStateKind.evaluation);

    final outcome = engine.dispatch(const CompleteEvaluationEvent());
    expect(engine.currentState.kind, ReplayerFsmStateKind.outcome);
    expect(outcome, isNotNull);
  });

  test('illegal bet below minimum is rejected deterministically', () {
    final engine = ScenarioReplayerEngine(_spec());
    engine.dispatch(const StartHandEvent());

    expect(
      () => engine.dispatch(
        const SubmitActionEvent(
          seat: ReplayerSeat.hero,
          kind: ReplayerActionKind.betRaise,
          amount: 15,
        ),
      ),
      throwsA(
        isA<ReplayerValidationError>().having(
          (e) => e.code,
          'code',
          'amount_below_minimum',
        ),
      ),
    );
  });

  test('pot/stack update for call and raise are exact', () {
    final callEngine = ScenarioReplayerEngine(_spec());
    callEngine.dispatch(const StartHandEvent());
    callEngine.dispatch(
      const SubmitActionEvent(
        seat: ReplayerSeat.hero,
        kind: ReplayerActionKind.callCheck,
      ),
    );
    final callVm = callEngine.viewModel();
    expect(callVm.heroStack, 90);
    expect(callVm.pot, 20);
    expect(callVm.toCall, 0);

    final raiseEngine = ScenarioReplayerEngine(_spec());
    raiseEngine.dispatch(const StartHandEvent());
    raiseEngine.dispatch(
      const SubmitActionEvent(
        seat: ReplayerSeat.hero,
        kind: ReplayerActionKind.betRaise,
        amount: 30,
      ),
    );
    final raiseVm = raiseEngine.viewModel();
    expect(raiseVm.heroStack, 70);
    expect(raiseVm.pot, 40);
    expect(raiseVm.toCall, 30);
  });

  test('determinism: same scenario and events yields same final outcome', () {
    ScenarioReplayerOutcome run() {
      final engine = ScenarioReplayerEngine(_spec());
      engine.dispatch(const StartHandEvent());
      engine.dispatch(
        const SubmitActionEvent(
          seat: ReplayerSeat.hero,
          kind: ReplayerActionKind.callCheck,
        ),
      );
      engine.dispatch(const ResolveStreetEvent());
      final outcome = engine.dispatch(const CompleteEvaluationEvent());
      return outcome!;
    }

    final first = run();
    final second = run();
    expect(first, second);
  });
}
