import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final loop = _SelfOptimizationLoop();
  try {
    final result = await loop.run();
    await loop.writePlan(result);
    await loop.emitTelemetry(result);
  } finally {
    await loop.restorePermissions();
  }
}

class _SelfOptimizationLoop {
  bool _reportsWritable = false;

  Future<_OptimizationResult> run() async {
    final stopwatch = Stopwatch()..start();
    final health = await _readHealthSummary();
    final telemetry = await _readTelemetry();
    final actions = _buildActions(health);
    stopwatch.stop();
    return _OptimizationResult(
      timestamp: DateTime.now().toUtc(),
      health: health,
      telemetry: telemetry,
      actions: actions,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<_HealthSummary> _readHealthSummary() async {
    final file = File('release/_reports/health_insight_summary.txt');
    if (!file.existsSync()) {
      throw StateError('health_insight_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    DateTime? timestamp;
    final metrics = <_Metric>[
      for (final template in _metricTemplates) _Metric(template.label),
    ];
    var inTable = false;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('Timestamp:')) {
        timestamp = _tryParseIso(line.substring('Timestamp:'.length).trim());
        continue;
      }
      if (line.startsWith('| Metric |')) {
        inTable = true;
        continue;
      }
      if (!inTable || !raw.startsWith('|') || raw.contains('---')) {
        continue;
      }
      final parts = raw.split('|').map((p) => p.trim()).toList();
      if (parts.length < 5) continue;
      final label = parts[1];
      final value = double.tryParse(parts[2]);
      final badge = parts[3];
      for (final metric in metrics) {
        if (metric.label == label) {
          metric.value = value;
          metric.badge = badge;
        }
      }
    }
    return _HealthSummary(timestamp: timestamp, metrics: metrics);
  }

  Future<List<_TelemetryEvent>> _readTelemetry() async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) return <_TelemetryEvent>[];
    final lines = await file.readAsLines();
    final events = <_TelemetryEvent>[];
    for (final raw in lines.reversed.take(200)) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          final event = decoded['event'] as String?;
          final timestamp = decoded['timestamp'] as String?;
          if (event != null) {
            events.add(_TelemetryEvent(name: event, timestamp: timestamp));
          }
        }
      } catch (_) {
        // ignore bad lines
      }
    }
    return events;
  }

  List<_ActionPlan> _buildActions(_HealthSummary summary) {
    final plans = <_ActionPlan>[];
    for (final metric in summary.metrics) {
      final template = _metricTemplates.firstWhere(
        (t) => t.label == metric.label,
        orElse: () =>
            const _MetricTemplate('Custom Metric', 'Review metric', 1.0),
      );
      final badge = metric.badge ?? 'UNKNOWN';
      final value = metric.value ?? 0.8;
      final severity = _badgeSeverity(badge);
      if (severity <= 0) continue;
      final corrective =
          ((1 - value).clamp(0.0, 1.0) * template.weight * severity)
              .toStringAsFixed(3);
      plans.add(
        _ActionPlan(
          metric: metric.label,
          value: value,
          badge: badge,
          action: template.action,
          correctiveWeight: double.parse(corrective),
        ),
      );
    }
    plans.sort((a, b) => b.correctiveWeight.compareTo(a.correctiveWeight));
    return plans;
  }

  Future<void> writePlan(_OptimizationResult result) async {
    final buffer = StringBuffer()
      ..writeln('Self-Optimization Plan')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Source: health_insight_summary.txt + telemetry.jsonl')
      ..writeln();

    if (result.actions.isEmpty) {
      buffer
        ..writeln(
          'All tracked metrics are GREEN. No corrective action required.',
        )
        ..writeln('Duration (ms): ${result.durationMs}');
    } else {
      buffer
        ..writeln(
          '| Priority | Metric | Current | Badge | Recommended Action | Corrective Weight |',
        )
        ..writeln(
          '|----------|--------|---------|-------|---------------------|-------------------|',
        );
      for (var i = 0; i < result.actions.length; i++) {
        final action = result.actions[i];
        buffer.writeln(
          '| ${i + 1} | ${action.metric} | ${action.value.toStringAsFixed(3)} | ${action.badge} | ${action.action} | ${action.correctiveWeight.toStringAsFixed(3)} |',
        );
      }
      buffer
        ..writeln()
        ..writeln('Telemetry context (last 5 events):');
      final recent = result.telemetry
          .take(5)
          .map((e) => '- ${e.name} (${e.timestamp ?? 'no timestamp'})');
      recent.forEach(buffer.writeln);
      buffer.writeln('Duration (ms): ${result.durationMs}');
    }

    await _writeReportsFile(
      'release/_reports/self_optimization_plan.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_OptimizationResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.selfOptimizationCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'actions': result.actions.length,
      'corrections': result.actions.fold<double>(
        0,
        (sum, item) => sum + item.correctiveWeight,
      ),
      'duration_ms': result.durationMs,
    };
    final file = File('release/_reports/telemetry.jsonl');
    try {
      await file.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _OptimizationResult {
  _OptimizationResult({
    required this.timestamp,
    required this.health,
    required this.telemetry,
    required this.actions,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _HealthSummary health;
  final List<_TelemetryEvent> telemetry;
  final List<_ActionPlan> actions;
  final int durationMs;
}

class _HealthSummary {
  _HealthSummary({required this.timestamp, required this.metrics});

  final DateTime? timestamp;
  final List<_Metric> metrics;
}

class _TelemetryEvent {
  _TelemetryEvent({required this.name, required this.timestamp});

  final String name;
  final String? timestamp;
}

class _Metric {
  _Metric(this.label);

  final String label;
  double? value;
  String? badge;
}

class _ActionPlan {
  _ActionPlan({
    required this.metric,
    required this.value,
    required this.badge,
    required this.action,
    required this.correctiveWeight,
  });

  final String metric;
  final double value;
  final String badge;
  final String action;
  final double correctiveWeight;
}

class _MetricTemplate {
  const _MetricTemplate(this.label, this.action, this.weight);

  final String label;
  final String action;
  final double weight;
}

const List<_MetricTemplate> _metricTemplates = <_MetricTemplate>[
  _MetricTemplate(
    'Health Index',
    'Trigger holistic UX resilience bundle (trend + stability sweep).',
    1.2,
  ),
  _MetricTemplate(
    'Stability Score',
    'Re-run stability scaling audit and refresh regression anchors.',
    1.0,
  ),
  _MetricTemplate(
    'Forecast Trend (Day7)',
    'Adjust predictive model weights and re-export UX metrics.',
    0.9,
  ),
  _MetricTemplate(
    'Feedback Alpha',
    'Increase feedback sampling + designer sync cadence.',
    0.8,
  ),
];

int _badgeSeverity(String badge) {
  switch (badge.toUpperCase()) {
    case 'RED':
      return 2;
    case 'ORANGE':
      return 1;
    default:
      return 0;
  }
}

DateTime? _tryParseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}
