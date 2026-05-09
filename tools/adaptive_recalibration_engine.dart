import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _revalidationPath =
    'release/_reports/reliability_revalidation_summary.txt';
const String _learningPath = 'release/_reports/telemetry_learning_summary.txt';
const String _outputPath =
    'release/_reports/adaptive_recalibration_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

const double _alpha = 0.5;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final revalidation = await _parseRevalidation();
  final learning = await _parseLearning();

  final componentScores = _computeComponentScores(revalidation, learning);

  final newWeights = _recalculateWeights(
    oldWeights: revalidation.weights,
    scores: componentScores,
  );

  final predictedIndex = _predictIndex(
    weights: newWeights,
    scores: componentScores,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      revalidation: revalidation,
      learning: learning,
      newWeights: newWeights,
      scores: componentScores,
      predictedIndex: predictedIndex,
    );
    await _appendTelemetry(
      oldWeights: revalidation.weights,
      newWeights: newWeights,
      predictedIndex: predictedIndex,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_recalibration_engine: '
    'weights=${newWeights.toStringAsFixed()} predicted=${predictedIndex.toStringAsFixed(2)}',
  );
}

Future<_RevalidationSnapshot> _parseRevalidation() async {
  final file = File(_revalidationPath);
  if (!await file.exists()) return const _RevalidationSnapshot();
  final lines = await file.readAsLines();

  double oldIndex = 0;
  String oldStatus = 'UNKNOWN';
  double revalidatedIndex = 0;
  String revalidatedStatus = 'UNKNOWN';
  double varianceObserved = 0;
  double varianceThreshold = 0;
  double accuracyObserved = 0;
  double accuracyThreshold = 0;
  double successObserved = 0;
  double successThreshold = 0;
  final weights = <String, double>{};
  final scores = <String, double>{};

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Previous reliability index')) {
      final match = RegExp(r'([0-9]+\.?[0-9]*) \((\w+)\)').firstMatch(line);
      if (match != null) {
        oldIndex = double.tryParse(match.group(1) ?? '') ?? 0;
        oldStatus = match.group(2) ?? oldStatus;
      }
    } else if (line.startsWith('Revalidated index')) {
      final match = RegExp(r'([0-9]+\.?[0-9]*) \((\w+)\)').firstMatch(line);
      if (match != null) {
        revalidatedIndex = double.tryParse(match.group(1) ?? '') ?? 0;
        revalidatedStatus = match.group(2) ?? revalidatedStatus;
      }
    } else if (line.startsWith('- Variance observed')) {
      varianceObserved =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(line)?.group(1) ?? '',
          ) ??
          0;
    } else if (line.startsWith('- Variance threshold')) {
      varianceThreshold =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(line)?.group(1) ?? '',
          ) ??
          0;
    } else if (line.startsWith('- Accuracy observed')) {
      accuracyObserved =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(line)?.group(1) ?? '',
          ) ??
          0;
    } else if (line.startsWith('- Accuracy threshold')) {
      accuracyThreshold =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(line)?.group(1) ?? '',
          ) ??
          0;
    } else if (line.startsWith('- Success observed')) {
      successObserved =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(line)?.group(1) ?? '',
          ) ??
          0;
    } else if (line.startsWith('- Success threshold')) {
      successThreshold =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(line)?.group(1) ?? '',
          ) ??
          0;
    } else if (line.startsWith('- Variance weight')) {
      final match = RegExp(
        r'(-?\d+\.?\d*).*\(score=(-?\d+\.?\d*)\)',
      ).firstMatch(line);
      if (match != null) {
        weights['variance'] = double.tryParse(match.group(1) ?? '') ?? 0.0;
        scores['variance'] = double.tryParse(match.group(2) ?? '') ?? 0.0;
      }
    } else if (line.startsWith('- Accuracy weight')) {
      final match = RegExp(
        r'(-?\d+\.?\d*).*\(score=(-?\d+\.?\d*)\)',
      ).firstMatch(line);
      if (match != null) {
        weights['accuracy'] = double.tryParse(match.group(1) ?? '') ?? 0.0;
        scores['accuracy'] = double.tryParse(match.group(2) ?? '') ?? 0.0;
      }
    } else if (line.startsWith('- Success weight')) {
      final match = RegExp(
        r'(-?\d+\.?\d*).*\(score=(-?\d+\.?\d*)\)',
      ).firstMatch(line);
      if (match != null) {
        weights['success'] = double.tryParse(match.group(1) ?? '') ?? 0.0;
        scores['success'] = double.tryParse(match.group(2) ?? '') ?? 0.0;
      }
    }
  }

  return _RevalidationSnapshot(
    oldIndex: oldIndex,
    oldStatus: oldStatus,
    revalidatedIndex: revalidatedIndex,
    revalidatedStatus: revalidatedStatus,
    varianceObserved: varianceObserved,
    varianceThreshold: varianceThreshold,
    accuracyObserved: accuracyObserved,
    accuracyThreshold: accuracyThreshold,
    successObserved: successObserved,
    successThreshold: successThreshold,
    weights: _ComponentWeights(
      variance: weights['variance'] ?? 0.33,
      accuracy: weights['accuracy'] ?? 0.33,
      success: weights['success'] ?? 0.34,
    ),
    reportedScores: _ComponentScores(
      variance: scores['variance'] ?? 0,
      accuracy: scores['accuracy'] ?? 0,
      success: scores['success'] ?? 0,
    ),
  );
}

