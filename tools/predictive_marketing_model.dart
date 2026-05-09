import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _intelligencePath =
    '$_reportsDir/marketing_intelligence_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryOutPath = '$_reportsDir/predictive_marketing_summary.txt';
const String _telemetryOutPath = '$_reportsDir/telemetry.jsonl';

const double _minForecastConversion = 40;
const double _minForecastRetention = 60;
const int _forecastPeriods = 5;
const double _ewmaAlpha = 0.3;
const double _maxNegativeDropPercent = 15.0;

Future<void> main(List<String> args) async {
  final model = PredictiveMarketingModel();
  final ok = await model.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PredictiveMarketingModel {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final baseline = await _loadBaseline();
    final history = await _loadTelemetryHistory();
    final forecasts = _ForecastEngine(history, baseline).forecast();

    await _withReportsWritable(() async {
      await _writeSummary(forecasts, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(forecasts, stopwatch.elapsedMilliseconds);
    });

    return forecasts.conversion.forecast >= _minForecastConversion &&
        forecasts.retention.forecast >= _minForecastRetention;
  }

  Future<_BaselineMetrics> _loadBaseline() async {
    final file = File(_intelligencePath);
    if (!await file.exists()) {
      throw StateError(
        'Marketing intelligence summary missing at $_intelligencePath. '
        'Run tools/marketing_intelligence_dashboard.dart first.',
      );
    }
    double conversion = 0;
    double retention = 0;
    double engagement = 0;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Funnel conversion avg:')) {
        conversion =
            double.tryParse(
              trimmed.split(':').last.trim().replaceAll('%', ''),
            ) ??
            0;
      } else if (trimmed.startsWith('Retention Health Index:')) {
        retention =
            double.tryParse(
              trimmed.split(':').last.trim().replaceAll('%', ''),
            ) ??
            0;
      } else if (trimmed.startsWith('Engagement Pearson r:')) {
        final value = double.tryParse(trimmed.split(':').last.trim()) ?? 0;
        engagement = value.clamp(0, 1) * 100;
      }
    }
    return _BaselineMetrics(
      conversion: conversion,
      retention: retention,
      engagement: engagement,
    );
  }

  Future<_HistoricalSeries> _loadTelemetryHistory() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      throw StateError('Telemetry stream missing at $_telemetryPath');
    }
    final conversionSeries = <double>[];
    final retentionSeries = <double>[];
    final engagementSeries = <double>[];

    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line);
        if (decoded is! Map<String, Object?>) continue;
        final event = decoded['event']?.toString() ?? '';
        switch (event) {
          case 'marketing_intelligence_completed':
            conversionSeries.add(
              (decoded['conversion_avg'] as num?)?.toDouble() ?? 0,
            );
            retentionSeries.add(
              (decoded['retention_health_index'] as num?)?.toDouble() ?? 0,
            );
            final engagement = ((decoded['pearson_r'] as num?)?.toDouble() ?? 0)
                .clamp(0, 1);
            engagementSeries.add(engagement * 100);
            break;
          case 'marketing_funnel_analytics_completed':
            conversionSeries.add(
              (decoded['total_retention'] as num?)?.toDouble() ?? 0,
            );
            break;
          case 'retention_heatmap_completed':
            retentionSeries.add(
              (decoded['retention_health_index'] as num?)?.toDouble() ?? 0,
            );
            break;
          case 'engagement_correlation_completed':
            final pearson = ((decoded['pearson_r'] as num?)?.toDouble() ?? 0)
                .clamp(0, 1);
            engagementSeries.add(pearson * 100);
            break;
        }
      } catch (_) {
        // ignore malformed entries
      }
    }

    return _HistoricalSeries(
      conversion: conversionSeries,
      retention: retentionSeries,
      engagement: engagementSeries,
    );
  }
}

class _ForecastEngine {
  _ForecastEngine(this.series, this.baseline);

  final _HistoricalSeries series;
  final _BaselineMetrics baseline;

  _ForecastBundle forecast() {
    final conversion = _forecastSeries(series.conversion, baseline.conversion);
    final retention = _forecastSeries(series.retention, baseline.retention);
    final engagement = _forecastSeries(series.engagement, baseline.engagement);
    return _ForecastBundle(
      conversion: conversion,
      retention: retention,
      engagement: engagement,
    );
  }

