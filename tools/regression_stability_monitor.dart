import 'dart:convert';
import 'dart:io';

const String _stabilitySummaryPath =
    'release/_reports/stability_dashboard_summary.json';
const String _telemetrySummaryPath =
    'release/_reports/telemetry_consistency_summary.txt';
const String _historyPath =
    'release/_reports/_regression_stability_history.json';
const String _summaryOutPath =
    'release/_reports/regression_stability_summary.txt';
const String _telemetryOutPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  await RegressionStabilityMonitor().run();
}

class RegressionStabilityMonitor {
  Future<void> run() async {
    final stability = await _loadStabilitySnapshot();
    final telemetry = await _loadTelemetrySummary();
    final counts = _StatusCounts.fromReports(stability.reports);

    final now = DateTime.now().toUtc();
    final snapshotId =
        '${stability.generatedAtIso}|${telemetry.generatedIso ?? 'n/a'}';
    final newEntry = _HistoryEntry(
      snapshotId: snapshotId,
      recordedAtIso: now.toIso8601String(),
      stabilityGeneratedAt: stability.generatedAtIso,
      telemetryGeneratedAt: telemetry.generatedIso,
      healthScore: counts.passRatio,
      passRatio: counts.passRatio,
      warnRatio: counts.warnRatio,
      failRatio: counts.failRatio,
      telemetryVerdict: telemetry.verdict,
    );

    final history = await _loadHistory();
    final mergedHistory = _mergeHistory(history, newEntry);

    final verdict = _deriveVerdict(newEntry.healthScore);
    await _withReportsWritable(() async {
      await _writeSummary(
        snapshot: stability,
        telemetry: telemetry,
        counts: counts,
        entry: newEntry,
        history: mergedHistory,
        verdict: verdict,
      );
      await _writeHistory(mergedHistory);
      await _emitTelemetry(
        entry: newEntry,
        verdict: verdict,
        totalRuns: mergedHistory.length,
      );
    });

    if (verdict.verdict == _Verdict.fail) {
      exitCode = 2;
    }
  }
}

class _StabilitySnapshot {
  const _StabilitySnapshot({
    required this.generatedAtIso,
    required this.healthScore,
    required this.reports,
  });

  final String generatedAtIso;
  final double healthScore;
  final List<_ReportStatus> reports;
}

class _ReportStatus {
  const _ReportStatus(this.name, this.status);

  final String name;
  final String status;
}

class _TelemetrySummary {
  const _TelemetrySummary({required this.generatedIso, required this.verdict});

  final String? generatedIso;
  final String verdict;
}

class _StatusCounts {
  _StatusCounts(this.pass, this.warn, this.fail);

  final int pass;
  final int warn;
  final int fail;

  int get total => pass + warn + fail;

  double get passRatio => _ratio(pass);

  double get warnRatio => _ratio(warn);

  double get failRatio => _ratio(fail);

  double _ratio(int value) {
    if (total == 0) {
      return 0;
    }
    return (value / total) * 100;
  }

  static _StatusCounts fromReports(List<_ReportStatus> reports) {
    var pass = 0;
    var warn = 0;
    var fail = 0;
    for (final report in reports) {
      switch (report.status) {
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
    }
    return _StatusCounts(pass, warn, fail);
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.snapshotId,
    required this.recordedAtIso,
    required this.stabilityGeneratedAt,
    required this.telemetryGeneratedAt,
    required this.healthScore,
    required this.passRatio,
    required this.warnRatio,
    required this.failRatio,
    required this.telemetryVerdict,
  });

  final String snapshotId;
  final String recordedAtIso;
  final String stabilityGeneratedAt;
  final String? telemetryGeneratedAt;
  final double healthScore;
  final double passRatio;
  final double warnRatio;
  final double failRatio;
  final String telemetryVerdict;

