import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final engine = _MaintenanceAutomationEngine();
  try {
    final result = await engine.run();
    await engine.writeSummary(result);
    await engine.emitTelemetry(result);
  } finally {
    await engine.restorePermissions();
  }
}

class _MaintenanceAutomationEngine {
  bool _reportsWritable = false;

  Future<_AutomationResult> run() async {
    final watch = Stopwatch()..start();
    final stability = await _readStabilitySummary();
    final telemetry = await _readTelemetry();

    final degradationRate = stability.metrics.isEmpty
        ? 0.0
        : stability.metrics
                  .map((m) => m.variancePercent.abs())
                  .fold<double>(0.0, (a, b) => a + b) /
              stability.metrics.length;
    final riskFlags = stability.metrics
        .where((m) => m.flag.toUpperCase() == 'RISK')
        .length;
    final riskScore = math
        .min(100.0, degradationRate + riskFlags * 10)
        .toDouble();
    final nextCycleDays = riskScore > 40
        ? 7
        : riskScore > 20
        ? 14
        : 30;

    watch.stop();
    return _AutomationResult(
      timestamp: DateTime.now().toUtc(),
      stability: stability,
      telemetry: telemetry,
      degradationRate: degradationRate,
      riskFlags: riskFlags,
      riskScore: riskScore,
      nextCycleDays: nextCycleDays,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_StabilitySummary> _readStabilitySummary() async {
    final file = File('release/_reports/stability_preservation_summary.txt');
    if (!file.existsSync()) {
      throw StateError('stability_preservation_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    final metrics = <_VarianceMetric>[];
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
      final name = parts[1];
      final current = double.tryParse(parts[2]);
      final baseline = double.tryParse(parts[3]);
      final variance = double.tryParse(parts[4]);
      final flag = parts[5];
      final action = parts.length > 6 ? parts[6] : '';
      if (name.isEmpty ||
          current == null ||
          baseline == null ||
          variance == null) {
        continue;
      }
      metrics.add(
        _VarianceMetric(
          name: name,
          current: current,
          baseline: baseline,
          variancePercent: variance,
          flag: flag,
          action: action,
        ),
      );
    }
    return _StabilitySummary(metrics: metrics);
  }

  Future<List<_TelemetryEvent>> _readTelemetry() async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) return <_TelemetryEvent>[];
    final lines = await file.readAsLines();
    final events = <_TelemetryEvent>[];
    for (final raw in lines.reversed.take(5)) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          final name = decoded['event'] as String?;
          final timestamp = decoded['timestamp'] as String?;
          if (name != null) {
            events.add(_TelemetryEvent(name: name, timestamp: timestamp));
          }
        }
      } catch (_) {
        // ignore malformed entries
      }
    }
    return events;
  }

  Future<void> writeSummary(_AutomationResult result) async {
    final buffer = StringBuffer()
      ..writeln('Maintenance Automation Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Sources: stability_preservation_summary, telemetry.jsonl')
      ..writeln(
        'Degradation rate: ${result.degradationRate.toStringAsFixed(2)}% | Risk score: ${result.riskScore.toStringAsFixed(1)}',
      )
      ..writeln('Next recommended cycle: ${result.nextCycleDays} days')
      ..writeln();

    if (result.stability.metrics.isEmpty) {
      buffer.writeln('No variance metrics detected in stability summary.');
    } else {
      buffer
        ..writeln(
          '| Metric | Current | Baseline | Variance % | Flag | Action |',
        )
        ..writeln(
          '|--------|---------|----------|------------|------|--------|',
        );
      for (final metric in result.stability.metrics) {
        buffer.writeln(
          '| ${metric.name} | '
          '${metric.current.toStringAsFixed(3)} | '
          '${metric.baseline.toStringAsFixed(3)} | '
          '${metric.variancePercent.toStringAsFixed(2)} | '
          '${metric.flag} | ${metric.action} |',
        );
      }
      buffer.writeln();
    }

    final weeklyDate = result.timestamp.add(const Duration(days: 7));
    final monthlyDate = result.timestamp.add(const Duration(days: 30));
    buffer
      ..writeln('| Cycle | Next Run | Notes |')
      ..writeln('|-------|----------|-------|')
      ..writeln(
        '| Weekly | ${weeklyDate.toIso8601String()} | ${_cycleNote(result.riskScore, threshold: 40)} |',
      )
      ..writeln(
        '| Monthly | ${monthlyDate.toIso8601String()} | ${_cycleNote(result.riskScore, threshold: 20)} |',
      )
      ..writeln();

    buffer.writeln('Recent telemetry events:');
    if (result.telemetry.isEmpty) {
      buffer.writeln('- (none)');
    } else {
      for (final event in result.telemetry) {
        buffer.writeln(
          '- ${event.name} (${event.timestamp ?? 'no timestamp'})',
        );
      }
    }
    buffer.writeln('Duration (ms): ${result.durationMs}');

    await _writeReportsFile(
      'release/_reports/maintenance_automation_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_AutomationResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.maintenanceAutomationCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'risk_score': _round(result.riskScore, 2),
      'next_cycle_days': result.nextCycleDays,
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

  String _cycleNote(double riskScore, {required double threshold}) {
    if (riskScore > threshold) {
      return 'Escalate inspection cadence';
    }
    return 'Standard monitoring';
  }
}

class _AutomationResult {
  _AutomationResult({
    required this.timestamp,
    required this.stability,
    required this.telemetry,
    required this.degradationRate,
    required this.riskFlags,
    required this.riskScore,
    required this.nextCycleDays,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _StabilitySummary stability;
  final List<_TelemetryEvent> telemetry;
  final double degradationRate;
  final int riskFlags;
  final double riskScore;
  final int nextCycleDays;
  final int durationMs;
}

class _StabilitySummary {
  _StabilitySummary({required this.metrics});

  final List<_VarianceMetric> metrics;
}

class _VarianceMetric {
  _VarianceMetric({
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

double _round(double value, int precision) {
  final factor = math.pow(10, precision).toDouble();
  return (value * factor).round() / factor;
}