Future<_LearningSnapshot> _parseLearning() async {
  final file = File(_learningPath);
  if (!await file.exists()) return const _LearningSnapshot();
  final lines = await file.readAsLines();

  double valueFor(String label) {
    final row = lines.firstWhere(
      (line) => line.contains(label),
      orElse: () => '',
    );
    if (row.isEmpty) return 0;
    final match = RegExp(r'(-?\d+\.?\d*)').firstMatch(row);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  return _LearningSnapshot(
    riskThreshold: valueFor('- Risk threshold'),
    varianceThreshold: valueFor('- Variance threshold'),
    latencyThreshold: valueFor('- Latency threshold'),
    successThreshold: valueFor('- Success rate threshold'),
  );
}

_ComponentScores _computeComponentScores(
  _RevalidationSnapshot revalidation,
  _LearningSnapshot learning,
) {
  double varianceThreshold = revalidation.varianceThreshold != 0
      ? revalidation.varianceThreshold.abs()
      : learning.varianceThreshold.abs();
  if (varianceThreshold == 0) varianceThreshold = 1;

  final double accuracyThreshold = revalidation.accuracyThreshold != 0
      ? revalidation.accuracyThreshold
      : (learning.riskThreshold > 0
            ? (1 - learning.riskThreshold).clamp(0, 1)
            : 1);

  final double successThreshold = revalidation.successThreshold != 0
      ? revalidation.successThreshold
      : (learning.successThreshold != 0 ? learning.successThreshold : 1);

  final varianceScore =
      (1 - min((revalidation.varianceObserved.abs()) / varianceThreshold, 1))
          .clamp(0, 1)
          .toDouble();
  final accuracyScore =
      (revalidation.accuracyObserved == 0
              ? 0
              : (revalidation.accuracyObserved / accuracyThreshold))
          .clamp(0, 1)
          .toDouble();
  final successScore =
      (successThreshold == 0
              ? revalidation.successObserved
              : (revalidation.successObserved / successThreshold))
          .clamp(0, 1)
          .toDouble();

  return _ComponentScores(
    variance: double.parse(varianceScore.toStringAsFixed(2)),
    accuracy: double.parse(accuracyScore.toStringAsFixed(2)),
    success: double.parse(successScore.toStringAsFixed(2)),
  );
}

_ComponentWeights _recalculateWeights({
  required _ComponentWeights oldWeights,
  required _ComponentScores scores,
}) {
  final values = [scores.variance, scores.accuracy, scores.success];
  final total = values.fold<double>(0, (sum, v) => sum + v);
  List<double> feedback;
  if (total == 0) {
    feedback = [1 / 3, 1 / 3, 1 / 3];
  } else {
    feedback = values.map((v) => v / total).toList();
  }

  double mix(double old, double fb) => (1 - _alpha) * old + _alpha * fb;

  double variance = mix(oldWeights.variance, feedback[0]);
  double accuracy = mix(oldWeights.accuracy, feedback[1]);
  double success = mix(oldWeights.success, feedback[2]);
  final sum = variance + accuracy + success;
  if (sum != 0) {
    variance /= sum;
    accuracy /= sum;
    success /= sum;
  }

  return _ComponentWeights(
    variance: double.parse(variance.toStringAsFixed(3)),
    accuracy: double.parse(accuracy.toStringAsFixed(3)),
    success: double.parse(success.toStringAsFixed(3)),
  );
}

double _predictIndex({
  required _ComponentWeights weights,
  required _ComponentScores scores,
}) {
  final index =
      weights.variance * scores.variance +
      weights.accuracy * scores.accuracy +
      weights.success * scores.success;
  return double.parse(index.toStringAsFixed(2));
}

Future<void> _writeSummary({
  required _RevalidationSnapshot revalidation,
  required _LearningSnapshot learning,
  required _ComponentWeights newWeights,
  required _ComponentScores scores,
  required double predictedIndex,
}) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE RECALIBRATION SUMMARY')
    ..writeln('===============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Learning rate α = ${_alpha.toStringAsFixed(2)}')
    ..writeln()
    ..writeln(
      'Previous reliability index: '
      '${revalidation.revalidatedIndex.toStringAsFixed(2)} '
      '(${revalidation.revalidatedStatus})',
    )
    ..writeln(
      'Component scores (variance/accuracy/success): '
      '${scores.variance.toStringAsFixed(2)} / '
      '${scores.accuracy.toStringAsFixed(2)} / '
      '${scores.success.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln('Weights')
    ..writeln(
      '- Variance: ${revalidation.weights.variance.toStringAsFixed(2)} '
      '→ ${newWeights.variance.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Accuracy: ${revalidation.weights.accuracy.toStringAsFixed(2)} '
      '→ ${newWeights.accuracy.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Success: ${revalidation.weights.success.toStringAsFixed(2)} '
      '→ ${newWeights.success.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln(
      'Predicted reliability index: ${predictedIndex.toStringAsFixed(2)}',
    )
    ..writeln(
      'Learning thresholds (variance / success / risk): '
      '${learning.varianceThreshold.toStringAsFixed(3)} / '
      '${learning.successThreshold.toStringAsFixed(3)} / '
      '${learning.riskThreshold.toStringAsFixed(3)}',
    );

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required _ComponentWeights oldWeights,
  required _ComponentWeights newWeights,
  required double predictedIndex,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_recalibration_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'old_weights': oldWeights.toJson(),
    'new_weights': newWeights.toJson(),
    'predicted_index': predictedIndex,
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
      'adaptive_recalibration_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

extension on _ComponentWeights {
  Map<String, double> toJson() => {
    'variance': double.parse(variance.toStringAsFixed(3)),
    'accuracy': double.parse(accuracy.toStringAsFixed(3)),
    'success': double.parse(success.toStringAsFixed(3)),
  };

  String toStringAsFixed([int fractionDigits = 2]) =>
      '(${variance.toStringAsFixed(fractionDigits)}, '
      '${accuracy.toStringAsFixed(fractionDigits)}, '
      '${success.toStringAsFixed(fractionDigits)})';
}

class _RevalidationSnapshot {
  const _RevalidationSnapshot({
    this.oldIndex = 0,
    this.oldStatus = 'UNKNOWN',
    this.revalidatedIndex = 0,
    this.revalidatedStatus = 'UNKNOWN',
    this.varianceObserved = 0,
    this.varianceThreshold = 0,
    this.accuracyObserved = 0,
    this.accuracyThreshold = 0,
    this.successObserved = 0,
    this.successThreshold = 0,
    this.weights = const _ComponentWeights(),
    this.reportedScores = const _ComponentScores(),
  });

  final double oldIndex;
  final String oldStatus;
  final double revalidatedIndex;
  final String revalidatedStatus;
  final double varianceObserved;
  final double varianceThreshold;
  final double accuracyObserved;
  final double accuracyThreshold;
  final double successObserved;
  final double successThreshold;
  final _ComponentWeights weights;
  final _ComponentScores reportedScores;
}

class _LearningSnapshot {
  const _LearningSnapshot({
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

class _ComponentWeights {
  const _ComponentWeights({
    this.variance = 0.33,
    this.accuracy = 0.33,
    this.success = 0.34,
  });

  final double variance;
  final double accuracy;
  final double success;
}

class _ComponentScores {
  const _ComponentScores({
    this.variance = 0,
    this.accuracy = 0,
    this.success = 0,
  });

  final double variance;
  final double accuracy;
  final double success;
}
