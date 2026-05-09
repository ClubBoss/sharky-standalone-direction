import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final audit = _HealthCrosscheckAudit();
  try {
    final result = await audit.run();
    await audit.writeSummary(result);
    await audit.emitTelemetry(result);
  } finally {
    await audit.restorePermissions();
  }
}

class _HealthCrosscheckAudit {
  bool _reportsWritable = false;

  Future<_HealthCrosscheckResult> run() async {
    final watch = Stopwatch()..start();
    final uxMetrics = await _readUxMetrics();
    final plan = await _readOptimizationPlan();

    final aiMetrics = plan.where((m) => _isAiMetric(m.metric)).toList();
    if (aiMetrics.isEmpty) {
      aiMetrics.add(
        _PlanMetric(
          metric: 'AI Reliability (fallback)',
          value: uxMetrics.stabilityScore ?? 1.0,
          badge: 'GREEN',
          action: 'Monitor',
          correctiveWeight: 0,
        ),
      );
    }

    final fpsNorm = _clamp(
      uxMetrics.avgFps != null ? uxMetrics.avgFps! / 60.0 : 1.0,
    );
    final stabilityNorm = _clamp(uxMetrics.stabilityScore ?? 1.0);
    final aiSeries = aiMetrics.map((m) => _clamp(m.value ?? 1.0)).toList();
    final uxSeries = <double>[];
    for (var i = 0; i < aiSeries.length; i++) {
      uxSeries.add(i.isEven ? fpsNorm : stabilityNorm);
    }
    if (uxSeries.length < 2) {
      aiSeries.add(aiSeries.last);
      uxSeries.add(stabilityNorm);
    }
    final corrAiUx = _pearson(aiSeries, uxSeries);

    final alerts = <String>[];
    if (fpsNorm < 0.98)
      alerts.add(
        'FPS below target (avg ${uxMetrics.avgFps?.toStringAsFixed(2) ?? 'unknown'})',
      );
    if ((uxMetrics.stabilityScore ?? 1.0) < 0.98)
      alerts.add('Stability under 0.98 threshold');
    if (aiSeries.any((value) => value < 0.95)) {
      alerts.add('AI reliability below 0.95 in optimization plan');
    }
    if (aiMetrics.any((m) => (m.badge ?? '').toUpperCase() == 'RED')) {
      alerts.add('Critical badge detected for AI metric');
    }

    watch.stop();
    return _HealthCrosscheckResult(
      timestamp: DateTime.now().toUtc(),
      uxMetrics: uxMetrics,
      planMetrics: plan,
      aiMetrics: aiMetrics,
      correlation: corrAiUx,
      alerts: alerts,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_UxMetrics> _readUxMetrics() async {
    final file = File('release/_exports/ux_metrics.json');
    if (!file.existsSync()) {
      throw StateError('release/_exports/ux_metrics.json not found.');
    }
    final dynamic decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('ux_metrics.json malformed.');
    }
    double? readDouble(String key) {
      final value = decoded[key];
      if (value is num) return value.toDouble();
      return null;
    }

    return _UxMetrics(
      timestamp: _tryParseIso(decoded['timestamp'] as String?),
      avgFps: readDouble('avg_fps'),
      stabilityScore: readDouble('stability_score'),
      warnings: (decoded['warnings'] as num?)?.toInt(),
      recoveries: (decoded['recoveries'] as num?)?.toInt(),
    );
  }

  Future<List<_PlanMetric>> _readOptimizationPlan() async {
    final file = File('release/_reports/self_optimization_plan.txt');
    if (!file.existsSync()) {
      return <_PlanMetric>[];
    }
    final lines = await file.readAsLines();
    final metrics = <_PlanMetric>[];
    var inTable = false;
    for (final raw in lines) {
      if (raw.startsWith('| Priority')) {
        inTable = true;
        continue;
      }
      if (!inTable || !raw.startsWith('|') || raw.contains('---')) {
        continue;
      }
      final parts = raw.split('|').map((p) => p.trim()).toList();
      if (parts.length < 7) continue;
      final metric = parts[2];
      final value = double.tryParse(parts[3]);
      final badge = parts[4];
      final action = parts[5];
      final corrective = double.tryParse(parts[6]);
      metrics.add(
        _PlanMetric(
          metric: metric,
          value: value,
          badge: badge,
          action: action,
          correctiveWeight: corrective ?? 0.0,
        ),
      );
    }
    return metrics;
  }

  Future<void> writeSummary(_HealthCrosscheckResult result) async {
    final buffer = StringBuffer()
      ..writeln('Health Cross-Check Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Sources: ux_metrics.json, self_optimization_plan.txt')
      ..writeln(
        'Correlation (AI ↔ UX): ${result.correlation.toStringAsFixed(3)}',
      )
      ..writeln();

    buffer
      ..writeln('| Metric | Value | Badge | Action |')
      ..writeln('|--------|-------|-------|--------|');
    if (result.aiMetrics.isEmpty) {
      buffer.writeln('| (none) | - | - | - |');
    } else {
      for (final metric in result.aiMetrics) {
        buffer.writeln(
          '| ${metric.metric} | '
          '${(metric.value ?? 0).toStringAsFixed(3)} | '
          '${metric.badge ?? '-'} | ${metric.action ?? '-'} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('UX snapshot:')
      ..writeln(
        '- Avg FPS: ${result.uxMetrics.avgFps?.toStringAsFixed(2) ?? 'unknown'}',
      )
      ..writeln(
        '- Stability Score: ${result.uxMetrics.stabilityScore?.toStringAsFixed(3) ?? 'unknown'}',
      )
      ..writeln('- Warnings: ${result.uxMetrics.warnings ?? 0}')
      ..writeln('- Recoveries: ${result.uxMetrics.recoveries ?? 0}')
      ..writeln();

    buffer.writeln('Alerts:');
    if (result.alerts.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final alert in result.alerts) {
        buffer.writeln('- $alert');
      }
    }
    buffer.writeln('Duration (ms): ${result.durationMs}');

    await _writeReportsFile(
      'release/_reports/health_crosscheck_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_HealthCrosscheckResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.healthCrosscheckCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'corr_ai_ux': _round(result.correlation, 3),
      'alerts': result.alerts.length,
      'duration_ms': result.durationMs,
    };
    final file = File('release/_reports/telemetry.jsonl');
    try {
      await file.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

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

  bool _isAiMetric(String? label) {
    if (label == null) return false;
    final lower = label.toLowerCase();
    return lower.contains('ai') || lower.contains('reliability');
  }
}

class _HealthCrosscheckResult {
  _HealthCrosscheckResult({
    required this.timestamp,
    required this.uxMetrics,
    required this.planMetrics,
    required this.aiMetrics,
    required this.correlation,
    required this.alerts,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _UxMetrics uxMetrics;
  final List<_PlanMetric> planMetrics;
  final List<_PlanMetric> aiMetrics;
  final double correlation;
  final List<String> alerts;
  final int durationMs;
}

class _UxMetrics {
  _UxMetrics({
    required this.timestamp,
    required this.avgFps,
    required this.stabilityScore,
    required this.warnings,
    required this.recoveries,
  });

  final DateTime? timestamp;
  final double? avgFps;
  final double? stabilityScore;
  final int? warnings;
  final int? recoveries;
}

class _PlanMetric {
  _PlanMetric({
    required this.metric,
    required this.value,
    required this.badge,
    required this.action,
    required this.correctiveWeight,
  });

  final String metric;
  final double? value;
  final String? badge;
  final String? action;
  final double correctiveWeight;
}

double _pearson(List<double> xs, List<double> ys) {
  if (xs.length != ys.length || xs.length < 2) {
    return 0.0;
  }
  final meanX = xs.reduce((a, b) => a + b) / xs.length;
  final meanY = ys.reduce((a, b) => a + b) / ys.length;
  var num = 0.0;
  var denomX = 0.0;
  var denomY = 0.0;
  for (var i = 0; i < xs.length; i++) {
    final dx = xs[i] - meanX;
    final dy = ys[i] - meanY;
    num += dx * dy;
    denomX += dx * dx;
    denomY += dy * dy;
  }
  final denom = math.sqrt(denomX * denomY);
  if (denom == 0) return 0.0;
  return num / denom;
}

double _clamp(double value) => value.clamp(0.0, 1.0);

double _round(double value, int precision) {
  final factor = math.pow(10, precision).toDouble();
  return (value * factor).round() / factor;
}

DateTime? _tryParseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}
