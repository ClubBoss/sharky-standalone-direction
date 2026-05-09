import 'dart:convert';
import 'dart:io';

const String _planPath = 'release/_reports/preventive_sweep_plan.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/self_maintenance_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final plan = await _readPlan();
  final telemetry = await _readTelemetry(limit: 200);
  final verification = _verify(plan, telemetry);

  await _withReportsWritable(() async {
    await _writeSummary(plan.generated, verification);
    await _appendTelemetry(
      successRate: verification.successRate,
      avgLatency: verification.averageLatency,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'self_maintenance_verifier: successRate='
    '${(verification.successRate * 100).toStringAsFixed(1)}% '
    'avgLatency=${verification.averageLatency.toStringAsFixed(0)}ms',
  );
}

class _PlanScenario {
  const _PlanScenario({
    required this.name,
    required this.action,
    required this.priority,
  });

  final String name;
  final String action;
  final double priority;
}

class _PlanSnapshot {
  const _PlanSnapshot({required this.generated, required this.scenarios});

  final DateTime? generated;
  final List<_PlanScenario> scenarios;
}

Future<_PlanSnapshot> _readPlan() async {
  final file = File(_planPath);
  if (!await file.exists()) {
    return const _PlanSnapshot(generated: null, scenarios: []);
  }
  DateTime? generated;
  final scenarios = <_PlanScenario>[];
  final rowPattern = RegExp(r'^\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*([0-9.]+)\s*\|');
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
      continue;
    }
    final match = rowPattern.firstMatch(trimmed);
    if (match != null) {
      scenarios.add(
        _PlanScenario(
          name: match.group(1)!,
          action: match.group(2)!,
          priority: double.tryParse(match.group(3) ?? '0') ?? 0.0,
        ),
      );
    }
  }
  return _PlanSnapshot(generated: generated, scenarios: scenarios);
}

class _TelemetryEvent {
  const _TelemetryEvent({
    required this.event,
    required this.timestamp,
    required this.latency,
  });

  final String event;
  final DateTime? timestamp;
  final double latency;
}

Future<List<_TelemetryEvent>> _readTelemetry({int limit = 200}) async {
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
            latency: (data['avg_latency_ms'] ?? data['mean_latency_ms'] ?? 0)
                .toString()
                .parseDouble(),
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }
  return events;
}

extension on String {
  double parseDouble() => double.tryParse(this) ?? 0.0;
}

class _VerificationResult {
  const _VerificationResult({
    required this.rows,
    required this.successRate,
    required this.averageLatency,
  });

  final List<_VerificationRow> rows;
  final double successRate;
  final double averageLatency;
}

class _VerificationRow {
  const _VerificationRow({
    required this.scenario,
    required this.resolved,
    required this.event,
    required this.latency,
  });

  final _PlanScenario scenario;
  final bool resolved;
  final String? event;
  final double latency;
}

_VerificationResult _verify(
  _PlanSnapshot plan,
  List<_TelemetryEvent> telemetry,
) {
  if (plan.scenarios.isEmpty) {
    return const _VerificationResult(
      rows: [],
      successRate: 1.0,
      averageLatency: 0,
    );
  }
  final rows = <_VerificationRow>[];
  for (final scenario in plan.scenarios) {
    final keyword = scenario.name.toLowerCase();
    final matching = telemetry.firstWhere(
      (event) => event.event.toLowerCase().contains(keyword),
      orElse: () =>
          const _TelemetryEvent(event: 'missing', timestamp: null, latency: 0),
    );
    final resolved = matching.event != 'missing';
    rows.add(
      _VerificationRow(
        scenario: scenario,
        resolved: resolved,
        event: resolved ? matching.event : null,
        latency: matching.latency,
      ),
    );
  }
  final successCount = rows.where((row) => row.resolved).length;
  final successRate = successCount / rows.length;
  final latencies = rows
      .where((row) => row.latency > 0)
      .map((row) => row.latency)
      .toList();
  final avgLatency = latencies.isEmpty
      ? 0.0
      : latencies.reduce((a, b) => a + b) / latencies.length;
  return _VerificationResult(
    rows: rows,
    successRate: successRate,
    averageLatency: avgLatency,
  );
}

Future<void> _writeSummary(
  DateTime? planGenerated,
  _VerificationResult verification,
) async {
  final buffer = StringBuffer()
    ..writeln('SELF-MAINTENANCE SUMMARY V2')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Plan reference: ${planGenerated?.toIso8601String() ?? 'unknown'}',
    )
    ..writeln(
      'Success rate: ${(verification.successRate * 100).toStringAsFixed(1)}%',
    )
    ..writeln(
      'Average latency: ${verification.averageLatency.toStringAsFixed(0)} ms',
    )
    ..writeln();
  if (verification.rows.isEmpty) {
    buffer.writeln('No scenarios to verify.');
  } else {
    buffer
      ..writeln('| Scenario | Action | Resolved | Event | Latency (ms) |')
      ..writeln('|----------|--------|----------|-------|--------------|');
    for (final row in verification.rows) {
      buffer.writeln(
        '| ${row.scenario.name} | ${row.scenario.action} | '
        '${row.resolved ? 'YES' : 'NO'} | ${row.event ?? 'n/a'} '
        '| ${row.latency.toStringAsFixed(0)} |',
      );
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double successRate,
  required double avgLatency,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'self_maintenance_verified',
    'timestamp': DateTime.now().toIso8601String(),
    'success_rate': successRate,
    'avg_latency': avgLatency,
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
      'self_maintenance_verifier: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
