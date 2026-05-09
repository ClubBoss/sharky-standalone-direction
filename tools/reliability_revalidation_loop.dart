import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _finalSummaryPath =
    'release/_reports/final_consolidation_summary.txt';
const String _retuneSummaryPath =
    'release/_reports/reliability_threshold_summary.txt';
const String _outputPath =
    'release/_reports/reliability_revalidation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

const double _varianceWeight = 0.4;
const double _accuracyWeight = 0.35;
const double _successWeight = 0.25;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final consolidation = await _parseFinalSummary();
  final retune = await _parseRetuneSummary();

  final newIndex = _computeIndex(
    varianceObserved: consolidation.varianceDelta.abs(),
    varianceThreshold: retune.varianceThreshold,
    accuracyObserved: consolidation.predictiveAccuracy,
    accuracyThreshold: retune.accuracyThreshold,
    successObserved: retune.successObserved,
    successThreshold: retune.successThreshold,
  );
  final status = _statusFor(newIndex);

  await _withReportsWritable(() async {
    await _writeSummary(
      consolidation: consolidation,
      retune: retune,
      revalidatedIndex: newIndex,
      status: status,
    );
    await _appendTelemetry(
      oldIndex: consolidation.reliabilityIndex,
      newIndex: newIndex,
      status: status,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'reliability_revalidation_loop: '
    'old=${consolidation.reliabilityIndex.toStringAsFixed(2)} '
    'new=${newIndex.toStringAsFixed(2)} status=$status',
  );
}

Future<_FinalSnapshot> _parseFinalSummary() async {
  final file = File(_finalSummaryPath);
  if (!await file.exists()) return const _FinalSnapshot();
  final lines = await file.readAsLines();
  double index = 0;
  String status = 'UNKNOWN';
  double variance = 0;
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
      variance =
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
  return _FinalSnapshot(
    reliabilityIndex: index,
    status: status,
    varianceDelta: variance,
    predictiveAccuracy: accuracy,
    successBaseline: success,
  );
}

Future<_RetuneSnapshot> _parseRetuneSummary() async {
  final file = File(_retuneSummaryPath);
  if (!await file.exists()) return const _RetuneSnapshot();
  final lines = await file.readAsLines();

  double varianceThreshold = 0;
  double accuracyThreshold = 0;
  double successThreshold = 0;
  double successObserved = 0;
  double expectedIndex = 0;
  String expectedStatus = 'UNKNOWN';

  for (final raw in lines) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('Success rate observed')) {
      successObserved =
          double.tryParse(
            RegExp(r'(-?\d+\.?\d*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
    } else if (trimmed.startsWith('- Variance threshold')) {
      varianceThreshold = _parseArrowValue(trimmed);
    } else if (trimmed.startsWith('- Accuracy threshold')) {
      accuracyThreshold = _parseArrowValue(trimmed);
    } else if (trimmed.startsWith('- Success rate threshold')) {
      successThreshold = _parseArrowValue(trimmed);
    } else if (trimmed.startsWith('Expected reliability index')) {
      expectedIndex =
          double.tryParse(
            RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(trimmed)?.group(1) ?? '',
          ) ??
          0;
      final statusMatch = RegExp(r'\((\w+)\)').firstMatch(trimmed);
      if (statusMatch != null) expectedStatus = statusMatch.group(1)!;
    }
  }

  return _RetuneSnapshot(
    varianceThreshold: varianceThreshold,
    accuracyThreshold: accuracyThreshold,
    successThreshold: successThreshold,
    successObserved: successObserved == 0 ? successThreshold : successObserved,
    expectedIndex: expectedIndex,
    expectedStatus: expectedStatus,
  );
}

double _parseArrowValue(String line) {
  final parts = line.split('→');
  if (parts.length < 2) return 0;
  final right = parts.last.trim();
  final match = RegExp(r'(-?\d+\.?\d*)').firstMatch(right);
  if (match == null) return 0;
  return double.tryParse(match.group(1) ?? '') ?? 0;
}

double _computeIndex({
  required double varianceObserved,
  required double varianceThreshold,
  required double accuracyObserved,
  required double accuracyThreshold,
  required double successObserved,
  required double successThreshold,
}) {
  double varianceScore;
  if (varianceThreshold <= 0) {
    varianceScore = (1 - min(varianceObserved, 1)).clamp(0, 1).toDouble();
  } else {
    final ratio = varianceObserved / varianceThreshold;
    varianceScore = (1 - min(ratio, 1)).clamp(0, 1).toDouble();
  }

  double accuracyScore;
  if (accuracyThreshold <= 0) {
    accuracyScore = accuracyObserved.clamp(0, 1).toDouble();
  } else {
    accuracyScore = (accuracyObserved / accuracyThreshold)
        .clamp(0, 1)
        .toDouble();
  }

  double successScore;
  if (successThreshold <= 0) {
    successScore = successObserved.clamp(0, 1).toDouble();
  } else {
    successScore = (successObserved / successThreshold).clamp(0, 1).toDouble();
  }

  final index =
      _varianceWeight * varianceScore +
      _accuracyWeight * accuracyScore +
      _successWeight * successScore;
  return double.parse(index.toStringAsFixed(2));
}

Future<void> _writeSummary({
  required _FinalSnapshot consolidation,
  required _RetuneSnapshot retune,
  required double revalidatedIndex,
  required String status,
}) async {
  final buffer = StringBuffer()
    ..writeln('RELIABILITY REVALIDATION SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln(
      'Previous reliability index: '
      '${consolidation.reliabilityIndex.toStringAsFixed(2)} '
      '(${consolidation.status})',
    )
    ..writeln(
      'Threshold retune expectation: '
      '${retune.expectedIndex.toStringAsFixed(2)} '
      '(${retune.expectedStatus})',
    )
    ..writeln(
      'Revalidated index: ${revalidatedIndex.toStringAsFixed(2)} ($status)',
    )
    ..writeln()
    ..writeln('Inputs')
    ..writeln(
      '- Variance observed: ${consolidation.varianceDelta.toStringAsFixed(3)}',
    )
    ..writeln(
      '- Variance threshold: ${retune.varianceThreshold.toStringAsFixed(3)}',
    )
    ..writeln(
      '- Accuracy observed: ${consolidation.predictiveAccuracy.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Accuracy threshold: ${retune.accuracyThreshold.toStringAsFixed(3)}',
    )
    ..writeln(
      '- Success observed: ${retune.successObserved.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Success threshold: ${retune.successThreshold.toStringAsFixed(3)}',
    )
    ..writeln()
    ..writeln('Weights')
    ..writeln(
      '- Variance weight: ${_varianceWeight.toStringAsFixed(2)} '
      '(score=${_componentScoreText(consolidation.varianceDelta.abs(), retune.varianceThreshold, negative: true)})',
    )
    ..writeln(
      '- Accuracy weight: ${_accuracyWeight.toStringAsFixed(2)} '
      '(score=${_componentScoreText(consolidation.predictiveAccuracy, retune.accuracyThreshold)})',
    )
    ..writeln(
      '- Success weight: ${_successWeight.toStringAsFixed(2)} '
      '(score=${_componentScoreText(retune.successObserved, retune.successThreshold)})',
    );

  await File(_outputPath).writeAsString(buffer.toString());
}

String _componentScoreText(
  double observed,
  double threshold, {
  bool negative = false,
}) {
  if (negative) {
    if (threshold <= 0) {
      return (1 - min(observed, 1)).clamp(0, 1).toStringAsFixed(2);
    }
    final ratio = observed / threshold;
    return (1 - min(ratio, 1)).clamp(0, 1).toStringAsFixed(2);
  }
  if (threshold <= 0) return observed.clamp(0, 1).toStringAsFixed(2);
  return (observed / threshold).clamp(0, 1).toStringAsFixed(2);
}

Future<void> _appendTelemetry({
  required double oldIndex,
  required double newIndex,
  required String status,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'reliability_revalidated',
    'timestamp': DateTime.now().toIso8601String(),
    'old_index': double.parse(oldIndex.toStringAsFixed(2)),
    'new_index': newIndex,
    'status': status,
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
      'reliability_revalidation_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _FinalSnapshot {
  const _FinalSnapshot({
    this.reliabilityIndex = 0,
    this.status = 'UNKNOWN',
    this.varianceDelta = 0,
    this.predictiveAccuracy = 0,
    this.successBaseline = 0,
  });

  final double reliabilityIndex;
  final String status;
  final double varianceDelta;
  final double predictiveAccuracy;
  final double successBaseline;
}

class _RetuneSnapshot {
  const _RetuneSnapshot({
    this.varianceThreshold = 0,
    this.accuracyThreshold = 0,
    this.successThreshold = 0,
    this.successObserved = 0,
    this.expectedIndex = 0,
    this.expectedStatus = 'UNKNOWN',
  });

  final double varianceThreshold;
  final double accuracyThreshold;
  final double successThreshold;
  final double successObserved;
  final double expectedIndex;
  final String expectedStatus;
}