  _ForecastResult _forecastSeries(List<double> data, double fallback) {
    if (data.isEmpty) data = [fallback];
    final ewma = _ewma(data, _ewmaAlpha);
    final trend = _trend(data);
    final forecast = ewma + trend * _forecastPeriods;
    final variance = _variance(data, ewma);
    final stdDev = sqrt(variance);
    final ci = 1.96 * stdDev;
    final minForecast = fallback > 0
        ? fallback * (1 - _maxNegativeDropPercent / 100)
        : 0;
    final adjustedForecast = max(minForecast, forecast).toDouble();
    final adjustedLower = max(0, adjustedForecast - ci).toDouble();
    final adjustedUpper = (adjustedForecast + ci).toDouble();
    return _ForecastResult(
      ewma: ewma,
      trend: trend,
      forecast: adjustedForecast,
      lower: adjustedLower,
      upper: adjustedUpper,
    );
  }

  double _ewma(List<double> data, double alpha) {
    var value = data.first;
    for (var i = 1; i < data.length; i++) {
      value = alpha * data[i] + (1 - alpha) * value;
    }
    return value;
  }

  double _trend(List<double> data) {
    if (data.length < 2) return 0;
    final xs = List<double>.generate(data.length, (i) => i.toDouble());
    final meanX = xs.reduce((a, b) => a + b) / xs.length;
    final meanY = data.reduce((a, b) => a + b) / data.length;
    double numerator = 0;
    double denominator = 0;
    for (var i = 0; i < data.length; i++) {
      final dx = xs[i] - meanX;
      numerator += dx * (data[i] - meanY);
      denominator += dx * dx;
    }
    return denominator == 0 ? 0 : numerator / denominator;
  }

  double _variance(List<double> data, double mean) {
    if (data.isEmpty) return 0;
    final sumSq = data
        .map((value) => pow(value - mean, 2))
        .reduce((a, b) => a + b);
    return sumSq / data.length;
  }
}

class _ForecastBundle {
  _ForecastBundle({
    required this.conversion,
    required this.retention,
    required this.engagement,
  });

  final _ForecastResult conversion;
  final _ForecastResult retention;
  final _ForecastResult engagement;
}

class _ForecastResult {
  _ForecastResult({
    required this.ewma,
    required this.trend,
    required this.forecast,
    required this.lower,
    required this.upper,
  });

  final double ewma;
  final double trend;
  final double forecast;
  final double lower;
  final double upper;
}

class _BaselineMetrics {
  _BaselineMetrics({
    required this.conversion,
    required this.retention,
    required this.engagement,
  });

  final double conversion;
  final double retention;
  final double engagement;
}

class _HistoricalSeries {
  _HistoricalSeries({
    required this.conversion,
    required this.retention,
    required this.engagement,
  });

  List<double> conversion;
  List<double> retention;
  List<double> engagement;
}

Future<void> _writeSummary(_ForecastBundle forecasts, int durationMs) async {
  final buffer = StringBuffer()
    ..writeln('PREDICTIVE MARKETING SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln()
    ..writeln(_formatForecast('Conversion', forecasts.conversion))
    ..writeln(_formatForecast('Retention', forecasts.retention))
    ..writeln(_formatForecast('Engagement', forecasts.engagement));

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry(_ForecastBundle forecasts, int durationMs) async {
  final payload = <String, Object?>{
    'event': 'predictive_marketing_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'conversion_forecast': forecasts.conversion.forecast,
    'retention_forecast': forecasts.retention.forecast,
    'engagement_forecast': forecasts.engagement.forecast,
    'duration_ms': durationMs,
  };
  final sink = File(_telemetryOutPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

String _formatForecast(String label, _ForecastResult result) {
  return '$label Forecast → ${result.forecast.toStringAsFixed(2)}% '
      '(EWMA=${result.ewma.toStringAsFixed(2)} trend=${result.trend.toStringAsFixed(2)} '
      'CI=[${result.lower.toStringAsFixed(2)}, ${result.upper.toStringAsFixed(2)}])';
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
