import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/simulation_action_loop.dart';
import 'package:poker_analyzer/engine/simulation_state_engine.dart';

void main() {
  test('action loop rotates players and tracks pot', () {
    final state = SimulationState(players: ['SB', 'BB', 'BTN']);
    final queue = ActionQueue([
      {'player': 'SB', 'type': 'bet', 'amount': 40},
      {'player': 'BB', 'type': 'call', 'amount': 40},
      {'player': 'BTN', 'type': 'fold', 'amount': 0},
    ]);
    final loop = ActionLoop(queue, state);

    final next = loop.nextAction();
    expect(next['player'], 'SB');

    loop.resolve({'player': 'SB', 'type': 'bet', 'amount': 40});
    expect(state.pot, 40);
    expect(loop.nextAction()['player'], 'BB');

    loop.resolve({'player': 'BB', 'type': 'call', 'amount': 40});
    expect(state.pot, 80);
    expect(loop.nextAction()['player'], 'BTN');

    loop.resolve({'player': 'BTN', 'type': 'fold', 'amount': 0});
    expect(state.pot, 80);
    expect(loop.isRoundComplete, isTrue);
  });

  test('round completes when all active players acted', () {
    final state = SimulationState(players: ['UTG', 'HJ', 'CO']);
    final queue = ActionQueue([
      {'player': 'UTG', 'type': 'bet', 'amount': 20},
      {'player': 'HJ', 'type': 'call', 'amount': 20},
      {'player': 'CO', 'type': 'call', 'amount': 20},
    ]);
    final loop = ActionLoop(queue, state);

    expect(loop.isRoundComplete, isFalse);
    loop.resolve(queue.peek()!);
    expect(loop.isRoundComplete, isFalse);

    loop.resolve(queue.peek()!);
    expect(loop.isRoundComplete, isFalse);

    loop.resolve(queue.peek()!);
    expect(loop.isRoundComplete, isTrue);
    expect(state.pot, 60);
  });
}
