import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _green = '\u001b[32m';
const _red = '\u001b[31m';
const _yellow = '\u001b[33m';
const _reset = '\u001b[0m';

Future<void> main(List<String> args) async {
  final start = DateTime.now();
  final steps = <_StepResult>[];

  steps.add(
    await _runStep(
      label: 'FORMAT',
      executable: 'dart',
      arguments: ['format', '--set-exit-if-changed', '.'],
    ),
  );

  steps.add(
    await _runStep(
      label: 'ANALYZE',
      executable: 'dart',
      arguments: ['analyze'],
    ),
  );

  steps.add(
    await _runStep(
      label: 'PACKS',
      executable: 'dart',
      arguments: ['run', 'tools/pack_validation_cli.dart'],
    ),
  );

  steps.add(
    await _runStep(
      label: 'TESTS',
      executable: 'dart',
      arguments: ['test'],
      timeout: const Duration(minutes: 10),
    ),
  );

  stdout.writeln('');
  stdout.writeln('Regression QA Summary');
  stdout.writeln('----------------------');

  for (final step in steps) {
    final statusColor = step.success ? _green : _red;
    final statusIcon = step.success ? '✅' : '❌';
    stdout.writeln(
      '$statusColor${step.label.padRight(8)} $statusIcon$_reset ${step.duration.inSeconds}s',
    );
    if (step.output.trim().isNotEmpty) {
      final safeOutput = step.output.trimRight();
      stdout.writeln('$_yellow--- ${step.label} output ---$_reset');
      stdout.writeln(safeOutput);
      stdout.writeln('$_yellow--- end ---$_reset');
    }
  }

  final passed = steps.where((s) => s.success).length;
  final failed = steps.length - passed;
  final end = DateTime.now();
  final totalDuration = end.difference(start).inSeconds;

  final telemetry = jsonEncode({
    'event': 'regression_qa_completed',
    'total_steps': steps.length,
    'passed': passed,
    'failed': failed,
    'duration_sec': totalDuration,
    'timestamp': end.toUtc().toIso8601String(),
  });
  stdout.writeln(telemetry);

  if (failed > 0) {
    exitCode = 1;
  }
}

class _StepResult {
  const _StepResult({
    required this.label,
    required this.success,
    required this.output,
    required this.duration,
  });

  final String label;
  final bool success;
  final String output;
  final Duration duration;
}

Future<_StepResult> _runStep({
  required String label,
  required String executable,
  required List<String> arguments,
  Duration? timeout,
}) async {
  final buffer = StringBuffer();
  final stopwatch = Stopwatch()..start();
  final process = await Process.start(
    executable,
    arguments,
    runInShell: false,
    environment: Platform.environment,
  );

  final stdoutFuture = process.stdout
      .transform(utf8.decoder)
      .listen(buffer.write);
  final stderrFuture = process.stderr
      .transform(utf8.decoder)
      .listen(buffer.write);

  Future<int> waitExit = process.exitCode;
  if (timeout != null) {
    waitExit = _withTimeout(process, timeout, buffer);
  }

  final exitCode = await waitExit;
  await stdoutFuture.cancel();
  await stderrFuture.cancel();
  stopwatch.stop();

  return _StepResult(
    label: label,
    success: exitCode == 0,
    output: buffer.toString(),
    duration: stopwatch.elapsed,
  );
}

Future<int> _withTimeout(
  Process process,
  Duration timeout,
  StringBuffer buffer,
) async {
  final completer = Completer<int>();
  Timer? timer;
  timer = Timer(timeout, () async {
    if (completer.isCompleted) {
      return;
    }
    buffer.writeln(
      'Process timed out after ${timeout.inSeconds}s. Killing process.',
    );
    process.kill(ProcessSignal.sigkill);
    completer.complete(1);
  });

  process.exitCode.then((code) {
    if (!completer.isCompleted) {
      timer?.cancel();
      completer.complete(code);
    }
  });

  return completer.future;
}
