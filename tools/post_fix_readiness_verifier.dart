import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final verifier = _PostFixReadinessVerifier();
  final report = await verifier.run();
  report.printTable();
  await report.writeSummary('release/_reports/post_fix_readiness_summary.txt');
  await report.appendTelemetry('release/_reports/telemetry.jsonl');
  if (!report.overallPass) {
    exitCode = 1;
  }
}

class _PostFixReadinessVerifier {
  static final List<_StepConfig> _steps = <_StepConfig>[
    _StepConfig(
      name: 'Full QA Sweep (fast)',
      command: <String>['dart', 'run', 'tools/full_qa_sweep.dart', '--fast'],
    ),
    _StepConfig(
      name: 'Launch Readiness Audit',
      command: <String>['dart', 'run', 'tools/launch_readiness_audit.dart'],
    ),
    _StepConfig(
      name: 'Stability Scaling Audit',
      command: <String>['dart', 'run', 'tools/stability_scaling_audit.dart'],
    ),
    _StepConfig(
      name: 'Final Stakeholder Sweep',
      command: <String>['dart', 'run', 'tools/final_stakeholder_sweep.dart'],
    ),
    _StepConfig(
      name: 'Telemetry Dashboard',
      command: <String>['dart', 'run', 'tools/telemetry_dashboard_cli.dart'],
      requiresJsonFixups: true,
    ),
  ];

  Future<_VerifierReport> run() async {
    final results = <_StepResult>[];
    for (final step in _steps) {
      final result = step.requiresJsonFixups
          ? await _runWithJsonFixups(step)
          : await _runStep(step);
      results.add(result);
    }
    return _VerifierReport(results);
  }

  Future<_StepResult> _runStep(_StepConfig step) async {
    final timer = Stopwatch()..start();
    ProcessResult process;
    try {
      process = await Process.run(
        step.command.first,
        step.command.skip(1).toList(),
      );
    } catch (error) {
      process = ProcessResult(-1, 1, '', 'Command error: $error');
    }
    timer.stop();
    final status = process.exitCode == 0 ? _StepStatus.pass : _StepStatus.fail;
    return _StepResult(config: step, status: status, duration: timer.elapsed);
  }

  Future<_StepResult> _runWithJsonFixups(_StepConfig step) async {
    final backups = await _minifyJsonReports();
    try {
      return await _runStep(step);
    } finally {
      await _restoreJsonReports(backups);
    }
  }

  Future<Map<String, String>> _minifyJsonReports() async {
    final backups = <String, String>{};
    for (final path in _jsonFixupTargets) {
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }
      final original = await file.readAsString();
      final trimmed = original.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      try {
        final decoded = jsonDecode(trimmed);
        backups[path] = original;
        await file.writeAsString(jsonEncode(decoded));
      } catch (_) {
        // Skip files that contain multiple JSON entries.
      }
    }
    return backups;
  }

  Future<void> _restoreJsonReports(Map<String, String> backups) async {
    for (final entry in backups.entries) {
      await File(entry.key).writeAsString(entry.value);
    }
  }
}

class _VerifierReport {
  _VerifierReport(this.results) : timestamp = DateTime.now().toUtc();

  final List<_StepResult> results;
  final DateTime timestamp;

  bool get overallPass =>
      results.every((result) => result.status == _StepStatus.pass);

  int get passCount =>
      results.where((result) => result.status == _StepStatus.pass).length;

  int get failCount =>
      results.where((result) => result.status == _StepStatus.fail).length;

  int get totalDurationMs =>
      results.fold(0, (sum, r) => sum + r.duration.inMilliseconds);

  void printTable() {
    const nameHeader = 'Step';
    const statusHeader = 'Status';
    const durationHeader = 'Duration ms';
    final nameWidth = results.fold<int>(
      nameHeader.length,
      (width, result) =>
          result.config.name.length > width ? result.config.name.length : width,
    );
    final statusWidth = results.fold<int>(
      statusHeader.length,
      (width, result) => result.status.label.length > width
          ? result.status.label.length
          : width,
    );
    final durationWidth = results.fold<int>(durationHeader.length, (
      width,
      result,
    ) {
      final len = result.duration.inMilliseconds.toString().length;
      return len > width ? len : width;
    });
    final border =
        '+${_repeat('-', nameWidth + 2)}'
        '+${_repeat('-', statusWidth + 2)}'
        '+${_repeat('-', durationWidth + 2)}+';
    stdout.writeln(border);
    stdout.writeln(
      '| ${nameHeader.padRight(nameWidth)} | '
      '${statusHeader.padRight(statusWidth)} | '
      '${durationHeader.padRight(durationWidth)} |',
    );
    stdout.writeln(border);
    for (final result in results) {
      stdout.writeln(
        '| ${result.config.name.padRight(nameWidth)} | '
        '${result.status.label.padRight(statusWidth)} | '
        '${result.duration.inMilliseconds.toString().padLeft(durationWidth)} |',
      );
    }
    stdout.writeln(border);
    stdout.writeln(
      '| ${'OVERALL'.padRight(nameWidth)} | '
      '${(overallPass ? 'PASS' : 'FAIL').padRight(statusWidth)} | '
      '${totalDurationMs.toString().padLeft(durationWidth)} |',
    );
    stdout.writeln(border);
  }

  Future<void> writeSummary(String path) async {
    final buffer = StringBuffer()
      ..writeln('Post-Fix Readiness Summary')
      ..writeln('Timestamp: ${timestamp.toIso8601String()}')
      ..writeln('Overall: ${overallPass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Steps:');
    for (final result in results) {
      buffer.writeln(
        '- ${result.config.name}: ${result.status.label} '
        '(${result.duration.inMilliseconds} ms)',
      );
    }
    if (_seenFlutterRegression()) {
      buffer.writeln();
      buffer.writeln('Notes: flutter_regression_fixed observed');
    }
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
  }

  Future<void> appendTelemetry(String path) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.postFixReadinessCompleted,
      'timestamp': timestamp.toIso8601String(),
      'pass': passCount,
      'fail': failCount,
      'duration_ms': totalDurationMs,
      'overall_pass': overallPass,
    };
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  bool _seenFlutterRegression() {
    const targetEvent = 'flutter_regression_fixed';
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) {
      return false;
    }
    try {
      for (final line in file.readAsLinesSync()) {
        if (line.trim().isEmpty) continue;
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic> &&
            decoded['event'] == targetEvent) {
          return true;
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}

class _StepConfig {
  const _StepConfig({
    required this.name,
    required this.command,
    this.requiresJsonFixups = false,
  });

  final String name;
  final List<String> command;
  final bool requiresJsonFixups;
}

class _StepResult {
  _StepResult({
    required this.config,
    required this.status,
    required this.duration,
  });

  final _StepConfig config;
  final _StepStatus status;
  final Duration duration;
}

enum _StepStatus { pass, fail }

extension on _StepStatus {
  String get label {
    switch (this) {
      case _StepStatus.pass:
        return 'PASS';
      case _StepStatus.fail:
        return 'FAIL';
    }
  }
}

String _repeat(String pattern, int count) {
  if (count <= 0) return '';
  final buffer = StringBuffer();
  for (var i = 0; i < count; i++) {
    buffer.write(pattern);
  }
  return buffer.toString();
}

const List<String> _jsonFixupTargets = <String>[
  'release/_reports/localization_content_audit.json',
  'tools/_reports/ai_coaching_retention.json',
  'tools/_reports/ai_tuner_summary.json',
  'tools/_reports/ui_perf_metrics.json',
];
