import 'dart:convert';
import 'dart:io';

const String _marketingSummaryPath =
    'release/_reports/marketing_feedback_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/ab_campaign_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final marketing = await _parseMarketingSummary();
  final conversionHistory = await _extractConversionHistory();
  final baseline = conversionHistory.isNotEmpty
      ? conversionHistory.last
      : marketing.conversionRate;

  final simulation = _simulateCampaigns(
    baselineConversion: baseline,
    marketing: marketing,
    history: conversionHistory,
  );

  await _withReportsWritable(() async {
    await _writeSummary(marketing, simulation);
    await _appendTelemetry(
      liftPct: simulation.liftPct,
      riskDelta: simulation.riskDelta,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'ab_campaign_loop: lift=${simulation.liftPct.toStringAsFixed(2)}% '
    'riskDelta=${simulation.riskDelta.toStringAsFixed(2)}',
  );
}

Future<_MarketingSnapshot> _parseMarketingSummary() async {
  final file = File(_marketingSummaryPath);
  if (!await file.exists()) return const _MarketingSnapshot();
  double _parseValue(String label) {
    final line = file.readAsLinesSync().firstWhere(
      (row) => row.trim().startsWith(label),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final match = RegExp(r'[-+]?\d+\.?\d*').firstMatch(line);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  final lines = await file.readAsLines();
  String? _parseText(String label) {
    final line = lines.firstWhere(
      (row) => row.trim().startsWith(label),
      orElse: () => '',
    );
    if (line.isEmpty) return null;
    final parts = line.split(':');
    return parts.length > 1 ? parts.last.trim() : null;
  }

  final conversionRisk = _parseText('- Conversion risk') ?? 'Unknown';
  final trendSignal = _parseText('- Trend signal') ?? 'Neutral';
  final dropLine = _parseText('- Forecast drop detected') ?? 'false';
  final hasDrop = dropLine.toLowerCase().contains('true');

  return _MarketingSnapshot(
    conversionRate: _parseValue('- Conversion rate'),
    retentionPct: _parseValue('- Retention (7/30d)'),
    forecastTrend: _parseValue('- Forecast trend'),
    conversionRisk: conversionRisk,
    trendSignal: trendSignal,
    forecastDrop: hasDrop,
  );
}

Future<List<double>> _extractConversionHistory() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final conversions = <double>[];
  for (final raw in await file.readAsLines()) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic> &&
          decoded['event'] == 'analytics_dashboard_v2_completed') {
        final value = (decoded['conversion_pct'] as num?)?.toDouble();
        if (value != null) conversions.add(value);
      }
    } catch (_) {
      continue;
    }
  }
  return conversions;
}

_SimulationResult _simulateCampaigns({
  required double baselineConversion,
  required _MarketingSnapshot marketing,
  required List<double> history,
}) {
  final strategyA = baselineConversion;
  final improvementBase = _improvementFactor(marketing.conversionRisk);
  final trendMultiplier = _trendMultiplier(marketing.trendSignal);
  final dropPenalty = marketing.forecastDrop ? 0.75 : 1.0;
  final lift = improvementBase * trendMultiplier * dropPenalty;

  final strategyB = strategyA * (1 + lift);
  final liftPct = strategyA == 0
      ? strategyB * 100
      : (strategyB - strategyA) / strategyA * 100;

  // risk delta: convert qualitative to numeric index
  final riskScore = _riskScore(marketing.conversionRisk);
  final newRiskScore = (riskScore - lift * 2).clamp(0.0, 2.0);
  final riskDelta = riskScore - newRiskScore;

  double project(double base, double factor) => base * (1 + factor);
  final projection7 = project(strategyB, 0.05 * trendMultiplier);
  final projection30 = project(strategyB, 0.12 * trendMultiplier);

  return _SimulationResult(
    strategyA: strategyA,
    strategyB: strategyB,
    liftPct: liftPct,
    riskDelta: riskDelta,
    projection7: projection7,
    projection30: projection30,
    conversionHistory: history,
  );
}

