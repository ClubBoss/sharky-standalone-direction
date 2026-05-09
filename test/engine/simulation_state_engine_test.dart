import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/simulation_state_engine.dart';

void main() {
  test('applyAction updates pot and rotates turn', () {
    final state = SimulationState(players: ['SB', 'BB', 'BTN']);

    state.applyAction({'player': 'SB', 'type': 'bet', 'amount': 40});

    expect(state.pot, 40);
    expect(state.currentIndex, 1);

    state.applyAction({'player': 'BB', 'type': 'call', 'amount': 40});
    expect(state.pot, 80);
    expect(state.currentIndex, 2);

    state.applyAction({'player': 'BTN', 'type': 'fold', 'amount': 0});
    expect(state.pot, 80);
    expect(state.currentIndex, 0);
  });

  test('summary reports pot board and acting player', () {
    final state = SimulationState(
      players: ['SB', 'BB'],
      board: ['Ah', 'Kd', '7s'],
    );
    expect(state.summary(), 'Pot: 0 | Board: Ah Kd 7s | Next to act: SB');

    state.applyAction({'player': 'SB', 'type': 'bet', 'amount': 20});

    expect(state.summary(), 'Pot: 20 | Board: Ah Kd 7s | Next to act: BB');
  });

  test('reset clears state', () {
    final state = SimulationState(players: ['SB', 'BB']);
    state.applyAction({'player': 'SB', 'type': 'bet', 'amount': 10});
    state.reset();

    expect(state.pot, 0);
    expect(state.actions, isEmpty);
    expect(state.board, isEmpty);
    expect(state.currentIndex, 0);
  });
}
