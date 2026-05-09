import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final reporter = _HealthInsightReporter();
  try {
    final result = await reporter.run();
    await reporter.writeSummary(result);
    await reporter.emitTelemetry(result);
  } finally {
    await reporter.restorePermissions();
  }
}

class _HealthInsightReporter {
  bool _reportsWritable = false;

  Future<_HealthInsightResult> run() async {
    final sw = Stopwatch()..start();
    final uxMetrics = await _readUxMetricSummary();
    final dashboard = await _readUxDashboard();
    final forecast = await _readPredictiveTrend();
    final feedback = await _readFeedbackSummary();

    final stability = uxMetrics.stabilityScore ?? dashboard.stability ?? 0.0;
    final trend = forecast.trendDay7 ?? 0.0;
    final alpha = feedback.alphaAvg ?? 0.0;

    const stabilityWeight = 0.45;
    const trendWeight = 0.35;
    const feedbackWeight = 0.20;
    final healthIndex = _clamp01(
      stability * stabilityWeight +
          trend * trendWeight +
          alpha * feedbackWeight,
    );

    sw.stop();
    return _HealthInsightResult(
      timestamp: DateTime.now().toUtc(),
      uxMetrics: uxMetrics,
      dashboard: dashboard,
      forecast: forecast,
      feedback: feedback,
      healthIndex: healthIndex,
      stabilityWeight: stabilityWeight,
      trendWeight: trendWeight,
      feedbackWeight: feedbackWeight,
      durationMs: sw.elapsedMilliseconds,
    );
  }

