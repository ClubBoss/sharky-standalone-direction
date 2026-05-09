import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'adaptive_loop_v2_engine.dart' as v2;
import 'mini_ai_tuner_service.dart';

Future<Map<String, Object>> runAdaptiveLoopV3({
  String summaryPath = 'adaptive_learning_summary.json',
  String performancePath = 'user_performance.json',
  String reviewDirectoryPath = 'export/sessions',
  String reportPath = 'adaptive_loop_v3_report.json',
  String telemetryPath = 'telemetry/adaptive_loop_meta_recalibrated.log',
  String aiTunerTelemetryPath = 'telemetry/ai_tuner_recommendation.log',
}) async {
  final baseTuning = await v2.runAdaptiveLoopV2(
    plannerSummaryPath: summaryPath,
    performancePath: performancePath,
    semanticAuditPath: 'tools/_reports/content_semantic_audit.json',
  );

  final performance = _loadPerformance(performancePath);
  final reviews = _loadReviewEntries(reviewDirectoryPath);

  final metaScore = _computeMetaFeedbackScore(reviews, performance);
  final difficultyMultiplier = _reframeDifficulty(
    baseTuning['difficultyMultiplier'] as num? ?? 1.0,
    performance,
    metaScore,
  );
  final repetitionRate = _reframeRepetition(
    baseTuning['topicRepetitionRate'] as num? ?? 0.25,
    performance,
    metaScore,
  );

  final report = {
    'pass': true,
    'base': baseTuning,
    'meta_feedback_score': metaScore,
    'difficultyMultiplier': double.parse(
      difficultyMultiplier.toStringAsFixed(3),
    ),
    'topicRepetitionRate': double.parse(repetitionRate.toStringAsFixed(3)),
    'reviews_analyzed': reviews.length,
    'sentiment_breakdown': _sentimentBreakdown(reviews),
    'timestamp': DateTime.now().toIso8601String(),
  };

  final tunerService = MiniAiTunerService(
    sessionsDirectory: reviewDirectoryPath,
  );
  final latestSession = tunerService.resolveLatestSessionId();
  if (latestSession != null) {
    try {
      final tunerResult = await tunerService.analyzeSession(
        latestSession,
        writeReport: true,
      );
      report['mini_ai_tuner'] = tunerResult.toJson();
      await _appendAiTelemetry(aiTunerTelemetryPath, tunerResult);
    } catch (e) {
      report['mini_ai_tuner'] = {
        'pass': false,
        'session_id': latestSession,
        'error': e.toString(),
      };
    }
  } else {
    report['mini_ai_tuner'] = {'pass': false, 'reason': 'no_session_found'};
  }

  await File(
    reportPath,
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(report));
  await _appendTelemetry(telemetryPath, report);
  return report;
}

Future<void> _appendTelemetry(
  String telemetryPath,
  Map<String, Object> report,
) async {
  final file = File(telemetryPath);
  await file.parent.create(recursive: true);
  await file.writeAsString('${jsonEncode(report)}\n', mode: FileMode.append);
}

Future<void> _appendAiTelemetry(
  String telemetryPath,
  MiniAiResult result,
) async {
  final file = File(telemetryPath);
  await file.parent.create(recursive: true);
  final entry = {
    'event': 'ai_tuner_recommendation',
    'timestamp': result.timestampUtc.toIso8601String(),
    'session_id': result.sessionId,
    'verified_count': result.verifiedCount,
  };
  await file.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
}

Map<String, Object> _loadPerformance(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return <String, Object>{
      'error_rate': 0.18,
      'xp': 1200,
      'streak': 3,
      'ev_diff': 0.0,
    };
  }
  try {
    final data = jsonDecode(file.readAsStringSync());
    if (data is Map<String, Object?>) {
      return data.cast<String, Object>();
    }
  } catch (_) {}
  return <String, Object>{
    'error_rate': 0.18,
    'xp': 1200,
    'streak': 3,
    'ev_diff': 0.0,
  };
}

List<_ReviewEntry> _loadReviewEntries(String directoryPath) {
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) return const [];
  final entries = <_ReviewEntry>[];
  for (final file in directory.listSync(recursive: false)) {
    if (file is! File) continue;
    if (!file.path.endsWith('_review.json')) continue;
    try {
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded.whereType<Map>()) {
          final entry = _ReviewEntry.fromJson(item.cast<String, Object?>());
          if (entry != null) entries.add(entry);
        }
      } else if (decoded is Map<String, Object?>) {
        final entry = _ReviewEntry.fromJson(decoded);
        if (entry != null) entries.add(entry);
      }
    } catch (_) {
      continue;
    }
  }
  return entries;
}