double _improvementFactor(String risk) {
  switch (risk.toLowerCase()) {
    case 'high':
      return 0.35;
    case 'medium':
      return 0.18;
    case 'low':
      return 0.08;
    default:
      return 0.12;
  }
}

double _trendMultiplier(String signal) {
  switch (signal.toLowerCase()) {
    case 'bullish':
      return 1.2;
    case 'bearish':
      return 0.7;
    default:
      return 1.0;
  }
}

double _riskScore(String risk) {
  switch (risk.toLowerCase()) {
    case 'high':
      return 2.0;
    case 'medium':
      return 1.0;
    case 'low':
      return 0.0;
    default:
      return 1.0;
  }
}

Future<void> _writeSummary(
  _MarketingSnapshot marketing,
  _SimulationResult simulation,
) async {
  final buffer = StringBuffer()
    ..writeln('A/B CAMPAIGN SUMMARY')
    ..writeln('====================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Inputs')
    ..writeln(
      '- Baseline conversion rate: ${simulation.strategyA.toStringAsFixed(2)}%',
    )
    ..writeln('- Conversion risk: ${marketing.conversionRisk}')
    ..writeln('- Trend signal: ${marketing.trendSignal}')
    ..writeln('- Forecast drop detected: ${marketing.forecastDrop}')
    ..writeln()
    ..writeln('Simulation')
    ..writeln(
      '- Strategy A (current onboarding): '
      '${simulation.strategyA.toStringAsFixed(2)}%',
    )
    ..writeln(
      '- Strategy B (segmented flow): '
      '${simulation.strategyB.toStringAsFixed(2)}%',
    )
    ..writeln('- Estimated lift: ${simulation.liftPct.toStringAsFixed(2)}%')
    ..writeln(
      '- Risk delta: ${simulation.riskDelta.toStringAsFixed(2)} (lower is better)',
    )
    ..writeln(
      '- 7-day projected conversion: '
      '${simulation.projection7.toStringAsFixed(2)}%',
    )
    ..writeln(
      '- 30-day projected conversion: '
      '${simulation.projection30.toStringAsFixed(2)}%',
    )
    ..writeln()
    ..writeln('Recommendations');

  if (simulation.liftPct <= 0) {
    buffer.writeln('- Maintain Strategy A; insufficient lift expected.');
  } else {
    buffer
      ..writeln('- Roll out Strategy B to top acquisition cohorts.')
      ..writeln('- Instrument incremental telemetry for segmented flow.')
      ..writeln('- Re-evaluate conversion risk after 14 days.');
  }

  if (simulation.conversionHistory.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Recent conversion history (most recent last)')
      ..writeln(
        simulation.conversionHistory
            .take(6)
            .map((v) => v.toStringAsFixed(2))
            .join(' → '),
      );
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double liftPct,
  required double riskDelta,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'ab_campaign_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'lift_pct': double.parse(liftPct.toStringAsFixed(2)),
    'risk_delta': double.parse(riskDelta.toStringAsFixed(2)),
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
      'ab_campaign_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _MarketingSnapshot {
  const _MarketingSnapshot({
    this.conversionRate = 0,
    this.retentionPct = 0,
    this.forecastTrend = 0,
    this.conversionRisk = 'Unknown',
    this.trendSignal = 'Neutral',
    this.forecastDrop = false,
  });

  final double conversionRate;
  final double retentionPct;
  final double forecastTrend;
  final String conversionRisk;
  final String trendSignal;
  final bool forecastDrop;
}

class _SimulationResult {
  const _SimulationResult({
    required this.strategyA,
    required this.strategyB,
    required this.liftPct,
    required this.riskDelta,
    required this.projection7,
    required this.projection30,
    required this.conversionHistory,
  });

  final double strategyA;
  final double strategyB;
  final double liftPct;
  final double riskDelta;
  final double projection7;
  final double projection30;
  final List<double> conversionHistory;
}
