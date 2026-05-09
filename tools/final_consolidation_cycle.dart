import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _stabilityPath =
    'release/_reports/stability_verification_summary.txt';
const String _predictivePath =
    'release/_reports/predictive_correction_summary.txt';
const String _telemetryLearningPath =
    'release/_reports/telemetry_learning_summary.txt';
const String _adaptiveSummaryPath =
    'release/_reports/adaptive_feedback_summary.txt';
const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/final_consolidation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final stability = await _parseStability();
  final predictive = await _parsePredictive();
  final learning = await _parseTelemetryLearning();
  final adaptive = await _parseAdaptiveSummary();

  final index = _computeReliabilityIndex(
    stability: stability,
    predictive: predictive,
    learning: learning,
    adaptive: adaptive,
  );
  final status = _statusFor(index);
  final risks = _topRisks(stability, predictive, learning, adaptive);

  await _withReportsWritable(() async {
    await _writeSummary(
      stability: stability,
      predictive: predictive,
      learning: learning,
      adaptive: adaptive,
      index: index,
      status: status,
      risks: risks,
    );
    await _appendTelemetry(
      reliabilityIndex: index,
      status: status,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'final_consolidation_cycle: index=${index.toStringAsFixed(2)} status=$status',
  );
}

Future<_StabilityReport> _parseStability() async {
  final file = File(_stabilityPath);
  if (!await file.exists()) return const _StabilityReport();
  final lines = await file.readAsLines();
  double varianceDelta = 0;
  double passRate = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('- Variance delta')) {
      varianceDelta =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    } else if (trimmed.startsWith('- Pass rate')) {
      passRate =
          double.tryParse(
            RegExp(r'([0-9.]+)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    }
  }
  return _StabilityReport(varianceDelta: varianceDelta, passRate: passRate);
}

Future<_PredictiveReport> _parsePredictive() async {
  final file = File(_predictivePath);
  if (!await file.exists()) return const _PredictiveReport();
  final lines = await file.readAsLines();
  double accuracy = 0;
  double driftPct = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Accuracy score')) {
      accuracy =
          double.tryParse(
            RegExp(r'([0-9.]+)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    } else if (trimmed.startsWith('Drift')) {
      driftPct =
          double.tryParse(
            RegExp(r'([0-9.]+)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    }
  }
  return _PredictiveReport(accuracyScore: accuracy, driftPct: driftPct);
}

Future<_LearningReport> _parseTelemetryLearning() async {
  final file = File(_telemetryLearningPath);
  if (!await file.exists()) return const _LearningReport();
  final lines = await file.readAsLines();
  double risk = 0;
  double variance = 0;
  double latency = 0;
  double success = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    final value =
        double.tryParse(
          RegExp(r'(-?\d+\.?\d*)').firstMatch(trimmed)?.group(1) ?? '',
        ) ??
        null;
    if (trimmed.startsWith('- Risk threshold')) {
      risk = value ?? risk;
    } else if (trimmed.startsWith('- Variance threshold')) {
      variance = value ?? variance;
    } else if (trimmed.startsWith('- Latency threshold')) {
      latency = value ?? latency;
    } else if (trimmed.startsWith('- Success rate threshold')) {
      success = value ?? success;
    }
  }
  return _LearningReport(
    riskThreshold: risk,
    varianceThreshold: variance,
    latencyThreshold: latency,
    successThreshold: success,
  );
}

Future<_AdaptiveReport> _parseAdaptiveSummary() async {
  final file = File(_adaptiveSummaryPath);
  if (!await file.exists()) return const _AdaptiveReport();
  final lines = await file.readAsLines();
  double risk = 0;
  double variance = 0;
  double success = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('|')) continue;
    final cells = trimmed
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();
    if (cells.length < 4) continue;
    final label = cells[0];
    final retrained = double.tryParse(cells[2]) ?? 0;
    if (label.startsWith('Risk threshold')) {
      risk = retrained;
    } else if (label.startsWith('Variance threshold')) {
      variance = retrained;
    } else if (label.startsWith('Success rate threshold')) {
      success = retrained;
    }
  }
  return _AdaptiveReport(
    riskRebaseline: risk,
    varianceRebaseline: variance,
    successRebaseline: success,
  );
}

double _computeReliabilityIndex({
  required _StabilityReport stability,
  required _PredictiveReport predictive,
  required _LearningReport learning,
  required _AdaptiveReport adaptive,
}) {
  double normalizeVariance(double value) => (1 - min(max(value, 0), 1));
  final varianceScore = normalizeVariance(stability.varianceDelta.abs());
  final accuracyScore = predictive.accuracyScore.clamp(0, 1);
  final latencyScore = learning.latencyThreshold == 0
      ? 1
      : (1 - min(learning.latencyThreshold / 5000, 1));
  final successScore = adaptive.successRebaseline.clamp(0, 1);

  final index =
      0.35 * varianceScore +
      0.35 * accuracyScore +
      0.15 * latencyScore +
      0.15 * successScore;
  return double.parse(index.toStringAsFixed(2));
}

String _statusFor(double index) {
  if (index >= 0.8) return 'PASS';
  if (index >= 0.6) return 'WARN';
  return 'FAIL';
}

List<String> _topRisks(
  _StabilityReport stability,
  _PredictiveReport predictive,
  _LearningReport learning,
  _AdaptiveReport adaptive,
) {
  final risks = <String>[];
  if (stability.varianceDelta > 0.02) {
    risks.add('Variance delta ${stability.varianceDelta.toStringAsFixed(3)}');
  }
  if (predictive.accuracyScore < 0.6) {
    risks.add(
      'Predictive accuracy low (${predictive.accuracyScore.toStringAsFixed(2)})',
    );
  }
  if (learning.latencyThreshold > 4000) {
    risks.add(
      'Latency threshold high (${learning.latencyThreshold.toStringAsFixed(0)} ms)',
    );
  }
  if (adaptive.successRebaseline < 0.2) {
    risks.add(
      'Success re-baseline low (${adaptive.successRebaseline.toStringAsFixed(2)})',
    );
  }
  if (risks.isEmpty) {
    risks.add('No significant risks detected.');
  }
  return risks;
}

Future<void> _writeSummary({
  required _StabilityReport stability,
  required _PredictiveReport predictive,
  required _LearningReport learning,
  required _AdaptiveReport adaptive,
  required double index,
  required String status,
  required List<String> risks,
}) async {
  final buffer = StringBuffer()
    ..writeln('FINAL CONSOLIDATION SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Reliability Index: ${index.toStringAsFixed(2)} ($status)')
    ..writeln()
    ..writeln('Inputs')
    ..writeln('- Variance delta: ${stability.varianceDelta.toStringAsFixed(3)}')
    ..writeln(
      '- Predictive accuracy: ${predictive.accuracyScore.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Latency threshold: ${learning.latencyThreshold.toStringAsFixed(0)} ms',
    )
    ..writeln(
      '- Success threshold: ${adaptive.successRebaseline.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln('Top Risks:');
  for (final risk in risks.take(5)) {
    buffer.writeln('- $risk');
  }
  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double reliabilityIndex,
  required String status,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'final_consolidation_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'reliability_index': double.parse(reliabilityIndex.toStringAsFixed(2)),
    'status': status,
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
      'final_consolidation_cycle: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _StabilityReport {
  const _StabilityReport({this.varianceDelta = 0, this.passRate = 0});

  final double varianceDelta;
  final double passRate;
}

class _PredictiveReport {
  const _PredictiveReport({this.accuracyScore = 0, this.driftPct = 0});

  final double accuracyScore;
  final double driftPct;
}

class _LearningReport {
  const _LearningReport({
    this.riskThreshold = 0,
    this.varianceThreshold = 0,
    this.latencyThreshold = 0,
    this.successThreshold = 0,
  });

  final double riskThreshold;
  final double varianceThreshold;
  final double latencyThreshold;
  final double successThreshold;
}

class _AdaptiveReport {
  const _AdaptiveReport({
    this.riskRebaseline = 0,
    this.varianceRebaseline = 0,
    this.successRebaseline = 0,
  });

  final double riskRebaseline;
  final double varianceRebaseline;
  final double successRebaseline;
}
