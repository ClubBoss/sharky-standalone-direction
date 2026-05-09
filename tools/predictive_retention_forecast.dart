import 'dart:convert';
import 'dart:io';

const List<String> _uxMetricPaths = <String>[
  'release/_exports/ux_metrics.json',
  'release/_reports/ux_metrics.json',
  'ux_metrics.json',
];

const String _onboardingSummaryPath =
    'release/_reports/onboarding_flow_summary.txt';

const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/predictive_retention_forecast.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final uxMetrics = await _readUxMetrics();
  final onboarding = await _readOnboardingSummary();
  final history = _buildHistory(uxMetrics, onboarding);

  final forecasts = <_ForecastRecord>[];
  const horizons = [7, 14, 30];
  for (final days in horizons) {
    final value = _forecastRetention(history, days);
    final variance = onboarding.baselineRetention == null
        ? null
        : value - onboarding.baselineRetention!;
    forecasts.add(
      _ForecastRecord(days: days, value: value, varianceFromBaseline: variance),
    );
  }

  final trendLabel = _trendLabel(history);

  await _withReportsWritable(() async {
    await _writeSummary(
      uxMetrics: uxMetrics,
      onboarding: onboarding,
      history: history,
      forecasts: forecasts,
      trendLabel: trendLabel,
    );
    await _appendTelemetry(
      retention7d: forecasts.first.value,
      retention30d: forecasts.last.value,
      trendLabel: trendLabel,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'predictive_retention_forecast: 7d='
    '${(forecasts.first.value * 100).toStringAsFixed(1)}% '
    '30d=${(forecasts.last.value * 100).toStringAsFixed(1)}% '
    '(trend: $trendLabel).',
  );
}

Future<_UxMetricsSnapshot> _readUxMetrics() async {
  for (final path in _uxMetricPaths) {
    final file = File(path);
    if (!await file.exists()) continue;
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        final timestampRaw = data['timestamp']?.toString();
        final timestamp = timestampRaw == null
            ? null
            : DateTime.tryParse(timestampRaw);
        return _UxMetricsSnapshot(path: path, timestamp: timestamp, data: data);
      }
    } catch (_) {
      continue;
    }
  }
  return const _UxMetricsSnapshot(path: null, timestamp: null, data: {});
}

Future<_OnboardingSummary> _readOnboardingSummary() async {
  final file = File(_onboardingSummaryPath);
  if (!await file.exists()) {
    return const _OnboardingSummary(path: null, baselineRetention: null);
  }
  double? baseline;
  try {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final normalized = line.trim();
      if (normalized.startsWith('- Next-day retention:')) {
        final match = RegExp(r'([0-9.]+)%').firstMatch(normalized);
        if (match != null) {
          baseline = double.parse(match.group(1)!) / 100.0;
          break;
        } else if (normalized.endsWith('n/a')) {
          baseline = null;
        }
      }
    }
  } catch (_) {
    baseline = null;
  }
  return _OnboardingSummary(
    path: _onboardingSummaryPath,
    baselineRetention: baseline,
  );
}

List<double> _buildHistory(
  _UxMetricsSnapshot metrics,
  _OnboardingSummary summary,
) {
  final history = <double>[];

  void _addFrom(dynamic value) {
    if (value is num) {
      history.add(value.toDouble().clamp(0.0, 1.0));
    } else if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        history.add(parsed.clamp(0.0, 1.0));
      }
    }
  }

  final candidates = <dynamic>[
    metrics.data['retention_history'],
    metrics.data['retentionHistory'],
    metrics.data['retention_samples'],
    metrics.data['retention_samples_pct'],
  ];
  for (final candidate in candidates) {
    if (candidate is List) {
      for (final item in candidate) {
        _addFrom(item is num ? item / (item > 1 ? 100.0 : 1.0) : item);
      }
    }
  }

  if (history.isEmpty && summary.baselineRetention != null) {
    history.add(summary.baselineRetention!);
  }
  if (history.isEmpty) {
    history.add(0.0); // fallback to zero to avoid empty series
  }
  return history;
}

double _forecastRetention(List<double> history, int days) {
  final wma = _weightedAverage(history, 5);
  final trendProjection = _trendProjection(history, days);
  final result = 0.6 * wma + 0.4 * trendProjection;
  return result.clamp(0.0, 1.0);
}

double _weightedAverage(List<double> history, int window) {
  final slice = history.length <= window
      ? history
      : history.sublist(history.length - window);
  double weightedSum = 0.0;
  double weights = 0.0;
  for (var i = 0; i < slice.length; i++) {
    final weight = (i + 1).toDouble();
    weightedSum += slice[i] * weight;
    weights += weight;
  }
  return weights == 0 ? slice.last : weightedSum / weights;
}

