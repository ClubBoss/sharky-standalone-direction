import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _intelligencePath =
    '$_reportsDir/marketing_intelligence_summary.txt';
const String _predictivePath = '$_reportsDir/predictive_marketing_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryOutPath = '$_reportsDir/marketing_forecast_summary.txt';

const double _maxTrendDrop = 15.0;
const double _maxVariance = 10.0;

Future<void> main(List<String> args) async {
  final dashboard = MarketingForecastDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingForecastDashboard {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final reality = await _loadReality();
    final forecast = await _loadForecast();
    final telemetryTrends = await _loadTelemetryTrends();

    final gaps = _MetricGaps(reality: reality, forecast: forecast);
    final summary = _DashboardSummary(
      conversionTrend: _trendLabel(reality.conversion, forecast.conversion),
      retentionTrend: _trendLabel(reality.retention, forecast.retention),
      engagementTrend: _trendLabel(reality.engagement, forecast.engagement),
      conversionGap: gaps.conversionDelta,
      retentionGap: gaps.retentionDelta,
      engagementGap: gaps.engagementDelta,
      telemetryConversionSeries: telemetryTrends.conversion,
      telemetryRetentionSeries: telemetryTrends.retention,
      telemetryEngagementSeries: telemetryTrends.engagement,
    );

    await _withReportsWritable(() async {
      await _writeSummary(summary, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(summary, stopwatch.elapsedMilliseconds);
    });

    final dangerousTrend = summary.gapsExceed(_maxTrendDrop);
    final varianceExceeded = summary.varianceExceeds(_maxVariance);
    return !dangerousTrend && !varianceExceeded;
  }

  Future<_RealitySnapshot> _loadReality() async {
    final file = File(_intelligencePath);
    if (!await file.exists()) {
      throw StateError(
        'Marketing intelligence summary missing: $_intelligencePath. '
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
    return _RealitySnapshot(
      conversion: conversion,
      retention: retention,
      engagement: engagement,
    );
  }

  Future<_ForecastSnapshot> _loadForecast() async {
    final file = File(_predictivePath);
    if (!await file.exists()) {
      throw StateError(
        'Predictive marketing summary missing: $_predictivePath. '
        'Run tools/predictive_marketing_model.dart first.',
      );
    }
    double conversion = 0;
    double retention = 0;
    double engagement = 0;
    double conversionVar = 0;
    double retentionVar = 0;
    double engagementVar = 0;

    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Conversion Forecast')) {
        final parts = _parseForecastLine(trimmed);
        conversion = parts.value;
        conversionVar = parts.variance;
      } else if (trimmed.startsWith('Retention Forecast')) {
        final parts = _parseForecastLine(trimmed);
        retention = parts.value;
        retentionVar = parts.variance;
      } else if (trimmed.startsWith('Engagement Forecast')) {
        final parts = _parseForecastLine(trimmed);
        engagement = parts.value;
        engagementVar = parts.variance;
      }
    }
    return _ForecastSnapshot(
      conversion: conversion,
      retention: retention,
      engagement: engagement,
      conversionVariance: conversionVar,
      retentionVariance: retentionVar,
      engagementVariance: engagementVar,
    );
  }

  Future<_TelemetryTrends> _loadTelemetryTrends() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      return const _TelemetryTrends(
        conversion: [],
        retention: [],
        engagement: [],
      );
    }
    final conversion = <double>[];
    final retention = <double>[];
    final engagement = <double>[];

    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line);
        if (decoded is! Map<String, Object?>) continue;
        if (decoded['event'] == 'marketing_intelligence_completed') {
          final conv =
              (decoded['conversion_avg'] as num?)?.toDouble() ?? double.nan;
          final ret =
              (decoded['retention_health_index'] as num?)?.toDouble() ??
              double.nan;
          final pearson = ((decoded['pearson_r'] as num?)?.toDouble() ?? 0)
              .clamp(0, 1);
          final eng = pearson * 100;
          if (conv.isFinite && conv > 0) conversion.add(conv);
          if (ret.isFinite && ret > 0) retention.add(ret);
          if (eng > 0) engagement.add(eng.toDouble());
        }
      } catch (_) {
        // ignore malformed lines
      }
    }

    return _TelemetryTrends(
      conversion: conversion,
      retention: retention,
      engagement: engagement,
    );
  }

  _TrendLabel _trendLabel(double reality, double forecast) {
    final delta = forecast - reality;
    if (delta > _maxTrendDrop) return _TrendLabel('↑', delta);
    if (delta < -_maxTrendDrop) return _TrendLabel('↓', delta);
    return _TrendLabel('→', delta);
  }
}

class _MetricGaps {
  _MetricGaps({required this.reality, required this.forecast});

