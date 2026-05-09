import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now().toUtc();
  final steps = <_Step>[
    _Step(
      label: 'Pack Validation',
      command: ['dart', 'run', 'tools/pack_validation_cli.dart'],
    ),
    _Step(
      label: 'Regression QA Dashboard',
      command: ['dart', 'run', 'tools/regression_qa_dashboard.dart'],
    ),
    _Step(
      label: 'Release Packager',
      command: ['dart', 'run', 'tools/release_packager.dart'],
    ),
    _Step(
      label: 'Mobile Build (Android)',
      command: [
        'dart',
        'run',
        'tools/mobile_build_configurator.dart',
        '--platform=android',
      ],
    ),
    _Step(
      label: 'Auto Patch Builder',
      command: ['dart', 'run', 'tools/auto_patch_builder.dart'],
    ),
  ];

  final results = <_StepResult>[];
  var overallSuccess = true;

  for (final step in steps) {
    final result = await _runStep(step);
    results.add(result);
    if (!result.success) {
      overallSuccess = false;
      break;
    }
  }

  await _writeReport(results, start);
  final summary = jsonEncode({
    'event': 'continuous_delivery_completed',
    'duration_ms': DateTime.now().toUtc().difference(start).inMilliseconds,
    'steps_total': steps.length,
    'steps_completed': results.length,
    'steps_successful': results.where((result) => result.success).length,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });
  stdout.writeln(summary);

  if (!overallSuccess) {
    exit(1);
  }
}

Future<_StepResult> _runStep(_Step step) async {
  final begin = DateTime.now().toUtc();
  stdout.writeln('Running ${step.label}...');
  final process = await Process.run(
    step.command.first,
    step.command.sublist(1),
    runInShell: false,
  );
  final end = DateTime.now().toUtc();

  if (process.stdout is String && (process.stdout as String).isNotEmpty) {
    stdout.write(process.stdout);
  }
  if (process.stderr is String && (process.stderr as String).isNotEmpty) {
    stderr.write(process.stderr);
  }

  final success = process.exitCode == 0;
  stdout.writeln('${step.label} ${success ? 'PASSED' : 'FAILED'}');
  return _StepResult(
    step: step,
    success: success,
    exitCode: process.exitCode,
    duration: end.difference(begin),
  );
}

Future<void> _writeReport(List<_StepResult> results, DateTime start) async {
  final reportDir = Directory('release/_reports');
  await reportDir.create(recursive: true);

  final buffer = StringBuffer()
    ..writeln('=== CONTINUOUS DELIVERY REPORT ===')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln(
      'Total Duration: '
      '${DateTime.now().toUtc().difference(start).inSeconds} seconds',
    )
    ..writeln();

  for (final result in results) {
    final status = result.success ? 'PASS ✅' : 'FAIL ❌';
    buffer.writeln(
      '${result.step.label} -> $status | '
      'Exit: ${result.exitCode} | '
      'Duration: ${result.duration.inSeconds}s',
    );
  }

  final reportFile = File('${reportDir.path}/continuous_delivery_report.txt');
  await reportFile.writeAsString(buffer.toString());
}

class _Step {
  const _Step({required this.label, required this.command});

  final String label;
  final List<String> command;
}

class _StepResult {
  const _StepResult({
    required this.step,
    required this.success,
    required this.exitCode,
    required this.duration,
  });

  final _Step step;
  final bool success;
  final int exitCode;
  final Duration duration;
}
