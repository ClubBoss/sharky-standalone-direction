import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

/// Smoke test for simulation engine to verify core functionality.
void main() {
  group('SimulationEngine', () {
    test('initializes with correct player count', () {
      final engine = SimulationEngine(playerCount: 6, enableEconomy: false);
      expect(engine.players.length, 6);
      expect(engine.isRoundActive, false);
    });

    test('starts round and posts blinds', () {
      final engine = SimulationEngine(
        playerCount: 6,
        smallBlind: 10,
        bigBlind: 20,
        enableEconomy: false,
      );

      engine.startRound();

      expect(engine.isRoundActive, true);
      expect(engine.pot, 30); // SB + BB
      expect(engine.currentStreet, SimulationStreet.preFlop);
    });

    test('handles player fold action', () async {
      final engine = SimulationEngine(
        playerCount: 3,
        heroSeat: 0,
        enableEconomy: false,
      );
      engine.startRound();

      await _waitForHeroTurn(engine);

      expect(
        engine.players[engine.currentSeat].type,
        PlayerType.hero,
        reason: 'Hero should act before fold assertion',
      );

      expect(engine.players[engine.heroSeat].hasFolded, isFalse);

      engine.playerAction(PlayerAction.fold);

      expect(engine.players[engine.heroSeat].hasFolded, isTrue);
    });

    test('advances through streets', () {
      final engine = SimulationEngine(
        playerCount: 2,
        heroSeat: 0,
        enableEconomy: false,
      );
      engine.startRound();

      expect(engine.currentStreet, SimulationStreet.preFlop);

      // Simulate completing a street (simplified test)
      // In real game, would need proper betting round completion
    });

    test('tracks metrics', () {
      final engine = SimulationEngine(playerCount: 4, enableEconomy: false);
      expect(engine.metrics.roundCount, 0);

      engine.startRound();
      expect(engine.metrics.roundCount, 1);
    });

    test('event stream emits events', () async {
      final engine = SimulationEngine(
        playerCount: 3,
        heroSeat: 0,
        enableEconomy: false,
      );
      final events = <SimulationEvent>[];

      engine.eventStream.listen(events.add);

      engine.startRound();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.isNotEmpty, true);
      expect(events.first.type, 'round_start');

      engine.dispose();
    });

    test('disposes cleanly', () {
      final engine = SimulationEngine(playerCount: 4, enableEconomy: false);
      engine.dispose();
      // Should not throw
    });
  });
}

Future<void> _waitForHeroTurn(SimulationEngine engine) async {
  for (var i = 0; i < 40; i++) {
    if (engine.players[engine.currentSeat].type == PlayerType.hero) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }
  fail('Hero turn not reached before timeout');
}
