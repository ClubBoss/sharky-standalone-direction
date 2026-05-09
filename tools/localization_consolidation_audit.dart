import 'dart:convert';
import 'dart:io';

const String _summaryPath =
    'release/_reports/localization_consolidation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final auditor = LocalizationConsolidationAudit();
  final pass = await auditor.run();
  if (!pass) {
    exitCode = 2;
  }
}

class LocalizationConsolidationAudit {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final stages = <_StageDefinition>[
      _StageDefinition(
        name: 'localization_audit',
        command: ['dart', 'run', 'tools/localization_audit.dart'],
        summaryPath: 'release/_reports/localization_audit_summary.txt',
      ),
      _StageDefinition(
        name: 'content_schema_validator',
        command: ['dart', 'run', 'tools/content_schema_validator.dart'],
        summaryPath: 'release/_reports/content_schema_validator_summary.txt',
      ),
      _StageDefinition(
        name: 'content_semantic_audit',
        command: ['dart', 'run', 'tools/content_semantic_audit.dart'],
        summaryPath: 'release/_reports/content_semantic_audit_summary.txt',
      ),
    ];

    final results = <_StageResult>[];
    for (final stage in stages) {
      results.add(await _runStage(stage));
    }

    final passCount = results.where((result) => result.exitCode == 0).length;
    final healthIndex = (passCount / results.length) * 100;
    final verdict = passCount == results.length ? 'PASS' : 'FAIL';

    await _withReportsWritable(() async {
      await _writeSummary(
        results: results,
        healthIndex: healthIndex,
        verdict: verdict,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        results: results,
        healthIndex: healthIndex,
        verdict: verdict,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    return verdict == 'PASS';
  }

  Future<_StageResult> _runStage(_StageDefinition stage) async {
    final process = await Process.run(
      stage.command.first,
      stage.command.sublist(1),
      workingDirectory: Directory.current.path,
    );
    final summary = await _readSummary(stage.summaryPath);
    return _StageResult(
      stage: stage.name,
      exitCode: process.exitCode,
      stdout: (process.stdout ?? '').toString().trim(),
      stderr: (process.stderr ?? '').toString().trim(),
      summary: summary,
    );
  }

  Future<String> _readSummary(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return 'Summary not found at $path';
    }
    final lines = await file.readAsLines();
    final snippet = lines.take(15).join('\n');
    return snippet.isEmpty ? '(empty summary)' : snippet;
  }

  Future<void> _writeSummary({
    required List<_StageResult> results,
    required double healthIndex,
    required String verdict,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('LOCALIZATION CONSOLIDATION SUMMARY')
      ..writeln('=================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Health Index: ${healthIndex.toStringAsFixed(2)}%')
      ..writeln('Verdict: $verdict')
      ..writeln();

    for (final result in results) {
      buffer
        ..writeln('- Stage: ${result.stage}')
        ..writeln('  Exit code: ${result.exitCode}')
        ..writeln(
          '  Stdout: ${result.stdout.isEmpty ? '(none)' : result.stdout}',
        )
        ..writeln(
          '  Stderr: ${result.stderr.isEmpty ? '(none)' : result.stderr}',
        )
        ..writeln('  Summary excerpt:')
        ..writeln(_indent(result.summary, '    '))
        ..writeln();
    }

    await File(_summaryPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry({
    required List<_StageResult> results,
    required double healthIndex,
    required String verdict,
    required int durationMs,
  }) async {
    final payload = <String, Object?>{
      'event': 'localization_consolidation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'verdict': verdict,
      'health_index': healthIndex,
      'duration_ms': durationMs,
      'stages': {
        for (final result in results)
          result.stage: {
            'exit_code': result.exitCode,
            'stdout': result.stdout,
            'stderr': result.stderr,
          },
      },
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }

  String _indent(String text, String indent) {
    return text.split('\n').map((line) => '$indent$line').join('\n');
  }
}

class _StageDefinition {
  const _StageDefinition({
    required this.name,
    required this.command,
    required this.summaryPath,
  });

  final String name;
  final List<String> command;
  final String summaryPath;
}

class _StageResult {
  const _StageResult({
    required this.stage,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.summary,
  });

  final String stage;
  final int exitCode;
  final String stdout;
  final String stderr;
  final String summary;
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
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
