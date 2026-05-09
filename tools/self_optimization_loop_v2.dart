import 'dart:convert';
import 'dart:io';

const String _healthSummaryPath =
    'release/_reports/health_insight_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _planPath = 'release/_reports/self_optimization_v2_plan.txt';

const double _threshold = 0.8;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final health = await _readHealthSnapshot();
  final telemetry = await _readRecentTelemetry(limit: 20);
  final actions = _deriveActions(health);
  final avgWeight = actions.isEmpty
      ? 0.0
      : actions.map((a) => a.priority).reduce((a, b) => a + b) / actions.length;

  await _withReportsWritable(() async {
    await _writePlan(
      health: health,
      actions: actions,
      telemetry: telemetry,
      avgWeight: avgWeight,
    );
    await _appendTelemetry(
      actions: actions,
      avgWeight: avgWeight,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'self_optimization_loop_v2: ${actions.length} actions, '
    'avgWeight=${avgWeight.toStringAsFixed(2)}',
  );
}

Future<_HealthSnapshot> _readHealthSnapshot() async {
  final file = File(_healthSummaryPath);
  if (!await file.exists()) {
    return const _HealthSnapshot();
  }
  double? stability;
  double? trend;
  String? trendLabel;
  double? adaptation;
  double? index;

  final lines = await file.readAsLines();
  final componentPattern = RegExp(r'^-\s*(\w+) \([^)]*\):\s*([0-9.]+)');
  for (final line in lines) {
    final trimmed = line.trim();
    final componentMatch = componentPattern.firstMatch(trimmed);
    if (componentMatch != null) {
      final label = componentMatch.group(1)!.toLowerCase();
      final value = double.tryParse(componentMatch.group(2)!);
      if (value == null) continue;
      switch (label) {
        case 'stability':
          stability = value;
          break;
        case 'trend':
          trend = value;
          if (trimmed.contains('(') && trimmed.contains(')')) {
            final raw = trimmed.substring(
              trimmed.indexOf('(') + 1,
              trimmed.indexOf(')'),
            );
            trendLabel = raw.replaceAll('trend', '').trim();
          }
          break;
        case 'adaptation':
          adaptation = value;
          break;
      }
      continue;
    }
    if (trimmed.startsWith('Weighted Health Index:')) {
      index = double.tryParse(trimmed.split(':').last.trim());
    }
    if (trimmed.startsWith('- Trend (')) {
      final after = trimmed.split(')').last.trim();
      if (after.startsWith('(')) {
        trendLabel = after.substring(1, after.length - 1);
      } else if (trimmed.contains('(') && trimmed.contains(')')) {
        trendLabel = trimmed.substring(
          trimmed.indexOf('(') + 1,
          trimmed.indexOf(')'),
        );
      }
    }
  }
  return _HealthSnapshot(
    stability: stability,
    trend: trend,
    trendLabel: trendLabel,
    adaptation: adaptation,
    index: index,
  );
}

Future<List<_TelemetryEvent>> _readRecentTelemetry({int limit = 20}) async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final result = <_TelemetryEvent>[];
  for (final line in lines.reversed.take(limit)) {
    if (line.trim().isEmpty) continue;
    try {
      final jsonLine = json.decode(line);
      if (jsonLine is Map<String, dynamic>) {
        result.add(
          _TelemetryEvent(
            event: jsonLine['event']?.toString() ?? 'unknown',
            timestamp: jsonLine['timestamp']?.toString(),
            raw: jsonLine,
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }
  return result;
}

List<_ActionItem> _deriveActions(_HealthSnapshot health) {
  final items = <_ActionItem>[];

  void addIfBelow(String dimension, double? score, String action) {
    final value = score ?? 0.0;
    if (value >= _threshold) return;
    final deficit = (_threshold - value).clamp(0.0, _threshold);
    final priority = double.parse((deficit / _threshold).toStringAsFixed(2));
    items.add(
      _ActionItem(
        dimension: dimension,
        score: value,
        priority: priority,
        action: action,
      ),
    );
  }

  addIfBelow(
    'Health Index',
    health.index,
    'Kick off cross-discipline war-room to raise weighted index above 0.80',
  );
  addIfBelow(
    'Stability',
    health.stability,
    'Run stability scaling audit and replay recent recovery logs',
  );
  addIfBelow(
    'Trend',
    health.trend,
    'Launch retention experiments and deepen funnel instrumentation',
  );
  addIfBelow(
    'Adaptation',
    health.adaptation,
    'Tighten feedback adaptation weights and re-run cadence tuning',
  );

  return items;
}

Future<void> _writePlan({
  required _HealthSnapshot health,
  required List<_ActionItem> actions,
  required List<_TelemetryEvent> telemetry,
  required double avgWeight,
}) async {
  final buffer = StringBuffer()
    ..writeln('SELF-OPTIMIZATION PLAN V2')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Inputs:')
    ..writeln('- Health summary: $_healthSummaryPath')
    ..writeln('- Telemetry: $_telemetryPath')
    ..writeln()
    ..writeln('Current Scores:')
    ..writeln('- Health Index: ${_formatScore(health.index)}')
    ..writeln('- Stability: ${_formatScore(health.stability)}')
    ..writeln(
      '- Trend: ${_formatScore(health.trend)} (${health.trendLabel ?? 'n/a'})',
    )
    ..writeln('- Adaptation: ${_formatScore(health.adaptation)}')
    ..writeln()
    ..writeln(
      'Recommended Actions (avg weight ${avgWeight.toStringAsFixed(2)}):',
    );

  if (actions.isEmpty) {
    buffer.writeln('- All dimensions above threshold; maintain current plan.');
  } else {
    buffer.writeln('| Dimension | Score | Priority | Action |');
    buffer.writeln('|-----------|-------|----------|--------|');
    for (final item in actions) {
      buffer.writeln(
        '| ${item.dimension} | ${item.score.toStringAsFixed(2)} '
        '| ${item.priority.toStringAsFixed(2)} | ${item.action} |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('Recent Telemetry Signals:');
  if (telemetry.isEmpty) {
    buffer.writeln('- No telemetry records available.');
  } else {
    for (final event in telemetry.take(8).toList().reversed) {
      buffer.writeln('- ${event.timestamp ?? 'n/a'} :: ${event.event}');
    }
  }

  await File(_planPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required List<_ActionItem> actions,
  required double avgWeight,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'self_optimization_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'actions': actions.map((a) => a.dimension).join(', '),
    'avg_weight': avgWeight,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _formatScore(double? score) =>
    score == null ? 'n/a' : score.toStringAsFixed(2);

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
      'self_optimization_loop_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _HealthSnapshot {
  const _HealthSnapshot({
    this.index,
    this.stability,
    this.trend,
    this.trendLabel,
    this.adaptation,
  });

  final double? index;
  final double? stability;
  final double? trend;
  final String? trendLabel;
  final double? adaptation;
}

class _TelemetryEvent {
  const _TelemetryEvent({
    required this.event,
    required this.timestamp,
    required this.raw,
  });

  final String event;
  final String? timestamp;
  final Map<String, dynamic> raw;
}

class _ActionItem {
  _ActionItem({
    required this.dimension,
    required this.score,
    required this.priority,
    required this.action,
  });

  final String dimension;
  final double score;
  final double priority;
  final String action;
}
