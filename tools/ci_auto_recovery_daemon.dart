/// Regression normalization + freshness logic applied per Ω-9b.4 spec
/// (auto-rerun stale reports, normalize WARN/PASS thresholds, dedupe FAILs,
///  guard writes).
import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/ci_auto_recovery_summary.txt';
const String _statePath = 'release/_reports/_ci_auto_recovery_state.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const Duration _staleThreshold = Duration(hours: 4);

Future<void> main(List<String> args) async {
  final isFast = args.contains('--fast');
  await CiAutoRecoveryDaemon().run(isFast: isFast);
}

class CiAutoRecoveryDaemon {
  Future<void> run({bool isFast = false}) async {
    final now = DateTime.now().toUtc();
    // Refresh key regression summaries if stale before analysis.
    if (!isFast) {
      await _ensureFresh();
    }
    final state = await _RecoveryState.load();
    final reports = await _collectReports();

    final managedReports = reports
        .where(
          (report) => report.command != null && report.path != _summaryPath,
        )
        .toList();
    final managedFailures = managedReports
        .where((report) => report.verdict == 'FAIL')
        .toList();
    final unmanagedFailures = reports
        .where((report) => report.verdict == 'FAIL' && report.command == null)
        .toList();
    final staleReports = reports
        .where((report) => report.isStale(now))
        .toList();

    final candidate = isFast ? null : _selectCandidate(managedFailures);
    AttemptResult? attemptResult;
    String attemptNote = 'Auto-recovery attempt: not required.';
    if (!isFast && candidate != null) {
      if (state.alreadyAttempted(candidate.path, candidate.snapshotId)) {
        attemptNote =
            'Auto-recovery skipped (snapshot ${candidate.snapshotId} already attempted).';
      } else {
        attemptResult = await _rerun(candidate);
        attemptNote = 'Auto-recovery command executed.';
        state.recordAttempt(
          candidate.path,
          candidate.snapshotId,
          attemptResult.exitCode == 0,
        );
        await _withReportsWritable(() async {
          await state.save();
        });
      }
    }

    final verdict = _deriveVerdict(
      attemptResult: attemptResult,
      managedFailures: managedFailures,
      unmanagedFailures: unmanagedFailures,
      staleReports: staleReports,
    );

    final regressionMetrics = await _loadRegressionMetrics();
    final summaryStats = await _collectSummaryStats(regressionMetrics);

    await _withReportsWritable(() async {
      await _writeSummary(
        generatedAt: now,
        totalReports: reports.length,
        managedReports: managedReports.length,
        staleReports: staleReports,
        managedFailures: managedFailures,
        unmanagedFailures: unmanagedFailures,
        candidate: candidate,
        attemptResult: attemptResult,
        attemptNote: attemptNote,
        verdict: verdict,
        normalizedPassRatio: summaryStats.passRatio,
        isFast: isFast,
      );
      await _emitTelemetry(
        generatedAt: now,
        managedReports: managedReports.length,
        staleCount: staleReports.length,
        managedFailures: managedFailures.length,
        unmanagedFailures: unmanagedFailures.length,
        attemptResult: attemptResult,
        attemptNote: attemptNote,
        verdict: verdict,
      );
    });

    if (verdict.verdict == _Verdict.fail) {
      exitCode = 2;
    }
  }
}

class _ReportMeta {
  _ReportMeta({
    required this.path,
    required this.verdict,
    required this.generated,
    required this.modified,
    required this.command,
  });

  final String path;
  final String? verdict;
  final DateTime? generated;
  final DateTime modified;
  final String? command;

  DateTime get referenceTime => generated ?? modified;

  String get snapshotId => '$path|${referenceTime.toIso8601String()}';

  bool isStale(DateTime now) {
    final reference = referenceTime;
    final age = now.isAfter(reference)
        ? now.difference(reference)
        : reference.difference(now);
    return age > _staleThreshold;
  }
}

