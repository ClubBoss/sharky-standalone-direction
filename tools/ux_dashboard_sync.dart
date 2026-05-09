import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final sync = _UxDashboardSync();
  try {
    final metrics = await sync.collect();
    await sync.writeSummary(metrics);
    await sync.emitTelemetry(metrics);
  } finally {
    await sync.restorePermissions();
  }
}

class _UxDashboardSync {
  bool _reportsWritable = false;

  Future<_DashboardMetrics> collect() async {
    final watch = Stopwatch()..start();
    final metrics = await _readMetricsJson();
    final feedbackCount = await _countFeedbackRows();
    watch.stop();
    return _DashboardMetrics(
      timestamp: DateTime.now().toUtc(),
      avgFps: metrics.avgFps,
      peakMemMb: metrics.peakMemMb,
      recoveries: metrics.recoveries,
      stability: metrics.stabilityScore,
      warnings: metrics.warnings,
      feedbackItems: feedbackCount,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_MetricsJson> _readMetricsJson() async {
    final file = File('release/_exports/ux_metrics.json');
    if (!file.existsSync()) {
      throw StateError(
        'ux_metrics.json not found. Run ux_metric_exporter first.',
      );
    }
    final data = jsonDecode(await file.readAsString());
    if (data is! Map<String, dynamic>) {
      throw StateError('ux_metrics.json is malformed.');
    }
    double readDouble(String key) {
      final value = data[key];
      if (value is num) {
        return value.toDouble();
      }
      throw StateError('Missing numeric "$key" in ux_metrics.json');
    }

    int readInt(String key) {
      final value = data[key];
      if (value is num) {
        return value.toInt();
      }
      throw StateError('Missing integer "$key" in ux_metrics.json');
    }

    return _MetricsJson(
      avgFps: readDouble('avg_fps'),
      peakMemMb: readDouble('peak_mem_mb'),
      recoveries: readInt('recoveries'),
      stabilityScore: readDouble('stability_score'),
      warnings: readInt('warnings'),
    );
  }

  Future<int> _countFeedbackRows() async {
    final file = File('release/_reports/designer_feedback_matrix.md');
    if (!file.existsSync()) {
      throw StateError('designer_feedback_matrix.md not found.');
    }
    final lines = await file.readAsLines();
    var count = 0;
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      if (line.contains('Category') || line.contains('----------')) {
        continue;
      }
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length >= 4 && parts[1].isNotEmpty) {
        count += 1;
      }
    }
    return count;
  }

  Future<void> writeSummary(_DashboardMetrics metrics) async {
    final buffer = StringBuffer()
      ..writeln('UX Dashboard Summary')
      ..writeln('Timestamp: ${metrics.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Metric | Value | Badge | Notes |')
      ..writeln('|--------|-------|-------|-------|')
      ..writeln(
        _metricRow(
          'Avg FPS',
          metrics.avgFps.toStringAsFixed(2),
          _badgeHigher(metrics.avgFps, good: 60, warn: 58),
          'Target ≥60 FPS',
        ),
      )
      ..writeln(
        _metricRow(
          'Peak Mem (MB)',
          metrics.peakMemMb.toStringAsFixed(1),
          _badgeLower(metrics.peakMemMb, good: 360, warn: 400),
          'Lower is better',
        ),
      )
      ..writeln(
        _metricRow(
          'Stability',
          metrics.stability.toStringAsFixed(3),
          _badgeHigher(metrics.stability, good: 0.98, warn: 0.9),
          'Launch/QA/UX composite',
        ),
      )
      ..writeln(
        _metricRow(
          'Recoveries',
          metrics.recoveries.toString(),
          _badgeLower(metrics.recoveries.toDouble(), good: 1, warn: 2),
          'Auto-recoveries triggered',
        ),
      )
      ..writeln(
        _metricRow(
          'Feedback Items',
          metrics.feedbackItems.toString(),
          _badgeLower(metrics.feedbackItems.toDouble(), good: 4, warn: 6),
          'Active designer feedback rows',
        ),
      )
      ..writeln(
        _metricRow(
          'Warnings',
          metrics.warnings.toString(),
          _badgeLower(metrics.warnings.toDouble(), good: 2, warn: 4),
          'From stress summary',
        ),
      )
      ..writeln(
        '| Export Duration (ms) | ${metrics.durationMs} | - | Tool runtime |',
      );

    await _writeReportsFile(
      'release/_reports/ux_dashboard_summary.txt',
      buffer.toString(),
    );
  }

  String _metricRow(String label, String value, String badge, String notes) {
    return '| $label | $value | $badge | $notes |';
  }

  String _badgeHigher(
    double value, {
    required double good,
    required double warn,
  }) {
    if (value >= good) return 'GREEN';
    if (value >= warn) return 'ORANGE';
    return 'RED';
  }

  String _badgeLower(
    double value, {
    required double good,
    required double warn,
  }) {
    if (value <= good) return 'GREEN';
    if (value <= warn) return 'ORANGE';
    return 'RED';
  }

  Future<void> emitTelemetry(_DashboardMetrics metrics) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.uxDashboardSynced,
      'timestamp': metrics.timestamp.toIso8601String(),
      'fps_avg': metrics.avgFps,
      'stability': metrics.stability,
      'feedback': metrics.feedbackItems,
      'duration_ms': metrics.durationMs,
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

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _MetricsJson {
  _MetricsJson({
    required this.avgFps,
    required this.peakMemMb,
    required this.recoveries,
    required this.stabilityScore,
    required this.warnings,
  });

  final double avgFps;
  final double peakMemMb;
  final int recoveries;
  final double stabilityScore;
  final int warnings;
}

class _DashboardMetrics {
  _DashboardMetrics({
    required this.timestamp,
    required this.avgFps,
    required this.peakMemMb,
    required this.recoveries,
    required this.stability,
    required this.warnings,
    required this.feedbackItems,
    required this.durationMs,
  });

  final DateTime timestamp;
  final double avgFps;
  final double peakMemMb;
  final int recoveries;
  final double stability;
  final int warnings;
  final int feedbackItems;
  final int durationMs;
}
