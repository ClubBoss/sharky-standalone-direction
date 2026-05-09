import 'dart:convert';
import 'dart:io';

const String _marketingSummaryPath =
    'release/_reports/marketing_orchestration_summary.txt';
const String _analyticsSummaryPath =
    'release/_reports/analytics_dashboard_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/cross_channel_sync_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final marketing = await _parseMarketingSummary();
  final analytics = await _parseAnalyticsSummary();
  final channels = await _extractChannelTelemetry();

  final variance = _computeVariance(analytics.conversionRateHistory);
  final recommendations = _buildRecommendations(
    varianceAvg: variance,
    confidenceAvg: marketing.avgConfidence,
    conversionRate: analytics.currentConversion,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      marketing: marketing,
      analytics: analytics,
      varianceAvg: variance,
      recommendations: recommendations,
      channelCount: channels,
    );
    await _appendTelemetry(
      channels: channels,
      varianceAvg: variance,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'cross_channel_sync_engine: channels=$channels variance=${variance.toStringAsFixed(2)}',
  );
}

Future<_MarketingSchedule> _parseMarketingSummary() async {
  final file = File(_marketingSummaryPath);
  if (!await file.exists()) return const _MarketingSchedule();
  final lines = await file.readAsLines();
  final tableStart = lines.indexWhere(
    (line) => line.trim().startsWith('| Campaign'),
  );
  if (tableStart == -1) return const _MarketingSchedule();

  final entries = <_CampaignEntry>[];
  for (var i = tableStart + 2; i < lines.length; i++) {
    final row = lines[i].trim();
    if (!row.startsWith('|') || row.startsWith('| Telemetry')) break;
    final cells = row
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();
    if (cells.length < 4) continue;
    entries.add(
      _CampaignEntry(
        campaignId: cells[0],
        runDate: DateTime.tryParse(cells[1]),
        confidence: double.tryParse(cells[2]) ?? 0.0,
        notes: cells[3],
      ),
    );
  }

  final avgConfidence = entries.isEmpty
      ? 0.0
      : entries.map((e) => e.confidence).reduce((a, b) => a + b) /
            entries.length;
  return _MarketingSchedule(entries: entries, avgConfidence: avgConfidence);
}

Future<_AnalyticsSnapshot> _parseAnalyticsSummary() async {
  final file = File(_analyticsSummaryPath);
  if (!await file.exists()) return const _AnalyticsSnapshot();
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

  final conversionRate = _extract('- Conversion rate');
  final retention = _extract('- Retention');
  final forecast = _extract('- Forecast trend');

  return _AnalyticsSnapshot(
    currentConversion: conversionRate,
    retentionPct: retention,
    forecastTrend: forecast,
    conversionRateHistory: [conversionRate],
  );
}

Future<int> _extractChannelTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return 0;
  final channels = <String>{};
  for (final raw in await file.readAsLines()) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        channels.add(decoded['event']?.toString() ?? '');
      }
    } catch (_) {
      continue;
    }
  }
  channels.removeWhere((channel) => channel.isEmpty);
  return channels.length;
}

double _computeVariance(List<double> conversions) {
  if (conversions.length < 2) return 0.0;
  final mean = conversions.reduce((a, b) => a + b) / conversions.length;
  final variance =
      conversions
          .map((value) => (value - mean) * (value - mean))
          .reduce((a, b) => a + b) /
      conversions.length;
  return double.parse(variance.toStringAsFixed(2));
}

List<String> _buildRecommendations({
  required double varianceAvg,
  required double confidenceAvg,
  required double conversionRate,
}) {
  final recs = <String>[];
  if (varianceAvg > 10) {
    recs.add(
      'High cross-channel variance; align creative cadence across paid + lifecycle.',
    );
  } else {
    recs.add('Variance stable; keep cross-channel cadence steady.');
  }

  if (confidenceAvg < 0.7) {
    recs.add(
      'Confidence under 0.70; re-run control holdouts before next scale.',
    );
  } else {
    recs.add('Confidence strong; pre-authorize scaling playbooks.');
  }

  if (conversionRate < 10) {
    recs.add('Conversion below 10%; prioritize onboarding uplift channels.');
  }

  return recs;
}

Future<void> _writeSummary({
  required _MarketingSchedule marketing,
  required _AnalyticsSnapshot analytics,
  required double varianceAvg,
  required List<String> recommendations,
  required int channelCount,
}) async {
  final buffer = StringBuffer()
    ..writeln('CROSS-CHANNEL SYNC SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Channel Metrics')
    ..writeln('- Active telemetry channels: $channelCount')
    ..writeln('- Conversion variance: ${varianceAvg.toStringAsFixed(2)}')
    ..writeln(
      '- Avg campaign confidence: ${marketing.avgConfidence.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Current conversion: ${analytics.currentConversion.toStringAsFixed(2)}%',
    )
    ..writeln()
    ..writeln('Planned Campaigns (14-day horizon)')
    ..writeln('| Campaign ID | Confidence | Next Run Date |')
    ..writeln('|-------------|------------|---------------|');

  for (final entry in marketing.entries.take(5)) {
    buffer.writeln(
      '| ${entry.campaignId} | '
      '${entry.confidence.toStringAsFixed(2)} | '
      '${entry.runDate?.toIso8601String() ?? 'tbd'} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('Recommendations');
  for (final rec in recommendations) {
    buffer.writeln('- $rec');
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int channels,
  required double varianceAvg,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'cross_channel_sync_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'channels': channels,
    'variance_avg': double.parse(varianceAvg.toStringAsFixed(2)),
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
      'cross_channel_sync_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _MarketingSchedule {
  const _MarketingSchedule({this.entries = const [], this.avgConfidence = 0});

  final List<_CampaignEntry> entries;
  final double avgConfidence;
}

class _CampaignEntry {
  const _CampaignEntry({
    required this.campaignId,
    required this.runDate,
    required this.confidence,
    required this.notes,
  });

  final String campaignId;
  final DateTime? runDate;
  final double confidence;
  final String notes;
}

class _AnalyticsSnapshot {
  const _AnalyticsSnapshot({
    this.currentConversion = 0,
    this.retentionPct = 0,
    this.forecastTrend = 0,
    this.conversionRateHistory = const [],
  });

  final double currentConversion;
  final double retentionPct;
  final double forecastTrend;
  final List<double> conversionRateHistory;
}
