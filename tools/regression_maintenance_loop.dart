import 'dart:convert';
import 'dart:io';

const String _summaryOutPath =
    'release/_reports/regression_maintenance_summary.txt';
const String _historyPath =
    'release/_reports/_regression_maintenance_history.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const Duration _staleThreshold = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final loop = RegressionMaintenanceLoop();
  await loop.run();
}

class RegressionMaintenanceLoop {
  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final results = <_StageResult>[];

    for (final stage in _stages) {
      results.add(await _runStage(stage));
    }

    final passCount = results
        .where((stage) => stage.verdict == 'PASS')
        .length
        .toDouble();
    final warnCount = results
        .where((stage) => stage.verdict == 'WARN')
        .length
        .toDouble();
    final failCount = results
        .where((stage) => stage.verdict == 'FAIL')
        .length
        .toDouble();
    final total = results.length.toDouble().clamp(1, double.infinity);

    final regressionStabilityIndex =
        ((passCount + (warnCount * 0.5)) / total) * 100;
    final missingReports =
        results.expand((stage) => stage.missingSummaries).toSet().toList()
          ..sort();
    final staleReports =
        results.expand((stage) => stage.staleSummaries).toSet().toList()
          ..sort();

    final verdict =
        (regressionStabilityIndex >= 90 &&
            failCount == 0 &&
            missingReports.isEmpty)
        ? 'PASS'
        : 'FAIL';

    final history = await _loadHistory();
    final now = DateTime.now().toUtc();
    history.add({
      'timestamp': now.toIso8601String(),
      'regression_stability_index': regressionStabilityIndex,
      'pass': passCount.toInt(),
      'warn': warnCount.toInt(),
      'fail': failCount.toInt(),
      'missing_reports': missingReports,
      'stale_reports': staleReports,
      'verdict': verdict,
    });
    while (history.length > 20) {
      history.removeAt(0);
    }

    await _withReportsWritable(() async {
      await _writeSummary(
        results: results,
        regressionStabilityIndex: regressionStabilityIndex,
        passCount: passCount.toInt(),
        warnCount: warnCount.toInt(),
        failCount: failCount.toInt(),
        missingReports: missingReports,
        staleReports: staleReports,
        verdict: verdict,
        generatedAt: now,
        durationMs: stopwatch.elapsedMilliseconds,
        history: history,
      );
      await _writeHistory(history);
      await _emitTelemetry(
        regressionStabilityIndex: regressionStabilityIndex,
        passCount: passCount.toInt(),
        warnCount: warnCount.toInt(),
        failCount: failCount.toInt(),
        verdict: verdict,
        durationMs: stopwatch.elapsedMilliseconds,
        missingReports: missingReports,
        staleReports: staleReports,
      );
    });

    if (regressionStabilityIndex < 90 || failCount > 0) {
      exitCode = 2;
    }
  }
}

Future<_StageResult> _runStage(_StageDefinition stage) async {
  final stopwatch = Stopwatch()..start();
  final process = await Process.run(
    stage.command.first,
    stage.command.sublist(1),
    workingDirectory: Directory.current.path,
  );
  stopwatch.stop();

  final verdictDetails = await _evaluateStageVerdict(stage);
  var verdict =
      verdictDetails.verdict ?? (process.exitCode == 0 ? 'PASS' : 'FAIL');

  if (process.exitCode != 0) {
    verdict = 'FAIL';
  } else if (verdict == 'PASS' && verdictDetails.staleSummaries.isNotEmpty) {
    verdict = 'WARN';
  }
  if (verdictDetails.missingSummaries.isNotEmpty) {
    verdict = 'FAIL';
  }

  return _StageResult(
    name: stage.name,
    command: stage.command.join(' '),
    exitCode: process.exitCode,
    durationMs: stopwatch.elapsedMilliseconds,
    verdict: verdict,
    missingSummaries: verdictDetails.missingSummaries,
    staleSummaries: verdictDetails.staleSummaries,
  );
}

