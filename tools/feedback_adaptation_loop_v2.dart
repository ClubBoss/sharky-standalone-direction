import 'dart:convert';
import 'dart:io';

const String _forecastPath =
    'release/_reports/predictive_retention_forecast.txt';
const String _dashboardPath = 'release/_reports/ux_dashboard_summary.txt';
const String _reportsDir = 'release/_reports';
const String _summaryPath =
    'release/_reports/feedback_adaptation_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final forecast = await _readForecast();
  final dashboard = await _readDashboard();
  final weights = _computeWeights(forecast, dashboard);
  final recommendations = _buildRecommendations(weights, forecast, dashboard);
  final weightAvg =
      weights.values.fold<double>(0.0, (sum, value) => sum + value) /
      weights.length;

  await _withReportsWritable(() async {
    await _writeSummary(
      forecast: forecast,
      dashboard: dashboard,
      weights: weights,
      recommendations: recommendations,
      weightAvg: weightAvg,
    );
    await _appendTelemetry(
      weightAvg: weightAvg,
      recommendations: recommendations,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'feedback_adaptation_loop_v2: avgWeight='
    '${weightAvg.toStringAsFixed(2)} '
    'trend=${forecast.trend ?? 'n/a'} '
    'recommendations=${recommendations.join('; ')}',
  );
}

Future<_ForecastSnapshot> _readForecast() async {
  final file = File(_forecastPath);
  if (!await file.exists()) {
    return const _ForecastSnapshot.empty();
  }
  double? retention7;
  double? retention14;
  double? retention30;
  String? trend;
  final lines = await file.readAsLines();
  final rowPattern = RegExp(r'^\|\s*(\d+)d\s*\|\s*([0-9.]+)%');
  for (final line in lines) {
    final match = rowPattern.firstMatch(line.trim());
    if (match != null) {
      final days = int.tryParse(match.group(1)!);
      final pct = double.parse(match.group(2)!) / 100.0;
      switch (days) {
        case 7:
          retention7 = pct;
        case 14:
          retention14 = pct;
        case 30:
          retention30 = pct;
      }
      continue;
    }
    if (line.contains('Trend classification')) {
      trend = line.split(':').last.trim();
    }
  }
  return _ForecastSnapshot(
    retention7d: retention7,
    retention14d: retention14,
    retention30d: retention30,
    trend: trend,
  );
}

Future<_DashboardSnapshot> _readDashboard() async {
  final file = File(_dashboardPath);
  if (!await file.exists()) {
    return const _DashboardSnapshot.empty();
  }
  final lines = await file.readAsLines();
  final tablePattern = RegExp(r'^\|\s*(.+?)\s*\|\s*(.+?)\s*\|');
  final metrics = <String, String>{};
  for (final line in lines) {
    final match = tablePattern.firstMatch(line.trim());
    if (match == null) continue;
    metrics[match.group(1)!.trim()] = match.group(2)!.trim();
  }
  double? _metric(String key) {
    final value = metrics[key];
    if (value == null) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9\.-]'), ''));
  }

  return _DashboardSnapshot(
    avgFps: _metric('Avg FPS'),
    peakMem: _metric('Peak Mem (MB)'),
    recoveries: _metric('Recoveries'),
    warnings: _metric('Warnings'),
    stabilityScore: _metric('Stability'),
  );
}

Map<String, double> _computeWeights(
  _ForecastSnapshot forecast,
  _DashboardSnapshot dashboard,
) {
  double push = 1.0;
  double reward = 1.0;
  double emphasis = 1.0;

  final r7 = forecast.retention7d ?? 0.0;
  final r30 = forecast.retention30d ?? r7;
  final warnings = dashboard.warnings ?? 0.0;
  final fps = dashboard.avgFps ?? 60.0;

  if (r7 < 0.15) {
    push += (0.15 - r7) * 1.2;
  }
  push += (warnings / 10).clamp(0.0, 0.3);

  if (r30 < 0.2) {
    reward += (0.2 - r30) * 0.9;
  }
  if ((dashboard.recoveries ?? 0) > 0) {
    reward += 0.1;
  }

  if (fps < 58) {
    emphasis += 0.15;
  }
  if ((dashboard.stabilityScore ?? 1.0) < 0.95) {
    emphasis += 0.2;
  }
  if (forecast.trend == 'downward') {
    emphasis += 0.25;
  }

  return {
    'push_frequency': double.parse(push.toStringAsFixed(2)),
    'reward_timing': double.parse(reward.toStringAsFixed(2)),
    'ui_emphasis': double.parse(emphasis.toStringAsFixed(2)),
  };
}

