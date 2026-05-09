/// Regression normalization + freshness logic applied per Ω-9b.4 spec
/// (auto-rerun stale reports, normalize WARN/PASS thresholds, dedupe FAILs,
///  guard writes).
import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _summaryPath =
    '$_reportsDir/continuous_regression_guardian_summary.txt';
const String _ledgerPath = '$_reportsDir/_continuous_regression_ledger.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _rsiThreshold = 90.0;
const double _rsiDeltaFloor = -5.0;

Future<void> main(List<String> args) async {
  final isFast = args.contains('--fast');
  final guardian = ContinuousRegressionGuardian();
  final ok = await guardian.run(isFast: isFast);
  if (!ok) {
    exitCode = 2;
  }
}

class ContinuousRegressionGuardian {
  Future<bool> run({bool isFast = false}) async {
    final stopwatch = Stopwatch()..start();
    final stageResults = <_StageResult>[];

    var success = false;
    await _withReportsWritable(() async {
      // Ensure dependent summaries are fresh before running stages.
      if (!isFast) {
        await _ensureFresh();

        stageResults.add(await _runStage('regression_maintenance_loop'));
        final rsiAfterMaintenance = await _readRsi();
        if (rsiAfterMaintenance < _rsiThreshold) {
          stageResults.add(await _runStage('regression_auto_healing_daemon'));
        }
        stageResults.add(await _runStage('regression_consolidation_analyzer'));
        stageResults.add(await _runStage('continuous_audit_rebuild'));
      }

      // Recompute normalized PASS ratio with deduped FAILs prior to summary.
      final metrics = await _loadRegressionMetrics();
      final summaryStats = await _collectSummaryStats(metrics);

      final rsi = await _readRsi();
      final outcome = await _finalize(
        stageResults: stageResults,
        rsi: rsi,
        durationMs: stopwatch.elapsedMilliseconds,
        normalizedPassRatio: summaryStats.passRatio,
        isFast: isFast,
      );
      success = outcome.success;
    });
    return success;
  }

  Future<_GuardianOutcome> _finalize({
    required List<_StageResult> stageResults,
    required double rsi,
    required int durationMs,
    required double normalizedPassRatio,
    required bool isFast,
  }) async {
    final generatedAtIso = DateTime.now().toIso8601String();
    final ledger = await _safeReadLedger();
    final previousRsi = ledger.isNotEmpty
        ? (ledger.last['rsi'] as num?)?.toDouble() ?? 0
        : 0;
    final rsiDelta = rsi - previousRsi;
    final rdi = await _readRdi();

    var fsStatus = 'ok';
    final warnings = <String>[];
    final ledgerWriteResult = await _writeReportsFile(
      path: _ledgerPath,
      contents: () {
        final updatedLedger = List<Map<String, Object?>>.from(ledger)
          ..add({
            'timestamp': generatedAtIso,
            'rsi': rsi,
            'rdi': rdi,
            'rsi_delta': rsiDelta,
            'duration_ms': durationMs,
          });
        while (updatedLedger.length > 20) {
          updatedLedger.removeAt(0);
        }
        return const JsonEncoder.withIndent('  ').convert(updatedLedger);
      }(),
    );
    if (!ledgerWriteResult.success) {
      fsStatus = 'warn';
      warnings.add(ledgerWriteResult.message);
    }

    var success =
        fsStatus == 'ok' && rsi >= _rsiThreshold && rsiDelta >= _rsiDeltaFloor;

    var summaryText = _buildSummary(
      generatedAtIso: generatedAtIso,
      durationMs: durationMs,
      rsi: rsi,
      rdi: rdi,
      rsiDelta: rsiDelta,
      normalizedPassRatio: normalizedPassRatio,
      isFast: isFast,
      warnings: warnings,
      fsStatus: fsStatus,
      success: success,
      stageResults: stageResults,
    );
    final summaryWriteResult = await _writeReportsFile(
      path: _summaryPath,
      contents: summaryText,
    );
    if (!summaryWriteResult.success) {
      fsStatus = 'warn';
      success = false;
      warnings.add(summaryWriteResult.message);
      summaryText = _buildSummary(
        generatedAtIso: generatedAtIso,
        durationMs: durationMs,
        rsi: rsi,
        rdi: rdi,
        rsiDelta: rsiDelta,
        normalizedPassRatio: normalizedPassRatio,
        isFast: isFast,
        warnings: warnings,
        fsStatus: fsStatus,
        success: false,
        stageResults: stageResults,
      );
      final fallbackWriteResult = await _writeReportsFile(
        path: _summaryPath,
        contents: summaryText,
      );
      if (!fallbackWriteResult.success) {
        warnings.add(fallbackWriteResult.message);
        stderr.writeln(fallbackWriteResult.message);
      }
    }

    await _emitTelemetry(
      generatedAtIso: generatedAtIso,
      rsi: rsi,
      rdi: rdi,
      rsiDelta: rsiDelta,
      durationMs: durationMs,
      fsStatus: fsStatus,
      warnings: warnings,
      verdict: success ? 'PASS' : 'FAIL',
    );

    return _GuardianOutcome(success: success);
  }

