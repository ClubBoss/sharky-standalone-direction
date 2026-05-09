import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

/// Telemetry reporter for simulation metrics.
///
/// Writes simulation_round_ms, ai_action_count, user_interaction_latency,
/// and adaptive context to tools/_reports/simulation_metrics.json.
class SimulationTelemetry {
  static Future<void> writeMetricsReport(
    SimulationMetrics metrics, {
    BankrollManager? bankrollManager,
    BettingEconomy? bettingEconomy,
    double? difficultyMultiplier,
    double? repetitionRate,
    double? metaFeedbackScore,
  }) async {
    final reportsDir = Directory('tools/_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File('tools/_reports/simulation_metrics.json');
    final json = metrics.toJson(
      bankrollManager: bankrollManager,
      bettingEconomy: bettingEconomy,
    );

    // Add adaptive context
    if (difficultyMultiplier != null) {
      json['adaptive_difficulty_multiplier'] = difficultyMultiplier;
    }
    if (repetitionRate != null) {
      json['adaptive_repetition_rate'] = repetitionRate;
    }
    if (metaFeedbackScore != null) {
      json['meta_feedback_score'] = metaFeedbackScore;
    }

    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
      // ASCII-only log
      stdout.writeln('[SimulationTelemetry] Wrote metrics to ${file.path}');
      stdout.writeln('  Round count: ${json['round_count']}');
      stdout.writeln('  AI actions: ${json['ai_action_count']}');
      stdout.writeln(
        '  Avg round duration: ${json['avg_simulation_round_ms']}ms',
      );
      stdout.writeln(
        '  Avg user latency: ${json['avg_user_interaction_latency_ms']}ms',
      );
      if (difficultyMultiplier != null) {
        stdout.writeln(
          '  Difficulty: ${difficultyMultiplier.toStringAsFixed(2)}',
        );
      }
      if (repetitionRate != null) {
        stdout.writeln('  Repetition: ${repetitionRate.toStringAsFixed(2)}');
      }
      if (bankrollManager != null) {
        stdout.writeln('  Total bankroll: \$${bankrollManager.totalBankroll}');
      }
      if (bettingEconomy != null) {
        stdout.writeln('  Average pot: \$${bettingEconomy.averagePot}');
        stdout.writeln('  Rounds played: ${bettingEconomy.roundsPlayed}');
      }
    } catch (e) {
      stderr.writeln('[SimulationTelemetry] Failed to write metrics: $e');
    }

    // Write separate economy file if enabled
    if (bankrollManager != null && bettingEconomy != null) {
      await writeEconomyReport(bankrollManager, bettingEconomy);
    }
  }

  /// Writes detailed economy metrics to simulation_economy.json.
  static Future<void> writeEconomyReport(
    BankrollManager bankrollManager,
    BettingEconomy bettingEconomy,
  ) async {
    final reportsDir = Directory('tools/_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File('tools/_reports/simulation_economy.json');
    final json = {
      'bankroll': bankrollManager.toJson(),
      'economy': bettingEconomy.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
      stdout.writeln('[SimulationTelemetry] Wrote economy to ${file.path}');
    } catch (e) {
      stderr.writeln('[SimulationTelemetry] Failed to write economy: $e');
    }
  }

  static Future<Map<String, dynamic>?> readMetricsReport() async {
    final file = File('tools/_reports/simulation_metrics.json');
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('[SimulationTelemetry] Failed to read metrics: $e');
      return null;
    }
  }

  // Review usage events
  static Future<void> logReviewOpened() async {
    try {
      final file = File('tools/_reports/review_usage.log');
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      final line =
          '[review] session_review_opened ${DateTime.now().toIso8601String()}\n';
      await file.writeAsString(line, mode: FileMode.append);
      stdout.writeln(
        '[SimulationTelemetry] review event: session_review_opened',
      );
    } catch (e) {
      stderr.writeln('[SimulationTelemetry] failed review_opened: $e');
    }
  }

  static Future<void> logHandReplayed() async {
    try {
      final file = File('tools/_reports/review_usage.log');
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      final line =
          '[review] hand_replayed ${DateTime.now().toIso8601String()}\n';
      await file.writeAsString(line, mode: FileMode.append);
      stdout.writeln('[SimulationTelemetry] review event: hand_replayed');
    } catch (e) {
      stderr.writeln('[SimulationTelemetry] failed hand_replayed: $e');
    }
  }
}
