import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

class PersonalizationArtifactCheckResult {
  const PersonalizationArtifactCheckResult({
    required this.success,
    required this.artifactPath,
    required this.message,
  });

  final bool success;
  final String artifactPath;
  final String message;
}

/// Release artifact used by the home UI personalization hint.
PersonalizationArtifactCheckResult checkPersonalizationArtifact(
  Directory reportsDir,
) {
  final artifactPath = '${reportsDir.path}/personalization_next_action.jsonl';
  final artifact = File(artifactPath);
  final exists = artifact.existsSync();
  final message = exists
      ? 'personalization_next_action.jsonl present at $artifactPath'
      : 'personalization_next_action.jsonl missing at $artifactPath';
  return PersonalizationArtifactCheckResult(
    success: exists,
    artifactPath: artifactPath,
    message: message,
  );
}

Future<void> main(List<String> args) async {
  final reportsDir = Directory('release/_reports');
  if (!reportsDir.existsSync()) {
    stderr.writeln('Missing release/_reports directory.');
    exit(1);
  }

  final preparer = _PublicReleasePreparer();
  final report = await preparer.run();
  report.printSummary();
  await report.writeSummary('release/_reports/public_release_summary.txt');
  report.emitTelemetry();
  if (!report.success) {
    exitCode = 1;
  }
}

class _PublicReleasePreparer {
  static final List<_StepConfig> _steps = <_StepConfig>[
    _StepConfig(
      label: 'Final Stakeholder Sweep',
      command: <String>['dart', 'run', 'tools/final_stakeholder_sweep.dart'],
      requiredReport: 'release/_reports/final_stakeholder_summary.txt',
    ),
    _StepConfig(
      label: 'Marketing Analytics',
      command: <String>[
        'dart',
        'run',
        'tools/marketing_analytics_aggregator.dart',
      ],
      requiredReport: 'release/_reports/marketing_analytics_summary.txt',
    ),
    _StepConfig(
      label: 'Visual Polish Validator',
      command: <String>['dart', 'run', 'tools/visual_polish_sweep.dart'],
      requiredReport: 'release/_reports/ux_polish_sweep.txt',
    ),
    _StepConfig(
      label: 'Release Packaging Audit',
      command: <String>['dart', 'run', 'tools/release_packaging_audit.dart'],
      requiredReport: 'release/_reports/release_packaging_summary.txt',
    ),
  ];

  Future<_ReleaseReport> run() async {
    final steps = <_StepResult>[];
    var success = true;
    for (final step in _steps) {
      final result = await _run(step);
      steps.add(result);
      if (!result.success) {
        success = false;
        break;
      }
    }
    final artifactCheck = _checkPersonalizationArtifact(
      Directory('release/_reports'),
    );
    steps.add(artifactCheck);
    if (!artifactCheck.success) {
      success = false;
    }
    return _ReleaseReport(results: steps, success: success);
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
    var success = process.exitCode == 0;
    String? failureNote;
    if (success && step.requiredReport != null) {
      final reportFile = File(step.requiredReport!);
      if (!reportFile.existsSync()) {
        success = false;
        failureNote = 'Missing report: ${step.requiredReport}';
      }
    }
    return _StepResult(
      label: step.label,
      command: step.command.join(' '),
      success: success,
      duration: timer.elapsed,
      stdout: process.stdout.toString(),
      stderr: process.stderr.toString(),
      failureNote: failureNote,
    );
  }

  _StepResult _checkPersonalizationArtifact(Directory reportsDir) {
    final artifactResult = checkPersonalizationArtifact(reportsDir);
    return _StepResult(
      label: 'Personalization next action',
      command: '(artifact check)',
      success: artifactResult.success,
      duration: Duration.zero,
      stdout: artifactResult.success ? 'artifact present' : '',
      stderr: artifactResult.success ? '' : artifactResult.message,
      failureNote: (artifactResult.success) ? null : artifactResult.message,
    );
  }
}

class _ReleaseReport {
  _ReleaseReport({required this.results, required this.success});

  final List<_StepResult> results;
  final bool success;

  int get warningCount => results.where((result) => !result.success).length;

  Map<String, int> get durations => Map<String, int>.fromEntries(
    results.map(
      (result) => MapEntry(result.label, result.duration.inMilliseconds),
    ),
  );

  void printSummary() {
    const border = '+---------------------------+--------+----------+';
    stdout.writeln(border);
    stdout.writeln('| Step                      | Status | Duration |');
    stdout.writeln(border);
    for (final result in results) {
      final status = result.success ? 'PASS' : 'FAIL';
      stdout.writeln(
        '| ${result.label.padRight(25)} | '
        '${status.padRight(6)} | '
        '${_fmtDuration(result.duration).padLeft(8)} |',
      );
    }
    stdout.writeln(border);
    stdout.writeln('Overall: ${success ? 'PASS' : 'FAIL'}');
  }

  Future<void> writeSummary(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Public Release Summary')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('Overall: ${success ? 'PASS' : 'FAIL'}')
      ..writeln();
    for (final result in results) {
      final status = result.success ? 'PASS' : 'FAIL';
      buffer.writeln(
        '- ${result.label}: $status (${_fmtDuration(result.duration)})',
      );
      if (result.failureNote != null) {
        buffer.writeln('  note: ${result.failureNote}');
      } else if (!result.success && result.stderr.trim().isNotEmpty) {
        buffer.writeln('  stderr: ${result.stderr.trim().split('\n').first}');
      }
    }
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': TelemetryEvents.publicReleaseCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'success': success,
      'warning_count': warningCount,
      'durations_ms': durations,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _StepConfig {
  const _StepConfig({
    required this.label,
    required this.command,
    this.requiredReport,
  });

  final String label;
  final List<String> command;
  final String? requiredReport;
}

class _StepResult {
  _StepResult({
    required this.label,
    required this.command,
    required this.success,
    required this.duration,
    required this.stdout,
    required this.stderr,
    this.failureNote,
  });

  final String label;
  final String command;
  final bool success;
  final Duration duration;
  final String stdout;
  final String stderr;
  final String? failureNote;
}

String _fmtDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${minutes}m${seconds}s';
}
