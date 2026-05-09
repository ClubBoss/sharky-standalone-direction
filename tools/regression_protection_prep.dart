import 'dart:convert';
import 'dart:io';

const String _summaryPath =
    'release/_reports/regression_protection_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const List<_ToolSpec> _tools = [
  _ToolSpec(
    'content_evolution_refactor',
    'tools/content_evolution_refactor.dart',
  ),
  _ToolSpec('adaptive_drill_balancer', 'tools/adaptive_drill_balancer.dart'),
  _ToolSpec('adaptive_quiz_composer', 'tools/adaptive_quiz_composer.dart'),
  _ToolSpec('adaptive_recap_generator', 'tools/adaptive_recap_generator.dart'),
];
const List<String> _expectedReports = [
  'release/_reports/content_evolution_summary.txt',
  'release/_reports/adaptive_drill_balance_summary.txt',
  'release/_reports/adaptive_quiz_summary.txt',
  'release/_reports/adaptive_recap_summary.txt',
];
const List<String> _expectedPreviewDirs = ['content_adaptive_preview'];

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final results = <_ToolResult>[];
  var hasFailure = false;

  for (final tool in _tools) {
    final result = await _runTool(tool);
    results.add(result);
    if (!result.success) {
      hasFailure = true;
    }
  }

  final missingReports = _expectedReports
      .where((path) => !File(path).existsSync())
      .toList();
  final missingDirs = _expectedPreviewDirs
      .where((dir) => !Directory(dir).existsSync())
      .toList();

  if (missingReports.isNotEmpty) {
    hasFailure = true;
  }
  if (missingDirs.isNotEmpty) {
    hasFailure = true;
  }

  final index = (results.where((r) => r.success).length / _tools.length) * 100;
  final verdict = _verdict(index);

  await _withReportsWritable(() async {
    await _writeSummary(
      results: results,
      missingReports: missingReports,
      missingDirs: missingDirs,
      index: index,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _appendTelemetry(
      index: index,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  if (hasFailure) {
    stderr.writeln(
      'regression_protection_prep: failure detected (verdict=$verdict)',
    );
    exitCode = 1;
  } else {
    stdout.writeln(
      'regression_protection_prep: completed (verdict=$verdict index=${index.toStringAsFixed(1)}%)',
    );
  }
}

Future<_ToolResult> _runTool(_ToolSpec spec) async {
  final executable = spec.path.endsWith('.dart')
      ? ['dart', 'run', spec.path]
      : spec.path.split(' ');
  final process = await Process.run(executable.first, executable.sublist(1));

  final success = process.exitCode == 0;
  return _ToolResult(
    name: spec.name,
    success: success,
    stdout: process.stdout.toString(),
    stderr: process.stderr.toString(),
  );
}

Future<void> _writeSummary({
  required List<_ToolResult> results,
  required List<String> missingReports,
  required List<String> missingDirs,
  required double index,
  required String verdict,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION PROTECTION SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Regression Health Index: ${index.toStringAsFixed(1)}% ($verdict)',
    )
    ..writeln('Duration: ${durationMs}ms')
    ..writeln();

  for (final result in results) {
    buffer.writeln(
      'Tool: ${result.name} → ${result.success ? 'PASS' : 'FAIL'} '
      '(${result.success ? 0 : 1} errors)',
    );
    if (!result.success) {
      buffer
        ..writeln('  stderr: ${result.stderr.trim()}')
        ..writeln('  stdout: ${result.stdout.trim()}');
    }
  }

  if (missingReports.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Missing reports:')
      ..writeln(missingReports.join('\n'));
  }

  if (missingDirs.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Missing preview directories:')
      ..writeln(missingDirs.join('\n'));
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double index,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_protection_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'index': double.parse(index.toStringAsFixed(1)),
    'verdict': verdict,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _verdict(double index) {
  if (index >= 96) return 'PASS';
  if (index >= 80) return 'WARN';
  return 'FAIL';
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'regression_protection_prep: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ToolSpec {
  const _ToolSpec(this.name, this.path);

  final String name;
  final String path;
}

class _ToolResult {
  const _ToolResult({
    required this.name,
    required this.success,
    required this.stdout,
    required this.stderr,
  });

  final String name;
  final bool success;
  final String stdout;
  final String stderr;
}