  Map<String, Object?> toJson() => <String, Object?>{
    'snapshot_id': snapshotId,
    'recorded_at': recordedAtIso,
    'stability_generated_at': stabilityGeneratedAt,
    'telemetry_generated_at': telemetryGeneratedAt,
    'health_score': healthScore,
    'pass_ratio': passRatio,
    'warn_ratio': warnRatio,
    'fail_ratio': failRatio,
    'telemetry_verdict': telemetryVerdict,
  };

  static _HistoryEntry fromJson(Map<String, Object?> json) {
    return _HistoryEntry(
      snapshotId: json['snapshot_id']?.toString() ?? '',
      recordedAtIso: json['recorded_at']?.toString() ?? '',
      stabilityGeneratedAt:
          json['stability_generated_at']?.toString() ?? 'unknown',
      telemetryGeneratedAt: json['telemetry_generated_at']?.toString(),
      healthScore: _asDouble(json['health_score']),
      passRatio: _asDouble(json['pass_ratio']),
      warnRatio: _asDouble(json['warn_ratio']),
      failRatio: _asDouble(json['fail_ratio']),
      telemetryVerdict: json['telemetry_verdict']?.toString() ?? 'UNKNOWN',
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }
}

enum _Verdict { pass, warn, fail }

Future<_StabilitySnapshot> _loadStabilitySnapshot() async {
  final file = File(_stabilitySummaryPath);
  if (!await file.exists()) {
    throw StateError(
      'Missing stability dashboard summary at '
      '$_stabilitySummaryPath',
    );
  }
  final decoded = json.decode(await file.readAsString());
  if (decoded is! Map<String, Object?>) {
    throw StateError('Invalid stability dashboard summary format.');
  }
  final reportsRaw = decoded['reports'];
  if (reportsRaw is! List) {
    throw StateError('Stability summary missing reports array.');
  }
  final reports = <_ReportStatus>[];
  for (final item in reportsRaw) {
    if (item is Map<String, Object?>) {
      final fileName = item['file']?.toString() ?? 'unknown';
      final status = item['status']?.toString().toUpperCase() ?? 'WARN';
      reports.add(_ReportStatus(fileName, status));
    }
  }
  final generated = decoded['generated_at']?.toString() ?? 'unknown';
  final healthScore = decoded['health_score'];
  if (healthScore is! num) {
    throw StateError('Stability summary missing numeric health_score.');
  }
  return _StabilitySnapshot(
    generatedAtIso: generated,
    healthScore: healthScore.toDouble(),
    reports: reports,
  );
}

Future<_TelemetrySummary> _loadTelemetrySummary() async {
  final file = File(_telemetrySummaryPath);
  if (!await file.exists()) {
    throw StateError('Missing telemetry summary at $_telemetrySummaryPath');
  }
  final lines = await file.readAsLines();
  String? generated;
  String? verdict;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = _valueAfterColon(trimmed);
    } else if (trimmed.startsWith('Verdict:')) {
      final value = _valueAfterColon(trimmed);
      verdict = value?.toUpperCase();
    }
  }
  return _TelemetrySummary(
    generatedIso: generated,
    verdict: verdict ?? 'UNKNOWN',
  );
}

Future<List<_HistoryEntry>> _loadHistory() async {
  final file = File(_historyPath);
  if (!await file.exists()) {
    return <_HistoryEntry>[];
  }
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map(
            (item) => _HistoryEntry.fromJson(Map<String, Object?>.from(item)),
          )
          .toList();
    }
  } catch (_) {
    // ignore corrupt history and start fresh
  }
  return <_HistoryEntry>[];
}

List<_HistoryEntry> _mergeHistory(
  List<_HistoryEntry> history,
  _HistoryEntry entry,
) {
  final merged = List<_HistoryEntry>.from(history);
  final existingIndex = merged.indexWhere(
    (item) => item.snapshotId == entry.snapshotId,
  );
  if (existingIndex >= 0) {
    merged[existingIndex] = entry;
  } else {
    merged.add(entry);
    if (merged.length > 10) {
      merged.removeRange(0, merged.length - 10);
    }
  }
  return merged;
}

