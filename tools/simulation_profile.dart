import 'dart:async';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_telemetry.dart';

/// Headless simulation profiler for AI calibration.
///
/// Runs 1000 rounds of poker simulation with rule-based AI opponents,
/// collects comprehensive metrics, and exports AI calibration data.
///
/// Usage:
///   dart run tools/simulation_profile.dart [--rounds=1000] [--players=6]
///
/// Output: tools/_reports/simulation_metrics.json with aggregated analytics.
Future<void> main(List<String> args) async {
  // Parse arguments
  var rounds = 1000;
  var players = 6;

  for (final arg in args) {
    if (arg.startsWith('--rounds=')) {
      rounds = int.tryParse(arg.split('=')[1]) ?? rounds;
    } else if (arg.startsWith('--players=')) {
      players = int.tryParse(arg.split('=')[1]) ?? players;
    }
  }

  if (players < 2 || players > 10) {
    stderr.writeln('Error: players must be between 2 and 10');
    exit(1);
  }

  stdout.writeln('═' * 60);
  stdout.writeln('Poker AI Simulation Profiler');
  stdout.writeln('═' * 60);
  stdout.writeln('Configuration:');
  stdout.writeln('  Rounds: $rounds');
  stdout.writeln('  Players: $players');
  stdout.writeln('  Mode: Headless (no UI)');
  stdout.writeln('');

  final engine = SimulationEngine(
    playerCount: players,
    heroSeat: 0,
    smallBlind: 10,
    bigBlind: 20,
    initialStack: 1000,
  );

  // Subscribe to events for progress tracking
  var completedRounds = 0;
  var lastProgress = 0;

  engine.eventStream.listen((event) {
    if (event.type == 'round_end') {
      completedRounds++;
      final progress = (completedRounds / rounds * 100).toInt();
      if (progress >= lastProgress + 10) {
        stdout.writeln(
          '  Progress: $progress% ($completedRounds/$rounds rounds)',
        );
        lastProgress = progress;
      }
    }
  });

  stdout.writeln('Starting simulation...');
  final startTime = DateTime.now();

  // Run simulation rounds
  for (var i = 0; i < rounds; i++) {
    engine.startRound();

    // Auto-play hero with simple strategy (to advance simulation)
    await for (final _ in engine.eventStream) {
      if (!engine.isRoundActive) break;

      if (engine.currentSeat == engine.heroSeat) {
        // Hero calls or folds randomly (simple headless strategy)
        final action = _random.nextDouble() < 0.7
            ? PlayerAction.call
            : PlayerAction.fold;
        engine.playerAction(action);
      }
    }

    // Small delay to prevent event queue overflow
    if (i % 100 == 0) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
  final duration = DateTime.now().difference(startTime);
  stdout.writeln('');
  stdout.writeln('Simulation complete!');
  stdout.writeln('  Duration: ${duration.inSeconds}s');
  stdout.writeln(
    '  Rounds per second: ${(rounds / duration.inSeconds).toStringAsFixed(2)}',
  );
  stdout.writeln('');

  // Write metrics report
  stdout.writeln('Generating metrics report...');
  await SimulationTelemetry.writeMetricsReport(engine.metrics);

  // Print summary
  stdout.writeln('');
  stdout.writeln('═' * 60);
  stdout.writeln('AI Calibration Summary');
  stdout.writeln('═' * 60);
  stdout.writeln('Total AI actions: ${engine.metrics.aiActionCount}');
  stdout.writeln('  Raises: ${engine.metrics.aiRaiseCount}');
  stdout.writeln('  Calls: ${engine.metrics.aiCallCount}');
  stdout.writeln('  Folds: ${engine.metrics.aiFoldCount}');
  stdout.writeln('');
  stdout.writeln(
    'AI Aggression Factor: ${(engine.metrics.aiAggressionFactor * 100).toStringAsFixed(1)}%',
  );
  stdout.writeln(
    'AI Decision Accuracy: ${(engine.metrics.aiDecisionAccuracy * 100).toStringAsFixed(1)}%',
  );
  stdout.writeln('');
  stdout.writeln('Personality Distribution:');
  stdout.writeln(
    '  Tight: ${engine.metrics.personalityActionCounts[AiPersonality.tight]} actions',
  );
  stdout.writeln(
    '  Aggressive: ${engine.metrics.personalityActionCounts[AiPersonality.aggressive]} actions',
  );
  stdout.writeln(
    '  Passive: ${engine.metrics.personalityActionCounts[AiPersonality.passive]} actions',
  );
  stdout.writeln('');

  final avgRoundMs = engine.metrics.roundDurations.isEmpty
      ? 0
      : (engine.metrics.roundDurations.reduce((a, b) => a + b) /
                engine.metrics.roundDurations.length)
            .round();
  stdout.writeln('Average round duration: ${avgRoundMs}ms');
  stdout.writeln('');
  stdout.writeln('Metrics exported to: tools/_reports/simulation_metrics.json');
  stdout.writeln('═' * 60);

  engine.dispose();
  exit(0);
}

final _random = Random();

/// Random number generator for headless hero strategy.
class Random {
  int _seed = DateTime.now().millisecondsSinceEpoch;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}