  Future<_StageResult> _runStage(String target) async {
    final stageCommand = _StageRunner.commandFor(target);
    final stopwatch = Stopwatch()..start();
    final result = await Process.run(
      stageCommand.first,
      stageCommand.sublist(1),
      workingDirectory: Directory.current.path,
    );
    stopwatch.stop();
    return _StageResult(
      name: target,
      exitCode: result.exitCode,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<double> _readRsi() async {
    final file = File('$_reportsDir/regression_maintenance_summary.txt');
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

  Future<double> _readRdi() async {
    final file = File('$_reportsDir/engagement_correlation_summary.txt');
    if (!await file.exists()) return 0;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Retention Health Index:')) {
        final value = trimmed.split(':').last.trim().replaceAll('%', '');
        return double.tryParse(value) ?? 0;
      }
    }
    return 0;
  }

  Future<List<Map<String, Object?>>> _safeReadLedger() async {
    final file = File(_ledgerPath);
    if (!await file.exists()) return [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((entry) => entry.cast<String, Object?>())
            .toList();
      }
    } catch (_) {}
    return [];
  }
}

String _buildSummary({
  required String generatedAtIso,
  required int durationMs,
  required double rsi,
  required double rdi,
  required double rsiDelta,
  required double normalizedPassRatio,
  required bool isFast,
  required List<String> warnings,
  required String fsStatus,
  required bool success,
  required List<_StageResult> stageResults,
}) {
  final buffer = StringBuffer()
    ..writeln('CONTINUOUS REGRESSION GUARDIAN SUMMARY')
    ..writeln('======================================')
    ..writeln('Generated: $generatedAtIso')
    ..writeln(isFast ? 'Mode: FAST (no child tools re-run)' : 'Mode: FULL')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('RSI: ${rsi.toStringAsFixed(2)}%')
    ..writeln('RDI: ${rdi.toStringAsFixed(2)}')
    ..writeln('RSI delta vs previous: ${rsiDelta.toStringAsFixed(2)}')
    ..writeln(
      'Normalized PASS ratio: ${normalizedPassRatio.toStringAsFixed(2)}%',
    );
  if (warnings.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Warnings:');
    for (final warning in warnings) {
      buffer.writeln('-- $warning');
    }
  }
  buffer
    ..writeln()
    ..writeln('FS write status: $fsStatus')
    ..writeln('Verdict: ${success ? 'PASS' : 'FAIL'}')
    ..writeln()
    ..writeln('Stage results:');
  for (final stage in stageResults) {
    buffer.writeln(
      '- ${stage.name}: exit ${stage.exitCode} (${stage.durationMs}ms)',
    );
  }
  return buffer.toString();
}

// Ω-9b.4 helpers: freshness, normalization, pass ratio, dedupe, telemetry

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

class _RegressionMetrics {
  const _RegressionMetrics({required this.rsi, required this.health});
  final double rsi;
  final double health;
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
    final verdict = await _extractVerdictFromFile(entity);
    if (verdict == null) continue;
    if (!name.startsWith('regression_')) {
      other++;
      continue;
    }
    final normalized = _normalizeVerdict(verdict, metrics);
    if (normalized == 'FAIL') {
      if (!seenFails.add(name)) continue; // dedupe FAILs
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

Future<String?> _extractVerdictFromFile(File file) async {
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

Future<void> _ensureFresh() async {
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
    try {
      final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
      sink.writeln(jsonEncode(payload));
      await sink.close();
    } catch (_) {}
  });
}

Future<void> _emitTelemetry({
  required String generatedAtIso,
  required double rsi,
  required double rdi,
  required double rsiDelta,
  required int durationMs,
  required String fsStatus,
  required List<String> warnings,
  required String verdict,
}) async {
  final payload = {
    'event': 'continuous_regression_guardian_completed',
    'timestamp': generatedAtIso,
    'rsi': rsi,
    'rdi': rdi,
    'rsi_delta': rsiDelta,
    'duration_ms': durationMs,
    'fs_write_status': fsStatus,
    'warnings': warnings,
    'verdict': verdict,
  };
  try {
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  } catch (error) {
    stderr.writeln('WARN: unable to append telemetry: $error');
  }
}

Future<_FileWriteResult> _writeReportsFile({
  required String path,
  required String contents,
}) async {
  final file = File(path);
  try {
    await file.parent.create(recursive: true);
  } catch (_) {}
  await _ensureWritable(file.parent);
  await _ensureWritable(file);
  try {
    await file.writeAsString(contents);
    return const _FileWriteResult(success: true, message: '');
  } catch (error) {
    return _FileWriteResult(
      success: false,
      message: 'FS_WRITE_WARN: unable to write $path. $error',
    );
  }
}

Future<void> _ensureWritable(FileSystemEntity entity) async {
  try {
    await Process.run('chmod', ['u+w', entity.path]);
  } catch (_) {}
}

class _FileWriteResult {
  const _FileWriteResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class _StageResult {
  _StageResult({
    required this.name,
    required this.exitCode,
    required this.durationMs,
  });

  final String name;
  final int exitCode;
  final int durationMs;
}

class _GuardianOutcome {
  _GuardianOutcome({required this.success});

  final bool success;
}

class _StageRunner {
  static List<String> commandFor(String target) {
    switch (target) {
      case 'regression_maintenance_loop':
        return ['dart', 'run', 'tools/regression_maintenance_loop.dart'];
      case 'regression_auto_healing_daemon':
        return ['dart', 'run', 'tools/regression_auto_healing_daemon.dart'];
      case 'regression_consolidation_analyzer':
        return ['dart', 'run', 'tools/regression_consolidation_analyzer.dart'];
      case 'continuous_audit_rebuild':
        return ['dart', 'run', 'tools/continuous_audit_rebuild.dart'];
      default:
        throw StateError('Unknown target: $target');
    }
  }
}

Future<bool> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
  return true;
}
