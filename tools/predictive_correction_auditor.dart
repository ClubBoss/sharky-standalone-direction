import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _stabilitySummaryPath =
    'release/_reports/stability_verification_summary.txt';
const String _telemetryLearningPath =
    'release/_reports/telemetry_learning_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _summaryPath =
    'release/_reports/predictive_correction_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final stability = await _parseStabilitySummary();
  final telemetryLearning = await _parseTelemetryLearning();
  final correlation = _simulateCorrelation(
    stability.varianceDelta,
    telemetryLearning.varianceThreshold,
  );
  final accuracy = _scoreAccuracy(correlation);
  final driftPct = stability.varianceDelta * 100;
  final classification = _classifyAccuracy(accuracy);

  await _withReportsWritable(() async {
    await _writeSummary(
      stability,
      telemetryLearning,
      correlation,
      accuracy,
      driftPct,
      classification,
    );
    await _appendTelemetry(
      accuracyScore: accuracy,
      driftPct: driftPct,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'predictive_correction_auditor: accuracy=${accuracy.toStringAsFixed(2)} '
    'classification=$classification',
  );
}

Future<_StabilitySnapshot> _parseStabilitySummary() async {
  final file = File(_stabilitySummaryPath);
  if (!await file.exists()) return const _StabilitySnapshot();
  final lines = await file.readAsLines();
  double varianceDelta = 0;
  double volatilityDelta = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('- Variance delta')) {
      varianceDelta =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    } else if (trimmed.startsWith('- Volatility delta')) {
      volatilityDelta =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    }
  }
  return _StabilitySnapshot(
    varianceDelta: varianceDelta,
    volatilityDelta: volatilityDelta,
  );
}

Future<_TelemetryLearningSnapshot> _parseTelemetryLearning() async {
  final file = File(_telemetryLearningPath);
  if (!await file.exists()) return const _TelemetryLearningSnapshot();
  final lines = await file.readAsLines();
  double _value(String label) {
    final row = lines.firstWhere(
      (line) => line.contains(label),
      orElse: () => '',
    );
    if (row.isEmpty) return 0;
    final match = RegExp(r'(-?\d+\.?\d*)').firstMatch(row);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  return _TelemetryLearningSnapshot(
    riskThreshold: _value('- Risk threshold'),
    varianceThreshold: _value('- Variance threshold'),
    successRateThreshold: _value('- Success rate threshold'),
  );
}

double _simulateCorrelation(double actualDelta, double predictedVariance) {
  if (predictedVariance == 0 && actualDelta == 0) return 1.0;
  final numerator = actualDelta * predictedVariance;
  final denominator =
      sqrt(actualDelta * actualDelta + 1e-6) *
      sqrt(predictedVariance * predictedVariance + 1e-6);
  return (numerator / denominator).clamp(-1, 1);
}

double _scoreAccuracy(double correlation) {
  return double.parse((0.5 + correlation / 2).clamp(0, 1).toStringAsFixed(2));
}

String _classifyAccuracy(double accuracy) {
  if (accuracy >= 0.8) return 'Accurate';
  if (accuracy >= 0.6) return 'Moderate';
  return 'Off';
}

Future<void> _writeSummary(
  _StabilitySnapshot stability,
  _TelemetryLearningSnapshot learning,
  double correlation,
  double accuracy,
  double driftPct,
  String classification,
) async {
  final buffer = StringBuffer()
    ..writeln('PREDICTIVE CORRECTION SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln(
      'Accuracy score: ${accuracy.toStringAsFixed(2)} '
      '($classification)',
    )
    ..writeln('Variance delta: ${stability.varianceDelta.toStringAsFixed(3)}')
    ..writeln(
      'Forecast variance threshold: '
      '${learning.varianceThreshold.toStringAsFixed(3)}',
    )
    ..writeln('Drift: ${driftPct.toStringAsFixed(2)}%')
    ..writeln('Correlation: ${correlation.toStringAsFixed(2)}');

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double accuracyScore,
  required double driftPct,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'predictive_correction_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'accuracy_score': accuracyScore,
    'drift_pct': double.parse(driftPct.toStringAsFixed(2)),
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
      'predictive_correction_auditor: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _StabilitySnapshot {
  const _StabilitySnapshot({this.varianceDelta = 0, this.volatilityDelta = 0});

  final double varianceDelta;
  final double volatilityDelta;
}

class _TelemetryLearningSnapshot {
  const _TelemetryLearningSnapshot({
    this.riskThreshold = 0,
    this.varianceThreshold = 0,
    this.successRateThreshold = 0,
  });

  final double riskThreshold;
  final double varianceThreshold;
  final double successRateThreshold;
}
