import 'dart:convert';
import 'dart:io';

const String _forecastPath =
    'release/_reports/predictive_retention_forecast.txt';
const String _adaptationPath =
    'release/_reports/feedback_adaptation_v2_summary.txt';
const String _dashboardPath = 'release/_reports/ux_dashboard_summary.txt';

const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/health_insight_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final forecast = await _readForecast();
  final adaptation = await _readAdaptation();
  final dashboard = await _readDashboard();

  final stabilityScore = (dashboard.stability ?? 1.0).clamp(0.0, 1.0);
  final trendScore = _trendToScore(forecast.trend ?? 'flat');
  final adaptationScore = _adaptationToScore(adaptation.avgWeight);
  final healthIndex =
      0.4 * stabilityScore + 0.3 * trendScore + 0.3 * adaptationScore;

  await _withReportsWritable(() async {
    await _writeSummary(
      forecast: forecast,
      adaptation: adaptation,
      dashboard: dashboard,
      stabilityScore: stabilityScore,
      trendScore: trendScore,
      adaptationScore: adaptationScore,
      healthIndex: healthIndex,
    );
    await _appendTelemetry(
      index: healthIndex,
      stability: stabilityScore,
      trend: trendScore,
      adaptation: adaptationScore,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'health_insight_reporter_v2: index=${healthIndex.toStringAsFixed(2)} '
    '(stability=${stabilityScore.toStringAsFixed(2)}, '
    'trend=${trendScore.toStringAsFixed(2)}, '
    'adapt=${adaptationScore.toStringAsFixed(2)})',
  );
}

Future<_ForecastSnapshot> _readForecast() async {
  final file = File(_forecastPath);
  if (!await file.exists()) {
    return const _ForecastSnapshot.empty();
  }
  double? retention7;
  double? retention30;
  String? trend;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    final match = RegExp(r'^\|\s*(\d+)d\s*\|\s*([0-9.]+)%').firstMatch(trimmed);
    if (match != null) {
      final days = int.parse(match.group(1)!);
      final pct = double.parse(match.group(2)!) / 100.0;
      if (days == 7) retention7 = pct;
      if (days == 30) retention30 = pct;
      continue;
    }
    if (trimmed.startsWith('- Trend classification:')) {
      trend = trimmed.split(':').last.trim();
    }
  }
  return _ForecastSnapshot(
    retention7d: retention7,
    retention30d: retention30,
    trend: trend,
  );
}

Future<_AdaptationSnapshot> _readAdaptation() async {
  final file = File(_adaptationPath);
  if (!await file.exists()) {
    return const _AdaptationSnapshot.empty();
  }
  double? avgWeight;
  final recommendations = <String>[];
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Adaptive Weights')) {
      final match = RegExp(r'avg ([0-9.]+)').firstMatch(trimmed);
      if (match != null) avgWeight = double.tryParse(match.group(1)!);
    }
    if (trimmed.startsWith('- ')) {
      recommendations.add(trimmed.substring(2));
    }
  }
  return _AdaptationSnapshot(
    avgWeight: avgWeight,
    recommendations: recommendations,
  );
}

Future<_DashboardSnapshot> _readDashboard() async {
  final file = File(_dashboardPath);
  if (!await file.exists()) {
    return const _DashboardSnapshot.empty();
  }
  final metrics = <String, String>{};
  final tablePattern = RegExp(r'^\|\s*(.+?)\s*\|\s*(.+?)\s*\|');
  for (final line in await file.readAsLines()) {
    final match = tablePattern.firstMatch(line.trim());
    if (match != null) {
      metrics[match.group(1)!.trim()] = match.group(2)!.trim();
    }
  }
  double? _metric(String key) {
    final value = metrics[key];
    if (value == null) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.\-]'), ''));
  }

  return _DashboardSnapshot(
    stability: _metric('Stability'),
    warnings: _metric('Warnings'),
    avgFps: _metric('Avg FPS'),
  );
}

double _trendToScore(String trend) {
  switch (trend.toLowerCase()) {
    case 'upward':
      return 1.0;
    case 'flat':
      return 0.6;
    case 'downward':
      return 0.2;
    default:
      return 0.5;
  }
}

double _adaptationToScore(double? avgWeight) {
  if (avgWeight == null) return 0.5;
  if (avgWeight < 1.0) return 0.4;
  if (avgWeight < 1.2) return 0.6;
  if (avgWeight < 1.4) return 0.75;
  return 0.9;
}

Future<void> _writeSummary({
  required _ForecastSnapshot forecast,
  required _AdaptationSnapshot adaptation,
  required _DashboardSnapshot dashboard,
  required double stabilityScore,
  required double trendScore,
  required double adaptationScore,
  required double healthIndex,
}) async {
  final buffer = StringBuffer()
    ..writeln('HEALTH INSIGHT SUMMARY V2')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Sources:')
    ..writeln('- Forecast: $_forecastPath')
    ..writeln('- Adaptation: $_adaptationPath')
    ..writeln('- UX Dashboard: $_dashboardPath')
    ..writeln()
    ..writeln('Component Scores:')
    ..writeln('- Stability (40%): ${stabilityScore.toStringAsFixed(2)} ')
    ..writeln(
      '- Trend (30%): ${trendScore.toStringAsFixed(2)} (${forecast.trend ?? 'n/a'})',
    )
    ..writeln(
      '- Adaptation (30%): ${adaptationScore.toStringAsFixed(2)} (avg weight ${adaptation.avgWeight?.toStringAsFixed(2) ?? 'n/a'})',
    )
    ..writeln()
    ..writeln('Weighted Health Index: ${healthIndex.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Retention Snapshot:')
    ..writeln('- 7d: ${(forecast.retention7d ?? 0).toPercent()}')
    ..writeln('- 30d: ${(forecast.retention30d ?? 0).toPercent()}')
    ..writeln()
    ..writeln('UX Dashboard Signals:')
    ..writeln('- Avg FPS: ${dashboard.avgFps ?? double.nan}')
    ..writeln('- Warnings: ${dashboard.warnings ?? double.nan}')
    ..writeln('- Stability: ${dashboard.stability ?? double.nan}')
    ..writeln()
    ..writeln('Key Recommendations:');
  for (final rec in adaptation.recommendations.take(5)) {
    buffer.writeln('- $rec');
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double index,
  required double stability,
  required double trend,
  required double adaptation,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'health_insight_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'index': index,
    'stability': stability,
    'trend': trend,
    'adaptation': adaptation,
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
      'health_insight_reporter_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ForecastSnapshot {
  const _ForecastSnapshot({this.retention7d, this.retention30d, this.trend});
  const _ForecastSnapshot.empty()
    : this(retention7d: null, retention30d: null, trend: null);

  final double? retention7d;
  final double? retention30d;
  final String? trend;
}

class _AdaptationSnapshot {
  const _AdaptationSnapshot({this.avgWeight, required this.recommendations});
  const _AdaptationSnapshot.empty()
    : this(avgWeight: null, recommendations: const []);

  final double? avgWeight;
  final List<String> recommendations;
}

class _DashboardSnapshot {
  const _DashboardSnapshot({this.stability, this.warnings, this.avgFps});
  const _DashboardSnapshot.empty()
    : this(stability: null, warnings: null, avgFps: null);

  final double? stability;
  final double? warnings;
  final double? avgFps;
}

extension on double {
  String toPercent() => '${(this * 100).toStringAsFixed(1)}%';
}
