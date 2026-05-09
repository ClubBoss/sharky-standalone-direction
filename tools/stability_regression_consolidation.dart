/// Stage Ω-9b.4 regression normalization & consolidation.
///
/// Responsibilities:
/// - Auto-rerun stale regression/stability summaries (>24h age).
/// - Normalize WARN -> PASS when RSI ≥95 or Health ≥85.
/// - Collapse duplicate FAIL summaries so they are only counted once.
/// - Compute final PASS ratio after normalization and include history.
/// - Guard all report writes with temporary write permissions.
///
/// All output is ASCII-only and backward-compatible; new sections are appended.
import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualSummaryPath =
    'release/_reports/visual_cohesion_dashboard_v2_summary.txt';
const String _summaryOutPath =
    'release/_reports/stability_regression_consolidation_summary.txt';
const String _historyPath =
    'release/_reports/_stability_consolidation_history.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const Duration _staleThreshold = Duration(hours: 24);

const List<_SummaryRefreshTarget> _refreshTargets = [
  _SummaryRefreshTarget(
    path: 'release/_reports/regression_maintenance_summary.txt',
    command: ['dart', 'run', 'tools/regression_maintenance_loop.dart'],
    telemetryEvent: 'regression_maintenance_summary_refreshed',
  ),
  _SummaryRefreshTarget(
    path: 'release/_reports/regression_consolidation_summary.txt',
    command: ['dart', 'run', 'tools/regression_consolidation_analyzer.dart'],
    telemetryEvent: 'regression_consolidation_summary_refreshed',
  ),
  _SummaryRefreshTarget(
    path: 'release/_reports/telemetry_consistency_summary.txt',
    command: ['dart', 'run', 'tools/telemetry_consistency_daemon.dart'],
    telemetryEvent: 'telemetry_consistency_summary_refreshed',
  ),
  _SummaryRefreshTarget(
    path: 'release/_reports/stability_dashboard_summary.txt',
    command: ['dart', 'run', 'tools/stability_dashboard.dart'],
    telemetryEvent: 'stability_dashboard_summary_refreshed',
  ),
];

Future<void> main(List<String> args) async {
  final isFast = args.contains('--fast');
  await StabilityRegressionConsolidation().run(isFast: isFast);
}

class StabilityRegressionConsolidation {
  Future<void> run({bool isFast = false}) async {
    if (!isFast) {
      await _ensureFreshSummaries();
    }
    final stageResults = <_StageResult>[];
    if (!isFast) {
      await _setPermissions(true);
      try {
        for (final stage in _stages) {
          final result = await _runStage(stage);
          stageResults.add(result);
        }
      } finally {
        await _setPermissions(false);
      }
    }

    final metrics = await _loadRegressionMetrics();
    final summaries = await _collectSummaryStats(metrics);
    final visualIndex = await _readVisualHealthIndex();
    final thresholdsMet =
        summaries.passRatio >= 90.0 &&
        (visualIndex >= 85.0 || metrics.health >= 85.0);
    final stagesPassing = stageResults.every((stage) => stage.success);

    final verdict = stagesPassing && thresholdsMet ? 'PASS' : 'FAIL';
    final now = DateTime.now().toUtc();
    final history = await _loadHistory();
    history.add({
      'timestamp': now.toIso8601String(),
      'pass_ratio': summaries.passRatio,
      'visual_health_index': visualIndex,
      'stage_results': {
        for (final stage in stageResults)
          stage.name: {
            'exit_code': stage.exitCode,
            'duration_ms': stage.durationMs,
          },
      },
      'verdict': verdict,
    });
    while (history.length > 15) {
      history.removeAt(0);
    }
    final condensedHistory = _condenseHistory(history);

    await _withReportsWritable(() async {
      await _writeSummary(
        stageResults: stageResults,
        summaries: summaries,
        visualHealthIndex: visualIndex,
        verdict: verdict,
        history: condensedHistory,
        generatedAt: now,
        isFast: isFast,
      );
      await _writeHistory(condensedHistory);
      await _emitTelemetry(
        stageResults: stageResults,
        summaries: summaries,
        visualHealthIndex: visualIndex,
        verdict: verdict,
        generatedAt: now,
      );
    });

    if (verdict != 'PASS') {
      exitCode = 2;
    }
  }
}

final List<_StageDefinition> _stages = <_StageDefinition>[
  _StageDefinition(
    name: 'telemetry_consistency_daemon',
    command: ['dart', 'run', 'tools/telemetry_consistency_daemon.dart'],
  ),
  _StageDefinition(
    name: 'regression_stability_monitor',
    command: ['dart', 'run', 'tools/regression_stability_monitor.dart'],
  ),
  _StageDefinition(
    name: 'visual_cohesion_dashboard_v2',
    command: ['dart', 'run', 'tools/visual_cohesion_dashboard_v2.dart'],
  ),
];

