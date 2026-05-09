import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/stability_regression_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final summaries = await _collectSummaryFiles();
  final results = <_SubsystemResult>[];
  var pass = 0;
  var warn = 0;
  var fail = 0;

  for (final file in summaries) {
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
    results.add(
      _SubsystemResult(
        name: file.name,
        status: status,
        notes: _extractNote(content, status),
      ),
    );
  }

  final coverage = summaries.isEmpty
      ? 0.0
      : ((pass + warn + fail) / summaries.length) * 100;
  final coveragePct = double.parse(coverage.toStringAsFixed(2));

  await _withReportsWritable(() async {
    await _writeSummary(
      results: results,
      pass: pass,
      warn: warn,
      fail: fail,
      coveragePct: coveragePct,
    );
    await _appendTelemetry(
      pass: pass,
      warn: warn,
      fail: fail,
      coveragePct: coveragePct,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'stability_regression_matrix: pass=$pass warn=$warn fail=$fail coverage=$coveragePct%',
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
        name != 'stability_regression_summary.txt') {
      files.add(_SummaryFile(name: name, path: entity.path));
    }
  }
  files.sort((a, b) => a.name.compareTo(b.name));
  return files;
}

String _classifyStatus(String content) {
  final passMatch = RegExp(r'\bPASS\b').firstMatch(content);
  final warnMatch = RegExp(r'\bWARN\b').firstMatch(content);
  final failMatch = RegExp(r'\bFAIL\b').firstMatch(content);
  if (failMatch != null) return 'FAIL';
  if (warnMatch != null) return 'WARN';
  if (passMatch != null) return 'PASS';
  return 'WARN';
}

String _extractNote(String content, String status) {
  switch (status) {
    case 'FAIL':
      final failLine = RegExp(
        r'(^.*FAIL.*$)',
        multiLine: true,
      ).firstMatch(content);
      if (failLine != null) return failLine.group(0)!.trim();
      break;
    case 'WARN':
      final warnLine = RegExp(
        r'(^.*WARN.*$)',
        multiLine: true,
      ).firstMatch(content);
      if (warnLine != null) return warnLine.group(0)!.trim();
      break;
    case 'PASS':
      final passLine = RegExp(
        r'(^.*PASS.*$)',
        multiLine: true,
      ).firstMatch(content);
      if (passLine != null) return passLine.group(0)!.trim();
      break;
  }
  return 'No explicit status line found.';
}

Future<void> _writeSummary({
  required List<_SubsystemResult> results,
  required int pass,
  required int warn,
  required int fail,
  required double coveragePct,
}) async {
  final buffer = StringBuffer()
    ..writeln('STABILITY REGRESSION SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Subsystems: ${results.length}   PASS=$pass   WARN=$warn   FAIL=$fail   Coverage=${coveragePct.toStringAsFixed(2)}%',
    )
    ..writeln();

  for (final result in results) {
    buffer
      ..writeln('File: ${result.name}')
      ..writeln('  Status: ${result.status}')
      ..writeln('  Note: ${result.notes}')
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int pass,
  required int warn,
  required int fail,
  required double coveragePct,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'stability_regression_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'pass': pass,
    'warn': warn,
    'fail': fail,
    'coverage_pct': coveragePct,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'stability_regression_matrix: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _SummaryFile {
  const _SummaryFile({required this.name, required this.path});

  final String name;
  final String path;
}

class _SubsystemResult {
  const _SubsystemResult({
    required this.name,
    required this.status,
    required this.notes,
  });

  final String name;
  final String status;
  final String notes;
}
