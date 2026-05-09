import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final tasks = <_Task>[
    _Task(label: 'dart analyze', command: ['dart', 'analyze']),
    _Task(label: 'dart test', command: ['dart', 'test', '--concurrency=2']),
    _Task(
      label: 'pack_validation_cli',
      command: ['dart', 'run', 'tools/pack_validation_cli.dart'],
    ),
    _Task(
      label: 'release_packager',
      command: ['dart', 'run', 'tools/release_packager.dart'],
    ),
  ];

  final metrics = await Future.wait(tasks.map(_runTask));

  final totalParallelDuration = metrics
      .map((m) => m.duration)
      .reduce((a, b) => a > b ? a : b);
  final sequentialDuration = metrics
      .map((m) => m.duration)
      .fold<Duration>(Duration.zero, (a, b) => a + b);

  final reportDir = Directory('release/_reports');
  await reportDir.create(recursive: true);

  final reportFile = File('${reportDir.path}/parallel_ci_profile.txt');
  await reportFile.writeAsString(
    _buildReport(
      metrics: metrics,
      parallelDuration: totalParallelDuration,
      sequentialDuration: sequentialDuration,
      generatedAt: DateTime.now().toUtc(),
    ),
  );

  stdout.writeln(
    jsonEncode({
      'event': 'parallel_ci_profile_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'tasks': tasks.length,
      'parallel_duration_ms': totalParallelDuration.inMilliseconds,
      'sequential_duration_ms': sequentialDuration.inMilliseconds,
    }),
  );
}

Future<_Metric> _runTask(_Task task) async {
  final stopwatch = Stopwatch()..start();
  final process = await Process.start(
    task.command.first,
    task.command.sublist(1),
    runInShell: false,
  );

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  final stdoutFuture = process.stdout
      .transform(utf8.decoder)
      .forEach(stdoutBuffer.write);
  final stderrFuture = process.stderr
      .transform(utf8.decoder)
      .forEach(stderrBuffer.write);

  final exitCode = await process.exitCode;
  await Future.wait([stdoutFuture, stderrFuture]);
  stopwatch.stop();

  if (stdoutBuffer.isNotEmpty) {
    stdout.writeln(stdoutBuffer.toString());
  }
  if (stderrBuffer.isNotEmpty) {
    stderr.writeln(stderrBuffer.toString());
  }

  return _Metric(task: task, duration: stopwatch.elapsed, exitCode: exitCode);
}

String _buildReport({
  required List<_Metric> metrics,
  required Duration parallelDuration,
  required Duration sequentialDuration,
  required DateTime generatedAt,
}) {
  final buffer = StringBuffer()
    ..writeln('=== PARALLEL CI PROFILE ===')
    ..writeln('Generated: ${generatedAt.toIso8601String()}')
    ..writeln('Parallel Duration: ${parallelDuration.inSeconds}s')
    ..writeln('Sequential Duration: ${sequentialDuration.inSeconds}s')
    ..writeln(
      'Speedup: ${_formatSpeedup(parallelDuration, sequentialDuration)}x',
    )
    ..writeln()
    ..writeln('Task Details:');

  final maxLabelWidth = metrics
      .map((m) => m.task.label.length)
      .fold<int>(0, (a, b) => a > b ? a : b);
  final maxDuration = metrics
      .map((m) => m.duration)
      .reduce((a, b) => a > b ? a : b)
      .inMilliseconds;

  for (final metric in metrics) {
    final barLength = ((metric.duration.inMilliseconds / maxDuration) * 40)
        .clamp(1, 40)
        .round();
    final label = metric.task.label.padRight(maxLabelWidth);
    buffer.writeln(
      '$label | ${'#' * barLength} '
      '(${metric.duration.inSeconds}s, exit ${metric.exitCode})',
    );
  }

  return buffer.toString();
}

String _formatSpeedup(Duration parallel, Duration sequential) {
  if (parallel.inMilliseconds == 0) {
    return 'N/A';
  }
  final ratio = sequential.inMilliseconds / parallel.inMilliseconds;
  return ratio.toStringAsFixed(2);
}

class _Task {
  const _Task({required this.label, required this.command});

  final String label;
  final List<String> command;
}

class _Metric {
  const _Metric({
    required this.task,
    required this.duration,
    required this.exitCode,
  });

  final _Task task;
  final Duration duration;
  final int exitCode;
}