  final _RealitySnapshot reality;
  final _ForecastSnapshot forecast;

  double get conversionDelta => forecast.conversion - reality.conversion;
  double get retentionDelta => forecast.retention - reality.retention;
  double get engagementDelta => forecast.engagement - reality.engagement;
}

class _DashboardSummary {
  _DashboardSummary({
    required this.conversionTrend,
    required this.retentionTrend,
    required this.engagementTrend,
    required this.conversionGap,
    required this.retentionGap,
    required this.engagementGap,
    required this.telemetryConversionSeries,
    required this.telemetryRetentionSeries,
    required this.telemetryEngagementSeries,
  });

  final _TrendLabel conversionTrend;
  final _TrendLabel retentionTrend;
  final _TrendLabel engagementTrend;
  final double conversionGap;
  final double retentionGap;
  final double engagementGap;
  final List<double> telemetryConversionSeries;
  final List<double> telemetryRetentionSeries;
  final List<double> telemetryEngagementSeries;

  bool gapsExceed(double threshold) {
    return conversionGap < -threshold || retentionGap < -threshold;
  }

  bool varianceExceeds(double varianceThreshold) {
    final varConversion = _variance(telemetryConversionSeries);
    final varRetention = _variance(telemetryRetentionSeries);
    return varConversion > varianceThreshold ||
        varRetention > varianceThreshold;
  }
}

class _TrendLabel {
  _TrendLabel(this.symbol, this.delta);
  final String symbol;
  final double delta;
}

class _RealitySnapshot {
  _RealitySnapshot({
    required this.conversion,
    required this.retention,
    required this.engagement,
  });

  final double conversion;
  final double retention;
  final double engagement;
}

class _ForecastSnapshot {
  _ForecastSnapshot({
    required this.conversion,
    required this.retention,
    required this.engagement,
    required this.conversionVariance,
    required this.retentionVariance,
    required this.engagementVariance,
  });

  final double conversion;
  final double retention;
  final double engagement;
  final double conversionVariance;
  final double retentionVariance;
  final double engagementVariance;
}

class _TelemetryTrends {
  const _TelemetryTrends({
    required this.conversion,
    required this.retention,
    required this.engagement,
  });

  final List<double> conversion;
  final List<double> retention;
  final List<double> engagement;
}

class _ForecastLine {
  _ForecastLine({required this.value, required this.variance});
  final double value;
  final double variance;
}

_ForecastLine _parseForecastLine(String line) {
  final value =
      double.tryParse(line.split('→').last.split('%').first.trim()) ?? 0;
  final ciSection = line.split('CI=').last;
  final range = ciSection.substring(1, ciSection.length - 1);
  final parts = range.split(',');
  final lower = double.tryParse(parts[0].trim()) ?? 0;
  final upper = double.tryParse(parts[1].trim()) ?? 0;
  final variance = (upper - lower) / 2;
  return _ForecastLine(value: value, variance: variance.abs());
}

double _variance(List<double> series) {
  if (series.length < 2) return 0;
  final mean = series.reduce((a, b) => a + b) / series.length;
  final sum = series
      .map((value) => (value - mean) * (value - mean))
      .reduce((a, b) => a + b);
  return sum / series.length;
}

Future<void> _writeSummary(_DashboardSummary summary, int durationMs) async {
  final buffer = StringBuffer()
    ..writeln('MARKETING FORECAST SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln()
    ..writeln(
      'Conversion: ${summary.conversionTrend.symbol} '
      'Δ${summary.conversionGap.toStringAsFixed(2)}%',
    )
    ..writeln(
      'Retention: ${summary.retentionTrend.symbol} '
      'Δ${summary.retentionGap.toStringAsFixed(2)}%',
    )
    ..writeln(
      'Engagement: ${summary.engagementTrend.symbol} '
      'Δ${summary.engagementGap.toStringAsFixed(2)}%',
    )
    ..writeln()
    ..writeln('Telemetry trend samples:')
    ..writeln('  Conversion: ${summary.telemetryConversionSeries}')
    ..writeln('  Retention : ${summary.telemetryRetentionSeries}')
    ..writeln('  Engagement: ${summary.telemetryEngagementSeries}');

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry(_DashboardSummary summary, int durationMs) async {
  final payload = <String, Object?>{
    'event': 'marketing_forecast_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'conversion_gap': summary.conversionGap,
    'retention_gap': summary.retentionGap,
    'engagement_gap': summary.engagementGap,
    'conversion_trend': summary.conversionTrend.symbol,
    'retention_trend': summary.retentionTrend.symbol,
    'engagement_trend': summary.engagementTrend.symbol,
    'duration_ms': durationMs,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
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