Future<_StageResult> _runStage(_StageDefinition stage) async {
  final stopwatch = Stopwatch()..start();
  final result = await Process.run(
    stage.command.first,
    stage.command.sublist(1),
    workingDirectory: Directory.current.path,
  );
  stopwatch.stop();
  return _StageResult(
    name: stage.name,
    command: stage.command.join(' '),
    exitCode: result.exitCode,
    stdout: (result.stdout ?? '').toString(),
    stderr: (result.stderr ?? '').toString(),
    durationMs: stopwatch.elapsedMilliseconds,
  );
}

Future<_SummaryStats> _collectSummaryStats(_RegressionMetrics metrics) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    throw StateError('Missing reports directory at $_reportsDir');
  }
  var pass = 0;
  var warn = 0;
  var fail = 0;
  var other = 0;
  var total = 0;
  final seenFails = <String>{};
  for (final entity in dir.listSync()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.endsWith('_summary.txt') && !name.endsWith('_summary.json')) {
      continue;
    }
    final verdict = await _extractVerdict(entity);
    if (verdict == null) continue;
    if (!name.startsWith('regression_')) {
      other++;
      continue;
    }
    final normalized = _normalizeVerdicts(verdict, metrics);
    if (normalized == 'FAIL') {
      if (!_dedupeFails(name, seenFails)) {
        continue;
      }
    }
    total++;
    switch (normalized) {
      case 'PASS':
        pass++;
        break;
      case 'WARN':
        warn++;
        break;
      case 'FAIL':
        fail++;
        break;
      default:
        other++;
    }
  }
  return _SummaryStats(
    total: total,
    pass: pass,
    warn: warn,
    fail: fail,
    other: other,
  );
}

Future<String?> _extractVerdict(File file) async {
  try {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Verdict:')) {
        final value = _valueAfterColon(trimmed);
        return value?.toUpperCase();
      }
    }
  } catch (_) {
    // ignore unreadable files
  }
  return null;
}

String _normalizeVerdict(String verdict, _RegressionMetrics metrics) {
  if (verdict == 'WARN' && (metrics.rsi >= 95.0 || metrics.health >= 85.0)) {
    return 'PASS';
  }
  return verdict;
}

// Ω-9b helper aliases (pluralized API)
String _normalizeVerdicts(String verdict, _RegressionMetrics metrics) =>
    _normalizeVerdict(verdict, metrics);

bool _dedupeFails(String reportName, Set<String> seen) => seen.add(reportName);

Future<double> _readVisualHealthIndex() async {
  final file = File(_visualSummaryPath);
  if (!await file.exists()) return 0;
  try {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Overall Visual Health Index')) {
        final value = _valueAfterColon(trimmed)?.replaceAll('%', '');
        return double.tryParse(value ?? '') ?? 0;
      }
    }
  } catch (_) {
    // ignore parse errors
  }
  return 0;
}

Future<void> _writeSummary({
  required List<_StageResult> stageResults,
  required _SummaryStats summaries,
  required double visualHealthIndex,
  required String verdict,
  required List<Map<String, Object?>> history,
  required DateTime generatedAt,
  bool isFast = false,
}) async {
  final buffer = StringBuffer()
    ..writeln('STABILITY & REGRESSION CONSOLIDATION SUMMARY')
    ..writeln('===========================================')
    ..writeln('Generated: ${generatedAt.toIso8601String()}')
    ..writeln(isFast ? 'Mode: FAST (no child tools re-run)' : 'Mode: FULL')
    ..writeln('Verdict: $verdict')
    ..writeln(
      'PASS ratio: ${summaries.passRatio.toStringAsFixed(2)}% '
      '(PASS=${summaries.pass} | WARN=${summaries.warn} | FAIL=${summaries.fail} | OTHER=${summaries.other} | TOTAL=${summaries.total})',
    )
    ..writeln('Visual Health Index: ${visualHealthIndex.toStringAsFixed(2)}%')
    ..writeln();

  buffer.writeln('Stage Invocation Results:');
  for (final stage in stageResults) {
    buffer
      ..writeln('- ${stage.name}')
      ..writeln('  Command : ${stage.command}')
      ..writeln('  Exit    : ${stage.exitCode}')
      ..writeln('  Duration: ${stage.durationMs}ms');
    if (stage.stdout.isNotEmpty) {
      buffer.writeln('  Stdout  : ${_truncate(stage.stdout)}');
    }
    if (stage.stderr.isNotEmpty) {
      buffer.writeln('  Stderr  : ${_truncate(stage.stderr)}');
    }
    buffer.writeln();
  }

  if (history.isNotEmpty) {
    buffer.writeln('Recent History (latest ${history.length} entries):');
    for (final entry in history.reversed) {
      buffer.writeln(
        '- ${entry['timestamp']} | '
        'pass=${(entry['pass_ratio'] as num).toStringAsFixed(2)}% | '
        'visual=${(entry['visual_health_index'] as num).toStringAsFixed(2)}% | '
        'verdict=${entry['verdict']}',
      );
    }
  }

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _writeHistory(List<Map<String, Object?>> history) async {
  await File(_historyPath).writeAsString(jsonEncode(history));
}

Future<_RegressionMetrics> _loadRegressionMetrics() async {
  final rsi = await _readMaintenanceRsi();
  final health = await _readHealthScore();
  return _RegressionMetrics(rsi: rsi, health: health);
}

Future<double> _readMaintenanceRsi() async {
  const path = 'release/_reports/regression_maintenance_summary.txt';
  final file = File(path);
  if (!await file.exists()) return 0;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Regression Stability Index:')) {
      final value = trimmed.split(':').last.trim().replaceAll('%', '');
      return double.tryParse(value) ?? 0;
    }
  }
  return 0;
}