Future<_VerdictDetails> _evaluateStageVerdict(_StageDefinition stage) async {
  final missing = <String>[];
  final stale = <String>[];
  String? stageVerdict;
  final now = DateTime.now().toUtc();

  for (final path in stage.summaryPaths) {
    final file = File(path);
    if (!await file.exists()) {
      missing.add(path);
      continue;
    }
    final stat = await file.stat();
    if (now.difference(stat.modified.toUtc()) > _staleThreshold) {
      stale.add(path);
    }
    stageVerdict ??= await _extractVerdict(file);
  }

  return _VerdictDetails(
    verdict: stageVerdict,
    missingSummaries: missing,
    staleSummaries: stale,
  );
}

Future<String?> _extractVerdict(File file) async {
  try {
    if (file.path.endsWith('.json')) {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final verdict =
          decoded['verdict'] ?? decoded['Verdict'] ?? decoded['status'];
      if (verdict is String) {
        return verdict.toUpperCase();
      }
    } else {
      final lines = await file.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.toUpperCase().startsWith('VERDICT:')) {
          final value = trimmed.split(':').last.trim();
          if (value.isNotEmpty) {
            return value.toUpperCase();
          }
        }
      }
    }
  } catch (_) {
    // Ignore unreadable files.
  }
  return null;
}

Future<void> _writeSummary({
  required List<_StageResult> results,
  required double regressionStabilityIndex,
  required int passCount,
  required int warnCount,
  required int failCount,
  required List<String> missingReports,
  required List<String> staleReports,
  required String verdict,
  required DateTime generatedAt,
  required int durationMs,
  required List<Map<String, Object?>> history,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION MAINTENANCE SUMMARY')
    ..writeln('==============================')
    ..writeln('Generated: ${generatedAt.toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln(
      'Regression Stability Index: ${regressionStabilityIndex.toStringAsFixed(2)}%',
    )
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Stage outcomes:')
    ..writeln(
      '- PASS: $passCount | WARN: $warnCount | FAIL: $failCount (total ${results.length})',
    )
    ..writeln();

  if (missingReports.isEmpty) {
    buffer.writeln('Missing reports: none');
  } else {
    buffer.writeln('Missing reports (> 0):');
    for (final path in missingReports) {
      buffer.writeln('- $path');
    }
  }
  buffer.writeln();
  if (staleReports.isEmpty) {
    buffer.writeln('Stale reports (>24h): none');
  } else {
    buffer.writeln('Stale reports (>24h):');
    for (final path in staleReports) {
      buffer.writeln('- $path');
    }
  }

  buffer
    ..writeln()
    ..writeln('Per-stage breakdown:');
  for (final stage in results) {
    buffer
      ..writeln(
        '- ${stage.name}: ${stage.verdict} (exit ${stage.exitCode}, ${stage.durationMs}ms)',
      )
      ..writeln('  command: ${stage.command}');
    if (stage.missingSummaries.isNotEmpty) {
      buffer.writeln('  missing: ${stage.missingSummaries.join(', ')}');
    }
    if (stage.staleSummaries.isNotEmpty) {
      buffer.writeln('  stale: ${stage.staleSummaries.join(', ')}');
    }
  }

  buffer
    ..writeln()
    ..writeln('Rolling history (latest ${history.length}):');
  for (final entry in history) {
    buffer.writeln(
      '- ${entry['timestamp']}: RSI ${(entry['regression_stability_index'] as num).toStringAsFixed(2)}%, verdict ${entry['verdict']}',
    );
  }

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _writeHistory(List<Map<String, Object?>> history) async {
  final file = File(_historyPath);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(history));
}

Future<void> _emitTelemetry({
  required double regressionStabilityIndex,
  required int passCount,
  required int warnCount,
  required int failCount,
  required String verdict,
  required int durationMs,
  required List<String> missingReports,
  required List<String> staleReports,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_maintenance_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'regression_stability_index': regressionStabilityIndex,
    'pass': passCount,
    'warn': warnCount,
    'fail': failCount,
    'duration_ms': durationMs,
    'missing_reports': missingReports,
    'stale_reports': staleReports,
    'verdict': verdict,
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
      return decoded
          .whereType<Map>()
          .map((entry) => entry.cast<String, Object?>())
          .toList();
    }
  } catch (_) {
    // Ignore malformed history.
  }
  return <Map<String, Object?>>[];
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory('release/_reports');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // Ignore if chmod is unavailable.
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // Ignore if chmod is unavailable.
    }
  }
}

