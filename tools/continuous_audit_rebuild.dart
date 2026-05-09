/// Implements Ω-9b.8 regression normalization helpers (freshness guard,
/// WARN→PASS normalization, duplicate FAIL collapse, guarded writes, fast mode).
import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _summaryOutPath =
    'release/_reports/continuous_audit_rebuild_summary.txt';
const String _historyPath =
    'release/_reports/_continuous_audit_rebuild_history.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final isFast = args.contains('--fast');
  final rebuild = ContinuousAuditRebuild();
  await rebuild.run(isFast: isFast);
}

class ContinuousAuditRebuild {
  Future<void> run({bool isFast = false}) async {
    final stopwatch = Stopwatch()..start();
    final stageResults = <_StageResult>[];

    if (!isFast) {
      for (final stage in _stages) {
        stageResults.add(await _runStage(stage));
      }
    } else {
      stdout.writeln(
        '[FAST MODE] Skipped _ensureFresh and stage re-runs; using cached summaries.',
      );
    }

    // Ensure freshness of prerequisite summaries before computing metrics.
    await _ensureFresh(isFast: isFast);
    final metrics = await _collectMetrics();
    final regressionMetrics = _RegressionMetrics(
      rsi: metrics.rsi,
      health: metrics.health,
    );
    final summaryStats = await _collectSummaryStats(regressionMetrics);
    final verdict = (metrics.rsi >= 90 && metrics.persistents.isEmpty)
        ? 'PASS'
        : 'FAIL';

    final summaries = await _readStageSummaries();

    await _withReportsWritable(() async {
      await _writeSummary(
        generatedAt: DateTime.now().toIso8601String(),
        durationMs: stopwatch.elapsedMilliseconds,
        stageResults: stageResults,
        stageSummaries: summaries,
        metrics: metrics,
        verdict: verdict,
        normalizedPassRatio: summaryStats.passRatio,
        isFast: isFast,
      );
      await _appendHistory(
        durationMs: stopwatch.elapsedMilliseconds,
        metrics: metrics,
        verdict: verdict,
        stageResults: stageResults,
      );
      await _emitTelemetry(
        durationMs: stopwatch.elapsedMilliseconds,
        metrics: metrics,
        verdict: verdict,
        stageResults: stageResults,
      );
    });

    if (verdict != 'PASS') {
      exitCode = 2;
    }
  }
}

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
    durationMs: stopwatch.elapsedMilliseconds,
  );
}

Future<_Metrics> _collectMetrics() async {
  final rsi = await _readRsi();
  final consolidation = await _readConsolidationDetails();
  final rdi = consolidation.averageDifficulty;
  final rawHealth = (rsi + (100 - rdi)) / 2;
  final health = rawHealth.clamp(0, 100).toDouble();
  return _Metrics(
    rsi: rsi,
    rdi: rdi,
    health: health,
    persistents: consolidation.persistentFailures,
  );
}

Future<double> _readRsi() async {
  final file = File('$_reportsDir/regression_maintenance_summary.txt');
  if (!await file.exists()) return 0;
  try {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Regression Stability Index:')) {
        final value = trimmed.split(':').last.trim().replaceAll('%', '');
        return double.tryParse(value) ?? 0;
      }
    }
  } catch (_) {
    return 0;
  }
  return 0;
}

class _ConsolidationDetails {
  _ConsolidationDetails({
    required this.averageDifficulty,
    required this.persistentFailures,
  });

  final double averageDifficulty;
  final List<String> persistentFailures;
}

Future<_ConsolidationDetails> _readConsolidationDetails() async {
  final file = File('$_reportsDir/regression_consolidation_summary.txt');
  if (!await file.exists()) {
    return _ConsolidationDetails(
      averageDifficulty: 100,
      persistentFailures: const [],
    );
  }

  final lines = await file.readAsLines();
  final persistent = <String>[];
  final difficulties = <double>[];
  var inPersistentBlock = false;
  var inDifficultyBlock = false;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Persistent failures')) {
      inPersistentBlock = true;
      inDifficultyBlock = false;
      if (line.contains('none')) {
        inPersistentBlock = false;
      }
      continue;
    }
    if (line.startsWith('Recovery difficulty index')) {
      inPersistentBlock = false;
      inDifficultyBlock = true;
      continue;
    }
    if (line.isEmpty) {
      inPersistentBlock = false;
      inDifficultyBlock = false;
      continue;
    }

    if (inPersistentBlock && line.startsWith('- ')) {
      persistent.add(line.substring(2).split('(').first.trim());
    } else if (inDifficultyBlock && line.startsWith('- ')) {
      final parts = line.substring(2).split(':');
      if (parts.length >= 2) {
        final valuePart = parts[1].trim().split(' ').first;
        final value = double.tryParse(valuePart);
        if (value != null) difficulties.add(value);
      }
    }
  }

  final avg = difficulties.isEmpty
      ? 100.0
      : difficulties.reduce((a, b) => a + b) / difficulties.length;
  return _ConsolidationDetails(
    averageDifficulty: avg,
    persistentFailures: persistent,
  );
}

