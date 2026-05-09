import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now();
  final steps = <_Runner>[
    _Runner(
      label: 'pack_validation',
      command: ['dart', 'run', 'tools/pack_validation_cli.dart'],
    ),
    _Runner(
      label: 'regression_qa',
      command: ['dart', 'run', 'tools/regression_qa_dashboard.dart'],
    ),
    _Runner(
      label: 'generate_export',
      command: ['dart', 'run', 'tools/generate_and_export_packs.dart'],
    ),
    _Runner(
      label: 'generate_index',
      command: ['dart', 'run', 'tool/generate_packs_index.dart'],
    ),
  ];

  final results = <_StepResult>[];
  var failed = 0;

  for (final step in steps) {
    final result = await step.run();
    results.add(result);
    if (!result.success) {
      failed += 1;
    }
  }

  final end = DateTime.now();
  final buffer = StringBuffer()
    ..writeln('=== POKER ANALYZER RELEASE SUMMARY ===')
    ..writeln('Generated: ${end.toUtc().toIso8601String()}')
    ..writeln('');

  for (final result in results) {
    final status = result.success ? 'PASS' : 'FAIL';
    buffer
      ..writeln('--- ${result.label.toUpperCase()} ---')
      ..writeln('Status: $status')
      ..writeln('Duration: ${result.duration.inSeconds}s')
      ..writeln(
        result.output.trim().isEmpty
            ? 'Output: (no output)'
            : 'Output:\n${result.output.trim()}',
      )
      ..writeln('');
  }

  final reportDir = Directory('release/_reports');
  await reportDir.create(recursive: true);
  final reportFile = File('${reportDir.path}/release_summary.txt');
  await reportFile.writeAsString(buffer.toString());

  final telemetry = jsonEncode({
    'event': 'release_packager_completed',
    'total_steps': steps.length,
    'failed': failed,
    'duration_sec': end.difference(start).inSeconds,
    'failed_steps': results
        .where((r) => !r.success)
        .map((r) => r.label)
        .toList(),
    'timestamp': end.toUtc().toIso8601String(),
  });
  stdout.writeln(telemetry);

  if (failed > 0) {
    exitCode = 1;
  }
}

class _Runner {
  const _Runner({required this.label, required this.command});

  final String label;
  final List<String> command;

  Future<_StepResult> run() async {
    final stopwatch = Stopwatch()..start();
    final process = await Process.start(
      command.first,
      command.sublist(1),
      runInShell: false,
      environment: Platform.environment,
    );

    final buffer = StringBuffer();
    final stdoutSub = process.stdout
        .transform(utf8.decoder)
        .listen(buffer.write);
    final stderrSub = process.stderr
        .transform(utf8.decoder)
        .listen(buffer.write);

    final exitCode = await process.exitCode;
    await stdoutSub.cancel();
    await stderrSub.cancel();
    stopwatch.stop();

    return _StepResult(
      label: label,
      success: exitCode == 0,
      output: buffer.toString(),
      duration: stopwatch.elapsed,
    );
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