Future<double> _readHealthScore() async {
  const path = 'release/_reports/stability_dashboard_summary.json';
  final file = File(path);
  if (!await file.exists()) return 0;
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is Map<String, dynamic>) {
      final score = decoded['health_score'];
      if (score is num) return score.toDouble();
    }
  } catch (_) {}
  return 0;
}

List<Map<String, Object?>> _condenseHistory(
  List<Map<String, Object?>> history,
) {
  final result = <Map<String, Object?>>[];
  final seenFailSignatures = <String>{};
  for (final entry in history) {
    final verdict = entry['verdict']?.toString() ?? '';
    if (verdict == 'FAIL') {
      final signature =
          '${entry['pass_ratio']}-${entry['visual_health_index']}';
      if (!seenFailSignatures.add(signature)) {
        continue;
      }
    }
    result.add(entry);
  }
  return result;
}

Future<void> _emitTelemetry({
  required List<_StageResult> stageResults,
  required _SummaryStats summaries,
  required double visualHealthIndex,
  required String verdict,
  required DateTime generatedAt,
}) async {
  final payload = <String, Object?>{
    'event': 'stability_regression_consolidation_completed',
    'timestamp': generatedAt.toIso8601String(),
    'verdict': verdict,
    'pass_ratio': summaries.passRatio,
    'visual_health_index': visualHealthIndex,
    'report_counts': {
      'total': summaries.total,
      'pass': summaries.pass,
      'warn': summaries.warn,
      'fail': summaries.fail,
      'other': summaries.other,
    },
    'stages': {
      for (final stage in stageResults)
        stage.name: {
          'exit_code': stage.exitCode,
          'duration_ms': stage.durationMs,
        },
    },
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<List<Map<String, Object?>>> _loadHistory() async {
  final file = File(_historyPath);
  if (!await file.exists()) {
    return <Map<String, Object?>>[];
  }
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is List) {
      return decoded.whereType<Map>().map(Map<String, Object?>.from).toList();
    }
  } catch (_) {
    // ignore malformed history
  }
  return <Map<String, Object?>>[];
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
  await Process.run('chmod', ['-R', mode, _reportsDir]);
}

Future<void> _ensureFreshSummaries() async {
  for (final target in _refreshTargets) {
    await _ensureFresh(target);
  }
}

Future<void> _ensureFresh(_SummaryRefreshTarget target) async {
  final file = File(target.path);
  final needsRefresh = !await file.exists() || await _isStale(file);
  if (!needsRefresh) return;
  final result = await Process.run(
    target.command.first,
    target.command.sublist(1),
    workingDirectory: Directory.current.path,
  );
  await _appendRerunTelemetry(
    target.telemetryEvent,
    target.path,
    result.exitCode,
  );
}

Future<bool> _isStale(File file) async {
  try {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Generated:')) {
        final iso = trimmed.split(':').last.trim();
        final timestamp = DateTime.tryParse(iso);
        if (timestamp == null) return true;
        return DateTime.now().difference(timestamp) > _staleThreshold;
      }
    }
  } catch (_) {
    return true;
  }
  return true;
}

Future<void> _appendRerunTelemetry(
  String event,
  String summaryPath,
  int exitCode,
) async {
  await _withReportsWritable(() async {
    final payload = <String, Object?>{
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      'summary_path': summaryPath,
      'exit_code': exitCode,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  });
}

class _SummaryStats {
  const _SummaryStats({
    required this.total,
    required this.pass,
    required this.warn,
    required this.fail,
    required this.other,
  });

  final int total;
  final int pass;
  final int warn;
  final int fail;
  final int other;

  double get passRatio {
    if (total == 0) return 0;
    return (pass / total) * 100;
  }
}

class _RegressionMetrics {
  const _RegressionMetrics({required this.rsi, required this.health});

  final double rsi;
  final double health;
}

class _StageDefinition {
  const _StageDefinition({required this.name, required this.command});

  final String name;
  final List<String> command;
}

class _StageResult {
  const _StageResult({
    required this.name,
    required this.command,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.durationMs,
  });

  final String name;
  final String command;
  final int exitCode;
  final String stdout;
  final String stderr;
  final int durationMs;

  bool get success => exitCode == 0;
}

String _truncate(String value, {int max = 400}) {
  if (value.length <= max) return value;
  return '${value.substring(0, max)}...';
}

String? _valueAfterColon(String line) {
  final index = line.indexOf(':');
  if (index == -1) {
    return null;
  }
  return line.substring(index + 1).trim();
}

class _SummaryRefreshTarget {
  const _SummaryRefreshTarget({
    required this.path,
    required this.command,
    required this.telemetryEvent,
  });

  final String path;
  final List<String> command;
  final String telemetryEvent;
}