double _computeMetaFeedbackScore(
  List<_ReviewEntry> reviews,
  Map<String, Object> performance,
) {
  if (reviews.isEmpty) return 0.6;

  double weightedSum = 0.0;
  double totalWeight = 0.0;
  for (final review in reviews) {
    final sentimentValue = _sentimentValue(review.sentiment);
    final severityValue = _severityWeight(review.severity);
    weightedSum += sentimentValue * severityValue;
    totalWeight += severityValue;
  }
  final sentimentScore = totalWeight > 0 ? (weightedSum / totalWeight) : 0.5;

  final errorRate = (performance['error_rate'] as num?)?.toDouble() ?? 0.2;
  final evDiff = (performance['ev_diff'] as num?)?.toDouble() ?? 0.0;
  final streak = (performance['streak'] as num?)?.toDouble() ?? 0.0;

  final performanceScore = (1 - errorRate).clamp(0.0, 1.0);
  final evScore = (0.5 + evDiff).clamp(0.0, 1.0);
  final streakScore = (0.3 + streak * 0.05).clamp(0.0, 1.0);

  final metaScore =
      (sentimentScore * 0.45) +
      (performanceScore * 0.3) +
      (evScore * 0.15) +
      (streakScore * 0.1);

  return double.parse(metaScore.clamp(0.0, 1.0).toStringAsFixed(3));
}

double _sentimentValue(String sentiment) {
  switch (sentiment.toLowerCase()) {
    case 'praise':
      return 0.9;
    case 'minor':
      return 0.65;
    case 'critical':
      return 0.25;
    default:
      return 0.5;
  }
}

double _severityWeight(String severity) {
  switch (severity.toLowerCase()) {
    case 'critical':
      return 1.0;
    case 'major':
      return 0.8;
    case 'minor':
      return 0.5;
    case 'praise':
      return 0.3;
    default:
      return 0.4;
  }
}

Map<String, int> _sentimentBreakdown(List<_ReviewEntry> reviews) {
  final breakdown = <String, int>{};
  for (final review in reviews) {
    final key = review.sentiment.toLowerCase();
    breakdown[key] = (breakdown[key] ?? 0) + 1;
  }
  return breakdown;
}

double _reframeDifficulty(
  num baseDifficulty,
  Map<String, Object> performance,
  double metaScore,
) {
  final errorRate = (performance['error_rate'] as num?)?.toDouble() ?? 0.2;
  final xp = (performance['xp'] as num?)?.toDouble() ?? 0.0;
  final xpFactor = xp > 0 ? min(1.5, xp / 1500.0) : 1.0;

  double multiplier = baseDifficulty.toDouble();
  multiplier += (0.3 - errorRate) * 0.35;
  multiplier *= (0.9 + metaScore * 0.2);
  multiplier *= (0.95 + xpFactor * 0.05);

  return multiplier.clamp(0.75, 1.6);
}

double _reframeRepetition(
  num baseRate,
  Map<String, Object> performance,
  double metaScore,
) {
  final errorRate = (performance['error_rate'] as num?)?.toDouble() ?? 0.2;
  final base = baseRate.toDouble();
  final adjusted = base + (errorRate - 0.2) * 0.25 + (0.5 - metaScore) * 0.2;
  return adjusted.clamp(0.1, 0.85);
}

class _ReviewEntry {
  _ReviewEntry({
    required this.sentiment,
    required this.severity,
    required this.evDiff,
  });

  final String sentiment;
  final String severity;
  final double evDiff;

  static _ReviewEntry? fromJson(Map<String, Object?> json) {
    final sentiment = json['sentiment']?.toString();
    final severity = json['severity']?.toString() ?? sentiment;
    if (sentiment == null || sentiment.isEmpty) return null;
    final evDiff =
        (json['ev_diff'] as num?)?.toDouble() ??
        (json['evDelta'] as num?)?.toDouble() ??
        0.0;
    return _ReviewEntry(
      sentiment: sentiment,
      severity: severity ?? 'minor',
      evDiff: evDiff,
    );
  }
}

Future<void> main(List<String> args) async {
  final report = await runAdaptiveLoopV3();
  stdout.writeln(jsonEncode(report));
}
