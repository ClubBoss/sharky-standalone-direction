import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Aggregates AI coaching session data and computes retention metrics.
///
/// Reads ai_coach_metrics.json sessions, computes rolling retention score (RS),
/// identifies top 3 weakness tags, and exports to ai_coaching_retention.json.
///
/// Retention Score (RS) = avg(correct_ratio × confidence - |avg_ev_diff|)
///
/// Performance target: < 5ms/frame; ASCII-only logs; no new deps.
class AiCoachingAnalyticsService {
  AiCoachingAnalyticsService._();

  static const String _retentionPath =
      'tools/_reports/ai_coaching_retention.json';
  static const String _historyPath =
      'tools/_reports/ai_coach_history.jsonl'; // Line-delimited sessions

  /// Append current session to history file (JSONL format).
  static Future<void> archiveSession(Map<String, dynamic> sessionData) async {
    try {
      final file = File(_historyPath);
      final line = jsonEncode(sessionData);

      // Append to JSONL
      await file.writeAsString('$line\n', mode: FileMode.append);

      stdout.writeln('[AiCoachAnalytics] Archived session to $_historyPath');
    } catch (e) {
      stderr.writeln('[AiCoachAnalytics] Failed to archive session: $e');
    }
  }

  /// Read all historical sessions from JSONL file.
  static Future<List<Map<String, dynamic>>> _readSessionHistory() async {
    final file = File(_historyPath);
    if (!await file.exists()) {
      return [];
    }

    try {
      final lines = await file.readAsLines();
      final sessions = <Map<String, dynamic>>[];

      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final json = jsonDecode(line);
        if (json is Map<String, dynamic>) {
          sessions.add(json);
        }
      }

      return sessions;
    } catch (e) {
      stderr.writeln('[AiCoachAnalytics] Failed to read history: $e');
      return [];
    }
  }

  /// Compute retention score: avg(correct_ratio × confidence - |avg_ev_diff|)
  static double _computeRetentionScore(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return 0.0;

    double totalScore = 0.0;
    int validCount = 0;

    for (final session in sessions) {
      final correctRatio = (session['ai_correct_ratio'] as num?)?.toDouble();
      final avgConfidence = (session['avg_confidence'] as num?)?.toDouble();
      final avgEvDiff = (session['avg_ev_diff'] as num?)?.toDouble();

      if (correctRatio != null && avgConfidence != null && avgEvDiff != null) {
        final score = (correctRatio * avgConfidence) - avgEvDiff.abs();
        totalScore += score;
        validCount++;
      }
    }

    return validCount > 0 ? totalScore / validCount : 0.0;
  }

  /// Identify top 3 weakness tags from action breakdown.
  ///
  /// Weakness = action with lowest correct_ratio for that action type.
  static List<Map<String, dynamic>> _identifyWeaknesses(
    List<Map<String, dynamic>> sessions,
  ) {
    // Aggregate action performance: action -> {correct: n, total: m}
    final actionStats = <String, Map<String, int>>{};

    for (final session in sessions) {
      final actionBreakdown =
          session['action_breakdown'] as Map<String, dynamic>?;
      final correctRatio =
          (session['ai_correct_ratio'] as num?)?.toDouble() ?? 0.0;
      final hintCount = (session['ai_hint_count'] as num?)?.toInt() ?? 0;

      if (actionBreakdown == null || hintCount == 0) continue;

      // Estimate correct count per action (simplified: distribute proportionally)
      final estimatedCorrect = (hintCount * correctRatio).round();

      for (final entry in actionBreakdown.entries) {
        final action = entry.key;
        final count = (entry.value as num).toInt();

        if (!actionStats.containsKey(action)) {
          actionStats[action] = {'correct': 0, 'total': 0};
        }

        // Proportional distribution of correct actions
        final actionCorrect = (estimatedCorrect * (count / hintCount)).round();

        actionStats[action]!['correct'] =
            (actionStats[action]!['correct'] ?? 0) + actionCorrect;
        actionStats[action]!['total'] =
            (actionStats[action]!['total'] ?? 0) + count;
      }
    }

    // Calculate success rate per action and sort by weakness
    final weaknesses = <Map<String, dynamic>>[];

    for (final entry in actionStats.entries) {
      final action = entry.key;
      final stats = entry.value;
      final total = stats['total'] ?? 0;
      final correct = stats['correct'] ?? 0;

      if (total < 5) continue; // Ignore actions with < 5 samples

      final successRate = total > 0 ? correct / total : 0.0;

      weaknesses.add({
        'action': action,
        'success_rate': successRate,
        'total_count': total,
        'correct_count': correct,
      });
    }

    // Sort by success_rate ascending (worst first)
    weaknesses.sort((a, b) {
      final rateA = a['success_rate'] as double;
      final rateB = b['success_rate'] as double;
      return rateA.compareTo(rateB);
    });

    // Return top 3 weaknesses
    return weaknesses.take(3).toList();
  }

  /// Generate recommendations based on weaknesses.
  static List<String> _generateRecommendations(
    List<Map<String, dynamic>> weaknesses,
  ) {
    final recommendations = <String>[];

    for (final weakness in weaknesses) {
      final action = weakness['action'] as String;
      final successRate = weakness['success_rate'] as double;
      final percentage = (successRate * 100).toStringAsFixed(0);

      String recommendation;
      switch (action.toLowerCase()) {
        case 'fold':
          recommendation =
              'Focus on fold discipline ($percentage% success) - Review pot odds and hand strength thresholds';
          break;
        case 'call':
          recommendation =
              'Improve calling decisions ($percentage% success) - Study implied odds and position';
          break;
        case 'raise':
          recommendation =
              'Refine raise sizing ($percentage% success) - Practice value betting and bluff frequency';
          break;
        case 'bet':
          recommendation =
              'Optimize bet sizing ($percentage% success) - Work on range construction and board texture';
          break;
        case 'check':
          recommendation =
              'Better check decisions ($percentage% success) - Study pot control and showdown value';
          break;
        default:
          recommendation =
              'Review $action decisions ($percentage% success) - Focus on fundamental concepts';
      }

      recommendations.add(recommendation);
    }

    return recommendations;
  }

  /// Compute trend vs last 7 days.
  ///
  /// Returns percentage change in retention score: positive = improving.
  static double _computeTrend7(List<Map<String, dynamic>> allSessions) {
    if (allSessions.length < 2) return 0.0;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    // Recent sessions (last 7 days)
    final recentSessions = allSessions.where((s) {
      final timestamp = DateTime.tryParse(s['timestamp'] as String? ?? '');
      return timestamp != null && timestamp.isAfter(sevenDaysAgo);
    }).toList();

    // Previous sessions (7-14 days ago)
    final previousSessions = allSessions.where((s) {
      final timestamp = DateTime.tryParse(s['timestamp'] as String? ?? '');
      return timestamp != null &&
          timestamp.isAfter(fourteenDaysAgo) &&
          timestamp.isBefore(sevenDaysAgo);
    }).toList();

    if (recentSessions.isEmpty || previousSessions.isEmpty) return 0.0;

    final recentScore = _computeRetentionScore(recentSessions);
    final previousScore = _computeRetentionScore(previousSessions);

    if (previousScore == 0.0) return 0.0;

    // Percentage change
    return ((recentScore - previousScore) / previousScore.abs()) * 100;
  }

  /// Compute trend vs last 14 days window compared with the preceding 14 days.
  static double _computeTrend14(List<Map<String, dynamic>> allSessions) {
    if (allSessions.length < 2) return 0.0;

    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final twentyEightDaysAgo = now.subtract(const Duration(days: 28));

    // Recent 14 days
    final recentSessions = allSessions.where((s) {
      final timestamp = DateTime.tryParse(s['timestamp'] as String? ?? '');
      return timestamp != null && timestamp.isAfter(fourteenDaysAgo);
    }).toList();

    // Previous 14-28 days
    final previousSessions = allSessions.where((s) {
      final timestamp = DateTime.tryParse(s['timestamp'] as String? ?? '');
      return timestamp != null &&
          timestamp.isAfter(twentyEightDaysAgo) &&
          timestamp.isBefore(fourteenDaysAgo);
    }).toList();

    if (recentSessions.isEmpty || previousSessions.isEmpty) return 0.0;

    final recentScore = _computeRetentionScore(recentSessions);
    final previousScore = _computeRetentionScore(previousSessions);

    if (previousScore == 0.0) return 0.0;

    return ((recentScore - previousScore) / previousScore.abs()) * 100;
  }

  /// Generate retention analytics report.
  ///
  /// Aggregates sessions, computes RS, identifies weaknesses, and exports JSON.
  static Future<Map<String, dynamic>> generateRetentionReport() async {
    try {
      final sessions = await _readSessionHistory();

      if (sessions.isEmpty) {
        stdout.writeln(
          '[AiCoachAnalytics] No session history found, skipping report',
        );
        return {
          'retention_score': 0.0,
          'retention_score_percent': 0.0,
          'trend_vs_last_7_days': 0.0,
          'sessions_analyzed': 0,
          'top_3_weaknesses': <Map<String, dynamic>>[],
          'recommendations': <String>[],
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      final retentionScore = _computeRetentionScore(sessions);
      final retentionScorePercent = (retentionScore * 100).clamp(0.0, 100.0);
      final trend = _computeTrend7(sessions);
      final trend14 = _computeTrend14(sessions);
      final weaknesses = _identifyWeaknesses(sessions);
      final recommendations = _generateRecommendations(weaknesses);

      final report = {
        'retention_score': retentionScore,
        'retention_score_percent': retentionScorePercent,
        'trend_vs_last_7_days': trend,
        'sessions_analyzed': sessions.length,
        'top_3_weaknesses': weaknesses,
        'recommendations': recommendations,
        'timestamp': DateTime.now().toIso8601String(),
        'trend_vs_last_14_days': trend14,
      };

      // Write to retention JSON
      final file = File(_retentionPath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(report),
      );

      // ASCII-only log
      stdout.writeln('[AiCoachAnalytics] Generated retention report:');
      stdout.writeln(
        '  Retention Score: ${retentionScorePercent.toStringAsFixed(1)}%',
      );
      stdout.writeln(
        '  Trend (7d): ${trend >= 0 ? "+" : ""}${trend.toStringAsFixed(1)}%',
      );
      stdout.writeln('  Sessions: ${sessions.length}');
      stdout.writeln('  Weaknesses: ${weaknesses.length}');
      stdout.writeln('  Report: $_retentionPath');

      // Log to Firebase telemetry
      unawaited(
        FirebaseLiteTelemetryService.instance.logEvent(
          'ai_retention_score',
          params: {
            'retention_score_percent': retentionScorePercent,
            'trend_vs_last_7_days': trend,
            'trend_vs_last_14_days': trend14,
            'sessions_analyzed': sessions.length,
            'weakness_count': weaknesses.length,
          },
        ),
      );

      return report;
    } catch (e) {
      stderr.writeln('[AiCoachAnalytics] Failed to generate report: $e');
      rethrow;
    }
  }

  /// Read existing retention report.
  static Future<Map<String, dynamic>?> readRetentionReport() async {
    final file = File(_retentionPath);
    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('[AiCoachAnalytics] Failed to read retention report: $e');
      return null;
    }
  }

  /// Cleanup old sessions (keep last 30 days).
  static Future<void> cleanupOldSessions({int keepDays = 30}) async {
    try {
      final sessions = await _readSessionHistory();
      if (sessions.isEmpty) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

      final recentSessions = sessions.where((s) {
        final timestamp = DateTime.tryParse(s['timestamp'] as String? ?? '');
        return timestamp != null && timestamp.isAfter(cutoffDate);
      }).toList();

      if (recentSessions.length == sessions.length) return;

      // Rewrite history file with only recent sessions
      final file = File(_historyPath);
      final buffer = StringBuffer();
      for (final session in recentSessions) {
        buffer.writeln(jsonEncode(session));
      }

      await file.writeAsString(buffer.toString());

      final removed = sessions.length - recentSessions.length;
      stdout.writeln(
        '[AiCoachAnalytics] Cleaned up $removed old sessions (kept $keepDays days)',
      );
    } catch (e) {
      stderr.writeln('[AiCoachAnalytics] Failed to cleanup sessions: $e');
    }
  }
}
