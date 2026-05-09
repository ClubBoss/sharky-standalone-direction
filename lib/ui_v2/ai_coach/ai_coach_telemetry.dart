import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ai_coaching_analytics_service.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_engine.dart';

/// Telemetry tracker for AI coaching metrics.
///
/// Logs ai_hint_count, ai_correct_ratio, avg_ev_diff to
/// tools/_reports/ai_coach_metrics.json.
class AiCoachTelemetry {
  AiCoachTelemetry() : _startTime = DateTime.now();

  final DateTime _startTime;
  final List<CoachingFeedback> _feedbackHistory = [];

  /// Record a coaching feedback event.
  void recordFeedback(CoachingFeedback feedback) {
    _feedbackHistory.add(feedback);
  }

  /// Get total number of hints provided.
  int get hintCount => _feedbackHistory.length;

  /// Get ratio of optimal actions (correct decisions).
  double get correctRatio {
    if (_feedbackHistory.isEmpty) return 0.0;

    final correctCount = _feedbackHistory.where((f) => f.isOptimal).length;
    return correctCount / _feedbackHistory.length;
  }

  /// Get average EV difference across all actions.
  double get avgEvDiff {
    if (_feedbackHistory.isEmpty) return 0.0;

    final totalEv = _feedbackHistory.fold<double>(
      0.0,
      (sum, f) => sum + f.evDifference,
    );
    return totalEv / _feedbackHistory.length;
  }

  /// Get total session duration in milliseconds.
  int get sessionDurationMs =>
      DateTime.now().difference(_startTime).inMilliseconds;

  /// Get feedback breakdown by action type.
  Map<String, int> get actionBreakdown {
    final breakdown = <String, int>{};
    for (final feedback in _feedbackHistory) {
      final action = feedback.action.toLowerCase();
      breakdown[action] = (breakdown[action] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Get average confidence score.
  double get avgConfidence {
    if (_feedbackHistory.isEmpty) return 0.0;

    final totalConfidence = _feedbackHistory.fold<double>(
      0.0,
      (sum, f) => sum + f.confidenceScore,
    );
    return totalConfidence / _feedbackHistory.length;
  }

  /// Write coaching metrics to JSON file.
  Future<void> writeMetricsReport() async {
    final reportsDir = Directory('tools/_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File('tools/_reports/ai_coach_metrics.json');

    final json = {
      'ai_hint_count': hintCount,
      'ai_correct_ratio': correctRatio,
      'avg_ev_diff': avgEvDiff,
      'session_duration_ms': sessionDurationMs,
      'avg_confidence': avgConfidence,
      'action_breakdown': actionBreakdown,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      // Archive session to history for analytics
      await AiCoachingAnalyticsService.archiveSession(json);

      // ASCII-only log
      stdout.writeln('[AiCoachTelemetry] Wrote metrics to ${file.path}');
      stdout.writeln('  Hint count: $hintCount');
      stdout.writeln(
        '  Correct ratio: ${(correctRatio * 100).toStringAsFixed(1)}%',
      );
      stdout.writeln('  Avg EV diff: ${avgEvDiff.toStringAsFixed(2)} BB');
      stdout.writeln(
        '  Avg confidence: ${(avgConfidence * 100).toStringAsFixed(1)}%',
      );
      stdout.writeln('  Session duration: ${sessionDurationMs}ms');
    } catch (e) {
      stderr.writeln('[AiCoachTelemetry] Failed to write metrics: $e');
    }
  }

  /// Read existing coaching metrics from file.
  static Future<Map<String, dynamic>?> readMetricsReport() async {
    final file = File('tools/_reports/ai_coach_metrics.json');
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('[AiCoachTelemetry] Failed to read metrics: $e');
      return null;
    }
  }

  /// Get detailed feedback history.
  List<CoachingFeedback> get feedbackHistory =>
      List.unmodifiable(_feedbackHistory);

  /// Clear feedback history (e.g., start new session).
  void clear() {
    _feedbackHistory.clear();
  }
}
