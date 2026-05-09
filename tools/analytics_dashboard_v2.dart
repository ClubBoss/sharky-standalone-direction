import 'dart:convert';
import 'dart:io';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath =
    'release/_reports/analytics_dashboard_v2_summary.txt';
const String _reportsDir = 'release/_reports';
const String _uiMetricsPath = 'ui_metrics.json';
const String _forecastPath = 'adaptive_forecast.json';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final telemetryEvents = await _readTelemetry();
  final telemetryMetrics = _computeTelemetryMetrics(telemetryEvents);
  final funnel = _buildConversionFunnel(telemetryEvents);
  final uiTrend = await _readUxTrend();
  final forecast = await _readForecast();
  final riskBands = _deriveRiskBands(
    telemetryMetrics.retentionPct,
    funnel.conversionPct,
    forecast.riskLevel,
  );

  await _withReportsWritable(() async {
    await _writeSummary(telemetryMetrics, funnel, uiTrend, forecast, riskBands);
    await _appendTelemetryEvent(
      conversionPct: funnel.conversionPct,
      forecastTrend: forecast.trendScore,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'analytics_dashboard_v2: conversion=${funnel.conversionPct.toStringAsFixed(1)}% '
    'forecastTrend=${forecast.trendScore.toStringAsFixed(2)}',
  );
}

Future<List<Map<String, dynamic>>> _readTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final events = <Map<String, dynamic>>[];
  for (final raw in await file.readAsLines()) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map<String, dynamic>) {
        events.add(decoded);
      }
    } catch (_) {
      continue;
    }
  }
  return events;
}

_TelemetryMetrics _computeTelemetryMetrics(List<Map<String, dynamic>> events) {
  if (events.isEmpty) {
    return const _TelemetryMetrics();
  }

  final now = DateTime.now().toUtc();
  final dailyCounts = <DateTime, int>{};
  for (final event in events) {
    final ts = DateTime.tryParse(event['timestamp']?.toString() ?? '');
    if (ts == null) continue;
    final dateKey = DateTime.utc(ts.year, ts.month, ts.day);
    dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
  }

  double averageForRange(int days) {
    var total = 0;
    var samples = 0;
    for (var i = 0; i < days; i++) {
      final day = DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      if (dailyCounts.containsKey(day)) {
        total += dailyCounts[day]!;
        samples += 1;
      }
    }
    if (samples == 0) return 0;
    return total / samples;
  }

  int uniqueDaysInRange(int days) {
    var count = 0;
    for (var i = 0; i < days; i++) {
      final day = DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      if (dailyCounts.containsKey(day)) {
        count += 1;
      }
    }
    return count;
  }

  final dau = averageForRange(7);
  final wau = averageForRange(30);
  final unique7 = uniqueDaysInRange(7);
  final unique30 = uniqueDaysInRange(30);
  final retention = unique30 == 0 ? 0 : (unique7 / unique30) * 100.0;

  return _TelemetryMetrics(
    dau: dau,
    wau: wau,
    retentionPct: double.parse(retention.toStringAsFixed(2)),
  );
}

_ConversionFunnel _buildConversionFunnel(List<Map<String, dynamic>> events) {
  if (events.isEmpty) return const _ConversionFunnel();

  final int stageAcquire = events.length;
  int stageActivate = 0;
  int stageConvert = 0;

  for (final event in events) {
    final name = event['event']?.toString() ?? '';
    final coverage = (event['coverage_pct'] as num?)?.toDouble();

    final looksCompleted =
        name.contains('_completed') ||
        name.contains('_summary') ||
        name.contains('_exported');
    if (looksCompleted) {
      stageActivate += 1;
    }
    final qualifiesConversion =
        (coverage != null && coverage >= 90) ||
        (event.containsKey('pass') && event['pass'] == true) ||
        name.contains('snapshot_exported');
    if (qualifiesConversion) {
      stageConvert += 1;
    }
  }

  final conversion = stageAcquire == 0
      ? 0
      : (stageConvert / stageAcquire) * 100.0;

  return _ConversionFunnel(
    acquire: stageAcquire,
    activate: stageActivate,
    convert: stageConvert,
    conversionPct: double.parse(conversion.toStringAsFixed(2)),
  );
}

Future<_UxTrend> _readUxTrend() async {
  final file = File(_uiMetricsPath);
  if (!await file.exists()) return const _UxTrend();
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, dynamic>) {
      final adaptive =
          decoded['adaptive_drift_latest'] as Map<String, dynamic>? ?? {};
      final avgPercent = (adaptive['avgPercent'] as num?)?.toDouble() ?? 0.0;
      final pass = adaptive['pass'] == true;
      final driftHistory =
          (decoded['adaptive_drift_history'] as List?)
              ?.map((v) => (v as num).toDouble())
              .toList() ??
          const <double>[];
      final latestDrift = driftHistory.isEmpty ? 0.0 : driftHistory.last;
      final index = avgPercent - latestDrift;
      return _UxTrend(
        driftPercent: avgPercent,
        stabilityDelta: double.parse(index.toStringAsFixed(2)),
        pass: pass,
      );
    }
  } catch (_) {}
  return const _UxTrend();
}