double _trendProjection(List<double> history, int days) {
  if (history.length < 2) {
    return history.last;
  }
  final x = List<double>.generate(history.length, (index) => index.toDouble());
  final y = history;
  final slope = _linearRegressionSlope(x, y);
  final projectedSteps = days / 7.0;
  return (history.last + slope * projectedSteps).clamp(0.0, 1.0);
}

double _linearRegressionSlope(List<double> x, List<double> y) {
  final n = x.length;
  final meanX = x.reduce((a, b) => a + b) / n;
  final meanY = y.reduce((a, b) => a + b) / n;
  double numerator = 0.0;
  double denominator = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = x[i] - meanX;
    final dy = y[i] - meanY;
    numerator += dx * dy;
    denominator += dx * dx;
  }
  if (denominator == 0) return 0.0;
  return numerator / denominator;
}

String _trendLabel(List<double> history) {
  final slope = _trendProjection(history, 7) - history.last;
  if (slope > 0.01) return 'upward';
  if (slope < -0.01) return 'downward';
  return 'flat';
}

Future<void> _writeSummary({
  required _UxMetricsSnapshot uxMetrics,
  required _OnboardingSummary onboarding,
  required List<double> history,
  required List<_ForecastRecord> forecasts,
  required String trendLabel,
}) async {
  final buffer = StringBuffer()
    ..writeln('PREDICTIVE RETENTION FORECAST')
    ..writeln('==============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('UX metrics: ${uxMetrics.path ?? 'unavailable'}')
    ..writeln('Onboarding summary: ${onboarding.path ?? 'unavailable'}')
    ..writeln();

  final baselineLabel = onboarding.baselineRetention == null
      ? 'n/a'
      : '${(onboarding.baselineRetention! * 100).toStringAsFixed(1)}%';
  buffer
    ..writeln('Baseline next-day retention: $baselineLabel')
    ..writeln('Observed history points: ${history.length}')
    ..writeln();

  buffer
    ..writeln('| Horizon | Forecast | vs Baseline | Notes |')
    ..writeln('|---------|----------|-------------|-------|');
  for (final record in forecasts) {
    final forecastLabel = '${(record.value * 100).toStringAsFixed(1)}%';
    final varianceLabel = record.varianceFromBaseline == null
        ? 'n/a'
        : _formatVariance(record.varianceFromBaseline!);
    final note = record.days == 7
        ? 'Short-term health'
        : (record.days == 14 ? 'Momentum check' : 'Long-term durability');
    buffer.writeln(
      '| ${record.days}d | $forecastLabel | $varianceLabel | $note |',
    );
  }
  buffer.writeln();

  buffer
    ..writeln('Trend Analysis')
    ..writeln('--------------')
    ..writeln('- Trend classification: $trendLabel')
    ..writeln('- Weighted history (latest 8): ${_formatHistory(history)}')
    ..writeln();

  buffer
    ..writeln('ASCII Forecast Graph (percentage)')
    ..writeln('---------------------------------');
  for (final record in forecasts) {
    final percent = (record.value * 100).clamp(0, 100);
    final bars = '#' * (percent ~/ 2);
    buffer.writeln('${record.days.toString().padLeft(2)}d | $bars');
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

String _formatVariance(double variance) {
  final pct = (variance * 100).toStringAsFixed(1);
  if (variance > 0) return '+$pct%';
  if (variance < 0) return '$pct%';
  return '0.0%';
}

String _formatHistory(List<double> history) {
  final slice = history.length <= 8
      ? history
      : history.sublist(history.length - 8);
  return slice.map((e) => '${(e * 100).toStringAsFixed(1)}%').join(', ');
}

Future<void> _appendTelemetry({
  required double retention7d,
  required double retention30d,
  required String trendLabel,
  required int durationMs,
}) async {
  final event = <String, Object>{
    'event': 'predictive_retention_forecast_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'retention_7d': retention7d,
    'retention_30d': retention30d,
    'trend': trendLabel,
    'duration_ms': durationMs,
  };
  await File(
    _telemetryPath,
  ).writeAsString('${jsonEncode(event)}\n', mode: FileMode.append, flush: true);
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
      'predictive_retention_forecast: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _UxMetricsSnapshot {
  const _UxMetricsSnapshot({
    required this.path,
    required this.timestamp,
    required this.data,
  });

  final String? path;
  final DateTime? timestamp;
  final Map<String, dynamic> data;
}

class _OnboardingSummary {
  const _OnboardingSummary({
    required this.path,
    required this.baselineRetention,
  });

  final String? path;
  final double? baselineRetention;
}

class _ForecastRecord {
  _ForecastRecord({
    required this.days,
    required this.value,
    required this.varianceFromBaseline,
  });

  final int days;
  final double value;
  final double? varianceFromBaseline;
}
