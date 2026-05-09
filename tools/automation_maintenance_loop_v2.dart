import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _rsiSummaryPath = '$_reportsDir/rsi_auto_recovery_summary.txt';
const String _healthSummaryPath =
    '$_reportsDir/stability_health_remediation_summary.txt';
const String _telemetrySweepSummaryPath =
    '$_reportsDir/telemetry_health_sweep_summary.json';
const String _summaryTextPath =
    '$_reportsDir/automation_maintenance_loop_v2_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/automation_maintenance_loop_v2_summary.json';

const double _minIntegrityScore = 90.0;

Future<void> main(List<String> args) async {
  final loop = AutomationMaintenanceLoopV2();
  final ok = await loop.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AutomationMaintenanceLoopV2 {
  Future<bool> run() async {
    final metrics = await _collectMetrics();
    final (rerunEvents, rerunFailures) = await _performReruns(metrics);
    final integrityScore = _computeIntegrity(metrics);
    final pass = integrityScore >= _minIntegrityScore && rerunFailures.isEmpty;

    final summaryText = _buildTextSummary(
      metrics,
      rerunEvents,
      integrityScore,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      metrics,
      rerunEvents,
      integrityScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(metrics, integrityScore, rerunFailures, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Maintenance integrity ${integrityScore.toStringAsFixed(2)} below '
        '${_minIntegrityScore.toStringAsFixed(0)} or reruns failed.',
      );
    }

    return pass;
  }

  Future<_MaintenanceMetrics> _collectMetrics() async {
    final rsi = await _extractPercent(
      _rsiSummaryPath,
      RegExp(r'Latest RSI:\s*[0-9.]+% → ([0-9.]+)%'),
    );
    final fsHealth = await _extractPercent(
      _healthSummaryPath,
      RegExp(r'Health score \(≥85%\):\s*([0-9.]+)%'),
    );
    final telemetryCoverage = await _extractJsonValue(
      _telemetrySweepSummaryPath,
      'coverage_ratio',
    );
    final telemetryMiss = await _extractJsonValue(
      _telemetrySweepSummaryPath,
      'missing_events',
      count: true,
    );

    return _MaintenanceMetrics(
      rsi: rsi,
      fsHealth: fsHealth,
      telemetryCoverage: telemetryCoverage,
      telemetryMissingCount: telemetryMiss,
    );
  }

  double _computeIntegrity(_MaintenanceMetrics metrics) {
    return (metrics.rsi * 0.4) +
        (metrics.fsHealth * 0.3) +
        (metrics.telemetryCoverage * 0.3);
  }

  Future<(List<_RerunEvent>, List<_RerunEvent>)> _performReruns(
    _MaintenanceMetrics metrics,
  ) async {
    final events = <_RerunEvent>[];
    final failures = <_RerunEvent>[];
    final rerunTargets = <_RerunTarget>[
      _RerunTarget(
        name: 'rsi_auto_recovery_booster',
        command: ['dart', 'run', 'tools/rsi_auto_recovery_booster.dart'],
        summaryPath: _rsiSummaryPath,
      ),
      _RerunTarget(
        name: 'stability_health_remediation',
        command: ['dart', 'run', 'tools/stability_health_remediation.dart'],
        summaryPath: _healthSummaryPath,
      ),
      _RerunTarget(
        name: 'telemetry_health_sweep',
        command: ['dart', 'run', 'tools/telemetry_health_sweep.dart'],
        summaryPath: _telemetrySweepSummaryPath,
      ),
    ];

    for (final target in rerunTargets) {
      final lastModified = await _modifiedAt(target.summaryPath);
      final isStale =
          lastModified == null ||
          DateTime.now().difference(lastModified) > const Duration(hours: 24);
      if (!isStale) continue;
      final result = await _runCommand(target.command);
      final rerunEvent = _RerunEvent(
        name: target.name,
        exitCode: result.exitCode,
        duration: result.duration,
        success: result.exitCode == 0,
      );
      events.add(rerunEvent);
      if (!rerunEvent.success) {
        failures.add(rerunEvent);
      }
    }

    return (events, failures);
  }

  Future<DateTime?> _modifiedAt(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.lastModified();
  }

  Future<_CommandResult> _runCommand(List<String> command) async {
    final stopwatch = Stopwatch()..start();
    try {
      final process = await Process.run(command.first, command.sublist(1));
      return _CommandResult(
        exitCode: process.exitCode,
        duration: stopwatch.elapsed,
      );
    } catch (_) {
      return _CommandResult(exitCode: 1, duration: stopwatch.elapsed);
    }
  }

  Future<double> _extractPercent(String path, RegExp pattern) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final contents = await file.readAsString();
    final match = pattern.firstMatch(contents);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  Future<double> _extractJsonValue(
    String path,
    String field, {
    bool count = false,
  }) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    try {
      final dynamic decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return 0;
      final value = decoded[field];
      if (count) {
        if (value is List) return value.length.toDouble();
        return 0;
      }
      return (value as num?)?.toDouble() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _buildTextSummary(
    _MaintenanceMetrics metrics,
    List<_RerunEvent> reruns,
    double integrity,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('AUTOMATION MAINTENANCE LOOP v2 SUMMARY')
      ..writeln('=====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('RSI: ${metrics.rsi.toStringAsFixed(2)}%')
      ..writeln('FS health: ${metrics.fsHealth.toStringAsFixed(2)}%')
      ..writeln(
        'Telemetry coverage: ${metrics.telemetryCoverage.toStringAsFixed(2)}%',
      )
      ..writeln('Integrity score: ${integrity.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minIntegrityScore.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    if (reruns.isEmpty) {
      buffer.writeln('No reruns were required.');
    } else {
      buffer.writeln('Rerun attempts:');
      for (final rerun in reruns) {
        buffer.writeln(
          '  - ${rerun.name}: exit ${rerun.exitCode} '
          '(${rerun.duration.inSeconds}s) ${rerun.success ? '[OK]' : '[FAIL]'}',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    _MaintenanceMetrics metrics,
    List<_RerunEvent> reruns,
    double integrity,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'metrics': {
        'rsi': metrics.rsi,
        'fs_health': metrics.fsHealth,
        'telemetry_coverage': metrics.telemetryCoverage,
        'telemetry_missing_events': metrics.telemetryMissingCount,
      },
      'integrity_score': integrity,
      'threshold': _minIntegrityScore,
      'reruns': reruns
          .map(
            (rerun) => {
              'name': rerun.name,
              'exit_code': rerun.exitCode,
              'duration_seconds': rerun.duration.inSeconds,
              'success': rerun.success,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    _MaintenanceMetrics metrics,
    double integrity,
    List<_RerunEvent> rerunFailures,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'automation_maintenance_loop_v2_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'rsi': metrics.rsi,
      'fs_health': metrics.fsHealth,
      'telemetry_coverage': metrics.telemetryCoverage,
      'integrity_score': integrity,
      'rerun_failures': rerunFailures.map((rerun) => rerun.name).toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _MaintenanceMetrics {
  const _MaintenanceMetrics({
    required this.rsi,
    required this.fsHealth,
    required this.telemetryCoverage,
    required this.telemetryMissingCount,
  });

  final double rsi;
  final double fsHealth;
  final double telemetryCoverage;
  final double telemetryMissingCount;
}

class _RerunTarget {
  const _RerunTarget({
    required this.name,
    required this.command,
    required this.summaryPath,
  });

  final String name;
  final List<String> command;
  final String summaryPath;
}

class _RerunEvent {
  const _RerunEvent({
    required this.name,
    required this.exitCode,
    required this.duration,
    required this.success,
  });

  final String name;
  final int exitCode;
  final Duration duration;
  final bool success;
}

class _CommandResult {
  const _CommandResult({required this.exitCode, required this.duration});

  final int exitCode;
  final Duration duration;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