class _StageDefinition {
  const _StageDefinition({
    required this.name,
    required this.command,
    required this.summaryPaths,
  });

  final String name;
  final List<String> command;
  final List<String> summaryPaths;
}

class _StageResult {
  _StageResult({
    required this.name,
    required this.command,
    required this.exitCode,
    required this.durationMs,
    required this.verdict,
    required this.missingSummaries,
    required this.staleSummaries,
  });

  final String name;
  final String command;
  final int exitCode;
  final int durationMs;
  final String verdict;
  final List<String> missingSummaries;
  final List<String> staleSummaries;
}

class _VerdictDetails {
  _VerdictDetails({
    required this.verdict,
    required this.missingSummaries,
    required this.staleSummaries,
  });

  final String? verdict;
  final List<String> missingSummaries;
  final List<String> staleSummaries;
}

final List<_StageDefinition> _stages = <_StageDefinition>[
  _StageDefinition(
    name: 'content_schema_validator',
    command: ['dart', 'run', 'tools/content_schema_validator.dart'],
    summaryPaths: ['release/_reports/content_schema_validator_summary.txt'],
  ),
  _StageDefinition(
    name: 'content_semantic_audit',
    command: ['dart', 'run', 'tools/content_semantic_audit.dart'],
    summaryPaths: ['release/_reports/content_semantic_audit_summary.txt'],
  ),
  _StageDefinition(
    name: 'localization_consolidation_audit',
    command: ['dart', 'run', 'tools/localization_consolidation_audit.dart'],
    summaryPaths: ['release/_reports/localization_consolidation_summary.txt'],
  ),
  _StageDefinition(
    name: 'visual_cohesion_dashboard_v2',
    command: ['dart', 'run', 'tools/visual_cohesion_dashboard_v2.dart'],
    summaryPaths: ['release/_reports/visual_cohesion_dashboard_v2_summary.txt'],
  ),
  _StageDefinition(
    name: 'dynamic_visual_stress_test',
    command: ['dart', 'run', 'tools/dynamic_visual_stress_test.dart'],
    summaryPaths: ['release/_reports/dynamic_visual_stress_summary.txt'],
  ),
  _StageDefinition(
    name: 'ui_micro_animation_qa',
    command: ['dart', 'run', 'tools/ui_micro_animation_qa.dart'],
    summaryPaths: ['release/_reports/ui_micro_animation_summary.txt'],
  ),
  _StageDefinition(
    name: 'regression_diff_tool',
    command: ['dart', 'run', 'tools/regression_diff_tool.dart'],
    summaryPaths: ['release/_reports/regression_diff_summary.txt'],
  ),
  _StageDefinition(
    name: 'regression_stability_monitor',
    command: ['dart', 'run', 'tools/regression_stability_monitor.dart'],
    summaryPaths: ['release/_reports/regression_stability_summary.txt'],
  ),
  _StageDefinition(
    name: 'stability_dashboard',
    command: ['dart', 'run', 'tools/stability_dashboard.dart'],
    summaryPaths: [
      'release/_reports/stability_dashboard_summary.txt',
      'release/_reports/stability_dashboard_summary.json',
    ],
  ),
  _StageDefinition(
    name: 'stability_regression_consolidation',
    command: ['dart', 'run', 'tools/stability_regression_consolidation.dart'],
    summaryPaths: [
      'release/_reports/stability_regression_consolidation_summary.txt',
      'release/_reports/_stability_consolidation_history.json',
    ],
  ),
];
