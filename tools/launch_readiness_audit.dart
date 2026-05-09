import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final clock = Stopwatch()..start();
  final audit = _LaunchReadinessAudit();
  final result = await audit.run();
  result.printSummary();
  await result.writeReport('release/_reports/launch_readiness_summary.txt');
  result.emitTelemetry(clock.elapsed);
  if (!result.passed) {
    exit(1);
  }
}

class _LaunchReadinessAudit {
  static const int _expectedTelemetryEvents = 79;

  Future<_AuditResult> run() async {
    final steps = <_SubStepResult>[];
    var hardFailure = false;
    var warnings = 0;
    for (final step in _subSteps) {
      final result = await _run(step);
      steps.add(result);
      if (!result.success) {
        if (step.hardFail) {
          hardFailure = true;
          break;
        }
        warnings++;
      }
    }
    final telemetryStep = await _validateTelemetryEvents();
    steps.add(telemetryStep);
    if (!telemetryStep.success) {
      warnings++;
    }
    final stats = await _ReportParser().collect();
    if (stats.hasHardFailure) {
      hardFailure = true;
    }
    warnings += stats.warnCount;
    return _AuditResult(
      steps: steps,
      stats: stats,
      hardFailure: hardFailure,
      warnings: warnings,
    );
  }

  final List<_CommandStep> _subSteps = <_CommandStep>[
    _CommandStep(
      label: 'Telemetry Consistency',
      command: <String>[
        'dart',
        'run',
        'tools/telemetry_consistency_check.dart',
      ],
      hardFail: false,
    ),
    _CommandStep(
      label: 'Visual Polish Sweep',
      command: <String>['dart', 'run', 'tools/visual_polish_sweep.dart'],
      hardFail: false,
    ),
    _CommandStep(
      label: 'Pack Validation',
      command: <String>['dart', 'run', 'tools/pack_validation_cli.dart'],
      hardFail: false,
    ),
  ];

  Future<_SubStepResult> _validateTelemetryEvents() async {
    const label = 'Telemetry Registry';
    final timer = Stopwatch()..start();
    try {
      final file = File('release/_reports/telemetry.json');
      if (!file.existsSync()) {
        timer.stop();
        return _SubStepResult(
          label: label,
          success: false,
          stdout: '',
          stderr: 'telemetry.json not found',
          duration: timer.elapsed,
          warning: true,
        );
      }
      final decoded = jsonDecode(await file.readAsString());
      final eventsNode = decoded is Map ? decoded['events'] : null;
      final eventCount = eventsNode is Map ? eventsNode.length : 0;
      timer.stop();
      final success = eventCount == _expectedTelemetryEvents;
      return _SubStepResult(
        label: label,
        success: success,
        stdout: 'found $eventCount events (expected $_expectedTelemetryEvents)',
        stderr: '',
        duration: timer.elapsed,
        warning: !success,
      );
    } catch (error) {
      timer.stop();
      return _SubStepResult(
        label: label,
        success: false,
        stdout: '',
        stderr: 'Telemetry parse error: $error',
        duration: timer.elapsed,
        warning: true,
      );
    }
  }

  Future<_SubStepResult> _run(_CommandStep step) async {
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
    final warning = !success && !step.hardFail;
    return _SubStepResult(
      label: step.label,
      success: success,
      stdout: process.stdout.toString(),
      stderr: process.stderr.toString(),
      duration: timer.elapsed,
      warning: warning,
    );
  }
}

class _AuditResult {
  _AuditResult({
    required this.steps,
    required this.stats,
    required bool hardFailure,
    required this.warnings,
  }) : passed = !hardFailure;

  final List<_SubStepResult> steps;
  final _ReportStats stats;
  final bool passed;
  final int warnings;

  void printSummary() {
    final statusColor = passed ? _Ansi.green : _Ansi.red;
    stdout.writeln(
      '${statusColor}Launch Readiness: ${passed ? 'PASS' : 'FAIL'}${_Ansi.reset}',
    );
    for (final step in steps) {
      final status = step.success
          ? 'ok'
          : step.warning
          ? 'warn'
          : 'failed';
      final color = step.success
          ? _Ansi.green
          : step.warning
          ? _Ansi.yellow
          : _Ansi.red;
      final label = step.label.padRight(24);
      stdout.writeln(
        '$color- $label $status (${_fmtDuration(step.duration)})${_Ansi.reset}',
      );
      if (!step.success && step.stderr.trim().isNotEmpty) {
        stdout.writeln('  stderr: ${step.stderr.trim().split('\n').first}');
      }
    }
    stdout.writeln('');
    stdout.writeln('Report aggregates:');
    stdout.writeln(
      '  pass_rate=${stats.passRate.toStringAsFixed(2)}% '
      'warnings=$warnings '
      'missing_telemetry=${stats.missingTelemetry} '
      'content_errors=${stats.contentErrors} '
      'missing_reports=${stats.missingReports}',
    );
    if (passed && warnings > 0) {
      stdout.writeln('Audit PASS (warnings ignored)');
    }
  }

