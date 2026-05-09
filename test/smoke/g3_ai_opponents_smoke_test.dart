import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

/// Smoke test for G3 Session: Rule-based AI opponents integration.
///
/// Validates:
/// - AI opponents initialized with personalities
/// - AI makes decisions with reasoning
/// - Telemetry tracks AI metrics
/// - Simulation completes without crashes
void main() {
  group('G3 Session Smoke Test: Rule-Based AI Opponents', () {
    test('AI opponents initialize with distinct personalities', () {
      final engine = SimulationEngine(
        playerCount: 6,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
      );

      final aiPlayers = engine.players
          .where((p) => p.type == PlayerType.ai)
          .toList();

      expect(aiPlayers.length, 5);

      // Verify all AI players have personalities
      for (final player in aiPlayers) {
        expect(player.aiPersonality, isNotNull);
        expect(player.name, contains('AI'));
      }

      // Verify personality distribution
      final personalities = aiPlayers.map((p) => p.aiPersonality).toSet();
      expect(
        personalities.length,
        greaterThan(1),
      ); // At least 2 different personalities

      engine.dispose();
    });

    test('AI opponents make decisions with reasoning', () async {
      final engine = SimulationEngine(
        playerCount: 3, // Small game for quick test
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        autoPlayHero: true,
      );

      var aiDecisionWithReasoning = false;
      final completer = Completer<void>();

      engine.eventStream.listen((event) {
        if (event.type == 'action') {
          final player = engine.players[event.seatIndex];
          if (player.type == PlayerType.ai && player.lastReasoning != null) {
            aiDecisionWithReasoning = true;
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        }
      });

      engine.startRound();

      // Wait for first AI decision or timeout
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );

      expect(aiDecisionWithReasoning, isTrue);
      expect(engine.metrics.aiActionCount, greaterThan(0));

      engine.dispose();
    });

    test('Telemetry tracks AI metrics correctly', () async {
      final engine = SimulationEngine(
        playerCount: 3,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        autoPlayHero: true,
      );

      final completer = Completer<void>();
      var roundEnded = false;

      engine.eventStream.listen((event) {
        if (event.type == 'round_end') {
          roundEnded = true;
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      engine.startRound();

      // Let AI players make some decisions
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );

      if (roundEnded) {
        expect(engine.metrics.aiActionCount, greaterThan(0));

        // At least one action type should have occurred
        expect(
          engine.metrics.aiRaiseCount +
              engine.metrics.aiCallCount +
              engine.metrics.aiFoldCount,
          equals(engine.metrics.aiActionCount),
        );

        // Aggression factor should be valid
        expect(engine.metrics.aiAggressionFactor, greaterThanOrEqualTo(0.0));
        expect(engine.metrics.aiAggressionFactor, lessThanOrEqualTo(1.0));

        // Decision accuracy should be valid
        expect(engine.metrics.aiDecisionAccuracy, greaterThanOrEqualTo(0.0));
        expect(engine.metrics.aiDecisionAccuracy, lessThanOrEqualTo(1.0));

        // Personality counts should sum to total actions
        final personalityTotal =
            (engine.metrics.personalityActionCounts[AiPersonality.tight] ?? 0) +
            (engine.metrics.personalityActionCounts[AiPersonality.aggressive] ??
                0) +
            (engine.metrics.personalityActionCounts[AiPersonality.passive] ??
                0);
        expect(personalityTotal, equals(engine.metrics.aiActionCount));
      }

      engine.dispose();
    });

    test('Simulation completes multiple rounds without crashes', () async {
      final engine = SimulationEngine(
        playerCount: 4,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
      );

      var roundsCompleted = 0;
      const targetRounds = 3;
      final completer = Completer<void>();

      engine.eventStream.listen((event) {
        // Auto-play hero to advance simulation
        if (engine.isRoundActive &&
            engine.currentSeat == engine.heroSeat &&
            !completer.isCompleted) {
          // Hero folds immediately to speed up test
          Future.microtask(() {
            if (engine.isRoundActive) {
              engine.playerAction(PlayerAction.fold);
            }
          });
        }

        if (event.type == 'round_end') {
          roundsCompleted++;
          if (roundsCompleted >= targetRounds) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else {
            // Start next round
            Future.delayed(const Duration(milliseconds: 50), () {
              if (!engine.isRoundActive && !completer.isCompleted) {
                engine.startRound();
              }
            });
          }
        }
      });

      engine.startRound();

      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );

      expect(roundsCompleted, greaterThanOrEqualTo(2)); // At least 2 rounds
      expect(engine.metrics.roundCount, greaterThanOrEqualTo(2));
      expect(engine.metrics.aiActionCount, greaterThan(0));

      engine.dispose();
    });

    test('All personality types make decisions', () async {
      final engine = SimulationEngine(
        playerCount: 9, // More players = all personalities represented
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        autoPlayHero: true,
      );

      final completer = Completer<void>();
      engine.eventStream.listen((event) {
        if (event.type == 'round_end') {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      engine.startRound();

      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );

      // Verify all personalities made at least one action
      expect(
        engine.metrics.personalityActionCounts[AiPersonality.tight],
        greaterThan(0),
      );
      expect(
        engine.metrics.personalityActionCounts[AiPersonality.aggressive],
        greaterThan(0),
      );
      expect(
        engine.metrics.personalityActionCounts[AiPersonality.passive],
        greaterThan(0),
      );

      engine.dispose();
    });

    test('AI decision reasoning is descriptive', () async {
      final engine = SimulationEngine(
        playerCount: 3,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        autoPlayHero: true,
      );

      final reasonings = <String>[];
      final completer = Completer<void>();

      engine.eventStream.listen((event) {
        if (event.type == 'action') {
          final player = engine.players[event.seatIndex];
          if (player.type == PlayerType.ai && player.lastReasoning != null) {
            reasonings.add(player.lastReasoning!);
          }
        }
        if (event.type == 'round_end') {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      engine.startRound();

      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );

      expect(reasonings, isNotEmpty);

      // Verify reasoning contains expected keywords
      final allReasonings = reasonings.join(' ').toLowerCase();
      final hasValidKeywords =
          allReasonings.contains('fold') ||
          allReasonings.contains('call') ||
          allReasonings.contains('raise') ||
          allReasonings.contains('check') ||
          allReasonings.contains('bet');

      expect(hasValidKeywords, isTrue);

      engine.dispose();
    });
  });
}
