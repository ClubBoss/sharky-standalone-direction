import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _continuousSummaryPath =
    'release/_reports/continuous_stream_summary.txt';
const String _adaptiveSummaryPath =
    'release/_reports/adaptive_feedback_summary.txt';
const String _reportsDir = 'release/_reports';
const String _summaryPath =
    'release/_reports/stability_verification_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final continuous = await _parseContinuousSummary();
  final adaptive = await _parseAdaptiveSummary();

  final varianceDelta = continuous.avgVariance - adaptive.varianceThreshold;
  final volatilityDelta = continuous.passRate - adaptive.successRateThreshold;
  final outcome = _classifyOutcome(varianceDelta, volatilityDelta);

  await _withReportsWritable(() async {
    await _writeSummary(
      continuous: continuous,
      adaptive: adaptive,
      varianceDelta: varianceDelta,
      volatilityDelta: volatilityDelta,
      outcome: outcome,
    );
    await _appendTelemetry(
      varianceDelta: varianceDelta,
      improvementScore: volatilityDelta,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'stability_verification_cycle: varianceDelta=${varianceDelta.toStringAsFixed(3)} '
    'volatilityDelta=${volatilityDelta.toStringAsFixed(3)} outcome=$outcome',
  );
}

Future<_ContinuousMetrics> _parseContinuousSummary() async {
  final file = File(_continuousSummaryPath);
  if (!await file.exists()) return const _ContinuousMetrics();
  final lines = await file.readAsLines();

  double passRate = 0;
  final tableRows = <List<String>>[];
  bool inTable = false;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.contains('pass rate')) {
      final match = RegExp(r'pass rate\s([0-9.]+)').firstMatch(trimmed);
      if (match != null) {
        passRate = double.tryParse(match.group(1) ?? '') ?? 0;
      }
    }
    if (trimmed.startsWith('| Timestamp |')) {
      inTable = true;
      continue;
    }
    if (inTable) {
      if (!trimmed.startsWith('|') || trimmed.startsWith('| Thresholds')) break;
      final cells = trimmed.split('|').map((c) => c.trim()).toList();
      if (cells.length >= 6 && cells[1] != 'Timestamp') {
        tableRows.add(cells);
      }
    }
  }

  double avgVariance = 0;
  double volatility = 0;
  if (tableRows.isNotEmpty) {
    final variances = <double>[];
    final riskValues = <double>[];
    for (final row in tableRows) {
      final variance =
          double.tryParse(row[4] == '' ? row[3] : row[3]) ??
          double.tryParse(row[4]) ??
          0.0;
      variances.add(variance);
      final risk = double.tryParse(row[3]) ?? 0.0;
      riskValues.add(risk);
    }
    avgVariance = variances.reduce((a, b) => a + b) / max(1, variances.length);
    final meanRisk =
        riskValues.reduce((a, b) => a + b) / max(1, riskValues.length);
    final varianceRisk =
        riskValues
            .map((value) => pow(value - meanRisk, 2).toDouble())
            .reduce((a, b) => a + b) /
        max(1, riskValues.length);
    volatility = sqrt(varianceRisk);
  }

  return _ContinuousMetrics(
    passRate: passRate,
    avgVariance: avgVariance,
    volatility: volatility,
  );
}

Future<_AdaptiveThresholds> _parseAdaptiveSummary() async {
  final file = File(_adaptiveSummaryPath);
  if (!await file.exists()) return const _AdaptiveThresholds();
  final lines = await file.readAsLines();

  double _extractValue(String label) {
    final row = lines.firstWhere(
      (line) => line.contains(label),
      orElse: () => '',
    );
    if (row.isEmpty) return 0;
    final cells = row
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();
    if (cells.length < 3) return 0;
    return double.tryParse(cells[2]) ?? 0;
  }

  final variance = _extractValue('Variance threshold');
  final success = _extractValue('Success rate threshold');
  return _AdaptiveThresholds(
    varianceThreshold: variance,
    successRateThreshold: success,
  );
}

String _classifyOutcome(double varianceDelta, double volatilityDelta) {
  if (varianceDelta <= 0 && volatilityDelta >= 0.05) {
    return 'Improved';
  }
  if (varianceDelta.abs() < 0.01 && volatilityDelta.abs() < 0.02) {
    return 'Neutral';
  }
  return 'Degraded';
}

Future<void> _writeSummary({
  required _ContinuousMetrics continuous,
  required _AdaptiveThresholds adaptive,
  required double varianceDelta,
  required double volatilityDelta,
  required String outcome,
}) async {
  final buffer = StringBuffer()
    ..writeln('STABILITY VERIFICATION SUMMARY')
    ..writeln('==============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Outcome: $outcome')
    ..writeln()
    ..writeln('Metrics')
    ..writeln('- Pass rate: ${continuous.passRate.toStringAsFixed(2)}')
    ..writeln(
      '- Average variance: ${continuous.avgVariance.toStringAsFixed(3)} '
      'vs threshold ${adaptive.varianceThreshold.toStringAsFixed(3)}',
    )
    ..writeln(
      '- Volatility (risk std dev): ${continuous.volatility.toStringAsFixed(3)} '
      'vs success threshold ${adaptive.successRateThreshold.toStringAsFixed(3)}',
    )
    ..writeln('- Variance delta: ${varianceDelta.toStringAsFixed(3)}')
    ..writeln('- Volatility delta: ${volatilityDelta.toStringAsFixed(3)}');

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double varianceDelta,
  required double improvementScore,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'stability_verification_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'variance_delta': double.parse(varianceDelta.toStringAsFixed(3)),
    'improvement_score': double.parse(improvementScore.toStringAsFixed(3)),
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
      'stability_verification_cycle: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ContinuousMetrics {
  const _ContinuousMetrics({
    this.passRate = 0,
    this.avgVariance = 0,
    this.volatility = 0,
  });

  final double passRate;
  final double avgVariance;
  final double volatility;
}

class _AdaptiveThresholds {
  const _AdaptiveThresholds({
    this.varianceThreshold = 0,
    this.successRateThreshold = 0,
  });

  final double varianceThreshold;
  final double successRateThreshold;
}
