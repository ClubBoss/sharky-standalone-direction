import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final exporter = _UxMetricExporter();
  try {
    final metrics = await exporter.collect();
    await exporter.writeJson(metrics);
    await exporter.writeSummary(metrics);
    await exporter.emitTelemetry(metrics);
  } finally {
    await exporter.restorePermissions();
  }
}

class _UxMetricExporter {
  bool _reportsWritable = false;
  bool _exportsWritable = false;

  Future<_UxMetrics> collect() async {
    final watch = Stopwatch()..start();
    final stress = await _parseStressSummary(
      'release/_reports/ux_stress_recovery_summary.txt',
    );
    final stability = await _parseStabilityAudit(
      'release/_reports/stability_scaling_audit.txt',
    );
    watch.stop();

    return _UxMetrics(
      timestamp: DateTime.now().toUtc(),
      avgFps: stress.avgFps,
      peakMemMb: stress.peakMemMb,
      recoveries: stress.recoveries,
      stabilityScore: stability.stabilityScore,
      launchScore: stability.launchScore,
      qaScore: stability.qaScore,
      uxScore: stability.uxScore,
      warnings: stress.warnings,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_StressMetrics> _parseStressSummary(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('$path not found.');
    }
    final lines = await file.readAsLines();
    double? avgFps;
    double? memPeak;
    int? recoveries;
    int? warnings;
    for (final line in lines) {
      final normalized = line.trim();
      if (normalized.startsWith('| avg_fps')) {
        avgFps = _extractValue(normalized);
      } else if (normalized.startsWith('| mem_peak_mb')) {
        memPeak = _extractValue(normalized);
      } else if (normalized.startsWith('| recoveries')) {
        recoveries = _extractValue(normalized).toInt();
      } else if (normalized.startsWith('| warnings')) {
        warnings = _extractValue(normalized).toInt();
      }
    }
    if (avgFps == null ||
        memPeak == null ||
        recoveries == null ||
        warnings == null) {
      throw StateError('Could not parse summary metrics from $path');
    }
    return _StressMetrics(
      avgFps: avgFps,
      peakMemMb: memPeak,
      recoveries: recoveries,
      warnings: warnings,
    );
  }

  Future<_StabilityMetrics> _parseStabilityAudit(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('$path not found.');
    }
    final lines = await file.readAsLines();
    double? launch;
    double? qa;
    double? ux;
    double? stability;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Launch=')) {
        launch = double.tryParse(trimmed.split('=').last);
      } else if (trimmed.startsWith('QA=')) {
        qa = double.tryParse(trimmed.split('=').last);
      } else if (trimmed.startsWith('UX=')) {
        ux = double.tryParse(trimmed.split('=').last);
      } else if (trimmed.startsWith('stability_score=')) {
        stability = double.tryParse(trimmed.split('=').last);
      }
    }
    if (launch == null || qa == null || ux == null || stability == null) {
      throw StateError('Incomplete stability metrics in $path');
    }
    return _StabilityMetrics(
      launchScore: launch,
      qaScore: qa,
      uxScore: ux,
      stabilityScore: stability,
    );
  }

  double _extractValue(String tableLine) {
    final parts = tableLine.split('|').map((p) => p.trim()).toList();
    return double.parse(parts[2]);
  }

  Future<void> writeJson(_UxMetrics metrics) async {
    final file = File('release/_exports/ux_metrics.json');
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(metrics.toJson()));
    } on FileSystemException {
      await _makeExportsWritable();
      await file.writeAsString(jsonEncode(metrics.toJson()));
    }
  }

  Future<void> writeSummary(_UxMetrics metrics) async {
    final buffer = StringBuffer()
      ..writeln('UX Metric Summary')
      ..writeln('Timestamp: ${metrics.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Metric | Value |')
      ..writeln('|--------|-------|')
      ..writeln('| Avg FPS | ${metrics.avgFps.toStringAsFixed(2)} |')
      ..writeln('| Peak Mem (MB) | ${metrics.peakMemMb.toStringAsFixed(1)} |')
      ..writeln('| Recoveries | ${metrics.recoveries} |')
      ..writeln('| Warnings | ${metrics.warnings} |')
      ..writeln(
        '| Stability Score | ${metrics.stabilityScore.toStringAsFixed(3)} |',
      )
      ..writeln('| Launch Score | ${metrics.launchScore.toStringAsFixed(2)} |')
      ..writeln('| QA Score | ${metrics.qaScore.toStringAsFixed(2)} |')
      ..writeln('| UX Score | ${metrics.uxScore.toStringAsFixed(2)} |')
      ..writeln('| Export Duration (ms) | ${metrics.durationMs} |');

    final summaryFile = File('release/_reports/ux_metric_summary.txt');
    try {
      await summaryFile.writeAsString(buffer.toString());
    } on FileSystemException {
      await _makeReportsWritable();
      await summaryFile.writeAsString(buffer.toString());
    }
  }

  Future<void> emitTelemetry(_UxMetrics metrics) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.uxMetricExported,
      'timestamp': metrics.timestamp.toIso8601String(),
      'fps_avg': metrics.avgFps,
      'recoveries': metrics.recoveries,
      'stability': metrics.stabilityScore,
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

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
    if (_exportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_exports']);
      _exportsWritable = false;
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }

  Future<void> _makeExportsWritable() async {
    if (_exportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_exports']);
    _exportsWritable = true;
  }
}

class _StressMetrics {
  const _StressMetrics({
    required this.avgFps,
    required this.peakMemMb,
    required this.recoveries,
    required this.warnings,
  });

  final double avgFps;
  final double peakMemMb;
  final int recoveries;
  final int warnings;
}

class _StabilityMetrics {
  const _StabilityMetrics({
    required this.launchScore,
    required this.qaScore,
    required this.uxScore,
    required this.stabilityScore,
  });

  final double launchScore;
  final double qaScore;
  final double uxScore;
  final double stabilityScore;
}

class _UxMetrics {
  _UxMetrics({
    required this.timestamp,
    required this.avgFps,
    required this.peakMemMb,
    required this.recoveries,
    required this.stabilityScore,
    required this.launchScore,
    required this.qaScore,
    required this.uxScore,
    required this.warnings,
    required this.durationMs,
  });

  final DateTime timestamp;
  final double avgFps;
  final double peakMemMb;
  final int recoveries;
  final double stabilityScore;
  final double launchScore;
  final double qaScore;
  final double uxScore;
  final int warnings;
  final int durationMs;

  Map<String, Object> toJson() => <String, Object>{
    'timestamp': timestamp.toIso8601String(),
    'avg_fps': avgFps,
    'peak_mem_mb': peakMemMb,
    'recoveries': recoveries,
    'stability_score': stabilityScore,
    'launch_score': launchScore,
    'qa_score': qaScore,
    'ux_score': uxScore,
    'warnings': warnings,
    'duration_ms': durationMs,
  };
}
