import 'dart:convert';
import 'dart:io';

const String _revalidationPath =
    'release/_reports/reliability_revalidation_summary.txt';
const String _recalibrationPath =
    'release/_reports/adaptive_recalibration_summary.txt';
const String _outputPath = 'release/_reports/reliability_forecast_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

const _wmaWeights = [0.5, 0.3, 0.2]; // newest → oldest

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final revalidation = await _parseRevalidation();
  final recalibration = await _parseRecalibration();

  final indices = _Indices(
    learning: revalidation.learningIndex,
    revalidation: revalidation.revalidatedIndex,
    recalibration: recalibration.predictedIndex,
  );

  final weightedAverage = _weightedMovingAverage(indices);
  final forecast = _forecastTrajectory(indices);

  await _withReportsWritable(() async {
    await _writeSummary(
      indices: indices,
      weightedAverage: weightedAverage,
      forecast: forecast,
    );
    await _appendTelemetry(
      forecast: forecast,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'reliability_forecast_loop: '
    'short=${forecast.short.toStringAsFixed(2)} '
    'medium=${forecast.medium.toStringAsFixed(2)} '
    'long=${forecast.long.toStringAsFixed(2)} '
    'trajectory=${forecast.trajectory}',
  );
}

Future<_RevalidationSnapshot> _parseRevalidation() async {
  final file = File(_revalidationPath);
  if (!await file.exists()) return const _RevalidationSnapshot();
  final lines = await file.readAsLines();

  double _valueFromLine(String startsWith) {
    final line = lines.firstWhere(
      (l) => l.trim().startsWith(startsWith),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final match = RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(line);
    return match == null ? 0 : double.tryParse(match.group(1) ?? '') ?? 0;
  }

  final learningIndex = _valueFromLine('Threshold retune expectation');
  final revalidatedIndex = _valueFromLine('Revalidated index');
  final previousIndex = _valueFromLine('Previous reliability index');

  return _RevalidationSnapshot(
    learningIndex: learningIndex,
    revalidatedIndex: revalidatedIndex,
    previousIndex: previousIndex,
  );
}

Future<_RecalibrationSnapshot> _parseRecalibration() async {
  final file = File(_recalibrationPath);
  if (!await file.exists()) return const _RecalibrationSnapshot();
  final lines = await file.readAsLines();
  final line = lines.firstWhere(
    (l) => l.contains('Predicted reliability index'),
    orElse: () => '',
  );
  if (line.isEmpty) return const _RecalibrationSnapshot();
  final match = RegExp(r'([0-9]+\.?[0-9]*)').firstMatch(line);
  final value = match == null ? 0 : double.tryParse(match.group(1) ?? '') ?? 0;
  return _RecalibrationSnapshot(predictedIndex: value.toDouble());
}

double _weightedMovingAverage(_Indices indices) {
  final values = [
    indices.recalibration,
    indices.revalidation,
    indices.learning,
  ];
  double total = 0;
  for (var i = 0; i < values.length; i++) {
    total += values[i] * _wmaWeights[i];
  }
  return double.parse(total.toStringAsFixed(2));
}

_Forecast _forecastTrajectory(_Indices indices) {
  final i0 = indices.learning;
  final i1 = indices.revalidation;
  final i2 = indices.recalibration;

  final slope1 = i1 - i0;
  final slope2 = i2 - i1;
  final avgSlope = (slope1 + slope2) / 2;

  double clamp(double value) => value.clamp(0, 1).toDouble();

  final short = clamp(i2 + slope2);
  final medium = clamp(short + avgSlope);
  final long = clamp(medium + avgSlope);

  final delta = long - i2;
  final trajectory = delta > 0.05
      ? 'Upward'
      : delta < -0.05
      ? 'Downward'
      : 'Flat';

  return _Forecast(
    short: double.parse(short.toStringAsFixed(2)),
    medium: double.parse(medium.toStringAsFixed(2)),
    long: double.parse(long.toStringAsFixed(2)),
    weightedAverage: _weightedMovingAverage(indices),
    trajectory: trajectory,
  );
}

Future<void> _writeSummary({
  required _Indices indices,
  required double weightedAverage,
  required _Forecast forecast,
}) async {
  final buffer = StringBuffer()
    ..writeln('RELIABILITY FORECAST SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln(
      'Historical indices (learning / revalidation / recalibration): '
      '${indices.learning.toStringAsFixed(2)} / '
      '${indices.revalidation.toStringAsFixed(2)} / '
      '${indices.recalibration.toStringAsFixed(2)}',
    )
    ..writeln(
      'Weighted moving average (w=${_wmaWeights.join('/')}) '
      '= ${weightedAverage.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln('Forecast')
    ..writeln('- Short horizon: ${forecast.short.toStringAsFixed(2)}')
    ..writeln('- Medium horizon: ${forecast.medium.toStringAsFixed(2)}')
    ..writeln('- Long horizon: ${forecast.long.toStringAsFixed(2)}')
    ..writeln('Trajectory: ${forecast.trajectory}');

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required _Forecast forecast,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'reliability_forecast_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'short': forecast.short,
    'medium': forecast.medium,
    'long': forecast.long,
    'trajectory': forecast.trajectory,
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
      'reliability_forecast_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _Indices {
  const _Indices({
    required this.learning,
    required this.revalidation,
    required this.recalibration,
  });

  final double learning;
  final double revalidation;
  final double recalibration;
}

class _RevalidationSnapshot {
  const _RevalidationSnapshot({
    this.learningIndex = 0,
    this.revalidatedIndex = 0,
    this.previousIndex = 0,
  });

  final double learningIndex;
  final double revalidatedIndex;
  final double previousIndex;
}

class _RecalibrationSnapshot {
  const _RecalibrationSnapshot({this.predictedIndex = 0});

  final double predictedIndex;
}

class _Forecast {
  const _Forecast({
    required this.short,
    required this.medium,
    required this.long,
    required this.weightedAverage,
    required this.trajectory,
  });

  final double short;
  final double medium;
  final double long;
  final double weightedAverage;
  final String trajectory;
}
