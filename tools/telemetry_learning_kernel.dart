import 'dart:convert';
import 'dart:io';

const String _selfHealingPath = 'release/_reports/self_healing_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath = 'release/_reports/telemetry_learning_summary.txt';
const String _reportsDir = 'release/_reports';
const double _alpha = 0.3;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final baseMetrics = await _readLatestMetrics();
  final prevThresholds = await _readPreviousThresholds();
  final telemetrySamples = await _collectTelemetrySamples();

  final learned = _applySmoothing(
    previous: prevThresholds,
    current: baseMetrics,
    samples: telemetrySamples,
  );

  await _withReportsWritable(() async {
    await _writeSummary(learned);
    await _appendTelemetry(
      thresholds: learned,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'telemetry_learning_kernel: thresholds=${learned.toTelemetryPayload()}',
  );
}

Future<_MetricSnapshot> _readLatestMetrics() async {
  final file = File(_selfHealingPath);
  if (!await file.exists()) {
    return const _MetricSnapshot();
  }
  final lines = await file.readAsLines();
  double riskBefore = 0;
  double riskAfter = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Risk before')) {
      final match = RegExp(r'([\d.]+)').firstMatch(trimmed);
      if (match != null) {
        riskBefore = double.tryParse(match.group(1)!) ?? 0.0;
      }
    } else if (trimmed.startsWith('Risk after')) {
      final match = RegExp(r'([\d.]+)').firstMatch(trimmed);
      if (match != null) {
        riskAfter = double.tryParse(match.group(1)!) ?? 0.0;
      }
    }
  }
  return _MetricSnapshot(
    riskScore: riskAfter > 0 ? riskAfter : riskBefore,
    variance: 0.0,
    latencyMs: 0,
    successRate: riskAfter == 0 ? 1.0 : (riskBefore - riskAfter).clamp(0, 1),
  );
}

Future<_MetricSnapshot> _readPreviousThresholds() async {
  final file = File(_summaryPath);
  if (!await file.exists()) return const _MetricSnapshot();
  final lines = await file.readAsLines();
  double _extract(String label) {
    final line = lines.firstWhere(
      (row) => row.trim().startsWith(label),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final match = RegExp(r'[-+]?\d+\.?\d*').firstMatch(line);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  return _MetricSnapshot(
    riskScore: _extract('- Risk threshold'),
    variance: _extract('- Variance threshold'),
    latencyMs: _extract('- Latency threshold').toInt(),
    successRate: _extract('- Success rate threshold'),
  );
}

Future<_TelemetrySamples> _collectTelemetrySamples() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const _TelemetrySamples();
  final variances = <double>[];
  final latencies = <double>[];
  final risks = <double>[];
  for (final raw in await file.readAsLines()) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) continue;
      final event = decoded['event']?.toString() ?? '';
      final duration = (decoded['duration_ms'] as num?)?.toDouble();
      if (duration != null) latencies.add(duration);
      if (event == 'systemic_risk_synthesized') {
        final risk = (decoded['risk_score'] as num?)?.toDouble();
        if (risk != null) risks.add(risk);
      } else if (event == 'cross_channel_sync_completed') {
        final variance = (decoded['variance_avg'] as num?)?.toDouble();
        if (variance != null) variances.add(variance);
      }
    } catch (_) {
      continue;
    }
  }
  return _TelemetrySamples(
    riskScores: risks,
    variances: variances,
    latencies: latencies,
  );
}

_MetricSnapshot _applySmoothing({
  required _MetricSnapshot previous,
  required _MetricSnapshot current,
  required _TelemetrySamples samples,
}) {
  double smooth(double prev, double curr) =>
      double.parse((_alpha * curr + (1 - _alpha) * prev).toStringAsFixed(2));

  final varianceSample = samples.variances.isNotEmpty
      ? samples.variances.last
      : previous.variance;
  final latencySample = samples.latencies.isNotEmpty
      ? samples.latencies.reduce((a, b) => a + b) / samples.latencies.length
      : previous.latencyMs.toDouble();
  final successSample = samples.riskScores.isEmpty
      ? previous.successRate
      : (1 - samples.riskScores.last).clamp(0.0, 1.0);

  return _MetricSnapshot(
    riskScore: smooth(previous.riskScore, current.riskScore),
    variance: smooth(previous.variance, varianceSample),
    latencyMs: smooth(previous.latencyMs.toDouble(), latencySample).toInt(),
    successRate: smooth(previous.successRate, successSample),
  );
}

Future<void> _writeSummary(_MetricSnapshot snapshot) async {
  final buffer = StringBuffer()
    ..writeln('TELEMETRY LEARNING SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Alpha: $_alpha')
    ..writeln()
    ..writeln('Learned thresholds')
    ..writeln('- Risk threshold: ${snapshot.riskScore.toStringAsFixed(2)}')
    ..writeln('- Variance threshold: ${snapshot.variance.toStringAsFixed(2)}')
    ..writeln('- Latency threshold: ${snapshot.latencyMs} ms')
    ..writeln(
      '- Success rate threshold: ${snapshot.successRate.toStringAsFixed(2)}',
    );

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required _MetricSnapshot thresholds,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'telemetry_learning_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'learned_thresholds': thresholds.toTelemetryPayload(),
    'alpha': _alpha,
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
      'telemetry_learning_kernel: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _MetricSnapshot {
  const _MetricSnapshot({
    this.riskScore = 0,
    this.variance = 0,
    this.latencyMs = 0,
    this.successRate = 0,
  });

  final double riskScore;
  final double variance;
  final int latencyMs;
  final double successRate;

  Map<String, Object?> toTelemetryPayload() {
    return <String, Object?>{
      'risk': double.parse(riskScore.toStringAsFixed(2)),
      'variance': double.parse(variance.toStringAsFixed(2)),
      'latency_ms': latencyMs,
      'success_rate': double.parse(successRate.toStringAsFixed(2)),
    };
  }
}

class _TelemetrySamples {
  const _TelemetrySamples({
    this.riskScores = const [],
    this.variances = const [],
    this.latencies = const [],
  });

  final List<double> riskScores;
  final List<double> variances;
  final List<double> latencies;
}
