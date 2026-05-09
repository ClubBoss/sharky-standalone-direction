import 'package:test/test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';

ScenarioSpecV1 _fsmSpec() {
  return ScenarioSpecV1(
    decisionNodeV1: const DecisionNodeV1(
      street: Street.preflop,
      legalActions: <String>['Call', 'Fold', 'Raise'],
      solutionBestAction: 'Call',
    ),
    seatCount: 2,
    heroSeat: 0,
    initialStacks: const <int>[100, 100],
    actingSeatStart: 0,
    nodes: const <ScenarioNodeV1>[
      ScenarioNodeV1(
        id: 'n0',
        street: Street.preflop,
        actingSeatIndex: 0,
        pot: 10,
        decisionNode: DecisionNodeV1(
          street: Street.preflop,
          legalActions: <String>['Call', 'Fold', 'Raise'],
          solutionBestAction: 'Call',
        ),
      ),
    ],
  );
}

void main() {
  test(
    'runtime adapter uses engine and yields deterministic outcome snapshot',
    () {
      ScenarioState runOnce(ScenarioReplayerFsmV1 fsm) {
        var state = fsm.state;
        expect(state, isA<StreetActiveState>());
        final before = state as StreetActiveState;
        expect(before.pot, 10);
        expect(before.seats[0].stack, 100);

        state = fsm.applyUserAction('Call');
        expect(state, isA<EvaluationState>());
        state = fsm.advance();
        expect(state, isA<OutcomeState>());
        return state;
      }

      final first = ScenarioReplayerFsmV1.start(_fsmSpec());
      final second = ScenarioReplayerFsmV1.start(_fsmSpec());

      final firstOutcome = runOnce(first) as OutcomeState;
      final secondOutcome = runOnce(second) as OutcomeState;

      expect(firstOutcome.result, 'Call');
      expect(secondOutcome.result, 'Call');
      expect(first.state.runtimeType, second.state.runtimeType);
    },
  );
}
