import 'dart:convert';
import 'dart:io';
import 'dart:math';

const double _alpha = 0.4;
const String _finalSummaryPath =
    'release/_reports/final_consolidation_summary.txt';
const String _telemetryLearningPath =
    'release/_reports/telemetry_learning_summary.txt';
const String _outputPath = 'release/_reports/reliability_threshold_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final consolidation = await _parseFinalSummary();
  final learning = await _parseTelemetryLearning();
  final retuned = _retuneThresholds(consolidation, learning);

  final expectedIndex = _computeExpectedIndex(
    variance: retuned.varianceThreshold,
    accuracy: retuned.accuracyThreshold,
    success: retuned.successThreshold,
    latency: learning.latencyThreshold,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      consolidation: consolidation,
      learning: learning,
      retuned: retuned,
      expectedIndex: expectedIndex,
    );
    await _appendTelemetry(
      oldIndex: consolidation.reliabilityIndex,
      newIndex: expectedIndex,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'reliability_threshold_retuner: '
    'old=${consolidation.reliabilityIndex.toStringAsFixed(2)} '
    'new=${expectedIndex.toStringAsFixed(2)}',
  );
}

Future<_ConsolidationSnapshot> _parseFinalSummary() async {
  final file = File(_finalSummaryPath);
  if (!await file.exists()) return const _ConsolidationSnapshot();
  final lines = await file.readAsLines();
  double index = 0;
  String status = 'UNKNOWN';
  double varianceDelta = 0;
  double accuracy = 0;
  double success = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Reliability Index')) {
      index =
          double.tryParse(
            RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
      final statusMatch = RegExp(r'\((\w+)\)').firstMatch(trimmed);
      if (statusMatch != null) status = statusMatch.group(1)!;
    } else if (trimmed.startsWith('- Variance delta')) {
      varianceDelta =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    } else if (trimmed.startsWith('- Predictive accuracy')) {
      accuracy =
          double.tryParse(
            RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    } else if (trimmed.startsWith('- Success threshold')) {
      success =
          double.tryParse(
            RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    }
  }
  return _ConsolidationSnapshot(
    reliabilityIndex: index,
    status: status,
    varianceDelta: varianceDelta,
    predictiveAccuracy: accuracy,
    successObservation: success,
  );
}

Future<_LearningThresholds> _parseTelemetryLearning() async {
  final file = File(_telemetryLearningPath);
  if (!await file.exists()) return const _LearningThresholds();
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

  return _LearningThresholds(
    riskThreshold: _value('- Risk threshold'),
    varianceThreshold: _value('- Variance threshold'),
    latencyThreshold: _value('- Latency threshold'),
    successRateThreshold: _value('- Success rate threshold'),
  );
}

_RetunedThresholds _retuneThresholds(
  _ConsolidationSnapshot consolidation,
  _LearningThresholds learning,
) {
  double smooth(double oldValue, double observed) =>
      (1 - _alpha) * oldValue + _alpha * observed;

  final successObservation = consolidation.successObservation == 0
      ? learning.successRateThreshold
      : consolidation.successObservation;

  return _RetunedThresholds(
    varianceThreshold: smooth(
      learning.varianceThreshold,
      consolidation.varianceDelta.abs(),
    ),
    accuracyThreshold: smooth(
      learning.accuracyThreshold,
      consolidation.predictiveAccuracy,
    ),
    successThreshold: smooth(learning.successRateThreshold, successObservation),
    oldVarianceThreshold: learning.varianceThreshold,
    oldAccuracyThreshold: learning.accuracyThreshold,
    oldSuccessThreshold: learning.successRateThreshold,
  );
}

double _computeExpectedIndex({
  required double variance,
  required double accuracy,
  required double success,
  required double latency,
}) {
  final varianceScore = (1 - min(variance.abs(), 1)).clamp(0, 1);
  final accuracyScore = accuracy.clamp(0, 1);
  final latencyScore = latency == 0
      ? 1
      : (1 - min(latency / 5000, 1)).clamp(0, 1);
  final successScore = success.clamp(0, 1);
  final index =
      0.35 * varianceScore +
      0.35 * accuracyScore +
      0.15 * latencyScore +
      0.15 * successScore;
  return double.parse(index.toStringAsFixed(2));
}

Future<void> _writeSummary({
  required _ConsolidationSnapshot consolidation,
  required _LearningThresholds learning,
  required _RetunedThresholds retuned,
  required double expectedIndex,
}) async {
  final delta = expectedIndex - consolidation.reliabilityIndex;
  final buffer = StringBuffer()
    ..writeln('RELIABILITY THRESHOLD SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Alpha: ${_alpha.toStringAsFixed(2)}')
    ..writeln()
    ..writeln(
      'Previous reliability index: '
      '${consolidation.reliabilityIndex.toStringAsFixed(2)} '
      '(${consolidation.status})',
    )
    ..writeln(
      'Variance delta observed: ${consolidation.varianceDelta.toStringAsFixed(3)}',
    )
    ..writeln(
      'Predictive accuracy observed: '
      '${consolidation.predictiveAccuracy.toStringAsFixed(2)}',
    )
    ..writeln(
      'Success rate observed: '
      '${retuned.successThreshold.toStringAsFixed(2)} '
      '(smoothed)',
    )
    ..writeln()
    ..writeln('Threshold adjustments')
    ..writeln(
      '- Variance threshold: '
      '${retuned.oldVarianceThreshold.toStringAsFixed(3)} → '
      '${retuned.varianceThreshold.toStringAsFixed(3)}',
    )
    ..writeln(
      '- Accuracy threshold (derived from risk): '
      '${retuned.oldAccuracyThreshold.toStringAsFixed(3)} → '
      '${retuned.accuracyThreshold.toStringAsFixed(3)}',
    )
    ..writeln(
      '- Success rate threshold: '
      '${retuned.oldSuccessThreshold.toStringAsFixed(3)} → '
      '${retuned.successThreshold.toStringAsFixed(3)}',
    )
    ..writeln()
    ..writeln(
      'Expected reliability index: '
      '${expectedIndex.toStringAsFixed(2)} (${_statusFor(expectedIndex)})',
    )
    ..writeln(
      'Delta vs previous: '
      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln(
      'Latency baseline held at '
      '${learning.latencyThreshold.toStringAsFixed(0)} ms',
    );

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double oldIndex,
  required double newIndex,
  required int durationMs,
}) async {
  final payload = {
    'event': 'reliability_threshold_retuned',
    'timestamp': DateTime.now().toIso8601String(),
    'old_index': double.parse(oldIndex.toStringAsFixed(2)),
    'new_index': newIndex,
    'delta': double.parse((newIndex - oldIndex).toStringAsFixed(3)),
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _statusFor(double index) {
  if (index >= 0.8) return 'PASS';
  if (index >= 0.6) return 'WARN';
  return 'FAIL';
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
      'reliability_threshold_retuner: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ConsolidationSnapshot {
  const _ConsolidationSnapshot({
    this.reliabilityIndex = 0,
    this.status = 'UNKNOWN',
    this.varianceDelta = 0,
    this.predictiveAccuracy = 0,
    this.successObservation = 0,
  });

  final double reliabilityIndex;
  final String status;
  final double varianceDelta;
  final double predictiveAccuracy;
  final double successObservation;
}

class _LearningThresholds {
  const _LearningThresholds({
    this.riskThreshold = 0,
    this.varianceThreshold = 0,
    this.latencyThreshold = 0,
    this.successRateThreshold = 0,
  });

  final double riskThreshold;
  final double varianceThreshold;
  final double latencyThreshold;
  final double successRateThreshold;

  double get accuracyThreshold => (1 - riskThreshold).clamp(0, 1);
}

class _RetunedThresholds {
  const _RetunedThresholds({
    required this.varianceThreshold,
    required this.accuracyThreshold,
    required this.successThreshold,
    required this.oldVarianceThreshold,
    required this.oldAccuracyThreshold,
    required this.oldSuccessThreshold,
  });

  final double varianceThreshold;
  final double accuracyThreshold;
  final double successThreshold;
  final double oldVarianceThreshold;
  final double oldAccuracyThreshold;
  final double oldSuccessThreshold;
}
