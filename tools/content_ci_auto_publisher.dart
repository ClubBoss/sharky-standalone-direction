import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final summary = _PublisherSummary();

  try {
    final validation = await _runStep(
      name: 'validate_content',
      executable: 'dart',
      arguments: ['run', 'tools/content_validator.dart'],
    );
    summary.validationExitCode = validation.exitCode;
    summary.validationStdout = validation.stdout;
    summary.validationStderr = validation.stderr;
    if (validation.exitCode != 0) {
      summary.failures.add('Content validation failed');
      await summary.write();
      exitCode = 1;
      return;
    }

    final export = await _runStep(
      name: 'export_packs',
      executable: 'dart',
      arguments: ['run', 'tools/content_evolution_pipeline.dart', '--export'],
    );
    summary.exportExitCode = export.exitCode;
    summary.exportStdout = export.stdout;
    summary.exportStderr = export.stderr;
    if (export.exitCode != 0) {
      summary.failures.add('Pack export failed');
      await summary.write();
      exitCode = 1;
      return;
    }

    final index = await _runStep(
      name: 'generate_index',
      executable: 'dart',
      arguments: ['run', 'tools/content_evolution_pipeline.dart', '--index'],
    );
    summary.indexExitCode = index.exitCode;
    summary.indexStdout = index.stdout;
    summary.indexStderr = index.stderr;
    if (index.exitCode != 0) {
      summary.failures.add('Index generation failed');
      await summary.write();
      exitCode = 1;
      return;
    }

    summary.status = 'pass';
    summary.durationMs = stopwatch.elapsedMilliseconds;
    summary.packageCount = _extractCount(export.stdout);
    summary.indexCount = _extractCount(index.stdout);
    await summary.write();
  } catch (e) {
    summary.status = 'fail';
    summary.failures.add('Unexpected error: $e');
    await summary.write();
    exitCode = 1;
  }
}

Future<_CommandResult> _runStep({
  required String name,
  required String executable,
  required List<String> arguments,
}) async {
  final process = await Process.run(executable, arguments, runInShell: true);
  return _CommandResult(
    name: name,
    exitCode: process.exitCode,
    stdout: _normalizeOutput(process.stdout),
    stderr: _normalizeOutput(process.stderr),
  );
}

String _normalizeOutput(Object? output) {
  if (output == null) return '';
  if (output is String) return output.trim();
  if (output is List<int>) return utf8.decode(output).trim();
  return output.toString().trim();
}

int _extractCount(String stdout) {
  final match = RegExp(
    r'(?:packs|modules|files)[^\\d]*(\\d+)',
  ).firstMatch(stdout);
  if (match != null) {
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }
  return 0;
}

class _CommandResult {
  _CommandResult({
    required this.name,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final String name;
  final int exitCode;
  final String stdout;
  final String stderr;
}

class _PublisherSummary {
  String status = 'fail';
  int validationExitCode = -1;
  int exportExitCode = -1;
  int indexExitCode = -1;
  String validationStdout = '';
  String validationStderr = '';
  String exportStdout = '';
  String exportStderr = '';
  String indexStdout = '';
  String indexStderr = '';
  int packageCount = 0;
  int indexCount = 0;
  int durationMs = 0;
  final List<String> failures = <String>[];

  Map<String, Object?> toJson() {
    return {
      'status': status,
      'duration_ms': durationMs,
      'validation': {
        'exit_code': validationExitCode,
        'stdout': validationStdout,
        'stderr': validationStderr,
      },
      'export': {
        'exit_code': exportExitCode,
        'stdout': exportStdout,
        'stderr': exportStderr,
        'packages': packageCount,
      },
      'index': {
        'exit_code': indexExitCode,
        'stdout': indexStdout,
        'stderr': indexStderr,
        'index_count': indexCount,
      },
      'failures': failures,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> write() async {
    final file = File('tools/_reports/content_publish_summary.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(toJson()),
    );
  }
}
