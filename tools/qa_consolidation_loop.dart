import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/qa_consolidation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final files = await _collectSummaryFiles();
  int pass = 0;
  int warn = 0;
  int fail = 0;
  final details = <_QaResult>[];

  for (final file in files) {
    final content = await File(file.path).readAsString();
    final status = _classifyStatus(content);
    switch (status) {
      case 'PASS':
        pass++;
        break;
      case 'WARN':
        warn++;
        break;
      case 'FAIL':
        fail++;
        break;
    }
    details.add(_QaResult(name: file.name, status: status));
  }

  final total = pass + warn + fail;
  final qaIndex = total == 0 ? 0.0 : pass / total;
  final verdict = qaIndex >= 0.85 ? 'QA_PASS' : 'QA_BLOCKED';

  await _withReportsWritable(() async {
    await _writeSummary(
      pass: pass,
      warn: warn,
      fail: fail,
      qaIndex: qaIndex,
      verdict: verdict,
      details: details,
    );
    await _appendTelemetry(
      qaIndex: qaIndex,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'qa_consolidation_loop: pass=$pass warn=$warn fail=$fail index=${qaIndex.toStringAsFixed(2)} verdict=$verdict',
  );
}

Future<List<_SummaryFile>> _collectSummaryFiles() async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) return const [];
  final files = <_SummaryFile>[];
  await for (final entity in dir.list()) {
    if (entity is! File) continue;
    final name = p.basename(entity.path);
    if (name.endsWith('_summary.txt') &&
        name != 'qa_consolidation_summary.txt') {
      files.add(_SummaryFile(name: name, path: entity.path));
    }
  }
  files.sort((a, b) => a.name.compareTo(b.name));
  return files;
}

String _classifyStatus(String content) {
  if (RegExp(r'\bFAIL\b').hasMatch(content)) return 'FAIL';
  if (RegExp(r'\bWARN\b').hasMatch(content)) return 'WARN';
  if (RegExp(r'\bPASS\b').hasMatch(content)) return 'PASS';
  return 'WARN';
}

Future<void> _writeSummary({
  required int pass,
  required int warn,
  required int fail,
  required double qaIndex,
  required String verdict,
  required List<_QaResult> details,
}) async {
  final buffer = StringBuffer()
    ..writeln('QA CONSOLIDATION SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Subsystems: ${details.length}   PASS=$pass WARN=$warn FAIL=$fail   '
      'QA Index: ${qaIndex.toStringAsFixed(2)}   Verdict: $verdict',
    )
    ..writeln();

  for (final result in details) {
    buffer
      ..writeln('File: ${result.name}')
      ..writeln('  Status: ${result.status}')
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double qaIndex,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'qa_consolidation_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'qa_index': double.parse(qaIndex.toStringAsFixed(2)),
    'verdict': verdict,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
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
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'qa_consolidation_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _SummaryFile {
  const _SummaryFile({required this.name, required this.path});

  final String name;
  final String path;
}

class _QaResult {
  const _QaResult({required this.name, required this.status});

  final String name;
  final String status;
}
