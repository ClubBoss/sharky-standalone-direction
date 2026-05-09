import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/engine/simulation_ai_agent.dart';

/// Runs a repeatable AI tuning batch and reports aggregate metrics.
Future<void> main(List<String> args) async {
  final hands = args.isNotEmpty ? int.tryParse(args.first) ?? 100 : 100;
  if (hands <= 0) {
    stderr.writeln('Hand count must be positive.');
    exit(1);
  }

  final agent = SimulationAIAgent(
    aggression: 0.72,
    earlyStreetModifier: 0.95,
    lateStreetModifier: 1.12,
    baseDelayMs: 1150,
    seed: 20250317,
  );

  final stats = agent.simulateHand(hands);

  stdout.writeln('AI tuning batch summary ($hands hands):');
  stdout.writeln('- Win % (BTN): ${stats.winRatePercent.toStringAsFixed(1)}');
  stdout.writeln('- Bluff rate: ${stats.bluffRatePercent.toStringAsFixed(1)}');
  stdout.writeln('- Average pot: ${stats.averagePot.toStringAsFixed(1)} chips');
  stdout.writeln('- Bets sampled: ${stats.totalBets}');
  stdout.writeln('- Wins by position:');
  stats.winsByPosition.forEach((seat, share) {
    stdout.writeln('  * $seat: ${(share * 100).toStringAsFixed(1)}%');
  });

  _emitTelemetry(stats, hands: hands);
}

void _emitTelemetry(SimulationBatchStats stats, {required int hands}) {
  final payload = <String, Object>{
    'event': 'ai_tuning_completed',
    'hands': hands,
    'win_rate': double.parse(stats.winRate.toStringAsFixed(3)),
    'bluff_rate': double.parse(stats.bluffRate.toStringAsFixed(3)),
    'average_pot': double.parse(stats.averagePot.toStringAsFixed(2)),
    'wins_by_position': stats.winsByPosition.map(
      (seat, share) => MapEntry(seat, double.parse(share.toStringAsFixed(3))),
    ),
    'total_bets': stats.totalBets,
    'total_bluffs': stats.totalBluffs,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  };
  stdout.writeln(jsonEncode(payload));
}
