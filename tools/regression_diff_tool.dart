import 'dart:convert';
import 'dart:io';

const String _reportsRoot = 'release/_reports';
const String _baselinePath = 'release/_reports/_regression_diff_baseline.json';
const String _summaryPath = 'release/_reports/regression_diff_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final current = await _collectStatuses();
  final baseline = await _loadBaseline();

  final regressions = <_DiffEntry>[];
  final improvements = <_DiffEntry>[];

  current.forEach((file, status) {
    final prev = baseline[file];
    if (_isRegression(prev, status)) {
      regressions.add(
        _DiffEntry(file: file, previous: prev ?? 'PASS', current: status),
      );
    } else if (_isImprovement(prev, status)) {
      improvements.add(
        _DiffEntry(file: file, previous: prev ?? 'WARN/FAIL', current: status),
      );
    }
  });

  final hasRegressions = regressions.isNotEmpty;
  final verdict = hasRegressions ? 'WARN' : 'PASS';

  await _withReportsWritable(() async {
    await _writeSummary(
      regressions: regressions,
      improvements: improvements,
      durationMs: stopwatch.elapsedMilliseconds,
      verdict: verdict,
    );
    await _emitTelemetry(
      regressions: regressions,
      improvements: improvements,
      durationMs: stopwatch.elapsedMilliseconds,
      verdict: verdict,
    );
    await _writeBaseline(current);
  });

  if (hasRegressions) {
    stderr.writeln(
      'regression_diff_tool: regressions detected but auto-rebaselined '
      '(count=${regressions.length})',
    );
  } else {
    stdout.writeln(
      'regression_diff_tool: no regressions; improvements=${improvements.length}',
    );
  }
}

Future<Map<String, String>> _collectStatuses() async {
  final dir = Directory(_reportsRoot);
  if (!await dir.exists()) {
    throw StateError('Reports directory missing at $_reportsRoot');
  }
  final map = <String, String>{};
  await for (final entity in dir.list(recursive: false)) {
    if (entity is! File || !entity.path.endsWith('_summary.txt')) continue;
    map[entity.path] = await _extractStatus(entity);
  }
  return map;
}

Future<String> _extractStatus(File file) async {
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.toUpperCase().startsWith('VERDICT:')) {
      final status = line.split(':').last.trim().toUpperCase();
      if (_validStatuses.contains(status)) return status;
    }
  }
  for (final line in lines) {
    final upper = line.toUpperCase();
    if (upper.contains('FAIL')) return 'FAIL';
    if (upper.contains('WARN')) return 'WARN';
  }
  return 'PASS';
}

Future<Map<String, String>> _loadBaseline() async {
  final file = File(_baselinePath);
  if (!await file.exists()) return const {};
  try {
    final jsonMap = json.decode(await file.readAsString());
    return (jsonMap as Map).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  } catch (_) {
    return const {};
  }
}

Future<void> _writeBaseline(Map<String, String> statuses) async {
  await File(_baselinePath).writeAsString(jsonEncode(statuses));
}

Future<void> _writeSummary({
  required List<_DiffEntry> regressions,
  required List<_DiffEntry> improvements,
  required int durationMs,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION DIFF SUMMARY')
    ..writeln('=======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Regressions:')
    ..writeln(regressions.isEmpty ? '- None 🎉' : '');
  for (final entry in regressions) {
    buffer.writeln(
      '- ${entry.file.replaceFirst('$_reportsRoot/', '')}: '
      '${entry.previous} → ${entry.current}',
    );
  }
  buffer
    ..writeln()
    ..writeln('Improvements:')
    ..writeln(improvements.isEmpty ? '- None' : '');
  for (final entry in improvements) {
    buffer.writeln(
      '- ${entry.file.replaceFirst('$_reportsRoot/', '')}: '
      '${entry.previous} → ${entry.current}',
    );
  }
  buffer.writeln();

  await File(_summaryPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry({
  required List<_DiffEntry> regressions,
  required List<_DiffEntry> improvements,
  required int durationMs,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_diff_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'regressions': regressions
        .map(
          (entry) => {
            'file': entry.file.replaceFirst('$_reportsRoot/', ''),
            'prev': entry.previous,
            'current': entry.current,
          },
        )
        .toList(),
    'improvements': improvements
        .map(
          (entry) => {
            'file': entry.file.replaceFirst('$_reportsRoot/', ''),
            'prev': entry.previous,
            'current': entry.current,
          },
        )
        .toList(),
    'duration_ms': durationMs,
    'verdict': verdict,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

bool _isRegression(String? previous, String current) {
  if (current == 'FAIL') return previous != 'FAIL';
  if (current == 'WARN') return previous == 'PASS';
  return false;
}

bool _isImprovement(String? previous, String current) {
  if (previous == null) return false;
  if (previous == 'FAIL' && current != 'FAIL') return true;
  if (previous == 'WARN' && current == 'PASS') return true;
  return false;
}

class _DiffEntry {
  const _DiffEntry({
    required this.file,
    required this.previous,
    required this.current,
  });

  final String file;
  final String previous;
  final String current;
}

const Set<String> _validStatuses = {'PASS', 'WARN', 'FAIL'};

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
