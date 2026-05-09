import 'dart:convert';
import 'dart:io';

const String _selfSummaryPath = 'release/_reports/self_maintenance_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _outputPath =
    'release/_reports/autonomous_feedback_closure_plan.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final planSnapshot = await _readScenarios();
  final scenarios = planSnapshot.scenarios;
  final events = await _readTelemetry(limit: 200);
  final unresolved = scenarios.where((s) => !s.resolved).toList();
  final problematicEvents = _findProblematicEvents(events);

  final plan = unresolved
      .map(
        (scenario) => _ClosureAction(
          scenario: scenario,
          handler: _suggestHandler(scenario.name),
          relatedEvent: _matchEvent(scenario, events),
        ),
      )
      .toList();

  final successRate = scenarios.isEmpty
      ? 1.0
      : (scenarios.length - unresolved.length) / scenarios.length;
  final avgLatency = scenarios.isEmpty
      ? 0.0
      : scenarios.map((s) => s.latencyMs).reduce((a, b) => a + b) /
            scenarios.length;

  await _withReportsWritable(() async {
    await _writePlan(
      planSnapshot.generated,
      plan,
      problematicEvents,
      successRate,
      avgLatency,
    );
    await _appendTelemetry(
      successRate: successRate,
      avgLatency: avgLatency,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'autonomous_feedback_closure: resolved=${scenarios.length - unresolved.length} '
    'unresolved=${unresolved.length}',
  );
}

class _Scenario {
  const _Scenario({
    required this.name,
    required this.action,
    required this.resolved,
    required this.latencyMs,
  });

  final String name;
  final String action;
  final bool resolved;
  final double latencyMs;
}

class _PlanSnapshot {
  const _PlanSnapshot({required this.generated, required this.scenarios});

  final DateTime? generated;
  final List<_Scenario> scenarios;
}

Future<_PlanSnapshot> _readScenarios() async {
  final file = File(_selfSummaryPath);
  if (!await file.exists())
    return const _PlanSnapshot(generated: null, scenarios: []);
  DateTime? generated;
  final scenarios = <_Scenario>[];
  final rowPattern = RegExp(
    r'^\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(YES|NO)\s*\|\s*(.+?)\s*\|\s*(\d+)\s*\|',
  );
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
      continue;
    }
    final match = rowPattern.firstMatch(trimmed);
    if (match != null) {
      scenarios.add(
        _Scenario(
          name: match.group(1)!,
          action: match.group(2)!,
          resolved: match.group(3) == 'YES',
          latencyMs: double.tryParse(match.group(5) ?? '0') ?? 0,
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
    required this.data,
  });

  final String event;
  final DateTime? timestamp;
  final Map<String, dynamic> data;
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
            data: data,
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }
  return events;
}

class _ClosureAction {
  const _ClosureAction({
    required this.scenario,
    required this.handler,
    required this.relatedEvent,
  });

  final _Scenario scenario;
  final String handler;
  final _TelemetryEvent? relatedEvent;
}

String _suggestHandler(String scenario) {
  final lower = scenario.toLowerCase();
  if (lower.contains('corruption')) return 'scripts/io_integrity_guard.sh';
  if (lower.contains('summary')) return 'scripts/summary_regen_pipeline.sh';
  if (lower.contains('telemetry')) return 'scripts/telemetry_rotation_task.sh';
  return 'scripts/general_preventive_handler.sh';
}

_TelemetryEvent? _matchEvent(_Scenario scenario, List<_TelemetryEvent> events) {
  final keyword = scenario.name.toLowerCase();
  for (final event in events) {
    if (event.event.toLowerCase().contains(keyword)) {
      return event;
    }
  }
  return null;
}

class _ProblematicEvent {
  const _ProblematicEvent({required this.event, required this.details});

  final String event;
  final String details;
}

List<_ProblematicEvent> _findProblematicEvents(List<_TelemetryEvent> events) {
  final issues = <_ProblematicEvent>[];
  for (final event in events) {
    final data = event.data;
    bool flagged = false;
    final buffer = StringBuffer();
    if (data.containsKey('success_rate')) {
      final rate = (data['success_rate'] as num).toDouble();
      if (rate < 1.0) {
        flagged = true;
        buffer.writeln('success_rate=${rate.toStringAsFixed(2)}');
      }
    }
    if (data.containsKey('risk_high')) {
      final value = (data['risk_high'] as num).toInt();
      if (value > 0) {
        flagged = true;
        buffer.writeln('risk_high=$value');
      }
    }
    for (final field in ['missing', 'mismatched', 'pending_actions']) {
      final value = data[field];
      if (value is num && value > 0) {
        flagged = true;
        buffer.writeln('$field=$value');
      }
    }
    if (flagged) {
      issues.add(
        _ProblematicEvent(
          event: event.event,
          details: buffer.toString().trim().isEmpty
              ? 'threshold exceeded'
              : buffer.toString().trim(),
        ),
      );
    }
  }
  return issues;
}

Future<void> _writePlan(
  DateTime? generated,
  List<_ClosureAction> actions,
  List<_ProblematicEvent> issues,
  double successRate,
  double avgLatency,
) async {
  final buffer = StringBuffer()
    ..writeln('AUTONOMOUS FEEDBACK CLOSURE PLAN')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Self-maintenance snapshot: ${generated?.toIso8601String() ?? 'unknown'}',
    )
    ..writeln('Success rate: ${(successRate * 100).toStringAsFixed(1)}%')
    ..writeln('Average latency: ${avgLatency.toStringAsFixed(0)} ms')
    ..writeln();
  if (actions.isEmpty) {
    buffer.writeln('All scenarios resolved. No closure actions required.');
  } else {
    buffer
      ..writeln('| Scenario | Handler | Linked Event | Notes |')
      ..writeln('|----------|---------|--------------|-------|');
    for (final action in actions) {
      buffer.writeln(
        '| ${action.scenario.name} | ${action.handler} | '
        '${action.relatedEvent?.event ?? 'n/a'} | ${action.scenario.action} |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('Problematic Telemetry Events:');
  if (issues.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final issue in issues) {
      buffer.writeln('- ${issue.event}: ${issue.details}');
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
    'event': 'autonomous_feedback_closure_completed',
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
      'autonomous_feedback_closure: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