  Future<void> writeReport(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Launch Readiness Summary')
      ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('Overall: ${passed ? 'PASS' : 'FAIL'}')
      ..writeln('');
    for (final step in steps) {
      final status = step.success
          ? 'PASS'
          : step.warning
          ? 'WARN'
          : 'FAIL';
      buffer.writeln(
        '- ${step.label}: $status (${_fmtDuration(step.duration)})',
      );
    }
    buffer
      ..writeln('')
      ..writeln('Aggregate Metrics:')
      ..writeln('pass_rate=${stats.passRate.toStringAsFixed(2)}%')
      ..writeln('warnings=${stats.warnCount}')
      ..writeln('missing_telemetry=${stats.missingTelemetry}')
      ..writeln('content_errors=${stats.contentErrors}')
      ..writeln('missing_reports=${stats.missingReports}');
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry(Duration duration) {
    final payload = <String, Object>{
      'event': TelemetryEvents.launchReadinessCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'pass_rate': stats.passRate,
      'warnings': warnings,
      'missing_telemetry': stats.missingTelemetry,
      'content_errors': stats.contentErrors,
      'status': passed ? 'pass' : 'fail',
      'success': passed,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _SubStepResult {
  _SubStepResult({
    required this.label,
    required this.success,
    required this.stdout,
    required this.stderr,
    required this.duration,
    this.warning = false,
  });

  final String label;
  final bool success;
  final String stdout;
  final String stderr;
  final Duration duration;
  final bool warning;
}

class _CommandStep {
  const _CommandStep({
    required this.label,
    required this.command,
    required this.hardFail,
  });

  final String label;
  final List<String> command;
  final bool hardFail;
}

class _ReportParser {
  Future<_ReportStats> collect() async {
    final dir = Directory('release/_reports');
    if (!dir.existsSync()) {
      return _ReportStats.empty();
    }
    final stats = _ReportStats.empty();
    final Map<String, bool> required = <String, bool>{
      'visual_integrity': false,
      'localization_content': false,
      'ai_reliability': false,
    };
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final path = entity.path.toLowerCase();
      String? matched;
      required.forEach((key, _) {
        if (matched == null && path.contains(key)) {
          matched = key;
        }
      });
      if (matched == null) continue;
      required[matched!] = true;
      final content = await entity.readAsString();
      stats.add(content);
    }
    for (final entry in required.entries) {
      if (!entry.value) {
        stats.addMissingReport(entry.key);
      }
    }
    return stats;
  }
}

class _ReportStats {
  _ReportStats._();

  factory _ReportStats.empty() => _ReportStats._();

  int passCount = 0;
  int failCount = 0;
  int warnCount = 0;
  int missingTelemetry = 0;
  int contentErrors = 0;
  int missingReports = 0;

  double get passRate {
    final total = passCount + failCount;
    if (total == 0) {
      return 100.0;
    }
    return (passCount / total) * 100;
  }

  bool get hasHardFailure => failCount > 0;

  void add(String raw) {
    final content = raw.toLowerCase();
    passCount += _count(_passPattern, content);
    failCount += _count(_failPattern, content);
    warnCount += _count(_warnPattern, content);
    final telemetryMisses = _count(_missingTelemetryPattern, content);
    final contentIssues =
        _count(_contentErrorPattern, content) +
        _count(_packErrorPattern, content);
    missingTelemetry += telemetryMisses;
    contentErrors += contentIssues;
    warnCount += telemetryMisses + contentIssues;
  }

  void addMissingReport(String key) {
    missingReports++;
    warnCount++;
  }

  static int _count(RegExp pattern, String content) {
    return pattern.allMatches(content).length;
  }
}

String _fmtDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${minutes}m${seconds}s';
}

class _Ansi {
  static const String green = '\x1B[32m';
  static const String red = '\x1B[31m';
  static const String yellow = '\x1B[33m';
  static const String reset = '\x1B[0m';
}

final RegExp _passPattern = RegExp(r'\bpass\b', caseSensitive: false);
final RegExp _failPattern = RegExp(r'\bfail\b', caseSensitive: false);
final RegExp _warnPattern = RegExp(r'\bwarn(?:ing)?s?\b', caseSensitive: false);
final RegExp _missingTelemetryPattern = RegExp(
  r'missing[_\s-]?telemetry|telemetry[_\s-]?mismatch',
  caseSensitive: false,
);
final RegExp _contentErrorPattern = RegExp(
  r'content[_\s-]?(error|fail|issue|missing)',
  caseSensitive: false,
);
final RegExp _packErrorPattern = RegExp(
  r'pack[_\s-]?(error|fail|missing)',
  caseSensitive: false,
);
