import 'dart:convert';
import 'dart:io';

const String _planPath = 'release/_reports/self_optimization_v2_plan.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _summaryPath =
    'release/_reports/maintenance_automation_v2_summary.txt';

const Duration _reportMaxAge = Duration(days: 30);

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final plan = await _readPlan();
  final telemetry = await _readTelemetry(limit: 50);
  final expiredReports = await _findExpiredReports(maxAge: _reportMaxAge);
  final pendingActions = _detectPendingActions(plan, telemetry);

  await _withReportsWritable(() async {
    await _writeSummary(
      expiredReports: expiredReports,
      pendingActions: pendingActions,
      telemetry: telemetry,
    );
    await _appendTelemetry(
      expiredReports: expiredReports.length,
      pendingActions: pendingActions.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'maintenance_automation_v2: reports=${expiredReports.length} '
    'pending=${pendingActions.length}',
  );
}

class _ActionItem {
  const _ActionItem({
    required this.dimension,
    required this.score,
    required this.priority,
    required this.description,
  });

  final String dimension;
  final double score;
  final double priority;
  final String description;
}

class _PlanSnapshot {
  const _PlanSnapshot({required this.generated, required this.actions});

  final DateTime? generated;
  final List<_ActionItem> actions;
}

class _TelemetryEvent {
  const _TelemetryEvent({
    required this.event,
    required this.timestamp,
    required this.raw,
  });

  final String event;
  final DateTime? timestamp;
  final Map<String, dynamic> raw;
}

Future<_PlanSnapshot> _readPlan() async {
  final file = File(_planPath);
  if (!await file.exists()) {
    return const _PlanSnapshot(generated: null, actions: []);
  }
  DateTime? generated;
  final actions = <_ActionItem>[];
  final lines = await file.readAsLines();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
    }
    if (trimmed.startsWith('|')) {
      final columns = trimmed.split('|').map((c) => c.trim()).toList();
      if (columns.length >= 5) {
        final dimension = columns[1];
        if (dimension.isEmpty ||
            dimension.toLowerCase() == 'dimension' ||
            dimension.startsWith('-')) {
          continue;
        }
        final score = double.tryParse(columns[2]) ?? 0.0;
        final priority = double.tryParse(columns[3]) ?? 0.0;
        final action = columns[4];
        actions.add(
          _ActionItem(
            dimension: dimension,
            score: score,
            priority: priority,
            description: action,
          ),
        );
      }
    }
  }
  return _PlanSnapshot(generated: generated, actions: actions);
}

Future<List<_TelemetryEvent>> _readTelemetry({int limit = 50}) async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final events = <_TelemetryEvent>[];
  for (final line in lines.reversed.take(limit)) {
    if (line.trim().isEmpty) continue;
    try {
      final data = json.decode(line);
      if (data is Map<String, dynamic>) {
        events.add(
          _TelemetryEvent(
            event: data['event']?.toString() ?? 'unknown',
            timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? ''),
            raw: data,
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }
  return events;
}

Future<List<_ReportStatus>> _findExpiredReports({
  required Duration maxAge,
}) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) return const [];
  final now = DateTime.now();
  final statuses = <_ReportStatus>[];
  await for (final entity in dir.list()) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('_summary.txt')) continue;
    final modified = await entity.lastModified();
    final age = now.difference(modified);
    if (age > maxAge) {
      statuses.add(_ReportStatus(path: entity.path, ageDays: age.inDays));
    }
  }
  statuses.sort((a, b) => b.ageDays.compareTo(a.ageDays));
  return statuses;
}

class _ReportStatus {
  const _ReportStatus({required this.path, required this.ageDays});

  final String path;
  final int ageDays;
}

List<_ActionItem> _detectPendingActions(
  _PlanSnapshot plan,
  List<_TelemetryEvent> telemetry,
) {
  if (plan.actions.isEmpty) return const [];
  final planTime = plan.generated;
  final pending = <_ActionItem>[];
  for (final action in plan.actions) {
    final keyword = action.dimension.toLowerCase();
    final addressed = telemetry.any((event) {
      if (planTime != null &&
          event.timestamp != null &&
          event.timestamp!.isBefore(planTime)) {
        return false;
      }
      return event.event.toLowerCase().contains(keyword);
    });
    if (!addressed) {
      pending.add(action);
    }
  }
  return pending;
}

Future<void> _writeSummary({
  required List<_ReportStatus> expiredReports,
  required List<_ActionItem> pendingActions,
  required List<_TelemetryEvent> telemetry,
}) async {
  final reportStatus = _statusLabel(expiredReports.length);
  final actionStatus = _statusLabel(pendingActions.length);
  final overallStatus = _overallStatus(reportStatus, actionStatus);

  final buffer = StringBuffer()
    ..writeln('MAINTENANCE AUTOMATION SUMMARY V2')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Overall status: $overallStatus')
    ..writeln()
    ..writeln('| Category | Status | Count | Notes |')
    ..writeln('|----------|--------|-------|-------|')
    ..writeln(
      '| Reports | $reportStatus | ${expiredReports.length} | Oldest ${expiredReports.isEmpty ? 'n/a' : '${expiredReports.first.ageDays}d'} |',
    )
    ..writeln(
      '| Actions | $actionStatus | ${pendingActions.length} | Pending remediations |',
    )
    ..writeln()
    ..writeln('Expired Reports (>30d):');
  if (expiredReports.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final report in expiredReports.take(10)) {
      buffer.writeln('- ${report.path} (${report.ageDays}d)');
    }
    if (expiredReports.length > 10) {
      buffer.writeln('- ... (${expiredReports.length - 10} more)');
    }
  }

  buffer
    ..writeln()
    ..writeln('Pending Actions:');
  if (pendingActions.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final action in pendingActions) {
      buffer.writeln(
        '- ${action.dimension} (priority ${action.priority}) :: ${action.description}',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('Telemetry Review (last ${telemetry.length} events considered):');
  if (telemetry.isEmpty) {
    buffer.writeln('- No telemetry entries found.');
  } else {
    for (final event in telemetry.take(8).toList().reversed) {
      buffer.writeln(
        '- ${event.timestamp?.toIso8601String() ?? 'n/a'} :: ${event.event}',
      );
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

String _statusLabel(int count) {
  if (count == 0) return 'PASS';
  if (count <= 2) return 'WARN';
  return 'FAIL';
}

String _overallStatus(String reports, String actions) {
  if (reports == 'FAIL' || actions == 'FAIL') return 'FAIL';
  if (reports == 'WARN' || actions == 'WARN') return 'WARN';
  return 'PASS';
}

Future<void> _appendTelemetry({
  required int expiredReports,
  required int pendingActions,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'maintenance_automation_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'expired_reports': expiredReports,
    'pending_actions': pendingActions,
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
      'maintenance_automation_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