VerdictContext _deriveVerdict(double healthPercent) {
  if (healthPercent >= 95) {
    return VerdictContext(_Verdict.pass, 'Health >= 95%');
  }
  if (healthPercent >= 90) {
    return VerdictContext(_Verdict.warn, 'Health between 90% and 95%');
  }
  return VerdictContext(_Verdict.fail, 'Health below 90% threshold');
}

class VerdictContext {
  const VerdictContext(this.verdict, this.reason);

  final _Verdict verdict;
  final String reason;
}

Future<void> _writeSummary({
  required _StabilitySnapshot snapshot,
  required _TelemetrySummary telemetry,
  required _StatusCounts counts,
  required _HistoryEntry entry,
  required List<_HistoryEntry> history,
  required VerdictContext verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION STABILITY SUMMARY')
    ..writeln('============================')
    ..writeln('Command: dart run tools/regression_stability_monitor.dart')
    ..writeln('Generated: ${entry.recordedAtIso}')
    ..writeln(
      'Snapshots: stability=${snapshot.generatedAtIso} | '
      'telemetry=${telemetry.generatedIso ?? 'unknown'}',
    )
    ..writeln(
      'Health score (pass ratio): ${entry.healthScore.toStringAsFixed(2)}%',
    )
    ..writeln(
      'Stability health_score field: '
      '${snapshot.healthScore.toStringAsFixed(2)}%',
    )
    ..writeln('Pass ratio: ${counts.passRatio.toStringAsFixed(2)}%')
    ..writeln('Warn ratio: ${counts.warnRatio.toStringAsFixed(2)}%')
    ..writeln('Fail ratio: ${counts.failRatio.toStringAsFixed(2)}%')
    ..writeln('Telemetry verdict: ${telemetry.verdict}')
    ..writeln('Verdict: ${verdict.verdict.name.toUpperCase()}')
    ..writeln('Reason: ${verdict.reason}')
    ..writeln();

  if (history.isNotEmpty) {
    buffer
      ..writeln('Rolling ratios (latest ${history.length} / 10):')
      ..writeln(_formatHistory(history))
      ..writeln();
  }

  buffer
    ..writeln('Totals:')
    ..writeln('- Reports scanned: ${counts.total}')
    ..writeln('- PASS: ${counts.pass}')
    ..writeln('- WARN: ${counts.warn}')
    ..writeln('- FAIL: ${counts.fail}');

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

String _formatHistory(List<_HistoryEntry> history) {
  final buffer = StringBuffer();
  for (final entry in history) {
    buffer.writeln(
      '- ${entry.recordedAtIso} | health='
      '${entry.healthScore.toStringAsFixed(2)}% '
      '| P=${entry.passRatio.toStringAsFixed(1)}% '
      'W=${entry.warnRatio.toStringAsFixed(1)}% '
      'F=${entry.failRatio.toStringAsFixed(1)}% '
      '| telemetry=${entry.telemetryVerdict}',
    );
  }
  return buffer.toString();
}

Future<void> _writeHistory(List<_HistoryEntry> history) async {
  final file = File(_historyPath);
  final payload = history.map((entry) => entry.toJson()).toList();
  await file.writeAsString(jsonEncode(payload));
}

Future<void> _emitTelemetry({
  required _HistoryEntry entry,
  required VerdictContext verdict,
  required int totalRuns,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_stability_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'snapshot_id': entry.snapshotId,
    'health_score': entry.healthScore,
    'pass_ratio': entry.passRatio,
    'warn_ratio': entry.warnRatio,
    'fail_ratio': entry.failRatio,
    'telemetry_verdict': entry.telemetryVerdict,
    'total_runs_recorded': totalRuns,
    'verdict': verdict.verdict.name.toUpperCase(),
    'reason': verdict.reason,
  };
  final sink = File(_telemetryOutPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

String? _valueAfterColon(String line) {
  final index = line.indexOf(':');
  if (index == -1) {
    return null;
  }
  return line.substring(index + 1).trim();
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
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'regression_stability_monitor: chmod failed (${result.exitCode}) '
      '${result.stderr}',
    );
  }
}
