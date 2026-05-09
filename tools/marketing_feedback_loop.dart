import 'dart:convert';
import 'dart:io';

const String _analyticsSummaryPath =
    'release/_reports/analytics_dashboard_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath = 'release/_reports/marketing_feedback_summary.txt';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final analytics = await _parseAnalyticsSummary();
  final telemetry = await _readTelemetrySignals();
  final conversionRisk = _categorizeConversion(analytics.conversionRate);
  final trendSignal = _trendSignalFrom(analytics.forecastTrend, telemetry);
  final recommendations = _buildRecommendations(
    conversionRisk,
    trendSignal,
    telemetry.hasForecastDrop,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      analytics: analytics,
      conversionRisk: conversionRisk,
      trendSignal: trendSignal,
      recommendations: recommendations,
      telemetry: telemetry,
    );
    await _appendTelemetry(
      conversionRisk: conversionRisk,
      trendSignal: trendSignal,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'marketing_feedback_loop: conversionRisk=$conversionRisk trendSignal=$trendSignal',
  );
}

Future<_AnalyticsSnapshot> _parseAnalyticsSummary() async {
  final file = File(_analyticsSummaryPath);
  if (!await file.exists()) return const _AnalyticsSnapshot();
  final lines = await file.readAsLines();

  double _extractDouble(String prefix) {
    final line = lines.firstWhere(
      (row) => row.trim().startsWith(prefix),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final number = RegExp(r'[-+]?\d+\.?\d*').firstMatch(line);
    if (number == null) return 0;
    return double.tryParse(number.group(0) ?? '') ?? 0;
  }

  return _AnalyticsSnapshot(
    conversionRate: _extractDouble('Conversion rate'),
    retentionPct: _extractDouble('Retention (7/30d)'),
    forecastTrend: _extractDouble('Forecast trend'),
    avgDrift: _extractDouble('Avg drift (7d)'),
    avgXp: _extractDouble('Avg XP (30d)'),
  );
}

Future<_TelemetrySignals> _readTelemetrySignals() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const _TelemetrySignals();
  final lines = await file.readAsLines();

  DateTime? latestAutomation;
  DateTime? latestSnapshot;
  final forecastEvents = <_ForecastEvent>[];

  for (final raw in lines) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) continue;
      final name = decoded['event']?.toString() ?? '';
      final timestamp = DateTime.tryParse(
        decoded['timestamp']?.toString() ?? '',
      );
      if (timestamp == null) continue;
      if (name == 'automation_maintenance_vFinal_completed') {
        latestAutomation ??= timestamp;
      }
      if (name == 'analytics_dashboard_v2_completed') {
        latestSnapshot = timestamp;
        forecastEvents.add(
          _ForecastEvent(
            timestamp: timestamp,
            trend: (decoded['forecast_trend'] as num?)?.toDouble() ?? 0,
          ),
        );
      }
    } catch (_) {
      continue;
    }
  }

  bool hasTrendDrop = false;
  if (forecastEvents.length >= 2) {
    forecastEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final last = forecastEvents.last.trend;
    final previous = forecastEvents[forecastEvents.length - 2].trend;
    hasTrendDrop = last < previous;
  }

  return _TelemetrySignals(
    latestAutomation: latestAutomation,
    latestSnapshot: latestSnapshot,
    hasForecastDrop: hasTrendDrop,
  );
}

String _categorizeConversion(double conversionRate) {
  if (conversionRate >= 15) return 'Low';
  if (conversionRate >= 8) return 'Medium';
  return 'High';
}

String _trendSignalFrom(double forecastTrend, _TelemetrySignals telemetry) {
  if (telemetry.hasForecastDrop || forecastTrend < 0) return 'Bearish';
  if (forecastTrend <= 0.05) return 'Neutral';
  return 'Bullish';
}

List<String> _buildRecommendations(
  String conversionRisk,
  String trendSignal,
  bool hasForecastDrop,
) {
  final recs = <String>[];
  switch (conversionRisk) {
    case 'High':
      recs.add('Double down on onboarding funnels; conversion < 8%.');
      recs.add('Launch segmented nurture campaign for inactive cohorts.');
      break;
    case 'Medium':
      recs.add('A/B test pricing copy and CTA sequencing.');
      break;
    case 'Low':
      recs.add('Maintain current funnel; monitor weekly variance.');
      break;
  }

  if (trendSignal == 'Bearish') {
    recs.add('Activate safeguard budgets; trend score slipping.');
    if (hasForecastDrop) {
      recs.add('Alert marketing ops: forecast trend reversal detected.');
    }
  } else if (trendSignal == 'Bullish') {
    recs.add('Scale high-performing campaigns; trend momentum positive.');
  }

  return recs;
}

Future<void> _writeSummary({
  required _AnalyticsSnapshot analytics,
  required String conversionRisk,
  required String trendSignal,
  required List<String> recommendations,
  required _TelemetrySignals telemetry,
}) async {
  final buffer = StringBuffer()
    ..writeln('MARKETING FEEDBACK SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Key Metrics')
    ..writeln(
      '- Conversion rate: ${analytics.conversionRate.toStringAsFixed(2)}%',
    )
    ..writeln(
      '- Retention (7/30d): ${analytics.retentionPct.toStringAsFixed(2)}%',
    )
    ..writeln('- Forecast trend: ${analytics.forecastTrend.toStringAsFixed(3)}')
    ..writeln('- Avg drift (7d): ${analytics.avgDrift.toStringAsFixed(3)}')
    ..writeln('- Avg XP (30d): ${analytics.avgXp.toStringAsFixed(3)}')
    ..writeln()
    ..writeln('Risk Bands')
    ..writeln('- Conversion risk: $conversionRisk')
    ..writeln('- Trend signal: $trendSignal')
    ..writeln('- Forecast drop detected: ${telemetry.hasForecastDrop}')
    ..writeln()
    ..writeln('Next-Step Recommendations');

  if (recommendations.isEmpty) {
    buffer.writeln('- Maintain current topline playbooks; no action required.');
  } else {
    for (final rec in recommendations) {
      buffer.writeln('- $rec');
    }
  }

  buffer
    ..writeln()
    ..writeln('Telemetry timestamps')
    ..writeln(
      '- Last automation maintenance: '
      '${telemetry.latestAutomation?.toIso8601String() ?? 'n/a'}',
    )
    ..writeln(
      '- Last analytics snapshot: '
      '${telemetry.latestSnapshot?.toIso8601String() ?? 'n/a'}',
    );

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required String conversionRisk,
  required String trendSignal,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'marketing_feedback_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'conversion_risk': conversionRisk,
    'trend_signal': trendSignal,
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
      'marketing_feedback_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _AnalyticsSnapshot {
  const _AnalyticsSnapshot({
    this.conversionRate = 0,
    this.retentionPct = 0,
    this.forecastTrend = 0,
    this.avgDrift = 0,
    this.avgXp = 0,
  });

  final double conversionRate;
  final double retentionPct;
  final double forecastTrend;
  final double avgDrift;
  final double avgXp;
}

class _TelemetrySignals {
  const _TelemetrySignals({
    this.latestAutomation,
    this.latestSnapshot,
    this.hasForecastDrop = false,
  });

  final DateTime? latestAutomation;
  final DateTime? latestSnapshot;
  final bool hasForecastDrop;
}

class _ForecastEvent {
  const _ForecastEvent({required this.timestamp, required this.trend});

  final DateTime timestamp;
  final double trend;
}
