import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _monetizationSummaryPath =
    'release/_reports/monetization_conversion_summary.txt';
const String _outputPath = 'release/_reports/revenue_forecast_summary.txt';
const int _forecastPeriods = 5;
const double _alpha = 0.4;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final history = await _loadRevenueSeries();
  final monetization = await _MonetizationSummary.load(
    _monetizationSummaryPath,
  );
  if (history.isEmpty && monetization.revenueProxy == null) {
    throw StateError(
      'No revenue data found in telemetry or monetization summary.',
    );
  }
  if (monetization.revenueProxy != null) {
    history.add(monetization.revenueProxy!);
  }

  final ewma = _computeEwma(history, alpha: _alpha);
  final slope = _bayesianTrend(history);
  final forecast = List<double>.generate(_forecastPeriods, (index) {
    final value = max(0, ewma + slope * (index + 1));
    return double.parse(value.toStringAsFixed(2));
  });
  final forecastAvg = forecast.reduce((a, b) => a + b) / forecast.length;
  final verdict = forecastAvg >= (monetization.revenueProxy ?? ewma)
      ? 'PASS'
      : 'WARN';

  await _withReportsWritable(() async {
    await _writeSummary(
      history: history,
      monetization: monetization,
      ewma: ewma,
      slope: slope,
      forecast: forecast,
      forecastAvg: forecastAvg,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(
      monetization: monetization,
      ewma: ewma,
      slope: slope,
      forecast: forecast,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'revenue_forecast_model: samples=${history.length} '
    'forecast_avg=${forecastAvg.toStringAsFixed(2)} verdict=$verdict',
  );
}

Future<List<double>> _loadRevenueSeries() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return <double>[];
  final series = <double>[];
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is! Map<String, dynamic>) continue;
    if (payload['event'] == 'monetization_conversion_updated') {
      final value = _toDouble(payload['revenue_proxy']);
      if (value != null) {
        series.add(value);
      }
    }
  }
  return series;
}

double _computeEwma(List<double> data, {required double alpha}) {
  if (data.isEmpty) return 0;
  var value = data.first;
  for (var i = 1; i < data.length; i++) {
    value = alpha * data[i] + (1 - alpha) * value;
  }
  return value;
}

double _bayesianTrend(List<double> data) {
  if (data.length < 2) return 0;
  final mean = data.reduce((a, b) => a + b) / data.length;
  var numerator = 0.0;
  var denominator = 0.0;
  for (var i = 0; i < data.length; i++) {
    final x = i.toDouble() - ((data.length - 1) / 2);
    numerator += x * (data[i] - mean);
    denominator += x * x;
  }
  if (denominator == 0) return 0;
  return numerator / denominator / max(1, data.length / 2);
}

Future<void> _writeSummary({
  required List<double> history,
  required _MonetizationSummary monetization,
  required double ewma,
  required double slope,
  required List<double> forecast,
  required double forecastAvg,
  required String verdict,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('REVENUE FORECAST SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Samples ingested: ${history.length}')
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Current metrics:')
    ..writeln(
      '- Conversion rate: ${monetization.conversionRate?.toStringAsFixed(2) ?? 'n/a'}%',
    )
    ..writeln(
      '- Revenue proxy : ${monetization.revenueProxy?.toStringAsFixed(2) ?? 'n/a'}',
    )
    ..writeln()
    ..writeln('Model parameters:')
    ..writeln('- EWMA baseline : ${ewma.toStringAsFixed(2)}')
    ..writeln('- Trend (slope) : ${slope.toStringAsFixed(4)}')
    ..writeln('- Forecast horizon: $_forecastPeriods periods')
    ..writeln('- Forecast avg   : ${forecastAvg.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Forecast:')
    ..writeln(
      forecast
          .asMap()
          .entries
          .map(
            (entry) =>
                '- Period ${entry.key + 1}: ${entry.value.toStringAsFixed(2)}',
          )
          .join('\n'),
    )
    ..writeln();

  await File(_outputPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry({
  required _MonetizationSummary monetization,
  required double ewma,
  required double slope,
  required List<double> forecast,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'revenue_forecast_updated',
    'timestamp': DateTime.now().toIso8601String(),
    'conversion_rate': monetization.conversionRate,
    'revenue_proxy': monetization.revenueProxy,
    'ewma': ewma,
    'trend_slope': slope,
    'forecast': forecast,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _MonetizationSummary {
  const _MonetizationSummary({
    required this.revenueProxy,
    required this.conversionRate,
  });

  static Future<_MonetizationSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const _MonetizationSummary(
        revenueProxy: null,
        conversionRate: null,
      );
    }
    final lines = await file.readAsLines();
    double? revenue;
    double? conversion;
    final revenueRegex = RegExp(r'Revenue proxy.*:\s*([0-9.]+)');
    final conversionRegex = RegExp(r'Free→Premium rate\s*:\s*([0-9.]+)%');
    for (final line in lines) {
      final revenueMatch = revenueRegex.firstMatch(line);
      if (revenueMatch != null) {
        revenue = double.tryParse(revenueMatch.group(1)!);
      }
      final conversionMatch = conversionRegex.firstMatch(line);
      if (conversionMatch != null) {
        conversion = double.tryParse(conversionMatch.group(1)!);
      }
    }
    return _MonetizationSummary(
      revenueProxy: revenue,
      conversionRate: conversion,
    );
  }

  final double? revenueProxy;
  final double? conversionRate;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
