import 'dart:io';

class _QaStep {
  const _QaStep({
    required this.label,
    required this.command,
    required this.args,
  });

  final String label;
  final String command;
  final List<String> args;
}

class _QaResult {
  const _QaResult({required this.label, required this.exitCode});

  final String label;
  final int exitCode;
}

const List<_QaStep> _kQaSteps = <_QaStep>[
  _QaStep(
    label: 'validate_world_content_v1',
    command: 'dart',
    args: <String>['run', 'tools/validate_world_content_v1.dart'],
  ),
  _QaStep(
    label: 'audit_worlds_0_4_scoreboard_v1',
    command: 'dart',
    args: <String>['run', 'tools/audit_worlds_0_4_scoreboard_v1.dart'],
  ),
  _QaStep(
    label: 'audit_worlds_0_4_progression_v1',
    command: 'dart',
    args: <String>['run', 'tools/audit_worlds_0_4_progression_v1.dart'],
  ),
  _QaStep(
    label: 'audit_worlds_0_4_telemetry_v1',
    command: 'dart',
    args: <String>['run', 'tools/audit_worlds_0_4_telemetry_v1.dart'],
  ),
  _QaStep(
    label: 'audit_worlds_0_4_session_chain_v1',
    command: 'dart',
    args: <String>['run', 'tools/audit_worlds_0_4_session_chain_v1.dart'],
  ),
];

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln(
      'run_content_qa_r2_v1: no arguments supported (deterministic default suite only)',
    );
    stderr.writeln('usage: dart run tools/run_content_qa_r2_v1.dart');
    exitCode = 64;
    return;
  }

  final results = <_QaResult>[];
  for (final step in _kQaSteps) {
    stdout.writeln('run_content_qa_r2_v1: RUN ${step.label}');
    final result = Process.runSync(step.command, step.args);
    if (result.stdout is String && (result.stdout as String).isNotEmpty) {
      stdout.write(result.stdout as String);
    }
    if (result.stderr is String && (result.stderr as String).isNotEmpty) {
      stderr.write(result.stderr as String);
    }

    final stepResult = _QaResult(label: step.label, exitCode: result.exitCode);
    results.add(stepResult);
    stdout.writeln(
      'run_content_qa_r2_v1: ${result.exitCode == 0 ? 'OK' : 'FAIL'} ${step.label} exit=${result.exitCode}',
    );
    if (result.exitCode != 0) {
      _printSummary(results);
      exitCode = result.exitCode;
      return;
    }
  }

  _printSummary(results);
  exitCode = 0;
}

void _printSummary(List<_QaResult> results) {
  stdout.writeln('run_content_qa_r2_v1: SUMMARY');
  for (final result in results) {
    stdout.writeln(
      '- ${result.label}: ${result.exitCode == 0 ? 'OK' : 'FAIL(${result.exitCode})'}',
    );
  }
  final hasFailure = results.any((result) => result.exitCode != 0);
  stdout.writeln('run_content_qa_r2_v1: ${hasFailure ? 'FAIL' : 'OK'}');
}
