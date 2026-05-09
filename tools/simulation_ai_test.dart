import 'package:poker_analyzer/engine/simulation_action_loop.dart';
import 'package:poker_analyzer/engine/simulation_ai_agent.dart';
import 'package:poker_analyzer/engine/simulation_state_engine.dart';

Future<void> main(List<String> args) async {
  final agent = SimulationAIAgent(aggression: 0.6, seed: 4242);
  final players = <String>['SB', 'BB', 'HJ', 'CO', 'BTN'];
  final summaries = <String, int>{'bet': 0, 'call': 0, 'check': 0, 'fold': 0};

  for (var hand = 0; hand < 20; hand++) {
    final state = SimulationState(
      players: players,
      board: <String>['Ah', 'Kh', '7d'],
    );
    final loop = ActionLoop(ActionQueue(<Map<String, Object?>>[]), state);

    while (!loop.isRoundComplete) {
      final info = loop.nextAction();
      final player = info['player']?.toString() ?? 'SB';
      final decision = agent.decideAction(state);
      final action = <String, Object?>{
        'player': player,
        'type': decision['type'],
        'amount': decision['amount'],
      };
      loop.resolve(action);
      final type = action['type']?.toString() ?? 'check';
      summaries.update(type, (value) => value + 1, ifAbsent: () => 1);
    }
  }

  print('AI decision summary after 20 hands:');
  summaries.forEach((key, value) {
    print('- ${key.toUpperCase()}: $value');
  });
}
