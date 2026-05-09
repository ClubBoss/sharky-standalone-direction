import 'dart:convert';
import 'dart:io';

const String _reportsRoot = 'release/_reports';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _baselinePath =
    'release/_reports/_regression_auto_notifier_baseline.json';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final currentStatuses = await _collectStatuses();
  final previousStatuses = await _loadBaseline();

  final regressions = <_Regression>[];
  currentStatuses.forEach((file, status) {
    final previous = previousStatuses[file];
    if (_isRegression(previous, status)) {
      regressions.add(
        _Regression(
          file: file,
          previous: previous ?? 'UNKNOWN',
          current: status,
        ),
      );
    }
  });

  await _withReportsWritable(() async {
    await _writeBaseline(currentStatuses);
    await _emitTelemetry(regressions, stopwatch.elapsedMilliseconds);
  });

  if (regressions.isNotEmpty) {
    stderr.writeln('regression_auto_notifier: detected regressions:');
    for (final regression in regressions) {
      stderr.writeln(
        '- ${regression.file}: was ${regression.previous}, now ${regression.current}',
      );
    }
    exitCode = 2;
  } else {
    stdout.writeln('regression_auto_notifier: no regressions detected.');
  }
}

bool _isRegression(String? previous, String current) {
  if (current == 'FAIL') return previous != 'FAIL';
  if (current == 'WARN') return previous == 'PASS';
  return false;
}

Future<Map<String, String>> _collectStatuses() async {
  final root = Directory(_reportsRoot);
  if (!await root.exists()) {
    throw StateError('Reports directory missing at $_reportsRoot');
  }

  final statuses = <String, String>{};
  await for (final entity in root.list(recursive: false)) {
    if (entity is! File || !entity.path.endsWith('_summary.txt')) continue;
    final status = await _extractStatus(entity);
    statuses[entity.path] = status;
  }
  return statuses;
}

Future<String> _extractStatus(File file) async {
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.toUpperCase().startsWith('VERDICT:')) {
      final status = line.split(':').last.trim().toUpperCase();
      if (status == 'PASS' || status == 'WARN' || status == 'FAIL') {
        return status;
      }
    }
  }

  for (final line in lines) {
    final upper = line.toUpperCase();
    if (upper.contains('WARN')) return 'WARN';
    if (upper.contains('FAIL')) return 'FAIL';
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
  final file = File(_baselinePath);
  await file.writeAsString(jsonEncode(statuses));
}

Future<void> _emitTelemetry(
  List<_Regression> regressions,
  int durationMs,
) async {
  final payload = <String, Object?>{
    'event': 'regression_auto_notifier_triggered',
    'timestamp': DateTime.now().toIso8601String(),
    'regressions': regressions
        .map(
          (regression) => {
            'file': regression.file,
            'prev': regression.previous,
            'current': regression.current,
          },
        )
        .toList(),
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _Regression {
  const _Regression({
    required this.file,
    required this.previous,
    required this.current,
  });

  final String file;
  final String previous;
  final String current;
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