List<String> _buildRecommendations(
  Map<String, double> weights,
  _ForecastSnapshot forecast,
  _DashboardSnapshot dashboard,
) {
  final recs = <String>[];
  if (weights['push_frequency']! > 1.1) {
    recs.add(
      'Boost push cadence +${((weights['push_frequency']! - 1) * 100).toStringAsFixed(0)}%',
    );
  } else {
    recs.add('Maintain push cadence');
  }
  if (weights['reward_timing']! > 1.1) {
    recs.add('Pull rewards earlier in first session');
  } else {
    recs.add('Reward timing stable');
  }
  if (weights['ui_emphasis']! > 1.1) {
    recs.add('Highlight guidance modules in hero UI');
  } else {
    recs.add('UI emphasis unchanged');
  }
  if (forecast.trend == 'downward') {
    recs.add('Investigate cohort drop leading to downward trend');
  }
  if ((dashboard.warnings ?? 0) > 2) {
    recs.add('Resolve dashboard warnings before rollout');
  }
  return recs;
}

Future<void> _writeSummary({
  required _ForecastSnapshot forecast,
  required _DashboardSnapshot dashboard,
  required Map<String, double> weights,
  required List<String> recommendations,
  required double weightAvg,
}) async {
  final buffer = StringBuffer()
    ..writeln('FEEDBACK ADAPTATION LOOP V2')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Predictive forecast: $_forecastPath')
    ..writeln('UX dashboard: $_dashboardPath')
    ..writeln()
    ..writeln('Retention Inputs:')
    ..writeln('- 7d: ${(forecast.retention7d ?? 0).toStringAsPercent()}')
    ..writeln('- 14d: ${(forecast.retention14d ?? 0).toStringAsPercent()}')
    ..writeln('- 30d: ${(forecast.retention30d ?? 0).toStringAsPercent()}')
    ..writeln('- Trend: ${forecast.trend ?? 'n/a'}')
    ..writeln()
    ..writeln('Dashboard Signals:')
    ..writeln('- Avg FPS: ${dashboard.avgFps ?? double.nan}')
    ..writeln('- Peak Mem (MB): ${dashboard.peakMem ?? double.nan}')
    ..writeln('- Recoveries: ${dashboard.recoveries ?? 0}')
    ..writeln('- Warnings: ${dashboard.warnings ?? 0}')
    ..writeln('- Stability: ${dashboard.stabilityScore ?? double.nan}')
    ..writeln()
    ..writeln('Adaptive Weights (avg ${weightAvg.toStringAsFixed(2)}):')
    ..writeln('- Push frequency: ${weights['push_frequency']}')
    ..writeln('- Reward timing: ${weights['reward_timing']}')
    ..writeln('- UI emphasis: ${weights['ui_emphasis']}')
    ..writeln()
    ..writeln('Recommendations:');
  for (final rec in recommendations) {
    buffer.writeln('- $rec');
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double weightAvg,
  required List<String> recommendations,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'feedback_adaptation_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'weight_avg': weightAvg,
    'recommendations': recommendations.join('; '),
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    jsonEncode(payload) + '\n',
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
      'feedback_adaptation_loop_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ForecastSnapshot {
  const _ForecastSnapshot({
    required this.retention7d,
    required this.retention14d,
    required this.retention30d,
    required this.trend,
  });

  const _ForecastSnapshot.empty()
    : this(
        retention7d: null,
        retention14d: null,
        retention30d: null,
        trend: null,
      );

  final double? retention7d;
  final double? retention14d;
  final double? retention30d;
  final String? trend;
}

class _DashboardSnapshot {
  const _DashboardSnapshot({
    required this.avgFps,
    required this.peakMem,
    required this.recoveries,
    required this.warnings,
    required this.stabilityScore,
  });

  const _DashboardSnapshot.empty()
    : this(
        avgFps: null,
        peakMem: null,
        recoveries: null,
        warnings: null,
        stabilityScore: null,
      );

  final double? avgFps;
  final double? peakMem;
  final double? recoveries;
  final double? warnings;
  final double? stabilityScore;
}

extension _PercentFormat on double {
  String toStringAsPercent() => '${(this * 100).toStringAsFixed(1)}%';
}