class AttemptResult {
  const AttemptResult({
    required this.command,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final String command;
  final int exitCode;
  final String stdout;
  final String stderr;
}

enum _Verdict { pass, warn, fail }

class _RecoveryState {
  _RecoveryState(this.attempts);

  final Map<String, Object?> attempts;

  bool alreadyAttempted(String path, String snapshotId) {
    final data = attempts[path];
    if (data is Map<String, Object?>) {
      return data['snapshot_id'] == snapshotId;
    }
    return false;
  }

  void recordAttempt(String path, String snapshotId, bool success) {
    attempts[path] = <String, Object?>{
      'snapshot_id': snapshotId,
      'success': success,
    };
  }

  static Future<_RecoveryState> load() async {
    final file = File(_statePath);
    if (!await file.exists()) {
      return _RecoveryState(<String, Object?>{});
    }
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, Object?>) {
        return _RecoveryState(decoded);
      }
    } catch (_) {
      // ignore malformed state
    }
    return _RecoveryState(<String, Object?>{});
  }

  Future<void> save() async {
    final file = File(_statePath);
    await file.writeAsString(jsonEncode(attempts));
  }
}

Future<List<_ReportMeta>> _collectReports() async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    throw StateError('Reports directory missing at $_reportsDir');
  }
  final entities = dir.listSync().whereType<File>().where(
    (file) => file.path.endsWith('_summary.txt'),
  );
  final reports = <_ReportMeta>[];
  for (final file in entities) {
    final meta = await _parseSummary(file);
    reports.add(meta);
  }
  return reports;
}

Future<_ReportMeta> _parseSummary(File file) async {
  final lines = await file.readAsLines();
  String? verdict;
  DateTime? generated;
  String? command;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Verdict:')) {
      final value = _valueAfterColon(trimmed);
      verdict = value?.toUpperCase();
    } else if (trimmed.startsWith('Generated:')) {
      final value = _valueAfterColon(trimmed);
      generated = value == null ? null : _tryParseIso(value);
    } else if (trimmed.startsWith('Command:')) {
      command = _valueAfterColon(trimmed);
    }
  }
  final modified = await file.lastModified();
  return _ReportMeta(
    path: file.path,
    verdict: verdict,
    generated: generated,
    modified: modified.toUtc(),
    command: command?.isEmpty ?? true ? null : command,
  );
}

DateTime? _tryParseIso(String value) {
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}

_ReportMeta? _selectCandidate(List<_ReportMeta> failures) {
  if (failures.isEmpty) {
    return null;
  }
  failures.sort((a, b) => b.referenceTime.compareTo(a.referenceTime));
  return failures.first;
}

Future<AttemptResult> _rerun(_ReportMeta candidate) async {
  final result = await Process.run('bash', [
    '-lc',
    candidate.command!,
  ], workingDirectory: Directory.current.path);
  return AttemptResult(
    command: candidate.command!,
    exitCode: result.exitCode,
    stdout: (result.stdout ?? '').toString(),
    stderr: (result.stderr ?? '').toString(),
  );
}

VerdictContext _deriveVerdict({
  AttemptResult? attemptResult,
  required List<_ReportMeta> managedFailures,
  required List<_ReportMeta> unmanagedFailures,
  required List<_ReportMeta> staleReports,
}) {
  if (attemptResult != null && attemptResult.exitCode != 0) {
    return VerdictContext(
      _Verdict.fail,
      'Auto-recovery attempt did not succeed.',
    );
  }
  if (managedFailures.isEmpty &&
      unmanagedFailures.isEmpty &&
      staleReports.isEmpty) {
    return VerdictContext(_Verdict.pass, 'All managed reports healthy.');
  }
  return VerdictContext(
    _Verdict.warn,
    'Issues detected (stale or unmanaged failures) but no blocking recovery errors.',
  );
}

class VerdictContext {
  const VerdictContext(this.verdict, this.reason);

  final _Verdict verdict;
  final String reason;
}