  Future<_UxMetricSummary> _readUxMetricSummary() async {
    final file = File('release/_reports/ux_metric_summary.txt');
    if (!file.existsSync()) {
      throw StateError('release/_reports/ux_metric_summary.txt missing.');
    }
    final lines = await file.readAsLines();
    final metrics = <String, double>{};
    DateTime? timestamp;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('Timestamp:')) {
        timestamp = _tryParseIso(line.substring('Timestamp:'.length).trim());
        continue;
      }
      if (!raw.startsWith('|')) continue;
      if (raw.contains('---')) continue;
      final parts = raw.split('|').map((p) => p.trim()).toList();
      if (parts.length < 3) continue;
      final label = parts[1];
      final value = double.tryParse(parts[2]);
      if (label.isEmpty || value == null) continue;
      metrics[label] = value;
    }
    return _UxMetricSummary(
      timestamp: timestamp,
      stabilityScore: metrics['Stability Score'],
      uxScore: metrics['UX Score'],
      warnings: metrics['Warnings']?.toInt(),
    );
  }

  Future<_UxDashboardSummary> _readUxDashboard() async {
    final file = File('release/_reports/ux_dashboard_summary.txt');
    if (!file.existsSync()) {
      throw StateError('release/_reports/ux_dashboard_summary.txt missing.');
    }
    final lines = await file.readAsLines();
    DateTime? timestamp;
    double? stability;
    int? warnings;
    double? avgFps;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('Timestamp:')) {
        timestamp = _tryParseIso(line.substring('Timestamp:'.length).trim());
        continue;
      }
      if (!raw.startsWith('|')) continue;
      if (raw.contains('---')) continue;
      final parts = raw.split('|').map((p) => p.trim()).toList();
      if (parts.length < 5) continue;
      switch (parts[1]) {
        case 'Stability':
          stability = double.tryParse(parts[2]);
          break;
        case 'Warnings':
          warnings = int.tryParse(parts[2]);
          break;
        case 'Avg FPS':
          avgFps = double.tryParse(parts[2]);
          break;
      }
    }
    return _UxDashboardSummary(
      timestamp: timestamp,
      stability: stability,
      warnings: warnings,
      avgFps: avgFps,
    );
  }

  Future<_TrendForecast> _readPredictiveTrend() async {
    final file = File('release/_reports/predictive_trend_forecast.txt');
    if (!file.existsSync()) {
      throw StateError('predictive_trend_forecast.txt missing.');
    }
    final lines = await file.readAsLines();
    DateTime? timestamp;
    double? day7Trend;
    final tablePattern = RegExp(
      r'^\|\s*Day\s*(\d+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)',
    );
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('Timestamp:')) {
        timestamp = _tryParseIso(line.substring('Timestamp:'.length).trim());
        continue;
      }
      final match = tablePattern.firstMatch(raw);
      if (match != null) {
        final day = int.tryParse(match.group(1)!);
        if (day == null) continue;
        final trend = double.tryParse(match.group(3)!);
        if (trend != null) {
          day7Trend = trend;
        }
      }
    }
    return _TrendForecast(timestamp: timestamp, trendDay7: day7Trend);
  }

  Future<_FeedbackSummary> _readFeedbackSummary() async {
    final searchPaths = [
      'release/_reports/feedback_adaptation_summary.txt',
      'release/_exports/feedback_adaptation_summary.txt',
    ];
    File? file;
    for (final path in searchPaths) {
      final candidate = File(path);
      if (candidate.existsSync()) {
        file = candidate;
        break;
      }
    }
    if (file == null) {
      throw StateError('feedback_adaptation_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    DateTime? timestamp;
    double? alphaAvg;
    double? driftPct;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('Generated:')) {
        timestamp = _tryParseIso(line.substring('Generated:'.length).trim());
        continue;
      }
      if (line.startsWith('- alpha_avg:')) {
        alphaAvg = double.tryParse(
          line.substring('- alpha_avg:'.length).trim(),
        );
        continue;
      }
      if (line.startsWith('- drift_pct:')) {
        driftPct = double.tryParse(
          line.substring('- drift_pct:'.length).trim(),
        );
      }
    }
    return _FeedbackSummary(
      timestamp: timestamp,
      alphaAvg: alphaAvg,
      driftPct: driftPct,
    );
  }

  Future<void> writeSummary(_HealthInsightResult result) async {
    final buffer = StringBuffer()
      ..writeln('Health Insight Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln(
        'Sources: ux_metric_summary, ux_dashboard_summary, predictive_trend_forecast, feedback_adaptation_summary',
      )
      ..writeln(
        'Weights => Stability ${_percent(result.stabilityWeight)}, Trend ${_percent(result.trendWeight)}, Feedback ${_percent(result.feedbackWeight)}',
      )
      ..writeln();

    buffer
      ..writeln('| Metric | Value | Badge | Notes |')
      ..writeln('|--------|-------|-------|-------|')
      ..writeln(
        _metricRow('Health Index', result.healthIndex, 'Composite score (0-1)'),
      )
      ..writeln(
        _metricRow(
          'Stability Score',
          result.uxMetrics.stabilityScore ?? result.dashboard.stability ?? 0.0,
          'UX metric summary',
        ),
      )
      ..writeln(
        _metricRow(
          'Forecast Trend (Day7)',
          result.forecast.trendDay7 ?? 0.0,
          'Predictive trend forecaster',
        ),
      )
      ..writeln(
        _metricRow(
          'Feedback Alpha',
          result.feedback.alphaAvg ?? 0.0,
          'Feedback adaptation loop',
        ),
      );

    buffer
      ..writeln()
      ..writeln('Context metrics:')
      ..writeln('- Warnings (dashboard): ${result.dashboard.warnings ?? 0}')
      ..writeln(
        '- Avg FPS: ${(result.dashboard.avgFps ?? 0).toStringAsFixed(2)}',
      )
      ..writeln(
        '- Feedback drift %: ${(result.feedback.driftPct ?? 0).toStringAsFixed(2)}',
      )
      ..writeln()
      ..writeln('Health Index sparkline:')
      ..writeln(_bar(result.healthIndex));

    await _writeReportsFile(
      'release/_reports/health_insight_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_HealthInsightResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.healthInsightCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'health_index': _round(result.healthIndex, 3),
      'trend': _round(result.forecast.trendDay7 ?? 0.0, 3),
      'duration_ms': result.durationMs,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    try {
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  String _metricRow(String label, double value, String notes) {
    final clamped = _clamp01(value);
    return '| $label | ${clamped.toStringAsFixed(3)} | ${_badgeFor(clamped)} | $notes |';
  }

  String _badgeFor(double value) {
    if (value >= 0.9) return 'GREEN';
    if (value >= 0.75) return 'ORANGE';
    return 'RED';
  }

  String _bar(double value) {
    final normalized = _clamp01(value);
    final filled = (normalized * 20).round();
    final bar = '[${_repeat('#', filled)}${_repeat('.', 20 - filled)}]';
    return '$bar ${normalized.toStringAsFixed(3)}';
  }

  String _percent(double weight) => '${(weight * 100).toStringAsFixed(0)}%';

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _HealthInsightResult {
  _HealthInsightResult({
    required this.timestamp,
    required this.uxMetrics,
    required this.dashboard,
    required this.forecast,
    required this.feedback,
    required this.healthIndex,
    required this.stabilityWeight,
    required this.trendWeight,
    required this.feedbackWeight,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _UxMetricSummary uxMetrics;
  final _UxDashboardSummary dashboard;
  final _TrendForecast forecast;
  final _FeedbackSummary feedback;
  final double healthIndex;
  final double stabilityWeight;
  final double trendWeight;
  final double feedbackWeight;
  final int durationMs;
}

class _UxMetricSummary {
  _UxMetricSummary({
    required this.timestamp,
    required this.stabilityScore,
    required this.uxScore,
    required this.warnings,
  });

  final DateTime? timestamp;
  final double? stabilityScore;
  final double? uxScore;
  final int? warnings;
}

class _UxDashboardSummary {
  _UxDashboardSummary({
    required this.timestamp,
    required this.stability,
    required this.warnings,
    required this.avgFps,
  });

  final DateTime? timestamp;
  final double? stability;
  final int? warnings;
  final double? avgFps;
}

class _TrendForecast {
  _TrendForecast({required this.timestamp, required this.trendDay7});

  final DateTime? timestamp;
  final double? trendDay7;
}

class _FeedbackSummary {
  _FeedbackSummary({
    required this.timestamp,
    required this.alphaAvg,
    required this.driftPct,
  });

  final DateTime? timestamp;
  final double? alphaAvg;
  final double? driftPct;
}

double _clamp01(double value) => math.max(0.0, math.min(1.0, value));

double _round(double value, int precision) {
  final factor = math.pow(10, precision).toDouble();
  return (value * factor).round() / factor;
}

String _repeat(String char, int count) {
  if (count <= 0) return '';
  final buffer = StringBuffer();
  for (var i = 0; i < count; i++) {
    buffer.write(char);
  }
  return buffer.toString();
}

DateTime? _tryParseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}
