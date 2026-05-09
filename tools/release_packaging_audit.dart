import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final reportsDir = Directory('release/_reports');
  if (!reportsDir.existsSync()) {
    stderr.writeln('Missing release/_reports directory.');
    exit(1);
  }
  final audit = _ReleasePackagingAudit();
  final report = await audit.run();
  report.printSummary();
  await report.writeReport('release/_reports/release_packaging_summary.txt');
  report.emitTelemetry();
  if (!report.success) {
    exitCode = 1;
  }
}

class _ReleasePackagingAudit {
  static final List<_StepConfig> _steps = <_StepConfig>[
    _StepConfig(
      label: 'Pack Validation',
      command: <String>['dart', 'run', 'tools/pack_validation_cli.dart'],
    ),
    _StepConfig(
      label: 'Launch Readiness',
      command: <String>['dart', 'run', 'tools/launch_readiness_audit.dart'],
    ),
    _StepConfig(
      label: 'Telemetry Schema',
      command: <String>['dart', 'run', 'tools/telemetry_schema_validator.dart'],
    ),
    _StepConfig(
      label: 'Stability Audit',
      command: <String>['dart', 'run', 'tools/stability_scaling_audit.dart'],
    ),
  ];

  Future<_PackagingReport> run() async {
    final results = <_StepResult>[];
    var hardFailure = false;

    for (final step in _steps) {
      final result = await _run(step);
      results.add(result);
      if (!result.success) {
        hardFailure = true;
        break;
      }
    }

    return _PackagingReport(results: results, success: !hardFailure);
  }

  Future<_StepResult> _run(_StepConfig step) async {
    final timer = Stopwatch()..start();
    ProcessResult process;
    try {
      process = await Process.run(
        step.command.first,
        step.command.skip(1).toList(),
      );
    } catch (error) {
      process = ProcessResult(0, 1, '', 'Command error: $error');
    }
    timer.stop();
    final success = process.exitCode == 0;
    return _StepResult(
      label: step.label,
      command: step.command.join(' '),
      success: success,
      duration: timer.elapsed,
      stdout: process.stdout.toString(),
      stderr: process.stderr.toString(),
    );
  }
}

class _PackagingReport {
  _PackagingReport({required this.results, required this.success});

  final List<_StepResult> results;
  final bool success;

  int get warningCount => results.where((result) => !result.success).length;

  Map<String, int> get durations => Map<String, int>.fromEntries(
    results.map(
      (result) => MapEntry(result.label, result.duration.inMilliseconds),
    ),
  );

  Future<void> writeReport(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Release Packaging Summary')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('Overall: ${success ? 'PASS' : 'FAIL'}')
      ..writeln();
    for (final result in results) {
      final status = result.success ? 'PASS' : 'FAIL';
      buffer.writeln(
        '- ${result.label}: $status (${_fmtDuration(result.duration)})',
      );
      if (!result.success && result.stderr.trim().isNotEmpty) {
        buffer.writeln('  stderr: ${result.stderr.trim().split('\n').first}');
      }
    }
    await file.writeAsString(buffer.toString());
  }

  void printSummary() {
    const border = '+--------------------+--------+----------+';
    stdout.writeln(border);
    stdout.writeln('| Step               | Status | Duration |');
    stdout.writeln(border);
    for (final result in results) {
      final status = result.success ? 'PASS' : 'FAIL';
      stdout.writeln(
        '| ${result.label.padRight(18)} | '
        '${status.padRight(6)} | '
        '${_fmtDuration(result.duration).padLeft(8)} |',
      );
    }
    stdout.writeln(border);
    stdout.writeln('Overall: ${success ? 'PASS' : 'FAIL'}');
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': TelemetryEvents.releasePackagingCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'success': success,
      'warning_count': warningCount,
      'durations_ms': durations,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _StepConfig {
  const _StepConfig({required this.label, required this.command});

  final String label;
  final List<String> command;
}

class _StepResult {
  _StepResult({
    required this.label,
    required this.command,
    required this.success,
    required this.duration,
    required this.stdout,
    required this.stderr,
  });

  final String label;
  final String command;
  final bool success;
  final Duration duration;
  final String stdout;
  final String stderr;
}

String _fmtDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${minutes}m${seconds}s';
}