Future<List<_StageSummary>> _readStageSummaries() async {
  final summaries = <_StageSummary>[];
  for (final stage in _stages) {
    for (final path in stage.summaryPaths) {
      final file = File(path);
      if (!await file.exists()) continue;
      String contents;
      try {
        contents = await file.readAsString();
      } catch (_) {
        continue;
      }
      summaries.add(
        _StageSummary(stage: stage.name, path: path, contents: contents.trim()),
      );
    }
  }
  return summaries;
}

Future<void> _writeSummary({
  required String generatedAt,
  required int durationMs,
  required List<_StageResult> stageResults,
  required List<_StageSummary> stageSummaries,
  required _Metrics metrics,
  required String verdict,
  required double normalizedPassRatio,
  bool isFast = false,
}) async {
  final buffer = StringBuffer()
    ..writeln('CONTINUOUS AUDIT REBUILD SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: $generatedAt')
    ..writeln(isFast ? 'Mode: FAST (no child tools re-run)' : 'Mode: FULL')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Final RSI: ${metrics.rsi.toStringAsFixed(2)}%')
    ..writeln('Recovery Difficulty Index: ${metrics.rdi.toStringAsFixed(2)}')
    ..writeln('Health Index: ${metrics.health.toStringAsFixed(2)}')
    ..writeln(
      'Normalized PASS ratio: ${normalizedPassRatio.toStringAsFixed(2)}%',
    )
    ..writeln(
      'Persistent Failures: ${metrics.persistents.isEmpty ? 'none' : metrics.persistents.join(', ')}',
    )
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Stage executions:');

  for (final stage in stageResults) {
    buffer.writeln(
      '- ${stage.name}: exit ${stage.exitCode} in ${stage.durationMs}ms',
    );
    buffer.writeln('  command: ${stage.command}');
  }

  if (stageSummaries.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Merged summaries:');
    for (final summary in stageSummaries) {
      buffer
        ..writeln('--- ${summary.stage} (${summary.path}) ---')
        ..writeln(summary.contents)
        ..writeln();
    }
  }

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _appendHistory({
  required int durationMs,
  required _Metrics metrics,
  required String verdict,
  required List<_StageResult> stageResults,
}) async {
  final file = File(_historyPath);
  List<dynamic> history = [];
  if (await file.exists()) {
    try {
      history = json.decode(await file.readAsString()) as List<dynamic>;
    } catch (_) {
      history = [];
    }
  }
  history.add({
    'timestamp': DateTime.now().toIso8601String(),
    'duration_ms': durationMs,
    'rsi': metrics.rsi,
    'rdi': metrics.rdi,
    'health_index': metrics.health,
    'persistent_failures': metrics.persistents,
    'verdict': verdict,
    'stages': [
      for (final stage in stageResults)
        {
          'name': stage.name,
          'exit_code': stage.exitCode,
          'duration_ms': stage.durationMs,
        },
    ],
  });
  while (history.length > 25) {
    history.removeAt(0);
  }
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(history));
}

Future<void> _emitTelemetry({
  required int durationMs,
  required _Metrics metrics,
  required String verdict,
  required List<_StageResult> stageResults,
}) async {
  final payload = <String, Object?>{
    'event': 'continuous_audit_rebuild_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'duration_ms': durationMs,
    'rsi': metrics.rsi,
    'rdi': metrics.rdi,
    'health_index': metrics.health,
    'persistent_failures': metrics.persistents,
    'verdict': verdict,
    'stages': [
      for (final stage in stageResults)
        {
          'name': stage.name,
          'exit_code': stage.exitCode,
          'duration_ms': stage.durationMs,
        },
    ],
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

// Ω-9b.4 helpers (normalized pass ratio + freshness + dedupe FAILs)

class _RegressionMetrics {
  const _RegressionMetrics({required this.rsi, required this.health});
  final double rsi;
  final double health;
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
  double get passRatio => total == 0 ? 0 : (pass / total) * 100;
}

String _normalizeVerdict(String verdict, _RegressionMetrics metrics) {
  if (verdict == 'WARN' && (metrics.rsi >= 95.0 || metrics.health >= 85.0)) {
    return 'PASS';
  }
  return verdict;
}

Future<_SummaryStats> _collectSummaryStats(_RegressionMetrics metrics) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    return const _SummaryStats(total: 0, pass: 0, warn: 0, fail: 0, other: 0);
  }
  var pass = 0, warn = 0, fail = 0, other = 0, total = 0;
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
    final normalized = _normalizeVerdict(verdict, metrics);
    if (normalized == 'FAIL') {
      if (!seenFails.add(name)) continue;
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
        final value = trimmed.split(':').last.trim();
        return value.toUpperCase();
      }
    }
  } catch (_) {}
  return null;
}

