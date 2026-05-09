import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final unifier = _TelemetryUnifier.load();
  final summary = unifier.buildSummary();

  final outputData = summary.toJson();
  final encoder = const JsonEncoder.withIndent('  ');

  final reportsPath = File('tools/_reports/unified_telemetry_summary.json');
  reportsPath.parent.createSync(recursive: true);
  reportsPath.writeAsStringSync('${encoder.convert(outputData)}\n');

  final releasePath = File(
    'release/public_beta_v2/unified_telemetry_summary.json',
  );
  releasePath.parent.createSync(recursive: true);
  releasePath.writeAsStringSync('${encoder.convert(outputData)}\n');

  stdout.writeln(
    'Unified Telemetry Summary: '
    'confidence ${summary.avgConfidence.toStringAsFixed(2)}% | '
    'ev diff ${summary.avgEvDiff.toStringAsFixed(2)} | '
    'latency ${summary.avgLatencyMs.toStringAsFixed(2)} ms | '
    'retention ${summary.retentionScore.toStringAsFixed(2)}%',
  );
  stdout.writeln(
    'Unified Telemetry -> ${summary.statusLabel} '
    '(${summary.feedsMerged} feeds merged)',
  );
}

class _TelemetryUnifier {
  _TelemetryUnifier({
    required this.advisor,
    required this.feedback,
    required this.ux,
    required this.advisorLoaded,
    required this.feedbackLoaded,
    required this.uxLoaded,
  });

  final Map<String, dynamic> advisor;
  final Map<String, dynamic> feedback;
  final Map<String, dynamic> ux;
  final bool advisorLoaded;
  final bool feedbackLoaded;
  final bool uxLoaded;

  factory _TelemetryUnifier.load() {
    final advisor = _readJson('tools/_reports/ai_advisor_summary.json');
    final feedback = _readJson(
      'tools/_reports/public_beta_feedback_summary.json',
    );
    final ux = _readJson('tools/_reports/ux_feedback_metrics.json');

    return _TelemetryUnifier(
      advisor: advisor,
      feedback: feedback,
      ux: ux,
      advisorLoaded: advisor.isNotEmpty,
      feedbackLoaded: feedback.isNotEmpty,
      uxLoaded: ux.isNotEmpty,
    );
  }

  _UnifiedTelemetry buildSummary() {
    final feedsMerged = <String>[
      if (advisorLoaded) 'advisor',
      if (feedbackLoaded) 'feedback',
      if (uxLoaded) 'ux',
    ];

    final advisorMetrics = advisor['metrics'] as Map<String, dynamic>? ?? {};
    final confidence = _pickMetric(
      advisorMetrics['confidence'] as Map<String, dynamic>?,
    );
    final evDiff = _pickMetric(
      advisorMetrics['ev_diff'] as Map<String, dynamic>?,
    );

    final feedbackAggregates =
        feedback['aggregates'] as Map<String, dynamic>? ?? {};
    final latencyFromFeedback = _toDouble(
      feedbackAggregates['avg_ux_latency_ms'],
    );
    final retention = _toDouble(
      feedbackAggregates['avg_retention_score_percent'],
    );

    final uxLatency = _extractUxLatency(ux);
    final uxRetention = _extractUxRetention(ux);

    final avgLatencyMs = _firstNonZero([latencyFromFeedback, uxLatency]) ?? 0.0;
    final retentionScore = _firstNonZero([retention, uxRetention]) ?? 0.0;

    final statusLabel = feedsMerged.length >= 3
        ? 'PASS [OK]'
        : 'WARN [PARTIAL]';

    return _UnifiedTelemetry(
      generatedAt: DateTime.now().toUtc().toIso8601String(),
      advisor: advisor,
      feedback: feedback,
      ux: ux,
      avgConfidence: confidence ?? 0.0,
      avgEvDiff: evDiff ?? 0.0,
      avgLatencyMs: avgLatencyMs,
      retentionScore: retentionScore,
      feedsMerged: feedsMerged.length,
      statusLabel: statusLabel,
    );
  }
}

class _UnifiedTelemetry {
  _UnifiedTelemetry({
    required this.generatedAt,
    required this.advisor,
    required this.feedback,
    required this.ux,
    required this.avgConfidence,
    required this.avgEvDiff,
    required this.avgLatencyMs,
    required this.retentionScore,
    required this.feedsMerged,
    required this.statusLabel,
  });

  final String generatedAt;
  final Map<String, dynamic> advisor;
  final Map<String, dynamic> feedback;
  final Map<String, dynamic> ux;
  final double avgConfidence;
  final double avgEvDiff;
  final double avgLatencyMs;
  final double retentionScore;
  final int feedsMerged;
  final String statusLabel;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'generated_at': generatedAt,
      'feeds_merged': feedsMerged,
      'advisor': advisor,
      'feedback': feedback,
      'ux': ux,
      'derived_metrics': <String, dynamic>{
        'avg_confidence': avgConfidence,
        'avg_ev_diff': avgEvDiff,
        'avg_latency_ms': avgLatencyMs,
        'retention_score': retentionScore,
        'status': statusLabel,
      },
    };
  }
}

Map<String, dynamic> _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return const {};
  }
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (e) {
    stderr.writeln('[WARN] Failed to read $path: $e');
  }
  return const {};
}

double? _pickMetric(Map<String, dynamic>? metric) {
  if (metric == null) {
    return null;
  }
  final current = _toDouble(metric['current']);
  if (current != null && current != 0.0) {
    return current;
  }
  final sevenDay = _toDouble(metric['seven_day']);
  if (sevenDay != null && sevenDay != 0.0) {
    return sevenDay;
  }
  return current ?? sevenDay;
}

double? _extractUxLatency(Map<String, dynamic> ux) {
  if (ux.isEmpty) {
    return null;
  }
  final latencyKeys = [
    'avg_latency_ms',
    'latency_ms',
    'ux_latency_avg_ms',
    'average_latency_ms',
  ];
  for (final key in latencyKeys) {
    final value = _toDouble(ux[key]);
    if (value != null && value != 0.0) {
      return value;
    }
  }
  final metrics = ux['metrics'];
  if (metrics is Map<String, dynamic>) {
    for (final key in latencyKeys) {
      final value = _toDouble(metrics[key]);
      if (value != null && value != 0.0) {
        return value;
      }
    }
  }
  return null;
}

double? _extractUxRetention(Map<String, dynamic> ux) {
  if (ux.isEmpty) {
    return null;
  }
  final retentionKeys = [
    'retention_score',
    'retention_percent',
    'avg_retention_score_percent',
    'retention_score_percent',
  ];
  for (final key in retentionKeys) {
    final value = _toDouble(ux[key]);
    if (value != null && value != 0.0) {
      return value;
    }
  }
  final metrics = ux['metrics'];
  if (metrics is Map<String, dynamic>) {
    for (final key in retentionKeys) {
      final value = _toDouble(metrics[key]);
      if (value != null && value != 0.0) {
        return value;
      }
    }
  }
  return null;
}

double? _toDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

double? _firstNonZero(Iterable<double?> values) {
  for (final value in values) {
    if (value != null && value != 0.0) {
      return value;
    }
  }
  for (final value in values) {
    if (value != null) {
      return value;
    }
  }
  return null;
}
