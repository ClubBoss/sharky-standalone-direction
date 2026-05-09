import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _learningSummaryPath =
    'release/_reports/telemetry_learning_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/adaptive_feedback_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final previous = await _readLearningSummary();
  final window = await _collectTelemetryWindow();
  final retrained = _retrainThresholds(previous, window);

  await _withReportsWritable(() async {
    await _writeSummary(previous, retrained);
    await _appendTelemetry(
      confidenceAvg: retrained.confidenceAvg,
      thresholdDelta: retrained.thresholdDelta(previous),
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_feedback_trainer: confidenceAvg=${retrained.confidenceAvg.toStringAsFixed(2)} '
    'delta=${retrained.thresholdDelta(previous).toStringAsFixed(2)}',
  );
}

Future<_ThresholdSnapshot> _readLearningSummary() async {
  final file = File(_learningSummaryPath);
  if (!await file.exists()) return const _ThresholdSnapshot();
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

  return _ThresholdSnapshot(
    risk: _extract('- Risk threshold'),
    variance: _extract('- Variance threshold'),
    latencyMs: _extract('- Latency threshold').toInt(),
    successRate: _extract('- Success rate threshold'),
  );
}

Future<List<_TelemetryPoint>> _collectTelemetryWindow() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final points = <_TelemetryPoint>[];

  for (final raw in await file.readAsLines()) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) continue;
      final name = decoded['event']?.toString() ?? '';
      final timestamp = DateTime.tryParse(
        decoded['timestamp']?.toString() ?? '',
      );
      if (timestamp == null) continue;
      if (name == 'telemetry_learning_completed') {
        final thresholds = decoded['learned_thresholds'];
        if (thresholds is Map<String, dynamic>) {
          points.add(
            _TelemetryPoint(
              timestamp: timestamp,
              risk: (thresholds['risk'] as num?)?.toDouble(),
              variance: (thresholds['variance'] as num?)?.toDouble(),
              latencyMs: (thresholds['latency_ms'] as num?)?.toDouble(),
              successRate: (thresholds['success_rate'] as num?)?.toDouble(),
            ),
          );
        }
      } else if (name == 'self_healing_triggered') {
        points.add(
          _TelemetryPoint(
            timestamp: timestamp,
            successRate: (decoded['risk_reduction'] as num?)?.toDouble(),
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }

  points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return points.length <= 5 ? points : points.sublist(points.length - 5);
}

_RetrainedThresholds _retrainThresholds(
  _ThresholdSnapshot previous,
  List<_TelemetryPoint> window,
) {
  if (window.isEmpty) {
    return _RetrainedThresholds(
      risk: previous.risk,
      variance: previous.variance,
      latencyMs: previous.latencyMs,
      successRate: previous.successRate,
      confidenceAvg: 0,
    );
  }

  double weightedAverage(List<double> values) {
    if (values.isEmpty) return 0;
    var weightedSum = 0.0;
    var totalWeight = 0.0;
    for (var i = 0; i < values.length; i++) {
      final weight = (i + 1).toDouble();
      weightedSum += values[i] * weight;
      totalWeight += weight;
    }
    return weightedSum / totalWeight;
  }

  final riskValues = window
      .map((point) => point.risk ?? previous.risk)
      .toList();
  final varianceValues = window
      .map((point) => point.variance ?? previous.variance)
      .toList();
  final latencyValues = window
      .map((point) => point.latencyMs ?? previous.latencyMs.toDouble())
      .toList();
  final successValues = window
      .map((point) => point.successRate ?? previous.successRate)
      .toList();

  final smoothed = _ThresholdSnapshot(
    risk: weightedAverage(riskValues),
    variance: weightedAverage(varianceValues),
    latencyMs: weightedAverage(latencyValues).round(),
    successRate: weightedAverage(successValues),
  );

  final diff =
      (smoothed.risk - previous.risk).abs() +
      (smoothed.variance - previous.variance).abs() +
      (smoothed.successRate - previous.successRate).abs();

  final confidence = max(0.5, 1 - diff);
  final confidenceAvg = (confidence + (window.length / 5).clamp(0, 1)) / 2;

  return _RetrainedThresholds(
    risk: smoothed.risk,
    variance: smoothed.variance,
    latencyMs: smoothed.latencyMs,
    successRate: smoothed.successRate,
    confidenceAvg: confidenceAvg,
  );
}

Future<void> _writeSummary(
  _ThresholdSnapshot previous,
  _RetrainedThresholds retrained,
) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE FEEDBACK SUMMARY')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Confidence avg: ${retrained.confidenceAvg.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('| Metric | Previous | Retrained | Delta |')
    ..writeln('|--------|----------|-----------|-------|');

  void row(String label, double previousValue, double newValue) {
    buffer.writeln(
      '| $label | ${previousValue.toStringAsFixed(2)} | '
      '${newValue.toStringAsFixed(2)} | '
      '${(newValue - previousValue).toStringAsFixed(2)} |',
    );
  }

  row('Risk threshold', previous.risk, retrained.risk);
  row('Variance threshold', previous.variance, retrained.variance);
  row('Success rate threshold', previous.successRate, retrained.successRate);
  buffer.writeln(
    '| Latency threshold (ms) | ${previous.latencyMs} | '
    '${retrained.latencyMs} | ${retrained.latencyMs - previous.latencyMs} |',
  );

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double confidenceAvg,
  required double thresholdDelta,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_feedback_trained',
    'timestamp': DateTime.now().toIso8601String(),
    'confidence_avg': double.parse(confidenceAvg.toStringAsFixed(2)),
    'threshold_delta': double.parse(thresholdDelta.toStringAsFixed(2)),
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
      'adaptive_feedback_trainer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ThresholdSnapshot {
  const _ThresholdSnapshot({
    this.risk = 0,
    this.variance = 0,
    this.latencyMs = 0,
    this.successRate = 0,
  });

  final double risk;
  final double variance;
  final int latencyMs;
  final double successRate;
}

class _TelemetryPoint {
  const _TelemetryPoint({
    required this.timestamp,
    this.risk,
    this.variance,
    this.latencyMs,
    this.successRate,
  });

  final DateTime timestamp;
  final double? risk;
  final double? variance;
  final double? latencyMs;
  final double? successRate;
}

class _RetrainedThresholds extends _ThresholdSnapshot {
  const _RetrainedThresholds({
    required super.risk,
    required super.variance,
    required super.latencyMs,
    required super.successRate,
    required this.confidenceAvg,
  });

  final double confidenceAvg;

  double thresholdDelta(_ThresholdSnapshot previous) {
    final diff =
        (risk - previous.risk).abs() +
        (variance - previous.variance).abs() +
        (successRate - previous.successRate).abs();
    return diff;
  }
}