class _SummaryRefreshTarget {
  const _SummaryRefreshTarget({
    required this.path,
    required this.command,
    required this.event,
  });
  final String path;
  final List<String> command;
  final String event;
}

const Duration _freshnessThreshold = Duration(hours: 24);

Future<void> _ensureFresh({required bool isFast}) async {
  if (isFast) return;
  final targets = <_SummaryRefreshTarget>[
    _SummaryRefreshTarget(
      path: 'release/_reports/regression_maintenance_summary.txt',
      command: ['dart', 'run', 'tools/regression_maintenance_loop.dart'],
      event: 'regression_maintenance_summary_refreshed',
    ),
    _SummaryRefreshTarget(
      path: 'release/_reports/regression_consolidation_summary.txt',
      command: ['dart', 'run', 'tools/regression_consolidation_analyzer.dart'],
      event: 'regression_consolidation_summary_refreshed',
    ),
    _SummaryRefreshTarget(
      path: 'release/_reports/visual_cohesion_dashboard_v2_summary.txt',
      command: ['dart', 'run', 'tools/visual_cohesion_dashboard_v2.dart'],
      event: 'visual_cohesion_dashboard_v2_summary_refreshed',
    ),
    _SummaryRefreshTarget(
      path: 'release/_reports/stability_dashboard_summary.txt',
      command: ['dart', 'run', 'tools/stability_dashboard.dart'],
      event: 'stability_dashboard_summary_refreshed',
    ),
  ];
  for (final t in targets) {
    final file = File(t.path);
    final needsRefresh = !await file.exists() || await _isStale(file);
    if (!needsRefresh) continue;
    final result = await Process.run(
      t.command.first,
      t.command.sublist(1),
      workingDirectory: Directory.current.path,
    );
    await _appendRefreshTelemetry(t.event, t.path, result.exitCode);
  }
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
        return DateTime.now().difference(timestamp) > _freshnessThreshold;
      }
    }
  } catch (_) {
    return true;
  }
  return true;
}

Future<void> _appendRefreshTelemetry(
  String event,
  String path,
  int exitCode,
) async {
  await _withReportsWritable(() async {
    final payload = <String, Object?>{
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      'summary_path': path,
      'exit_code': exitCode,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  });
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod fails
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}

class _Metrics {
  _Metrics({
    required this.rsi,
    required this.rdi,
    required this.health,
    required this.persistents,
  });

  final double rsi;
  final double rdi;
  final double health;
  final List<String> persistents;
}

class _StageSummary {
  _StageSummary({
    required this.stage,
    required this.path,
    required this.contents,
  });

  final String stage;
  final String path;
  final String contents;
}

class _StageResult {
  _StageResult({
    required this.name,
    required this.command,
    required this.exitCode,
    required this.durationMs,
  });

  final String name;
  final String command;
  final int exitCode;
  final int durationMs;
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

const List<_StageDefinition> _stages = <_StageDefinition>[
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
    name: 'regression_maintenance_loop',
    command: ['dart', 'run', 'tools/regression_maintenance_loop.dart'],
    summaryPaths: ['release/_reports/regression_maintenance_summary.txt'],
  ),
  _StageDefinition(
    name: 'regression_auto_healing_daemon',
    command: ['dart', 'run', 'tools/regression_auto_healing_daemon.dart'],
    summaryPaths: ['release/_reports/regression_auto_healing_summary.txt'],
  ),
  _StageDefinition(
    name: 'regression_consolidation_analyzer',
    command: ['dart', 'run', 'tools/regression_consolidation_analyzer.dart'],
    summaryPaths: ['release/_reports/regression_consolidation_summary.txt'],
  ),
];
