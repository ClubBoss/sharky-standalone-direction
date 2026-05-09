import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:poker_analyzer/constants/telemetry_events.dart';

const double _tolerance = 0.05; // 5%

Future<void> main(List<String> args) async {
  final engine = _StabilityPreservationEngine();
  try {
    final result = await engine.run();
    await engine.writeSummary(result);
    await engine.emitTelemetry(result);
  } finally {
    await engine.restorePermissions();
  }
}

class _StabilityPreservationEngine {
  bool _reportsWritable = false;

  Future<_StabilityResult> run() async {
    final watch = Stopwatch()..start();
    final plan = await _readSelfOptimizationPlan();
    final baseline = await _readBaseline();
    final telemetry = await _readTelemetry();
    final variances = _computeVariances(plan, baseline);

    watch.stop();
    return _StabilityResult(
      timestamp: DateTime.now().toUtc(),
      variances: variances,
      telemetry: telemetry,
      varianceAvg: _averageVariance(variances),
      riskFlags: variances.where((v) => v.flag == 'RISK').length,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<List<_PlanMetric>> _readSelfOptimizationPlan() async {
    final file = File('release/_reports/self_optimization_plan.txt');
    if (!file.existsSync()) {
      throw StateError('self_optimization_plan.txt not found.');
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
      if (metric.isEmpty || value == null) continue;
      metrics.add(
        _PlanMetric(name: metric, value: value, badge: badge, action: action),
      );
    }
    return metrics;
  }

  Future<Map<String, double>> _readBaseline() async {
    final file = File('release/_reports/stability_preservation_summary.txt');
    if (!file.existsSync()) {
      return <String, double>{};
    }
    final lines = await file.readAsLines();
    final baselines = <String, double>{};
    var inTable = false;
    for (final raw in lines) {
      if (raw.startsWith('| Metric')) {
        inTable = true;
        continue;
      }
      if (!inTable || !raw.startsWith('|') || raw.contains('---')) {
        continue;
      }
      final parts = raw.split('|').map((p) => p.trim()).toList();
      if (parts.length < 6) continue;
      final metric = parts[1];
      final baseline = double.tryParse(parts[3]);
      if (metric.isEmpty || baseline == null) continue;
      baselines[metric] = baseline;
    }
    return baselines;
  }

  Future<List<_TelemetryEvent>> _readTelemetry() async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) return <_TelemetryEvent>[];
    final lines = await file.readAsLines();
    final events = <_TelemetryEvent>[];
    for (final raw in lines.reversed.take(10)) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final name = decoded['event'] as String?;
          final timestamp = decoded['timestamp'] as String?;
          if (name != null) {
            events.add(_TelemetryEvent(name: name, timestamp: timestamp));
          }
        }
      } catch (_) {
        // ignore malformed line
      }
    }
    return events;
  }

  List<_MetricVariance> _computeVariances(
    List<_PlanMetric> metrics,
    Map<String, double> baselines,
  ) {
    final variances = <_MetricVariance>[];
    for (final metric in metrics) {
      final baseline = baselines[metric.name] ?? metric.value;
      final variancePct = _variancePercent(metric.value, baseline);
      final flag = variancePct.abs() > _tolerance * 100 ? 'RISK' : 'STABLE';
      variances.add(
        _MetricVariance(
          name: metric.name,
          current: metric.value,
          baseline: baseline,
          variancePercent: variancePct,
          flag: flag,
          action: metric.action,
        ),
      );
    }
    return variances;
  }

  Future<void> writeSummary(_StabilityResult result) async {
    final buffer = StringBuffer()
      ..writeln('Stability Preservation Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Source: self_optimization_plan + telemetry')
      ..writeln('Variance tolerance: ${(100 * _tolerance).toStringAsFixed(1)}%')
      ..writeln();

    if (result.variances.isEmpty) {
      buffer
        ..writeln(
          'No metrics found in self_optimization_plan. Nothing to compare.',
        )
        ..writeln('Recent telemetry events:');
    } else {
      buffer
        ..writeln(
          '| Metric | Current | Baseline | Variance % | Flag | Action |',
        )
        ..writeln(
          '|--------|---------|----------|------------|------|--------|',
        );
      for (final variance in result.variances) {
        buffer.writeln(
          '| ${variance.name} | '
          '${variance.current.toStringAsFixed(3)} | '
          '${variance.baseline.toStringAsFixed(3)} | '
          '${variance.variancePercent.toStringAsFixed(2)} | '
          '${variance.flag} | ${variance.action} |',
        );
      }
      buffer
        ..writeln()
        ..writeln('Average variance: ${result.varianceAvg.toStringAsFixed(2)}%')
        ..writeln('Risk flags: ${result.riskFlags}')
        ..writeln()
        ..writeln('Recent telemetry events:');
    }

    if (result.telemetry.isEmpty) {
      buffer.writeln('- (no telemetry entries)');
    } else {
      for (final event in result.telemetry) {
        buffer.writeln(
          '- ${event.name} (${event.timestamp ?? 'no timestamp'})',
        );
      }
    }
    buffer.writeln('Duration (ms): ${result.durationMs}');

    await _writeReportsFile(
      'release/_reports/stability_preservation_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_StabilityResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.stabilityPreservationCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'variance_avg': _round(result.varianceAvg, 2),
      'risk_flags': result.riskFlags,
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
}

class _StabilityResult {
  _StabilityResult({
    required this.timestamp,
    required this.variances,
    required this.telemetry,
    required this.varianceAvg,
    required this.riskFlags,
    required this.durationMs,
  });

  final DateTime timestamp;
  final List<_MetricVariance> variances;
  final List<_TelemetryEvent> telemetry;
  final double varianceAvg;
  final int riskFlags;
  final int durationMs;
}

class _PlanMetric {
  _PlanMetric({
    required this.name,
    required this.value,
    required this.badge,
    required this.action,
  });

  final String name;
  final double value;
  final String badge;
  final String action;
}

class _MetricVariance {
  _MetricVariance({
    required this.name,
    required this.current,
    required this.baseline,
    required this.variancePercent,
    required this.flag,
    required this.action,
  });

  final String name;
  final double current;
  final double baseline;
  final double variancePercent;
  final String flag;
  final String action;
}

class _TelemetryEvent {
  _TelemetryEvent({required this.name, required this.timestamp});

  final String name;
  final String? timestamp;
}

double _variancePercent(double current, double baseline) {
  final denom = baseline.abs() < 0.0001 ? 1.0 : baseline.abs();
  return ((current - baseline) / denom) * 100;
}

double _averageVariance(List<_MetricVariance> variances) {
  if (variances.isEmpty) return 0.0;
  final sum = variances.fold<double>(
    0.0,
    (acc, v) => acc + v.variancePercent.abs(),
  );
  return sum / variances.length;
}

double _round(double value, int precision) {
  final factor = math.pow(10, precision).toDouble();
  return (value * factor).round() / factor;
}