Future<void> _writeSummary({
  required DateTime generatedAt,
  required int totalReports,
  required int managedReports,
  required List<_ReportMeta> staleReports,
  required List<_ReportMeta> managedFailures,
  required List<_ReportMeta> unmanagedFailures,
  _ReportMeta? candidate,
  AttemptResult? attemptResult,
  required String attemptNote,
  required VerdictContext verdict,
  required double normalizedPassRatio,
  bool isFast = false,
}) async {
  final buffer = StringBuffer()
    ..writeln('CI AUTO RECOVERY SUMMARY')
    ..writeln('========================')
    ..writeln('Command: dart run tools/ci_auto_recovery_daemon.dart')
    ..writeln('Generated: ${generatedAt.toIso8601String()}')
    ..writeln(isFast ? 'Mode: FAST (no child tools re-run)' : 'Mode: FULL')
    ..writeln('Reports scanned: $managedReports managed / $totalReports total')
    ..writeln('Stale threshold: ${_staleThreshold.inHours}h')
    ..writeln('Verdict: ${verdict.verdict.name.toUpperCase()}')
    ..writeln('Reason: ${verdict.reason}')
    ..writeln(
      'Normalized PASS ratio: ${normalizedPassRatio.toStringAsFixed(2)}%',
    )
    ..writeln();

  if (staleReports.isNotEmpty) {
    buffer.writeln('Stale reports:');
    for (final report in staleReports.take(5)) {
      buffer.writeln(
        '- ${report.path} (${report.referenceTime.toIso8601String()})',
      );
    }
    if (staleReports.length > 5) {
      buffer.writeln('- ... ${staleReports.length - 5} more');
    }
    buffer.writeln();
  }

  if (unmanagedFailures.isNotEmpty) {
    buffer.writeln('Unmanaged FAIL reports (no command metadata):');
    for (final report in unmanagedFailures.take(5)) {
      buffer.writeln('- ${report.path}');
    }
    if (unmanagedFailures.length > 5) {
      buffer.writeln('- ... ${unmanagedFailures.length - 5} more');
    }
    buffer.writeln();
  }

  if (managedFailures.isNotEmpty) {
    buffer.writeln('Managed FAIL reports:');
    for (final report in managedFailures) {
      buffer.writeln('- ${report.path} (command: ${report.command})');
    }
    buffer.writeln();
  }

  if (candidate != null) {
    buffer.writeln('Auto-recovery target: ${candidate.path}');
  } else {
    buffer.writeln('Auto-recovery target: none (no managed FAIL reports).');
  }

  if (attemptResult != null) {
    buffer
      ..writeln('Auto-recovery command: ${attemptResult.command}')
      ..writeln('Exit code: ${attemptResult.exitCode}')
      ..writeln('Stdout (truncated): ${_truncate(attemptResult.stdout)}')
      ..writeln('Stderr (truncated): ${_truncate(attemptResult.stderr)}');
  } else {
    buffer.writeln(attemptNote);
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

String _truncate(String value, [int max = 400]) {
  final clean = value.replaceAll('\x1B', '');
  if (clean.length <= max) {
    return clean;
  }
  return '${clean.substring(0, max)}...';
}

String? _valueAfterColon(String line) {
  final index = line.indexOf(':');
  if (index == -1) {
    return null;
  }
  return line.substring(index + 1).trim();
}

Future<void> _emitTelemetry({
  required DateTime generatedAt,
  required int managedReports,
  required int staleCount,
  required int managedFailures,
  required int unmanagedFailures,
  AttemptResult? attemptResult,
  required String attemptNote,
  required VerdictContext verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'ci_auto_recovery_completed',
    'timestamp': generatedAt.toIso8601String(),
    'managed_reports': managedReports,
    'stale_reports': staleCount,
    'managed_failures': managedFailures,
    'unmanaged_failures': unmanagedFailures,
    'attempted_command': attemptResult?.command,
    'attempt_exit_code': attemptResult?.exitCode,
    'attempt_note': attemptNote,
    'verdict': verdict.verdict.name.toUpperCase(),
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

// Ω-9b.4 normalization helpers

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
    final verdict = await _extractVerdictForNormalization(entity);
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

Future<String?> _extractVerdictForNormalization(File file) async {
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

const Duration _freshnessNormThreshold = Duration(hours: 24);

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
    final needsRefresh = !await file.exists() || await _isStaleForNorm(file);
    if (!needsRefresh) continue;
    final result = await Process.run(
      t.command.first,
      t.command.sublist(1),
      workingDirectory: Directory.current.path,
    );
    await _appendRefreshTelemetry(t.event, t.path, result.exitCode);
  }
}

Future<bool> _isStaleForNorm(File file) async {
  try {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Generated:')) {
        final iso = trimmed.split(':').last.trim();
        final timestamp = DateTime.tryParse(iso);
        if (timestamp == null) return true;
        return DateTime.now().difference(timestamp) > _freshnessNormThreshold;
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
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
