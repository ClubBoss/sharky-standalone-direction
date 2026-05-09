import 'dart:convert';
import 'dart:io';

const String _uxTuningPath = 'release/_reports/adaptive_ux_tuning_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _outputPath =
    'release/_reports/user_adaptation_feedback_summary.txt';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _parseUxTuningSummary();
  final signals = await _parseTelemetrySignals();

  final reports = <_FeedbackReport>[];
  double totalFeedback = 0;
  for (final moodEntry in moods.entries) {
    final mood = moodEntry.key;
    final tuning = moodEntry.value;
    final signal = signals[mood] ?? const _UserSignals();
    final feedbackScore = _computeFeedbackScore(signal);
    totalFeedback += feedbackScore;

    reports.add(
      _FeedbackReport(
        mood: mood,
        tuning: tuning,
        signals: signal,
        feedbackScore: feedbackScore,
        trend: _trendFor(feedbackScore),
      ),
    );
  }

  final avgFeedback = moods.isEmpty ? 0.0 : totalFeedback / moods.length;
  final trend = avgFeedback > 0.6
      ? 'Improving'
      : (avgFeedback < 0.4 ? 'Declining' : 'Stable');

  await _withReportsWritable(() async {
    await _writeSummary(reports, avgFeedback, trend);
    await _appendTelemetry(
      avgFeedback: avgFeedback,
      trend: trend,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'user_adaptation_feedback_loop: moods=${moods.length} '
    'avgFeedback=${avgFeedback.toStringAsFixed(2)} trend=$trend',
  );
}

Future<Map<String, _UxTuning>> _parseUxTuningSummary() async {
  final file = File(_uxTuningPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, _UxTuning>{};
  String? mood;
  double animation = 1;
  double button = 1;
  double spacing = 1;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      if (mood != null) {
        map[mood] = _UxTuning(
          animationSpeed: animation,
          buttonScale: button,
          spacingMultiplier: spacing,
        );
      }
      mood = line.substring(5).trim();
    } else if (line.startsWith('Animation speed:')) {
      animation = double.tryParse(line.split(':').last.trim()) ?? 1;
    } else if (line.startsWith('Button scale:')) {
      button = double.tryParse(line.split(':').last.trim()) ?? 1;
    } else if (line.startsWith('Spacing multiplier:')) {
      spacing = double.tryParse(line.split(':').last.trim()) ?? 1;
    }
  }
  if (mood != null) {
    map[mood] = _UxTuning(
      animationSpeed: animation,
      buttonScale: button,
      spacingMultiplier: spacing,
    );
  }
  return map;
}

Future<Map<String, _UserSignals>> _parseTelemetrySignals() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, _UserSignals>{};
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is! Map || payload['event'] != 'user_interaction') continue;
    final mood = payload['mood']?.toString() ?? 'unknown';
    final latency = (payload['touch_latency_ms'] as num?)?.toDouble() ?? 150;
    final cancelRate = (payload['cancel_rate'] as num?)?.toDouble() ?? 0.1;
    final completion =
        (payload['completion_time_ms'] as num?)?.toDouble() ?? 5000;
    map[mood] = _UserSignals(
      touchLatencyMs: latency,
      cancelRate: cancelRate,
      completionTimeMs: completion,
    );
  }
  return map;
}

double _computeFeedbackScore(_UserSignals signal) {
  final latencyScore = (200 / (signal.touchLatencyMs + 1)).clamp(0, 1);
  final cancelScore = (1 - signal.cancelRate).clamp(0, 1);
  final completionScore = (4000 / (signal.completionTimeMs + 1)).clamp(0, 1);
  return (latencyScore + cancelScore + completionScore) / 3;
}

String _trendFor(double score) {
  if (score >= 0.7) return 'Improving';
  if (score <= 0.4) return 'Declining';
  return 'Stable';
}

Future<void> _writeSummary(
  List<_FeedbackReport> reports,
  double avgFeedback,
  String trend,
) async {
  final buffer = StringBuffer()
    ..writeln('USER ADAPTATION FEEDBACK SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Moods evaluated: ${reports.length}   '
      'Avg feedback: ${avgFeedback.toStringAsFixed(2)}   Trend: $trend',
    )
    ..writeln();

  for (final report in reports) {
    buffer
      ..writeln('Mood: ${report.mood}')
      ..writeln(
        '  Signals → latency: '
        '${report.signals.touchLatencyMs.toStringAsFixed(0)} ms, '
        'cancel: ${report.signals.cancelRate.toStringAsFixed(2)}, '
        'completion: ${report.signals.completionTimeMs.toStringAsFixed(0)} ms',
      )
      ..writeln(
        '  Tuning → animation: ${report.tuning.animationSpeed.toStringAsFixed(2)}, '
        'button: ${report.tuning.buttonScale.toStringAsFixed(2)}, '
        'spacing: ${report.tuning.spacingMultiplier.toStringAsFixed(2)}',
      )
      ..writeln(
        '  Feedback score: ${report.feedbackScore.toStringAsFixed(2)} '
        '(${report.trend})',
      )
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double avgFeedback,
  required String trend,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'user_adaptation_feedback_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'avg_feedback': double.parse(avgFeedback.toStringAsFixed(2)),
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
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'user_adaptation_feedback_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _UxTuning {
  const _UxTuning({
    required this.animationSpeed,
    required this.buttonScale,
    required this.spacingMultiplier,
  });

  final double animationSpeed;
  final double buttonScale;
  final double spacingMultiplier;
}

class _UserSignals {
  const _UserSignals({
    this.touchLatencyMs = 150,
    this.cancelRate = 0.1,
    this.completionTimeMs = 5000,
  });

  final double touchLatencyMs;
  final double cancelRate;
  final double completionTimeMs;
}

class _FeedbackReport {
  const _FeedbackReport({
    required this.mood,
    required this.tuning,
    required this.signals,
    required this.feedbackScore,
    required this.trend,
  });

  final String mood;
  final _UxTuning tuning;
  final _UserSignals signals;
  final double feedbackScore;
  final String trend;
}