Future<_Forecast> _readForecast() async {
  final file = File(_forecastPath);
  if (!await file.exists()) return const _Forecast();
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, dynamic>) {
      List<double> _asDoubleList(String key) {
        final values = decoded[key];
        if (values is List) {
          return values.map((e) => (e as num).toDouble()).toList();
        }
        return const <double>[];
      }

      final drift = _asDoubleList('forecast_drift');
      final xp = _asDoubleList('forecast_xp');

      double _avg(List<double> list, int limit) {
        if (list.isEmpty) return 0;
        final slice = list.take(limit).toList();
        final sum = slice.fold<double>(0, (s, v) => s + v);
        return sum / slice.length;
      }

      final stability = (decoded['trend_stability'] as num?)?.toDouble() ?? 0.0;
      final trendDrift = (decoded['trend_drift'] as num?)?.toDouble() ?? 0.0;

      return _Forecast(
        avgDrift7: double.parse(_avg(drift, 7).toStringAsFixed(3)),
        avgXp30: double.parse(_avg(xp, 30).toStringAsFixed(3)),
        riskLevel: decoded['risk_level']?.toString() ?? 'Unknown',
        trendScore: double.parse((stability - trendDrift).toStringAsFixed(3)),
      );
    }
  } catch (_) {}
  return const _Forecast();
}

_RiskBands _deriveRiskBands(
  double retention,
  double conversion,
  String forecastRisk,
) {
  String _bandFrom(double value) {
    if (value >= 70) return 'Low';
    if (value >= 50) return 'Medium';
    return 'High';
  }

  final retentionBand = _bandFrom(retention);
  final conversionBand = _bandFrom(conversion);
  final forecastBand = forecastRisk.isEmpty ? 'Unknown' : forecastRisk;
  return _RiskBands(
    retention: retentionBand,
    conversion: conversionBand,
    forecast: forecastBand,
  );
}

Future<void> _writeSummary(
  _TelemetryMetrics telemetry,
  _ConversionFunnel funnel,
  _UxTrend uxTrend,
  _Forecast forecast,
  _RiskBands riskBands,
) async {
  final buffer = StringBuffer()
    ..writeln('ANALYTICS DASHBOARD V2')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Telemetry Metrics')
    ..writeln('- DAU (7d avg): ${telemetry.dau.toStringAsFixed(1)} events/day')
    ..writeln('- WAU (30d avg): ${telemetry.wau.toStringAsFixed(1)} events/day')
    ..writeln(
      '- Retention (7/30d): ${telemetry.retentionPct.toStringAsFixed(2)}%',
    )
    ..writeln()
    ..writeln('Conversion Funnel')
    ..writeln('- Acquire events: ${funnel.acquire}')
    ..writeln('- Activate events: ${funnel.activate}')
    ..writeln('- Convert events: ${funnel.convert}')
    ..writeln('- Conversion rate: ${funnel.conversionPct.toStringAsFixed(2)}%')
    ..writeln()
    ..writeln('UX Trend Index')
    ..writeln('- Drift percent: ${uxTrend.driftPercent.toStringAsFixed(2)}%')
    ..writeln('- Stability delta: ${uxTrend.stabilityDelta.toStringAsFixed(2)}')
    ..writeln('- Pass: ${uxTrend.pass}')
    ..writeln()
    ..writeln('Forecast Outlook')
    ..writeln('- Avg drift (7d): ${forecast.avgDrift7.toStringAsFixed(3)}')
    ..writeln('- Avg XP (30d): ${forecast.avgXp30.toStringAsFixed(3)}')
    ..writeln('- Risk level: ${forecast.riskLevel}')
    ..writeln('- Forecast trend: ${forecast.trendScore.toStringAsFixed(3)}')
    ..writeln()
    ..writeln('Risk Bands')
    ..writeln('- Retention risk: ${riskBands.retention}')
    ..writeln('- Conversion risk: ${riskBands.conversion}')
    ..writeln('- Forecast risk: ${riskBands.forecast}')
    ..writeln();

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetryEvent({
  required double conversionPct,
  required double forecastTrend,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'analytics_dashboard_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'conversion_pct': double.parse(conversionPct.toStringAsFixed(2)),
    'forecast_trend': double.parse(forecastTrend.toStringAsFixed(3)),
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
      'analytics_dashboard_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _TelemetryMetrics {
  const _TelemetryMetrics({this.dau = 0, this.wau = 0, this.retentionPct = 0});

  final double dau;
  final double wau;
  final double retentionPct;
}

class _ConversionFunnel {
  const _ConversionFunnel({
    this.acquire = 0,
    this.activate = 0,
    this.convert = 0,
    this.conversionPct = 0,
  });

  final int acquire;
  final int activate;
  final int convert;
  final double conversionPct;
}

class _UxTrend {
  const _UxTrend({
    this.driftPercent = 0,
    this.stabilityDelta = 0,
    this.pass = false,
  });

  final double driftPercent;
  final double stabilityDelta;
  final bool pass;
}

class _Forecast {
  const _Forecast({
    this.avgDrift7 = 0,
    this.avgXp30 = 0,
    this.riskLevel = 'Unknown',
    this.trendScore = 0,
  });

  final double avgDrift7;
  final double avgXp30;
  final String riskLevel;
  final double trendScore;
}

class _RiskBands {
  const _RiskBands({
    required this.retention,
    required this.conversion,
    required this.forecast,
  });

  final String retention;
  final String conversion;
  final String forecast;
}
