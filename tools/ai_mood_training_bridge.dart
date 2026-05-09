import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _telemetryLogPath = 'release/_reports/telemetry.jsonl';
const String _outputPath = 'release/_reports/ai_mood_training_summary.txt';
const String _telemetryPath = _telemetryLogPath;
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final parser = _TelemetryParser();
  await parser.process();

  final report = parser.buildReport();

  await _withReportsWritable(() async {
    await _writeSummary(report);
    await _appendTelemetry(
      moods: report.moodStats.length,
      avgScore: report.overallScore,
      trend: report.trend,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'ai_mood_training_bridge: moods=${report.moodStats.length} '
    'avg=${report.overallScore.toStringAsFixed(2)} trend=${report.trend}',
  );
}

class _TelemetryParser {
  final Map<String, _MoodStats> _stats = {};
  final List<double> _globalScores = [];
  double? _lastAlignmentPct;
  double? _lastBiasRatio;

  Future<void> process() async {
    final file = File(_telemetryLogPath);
    if (!await file.exists()) return;
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      dynamic payload;
      try {
        payload = json.decode(line);
      } catch (_) {
        continue;
      }
      if (payload is! Map) continue;
      final event = payload['event']?.toString();
      switch (event) {
        case 'ai_personalization_completed':
          _handlePersonalization(payload);
          break;
        case 'ai_visual_alignment_completed':
          _handleAlignment(payload);
          break;
        default:
          break;
      }
    }
  }

  void _handlePersonalization(Map payload) {
    final weights = payload['weights'];
    if (weights is! Map) return;
    final accuracy = _toDouble(weights['accuracy']);
    final streak = _toDouble(weights['streak']);
    final avgSessionTime = _toDouble(weights['avgSessionTime']);
    final mood = _detectMood(streak);
    final stats = _stats.putIfAbsent(mood, _MoodStats.new);

    final normEngagement = _normalize(streak, scale: 10);
    final normDuration = _normalize(avgSessionTime, scale: 900);
    final composite = (accuracy + normEngagement + normDuration) / 3;

    stats.count++;
    stats.sumAccuracy += accuracy;
    stats.sumEngagement += normEngagement;
    stats.sumDuration += normDuration;
    stats.sumComposite += composite;

    _globalScores.add(composite);
  }

  void _handleAlignment(Map payload) {
    _lastAlignmentPct = _toDouble(payload['alignment_pct']);
    _lastBiasRatio = _toDouble(payload['bias_ratio']);
  }

  _MoodReport buildReport() {
    final moodStats = <String, _MoodAggregate>{};
    double aggregateScore = 0;
    for (final entry in _stats.entries) {
      final stats = entry.value;
      final aggregate = stats.toAggregate();
      moodStats[entry.key] = aggregate;
      aggregateScore += aggregate.composite;
    }
    final overallScore = moodStats.isEmpty
        ? 0.0
        : aggregateScore / moodStats.length;
    final trend = _classifyTrend();
    return _MoodReport(
      moodStats: moodStats,
      overallScore: overallScore,
      trend: trend,
      alignmentPct: _lastAlignmentPct,
      biasRatio: _lastBiasRatio,
    );
  }

  String _detectMood(double streak) {
    if (streak > 5) return 'confident';
    if (streak < 0) return 'frustrated';
    return 'neutral';
  }

  double _normalize(double value, {required double scale}) {
    if (scale == 0) return 0;
    return min(max(value / scale, 0), 1);
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  String _classifyTrend() {
    if (_globalScores.length < 2) return 'Stable';
    final window = _globalScores.length >= 5
        ? _globalScores.sublist(_globalScores.length - 5)
        : _globalScores;
    final first = window.first;
    final last = window.last;
    final delta = last - first;
    if (delta > 0.02) return 'Improving';
    if (delta < -0.02) return 'Declining';
    return 'Stable';
  }
}

class _MoodStats {
  int count = 0;
  double sumAccuracy = 0;
  double sumEngagement = 0;
  double sumDuration = 0;
  double sumComposite = 0;

  _MoodAggregate toAggregate() {
    if (count == 0) {
      return const _MoodAggregate();
    }
    return _MoodAggregate(
      accuracy: sumAccuracy / count,
      engagement: sumEngagement / count,
      sessionDuration: sumDuration / count,
      composite: sumComposite / count,
    );
  }
}

class _MoodAggregate {
  const _MoodAggregate({
    this.accuracy = 0,
    this.engagement = 0,
    this.sessionDuration = 0,
    this.composite = 0,
  });

  final double accuracy;
  final double engagement;
  final double sessionDuration;
  final double composite;
}

class _MoodReport {
  const _MoodReport({
    required this.moodStats,
    required this.overallScore,
    required this.trend,
    required this.alignmentPct,
    required this.biasRatio,
  });

  final Map<String, _MoodAggregate> moodStats;
  final double overallScore;
  final String trend;
  final double? alignmentPct;
  final double? biasRatio;
}

Future<void> _writeSummary(_MoodReport report) async {
  final buffer = StringBuffer()
    ..writeln('AI MOOD TRAINING SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Trend: ${report.trend}   Overall score: '
      '${report.overallScore.toStringAsFixed(2)}',
    );
  if (report.alignmentPct != null || report.biasRatio != null) {
    buffer.writeln(
      'Alignment pct: ${report.alignmentPct?.toStringAsFixed(1) ?? 'n/a'}   '
      'Bias ratio: ${report.biasRatio?.toStringAsFixed(2) ?? 'n/a'}',
    );
  }
  buffer.writeln();
  if (report.moodStats.isEmpty) {
    buffer.writeln('No ai_personalization_completed telemetry found.');
  } else {
    for (final entry in report.moodStats.entries) {
      final stats = entry.value;
      buffer
        ..writeln('Mood: ${entry.key}')
        ..writeln(
          '  Accuracy: ${stats.accuracy.toStringAsFixed(2)}   '
          'Engagement: ${stats.engagement.toStringAsFixed(2)}   '
          'Session: ${stats.sessionDuration.toStringAsFixed(2)}',
        )
        ..writeln('  Composite score: ${stats.composite.toStringAsFixed(2)}')
        ..writeln();
    }
  }
  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int moods,
  required double avgScore,
  required String trend,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'ai_mood_training_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'moods': moods,
    'avg_score': double.parse(avgScore.toStringAsFixed(2)),
    'trend': trend,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'ai_mood_training_bridge: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
