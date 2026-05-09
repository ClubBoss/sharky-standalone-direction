import 'dart:convert';
import 'dart:io';

const String _crossSummaryPath =
    'release/_reports/cross_channel_sync_summary.txt';
const String _telemetryReliabilityPath =
    'release/_reports/telemetry_reliability_summary.txt';
const String _retentionForecastPath =
    'release/_reports/long_term_retention_forecast.txt';
const String _summaryPath = 'release/_reports/systemic_risk_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final cross = await _parseCrossChannelSummary();
  final telemetryReliability = await _parseTelemetryReliability();
  final retention = await _parseRetentionForecast();

  final riskScore = _aggregateRiskScore(
    variance: cross.variance,
    missingLinks: telemetryReliability.missingLinks,
    driftPct: retention.driftPct,
  );
  final band = _riskBand(riskScore);
  final recommendations = _buildRecommendations(
    cross: cross,
    telemetry: telemetryReliability,
    retention: retention,
    band: band,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      cross: cross,
      telemetry: telemetryReliability,
      retention: retention,
      riskScore: riskScore,
      band: band,
      recommendations: recommendations,
    );
    await _appendTelemetry(
      riskScore: riskScore,
      riskBand: band,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'systemic_risk_synthesizer: score=${riskScore.toStringAsFixed(2)} band=$band',
  );
}

Future<_CrossChannelSnapshot> _parseCrossChannelSummary() async {
  final file = File(_crossSummaryPath);
  if (!await file.exists()) return const _CrossChannelSnapshot();
  final lines = await file.readAsLines();

  double _extract(String label) {
    final line = lines.firstWhere(
      (row) => row.trim().startsWith(label),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final match = RegExp(r'[-+]?\d+\.?\d*').firstMatch(line);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  final channelCount = _extract('- Active telemetry channels');
  final variance = _extract('- Conversion variance');
  final confidence = _extract('- Avg campaign confidence');
  final conversion = _extract('- Current conversion');

  return _CrossChannelSnapshot(
    channels: channelCount.toInt(),
    variance: variance,
    avgConfidence: confidence,
    conversionRate: conversion,
  );
}

Future<_TelemetryReliabilitySnapshot> _parseTelemetryReliability() async {
  final file = File(_telemetryReliabilityPath);
  if (!await file.exists()) return const _TelemetryReliabilitySnapshot();
  final lines = await file.readAsLines();
  double _extract(String label) {
    final line = lines.firstWhere(
      (row) => row.trim().startsWith(label),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final match = RegExp(r'\d+').firstMatch(line);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  final missing = _extract('Missing summary');
  final duplicates = _extract('Duplicate telemetry events');
  final inconsistencies = _extract('Timestamp inconsistencies');

  return _TelemetryReliabilitySnapshot(
    missingLinks: missing.toInt(),
    duplicates: duplicates.toInt(),
    inconsistencies: inconsistencies.toInt(),
  );
}

Future<_RetentionForecastSnapshot> _parseRetentionForecast() async {
  final file = File(_retentionForecastPath);
  if (!await file.exists()) return const _RetentionForecastSnapshot();
  final lines = await file.readAsLines();

  final driftLine = lines.firstWhere(
    (line) => line.contains('drift'),
    orElse: () => '',
  );
  final driftMatch = RegExp(r'([\d.]+)\s*%').firstMatch(driftLine);
  final drift = driftMatch == null
      ? 0.0
      : double.tryParse(driftMatch.group(1) ?? '') ?? 0.0;

  final highRiskRows = lines
      .where((line) => line.contains('| HIGH |'))
      .toList();
  final risks = highRiskRows.length;

  return _RetentionForecastSnapshot(driftPct: drift, highRiskCategories: risks);
}

double _aggregateRiskScore({
  required double variance,
  required int missingLinks,
  required double driftPct,
}) {
  final varianceNorm = (variance / 10).clamp(0, 1);
  final missingNorm = (missingLinks / 20).clamp(0, 1);
  final driftNorm = (driftPct / 5).clamp(0, 1);
  final score = 0.4 * varianceNorm + 0.35 * missingNorm + 0.25 * driftNorm;
  return double.parse(score.toStringAsFixed(2));
}

String _riskBand(double score) {
  if (score < 0.33) return 'GREEN';
  if (score < 0.66) return 'ORANGE';
  return 'RED';
}

List<String> _buildRecommendations({
  required _CrossChannelSnapshot cross,
  required _TelemetryReliabilitySnapshot telemetry,
  required _RetentionForecastSnapshot retention,
  required String band,
}) {
  final recs = <String>[];
  if (cross.variance > 5) {
    recs.add('Variance above 5%; sync messaging cadence across channels.');
  } else {
    recs.add('Variance nominal; maintain current cross-channel cadence.');
  }

  if (telemetry.missingLinks > 0) {
    recs.add(
      'Resolve ${telemetry.missingLinks} missing telemetry references before next release.',
    );
  }
  if (retention.driftPct > 2 || retention.highRiskCategories > 0) {
    recs.add(
      'Retention drift ${retention.driftPct.toStringAsFixed(2)}%; run retention playbook.',
    );
  }
  if (band == 'RED') {
    recs.add('Overall risk RED—escalate to program management immediately.');
  } else if (band == 'ORANGE') {
    recs.add('Risk ORANGE—schedule mitigation review within 48 hours.');
  }

  return recs;
}

Future<void> _writeSummary({
  required _CrossChannelSnapshot cross,
  required _TelemetryReliabilitySnapshot telemetry,
  required _RetentionForecastSnapshot retention,
  required double riskScore,
  required String band,
  required List<String> recommendations,
}) async {
  final buffer = StringBuffer()
    ..writeln('SYSTEMIC RISK SUMMARY')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Risk Score: ${riskScore.toStringAsFixed(2)} ($band)')
    ..writeln()
    ..writeln('Context Metrics')
    ..writeln('- Channels monitored: ${cross.channels}')
    ..writeln('- Conversion variance: ${cross.variance.toStringAsFixed(2)}')
    ..writeln(
      '- Avg campaign confidence: ${cross.avgConfidence.toStringAsFixed(2)}',
    )
    ..writeln('- Telemetry missing links: ${telemetry.missingLinks}')
    ..writeln('- Retention drift: ${retention.driftPct.toStringAsFixed(2)}%')
    ..writeln(
      '- Forecast high-risk categories: ${retention.highRiskCategories}',
    )
    ..writeln()
    ..writeln('Recommendations');
  for (final rec in recommendations) {
    buffer.writeln('- $rec');
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double riskScore,
  required String riskBand,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'systemic_risk_synthesized',
    'timestamp': DateTime.now().toIso8601String(),
    'risk_score': double.parse(riskScore.toStringAsFixed(2)),
    'risk_band': riskBand,
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
      'systemic_risk_synthesizer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _CrossChannelSnapshot {
  const _CrossChannelSnapshot({
    this.channels = 0,
    this.variance = 0,
    this.avgConfidence = 0,
    this.conversionRate = 0,
  });

  final int channels;
  final double variance;
  final double avgConfidence;
  final double conversionRate;
}

class _TelemetryReliabilitySnapshot {
  const _TelemetryReliabilitySnapshot({
    this.missingLinks = 0,
    this.duplicates = 0,
    this.inconsistencies = 0,
  });

  final int missingLinks;
  final int duplicates;
  final int inconsistencies;
}

class _RetentionForecastSnapshot {
  const _RetentionForecastSnapshot({
    this.driftPct = 0,
    this.highRiskCategories = 0,
  });

  final double driftPct;
  final int highRiskCategories;
}
