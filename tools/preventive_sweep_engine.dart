import 'dart:convert';
import 'dart:io';

const String _summaryPath =
    'release/_reports/predictive_maintenance_summary.txt';
const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/preventive_sweep_plan.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final snapshot = await _readPredictiveSummary();
  final actions = _deriveActions(snapshot);
  final riskAvg = actions.isEmpty
      ? 0.0
      : actions.map((a) => a.riskScore).reduce((a, b) => a + b) /
            actions.length;

  await _withReportsWritable(() async {
    await _writePlan(snapshot.generated, actions);
    await _appendTelemetry(
      actions: actions.map((a) => a.name).join(', '),
      riskAvg: riskAvg,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'preventive_sweep_engine: actions=${actions.length} riskAvg=${riskAvg.toStringAsFixed(2)}',
  );
}

class _PredictiveSnapshot {
  const _PredictiveSnapshot({required this.generated, required this.rows});

  final DateTime? generated;
  final List<_ScenarioRow> rows;
}

class _ScenarioRow {
  const _ScenarioRow({
    required this.name,
    required this.latencyMs,
    required this.status,
    required this.risk,
    required this.nextMaintenance,
  });

  final String name;
  final int latencyMs;
  final String status;
  final String risk;
  final String nextMaintenance;
}

class _ActionRecommendation {
  const _ActionRecommendation({
    required this.name,
    required this.action,
    required this.riskScore,
  });

  final String name;
  final String action;
  final double riskScore;
}

Future<_PredictiveSnapshot> _readPredictiveSummary() async {
  final file = File(_summaryPath);
  if (!await file.exists()) {
    return const _PredictiveSnapshot(generated: null, rows: []);
  }
  DateTime? generated;
  final rows = <_ScenarioRow>[];
  final rowPattern = RegExp(
    r'^\|\s*(.+?)\s*\|\s*(\d+)\s*\|\s*(PASS|WARN|FAIL)\s*\|\s*(LOW|MED|HIGH)\s*\|\s*(.+?)\s*\|',
  );
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
      continue;
    }
    final match = rowPattern.firstMatch(trimmed);
    if (match != null) {
      rows.add(
        _ScenarioRow(
          name: match.group(1)!,
          latencyMs: int.parse(match.group(2)!),
          status: match.group(3)!,
          risk: match.group(4)!,
          nextMaintenance: match.group(5)!,
        ),
      );
    }
  }
  return _PredictiveSnapshot(generated: generated, rows: rows);
}

List<_ActionRecommendation> _deriveActions(_PredictiveSnapshot snapshot) {
  final recs = <_ActionRecommendation>[];
  for (final row in snapshot.rows) {
    final riskScore = row.risk == 'HIGH'
        ? 1.0
        : row.risk == 'MED'
        ? 0.6
        : 0.2;
    if (row.nextMaintenance.contains('due now') ||
        row.nextMaintenance.contains('0') ||
        row.nextMaintenance.contains('1d') ||
        row.nextMaintenance.contains('1')) {
      final action = _suggestAction(row.name);
      recs.add(
        _ActionRecommendation(
          name: row.name,
          action: action,
          riskScore: riskScore,
        ),
      );
    }
  }
  return recs;
}

String _suggestAction(String scenario) {
  final lower = scenario.toLowerCase();
  if (lower.contains('telemetry')) {
    return 'Rotate telemetry stores and rebuild indices';
  }
  if (lower.contains('summary')) {
    return 'Regenerate missing summaries and flush caches';
  }
  if (lower.contains('corruption')) {
    return 'Run I/O integrity sweep and reseed backups';
  }
  return 'Trigger preventive rebuild run';
}

Future<void> _writePlan(
  DateTime? generated,
  List<_ActionRecommendation> actions,
) async {
  final buffer = StringBuffer()
    ..writeln('PREVENTIVE SWEEP PLAN')
    ..writeln('=====================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Source predictive summary: ${generated?.toIso8601String() ?? 'unknown'}',
    )
    ..writeln();
  if (actions.isEmpty) {
    buffer.writeln('No scenarios require preventive action.');
  } else {
    buffer
      ..writeln('| Scenario | Recommended Action | Risk Score |')
      ..writeln('|----------|--------------------|------------|');
    for (final action in actions) {
      buffer.writeln(
        '| ${action.name} | ${action.action} | ${action.riskScore.toStringAsFixed(2)} |',
      );
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required String actions,
  required double riskAvg,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'preventive_sweep_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'actions': actions,
    'risk_avg': riskAvg,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    jsonEncode(payload) + '\n',
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
      'preventive_sweep_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
