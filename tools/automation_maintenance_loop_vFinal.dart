import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath =
    'release/_reports/automation_maintenance_vFinal_summary.txt';

const Duration _staleThreshold = Duration(days: 30);

const List<_OmegaAsset> _assets = [
  _OmegaAsset(
    label: 'Predictive Maintenance',
    path: 'release/_reports/predictive_maintenance_summary.txt',
    event: 'predictive_maintenance_completed',
  ),
  _OmegaAsset(
    label: 'Preventive Sweep Plan',
    path: 'release/_reports/preventive_sweep_plan.txt',
    event: 'preventive_sweep_completed',
  ),
  _OmegaAsset(
    label: 'Self-Maintenance Summary',
    path: 'release/_reports/self_maintenance_summary.txt',
    event: 'self_maintenance_verified',
  ),
  _OmegaAsset(
    label: 'Autonomous Feedback Closure',
    path: 'release/_reports/autonomous_feedback_closure_plan.txt',
    event: 'autonomous_feedback_closure_completed',
  ),
  _OmegaAsset(
    label: 'Visual Cohesion Autofix',
    path: 'release/_reports/visual_cohesion_autofix_summary.txt',
    event: 'visual_cohesion_autofix_completed',
  ),
  _OmegaAsset(
    label: 'Adaptive Curriculum Summary',
    path: 'release/_reports/adaptive_curriculum_summary.txt',
    event: 'adaptive_curriculum_expanded',
  ),
  _OmegaAsset(
    label: 'Drill Refinement Summary',
    path: 'release/_reports/drill_refinement_summary.txt',
    event: 'drill_refinement_completed',
  ),
  _OmegaAsset(
    label: 'Meta Review Consistency',
    path: 'release/_reports/meta_review_consistency_summary.txt',
    event: 'meta_review_consistency_completed',
  ),
  _OmegaAsset(
    label: 'Curriculum Snapshot',
    path: 'release/_reports/curriculum_snapshot_summary.txt',
    event: 'curriculum_snapshot_exported',
  ),
  _OmegaAsset(
    label: 'Visual Cohesion V3',
    path: 'release/_reports/visual_cohesion_v3_summary.txt',
    event: 'visual_cohesion_v3_completed',
  ),
];

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final telemetryEvents = await _loadTelemetry();

  final rows = <_AssetStatus>[];
  for (final asset in _assets) {
    rows.add(await _evaluateAsset(asset, telemetryEvents));
  }

  final total = rows.length;
  final pass = rows.where((r) => r.status == _Status.pass).length;
  final warn = rows.where((r) => r.status == _Status.warn).length;
  final fail = rows.where((r) => r.status == _Status.fail).length;
  final coveragePct = total == 0 ? 0.0 : (pass / total) * 100.0;

  await _withReportsWritable(() async {
    await _writeSummary(rows, coveragePct);
    await _appendTelemetry(
      pass: pass,
      warn: warn,
      fail: fail,
      coveragePct: coveragePct,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'automation_maintenance_loop_vFinal: pass=$pass warn=$warn fail=$fail',
  );
}

Future<List<Map<String, dynamic>>> _loadTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final events = <Map<String, dynamic>>[];
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        events.add(decoded);
      }
    } catch (_) {
      continue;
    }
  }
  return events;
}

Future<_AssetStatus> _evaluateAsset(
  _OmegaAsset asset,
  List<Map<String, dynamic>> telemetry,
) async {
  final file = File(asset.path);
  if (!await file.exists()) {
    return _AssetStatus(
      asset: asset,
      status: _Status.fail,
      notes: ['missing report'],
    );
  }

  final stat = await file.stat();
  final modified = stat.modified;
  final age = DateTime.now().difference(modified);
  final isStale = age > _staleThreshold;

  final events = telemetry.where((event) => event['event'] == asset.event);
  final hasTel = events.isNotEmpty;

  final notes = <String>[];
  _Status status = _Status.pass;

  if (isStale) {
    status = _Status.warn;
    notes.add('stale ${age.inDays}d');
  }

  if (!hasTel) {
    status = status == _Status.fail ? _Status.fail : _Status.warn;
    notes.add('telemetry missing (${asset.event})');
  } else {
    // ensure latest telemetry timestamp >= file mtime
    final latestTimestamp = events
        .map((e) => DateTime.tryParse(e['timestamp']?.toString() ?? ''))
        .whereType<DateTime>()
        .fold<DateTime?>(null, (prev, ts) {
          if (prev == null) return ts;
          return ts.isAfter(prev) ? ts : prev;
        });
    if (latestTimestamp != null && latestTimestamp.isBefore(modified)) {
      status = _Status.warn;
      notes.add('telemetry older than report');
    }
  }

  return _AssetStatus(
    asset: asset,
    status: status,
    notes: notes,
    lastModified: modified,
  );
}

Future<void> _writeSummary(List<_AssetStatus> rows, double coveragePct) async {
  final buffer = StringBuffer()
    ..writeln('AUTOMATION & MAINTENANCE LOOP — VFINAL')
    ..writeln('=====================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Coverage: ${coveragePct.toStringAsFixed(2)}%')
    ..writeln()
    ..writeln('| Asset | Status | Last Updated | Notes |')
    ..writeln('|-------|--------|--------------|-------|');

  for (final row in rows) {
    buffer.writeln(
      '| ${row.asset.label} | ${row.status.name.toUpperCase()} | '
      '${row.lastModified?.toIso8601String() ?? '-'} | '
      '${row.notes.isEmpty ? '-' : row.notes.join('; ')} |',
    );
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int pass,
  required int warn,
  required int fail,
  required double coveragePct,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'automation_maintenance_vFinal_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'pass': pass,
    'warn': warn,
    'fail': fail,
    'coverage_pct': double.parse(coveragePct.toStringAsFixed(2)),
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
      'automation_maintenance_loop_vFinal: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _OmegaAsset {
  const _OmegaAsset({
    required this.label,
    required this.path,
    required this.event,
  });

  final String label;
  final String path;
  final String event;
}

class _AssetStatus {
  const _AssetStatus({
    required this.asset,
    required this.status,
    required this.notes,
    this.lastModified,
  });

  final _OmegaAsset asset;
  final _Status status;
  final List<String> notes;
  final DateTime? lastModified;
}

enum _Status { pass, warn, fail }
