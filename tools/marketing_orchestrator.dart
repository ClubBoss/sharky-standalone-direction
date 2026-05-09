import 'dart:convert';
import 'dart:io';

const String _abSummaryPath = 'release/_reports/ab_campaign_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath =
    'release/_reports/marketing_orchestration_summary.txt';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final abSnapshot = await _parseAbSummary();
  final telemetrySignals = await _readTelemetrySignals();
  final plan = _buildPlan(abSnapshot, telemetrySignals);

  await _withReportsWritable(() async {
    await _writeSummary(plan, abSnapshot, telemetrySignals);
    await _appendTelemetry(
      plannedRuns: plan.entries.length,
      avgConfidence: plan.avgConfidence,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'marketing_orchestrator: planned=${plan.entries.length} '
    'avgConfidence=${plan.avgConfidence.toStringAsFixed(2)}',
  );
}

Future<_AbSnapshot> _parseAbSummary() async {
  final file = File(_abSummaryPath);
  if (!await file.exists()) return const _AbSnapshot();
  final lines = await file.readAsLines();

  double _extractNumber(String label) {
    final line = lines.firstWhere(
      (row) => row.trim().startsWith(label),
      orElse: () => '',
    );
    if (line.isEmpty) return 0;
    final match = RegExp(r'[-+]?\d+\.?\d*').firstMatch(line);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  return _AbSnapshot(
    baselineConversion: _extractNumber('- Strategy A'),
    strategyBConversion: _extractNumber('- Strategy B'),
    liftPct: _extractNumber('- Estimated lift'),
    riskDelta: _extractNumber('- Risk delta'),
    projection7: _extractNumber('- 7-day projected conversion'),
    projection30: _extractNumber('- 30-day projected conversion'),
  );
}

Future<_TelemetryInsights> _readTelemetrySignals() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const _TelemetryInsights();
  DateTime? lastMarketingFeedback;
  DateTime? lastAbRun;
  final conversionHistory = <double>[];

  for (final raw in await file.readAsLines()) {
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
      if (name == 'marketing_feedback_completed') {
        lastMarketingFeedback = timestamp;
      } else if (name == 'ab_campaign_completed') {
        lastAbRun = timestamp;
        final lift = (decoded['lift_pct'] as num?)?.toDouble();
        if (lift != null) conversionHistory.add(lift);
      } else if (name == 'analytics_dashboard_v2_completed') {
        final conv = (decoded['conversion_pct'] as num?)?.toDouble();
        if (conv != null) conversionHistory.add(conv);
      }
    } catch (_) {
      continue;
    }
  }

  return _TelemetryInsights(
    lastFeedback: lastMarketingFeedback,
    lastAbRun: lastAbRun,
    conversionHistory: conversionHistory,
  );
}

_OrchestrationPlan _buildPlan(
  _AbSnapshot snapshot,
  _TelemetryInsights telemetry,
) {
  final entries = <_PlanEntry>[];

  final now = DateTime.now();
  final needsFastFollow = snapshot.liftPct >= 20 || snapshot.riskDelta >= 0.5;
  final nextAbDate = telemetry.lastAbRun == null
      ? now.add(const Duration(days: 7))
      : telemetry.lastAbRun!.add(Duration(days: needsFastFollow ? 10 : 21));

  entries.add(
    _PlanEntry(
      name: 'Segmented Flow Follow-up',
      startDate: nextAbDate,
      confidence: _confidenceFrom(snapshot.liftPct, snapshot.riskDelta),
      notes: needsFastFollow
          ? 'High lift detected; prioritize new cohort within 10 days.'
          : 'Moderate lift; schedule standard cadence A/B.',
    ),
  );

  final telemetryRefreshDate = telemetry.lastFeedback == null
      ? now.add(const Duration(days: 7))
      : telemetry.lastFeedback!.add(const Duration(days: 14));
  entries.add(
    _PlanEntry(
      name: 'Telemetry Refresh Cycle',
      startDate: telemetryRefreshDate,
      confidence: 0.6,
      notes:
          'Refresh analytics + marketing feedback snapshots prior to next go/no-go.',
    ),
  );

  final attritionSignal = snapshot.projection30 - snapshot.baselineConversion;
  if (attritionSignal < 2) {
    entries.add(
      _PlanEntry(
        name: 'Retention Warm-up Campaign',
        startDate: nextAbDate.add(const Duration(days: 5)),
        confidence: 0.55,
        notes: 'Projected gains are modest; add retention-oriented creative.',
      ),
    );
  }

  final avgConfidence = entries.isEmpty
      ? 0.0
      : entries.map((e) => e.confidence).reduce((a, b) => a + b) /
            entries.length;

  return _OrchestrationPlan(entries: entries, avgConfidence: avgConfidence);
}

double _confidenceFrom(double liftPct, double riskDelta) {
  final base = (liftPct / 100).clamp(0.0, 0.6);
  final riskBonus = (riskDelta).clamp(0.0, 1.0) * 0.2;
  return (0.5 + base + riskBonus).clamp(0.5, 0.95);
}

Future<void> _writeSummary(
  _OrchestrationPlan plan,
  _AbSnapshot snapshot,
  _TelemetryInsights telemetry,
) async {
  final buffer = StringBuffer()
    ..writeln('MARKETING ORCHESTRATION SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Latest A/B Snapshot')
    ..writeln(
      '- Baseline conversion: ${snapshot.baselineConversion.toStringAsFixed(2)}%',
    )
    ..writeln(
      '- Strategy B conversion: '
      '${snapshot.strategyBConversion.toStringAsFixed(2)}%',
    )
    ..writeln('- Lift: ${snapshot.liftPct.toStringAsFixed(2)}%')
    ..writeln('- Risk delta: ${snapshot.riskDelta.toStringAsFixed(2)}')
    ..writeln('- 7d projection: ${snapshot.projection7.toStringAsFixed(2)}%')
    ..writeln('- 30d projection: ${snapshot.projection30.toStringAsFixed(2)}%')
    ..writeln()
    ..writeln(
      'Planned Campaigns (avg confidence '
      '${plan.avgConfidence.toStringAsFixed(2)})',
    )
    ..writeln('| Campaign | Start Date | Confidence | Notes |')
    ..writeln('|----------|------------|------------|-------|');

  for (final entry in plan.entries) {
    buffer.writeln(
      '| ${entry.name} | '
      '${entry.startDate.toIso8601String()} | '
      '${entry.confidence.toStringAsFixed(2)} | '
      '${entry.notes} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('Telemetry Anchors')
    ..writeln(
      '- Last marketing feedback: '
      '${telemetry.lastFeedback?.toIso8601String() ?? 'n/a'}',
    )
    ..writeln(
      '- Last A/B campaign: '
      '${telemetry.lastAbRun?.toIso8601String() ?? 'n/a'}',
    );

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int plannedRuns,
  required double avgConfidence,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'marketing_orchestration_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'planned_runs': plannedRuns,
    'avg_confidence': double.parse(avgConfidence.toStringAsFixed(2)),
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
      'marketing_orchestrator: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}

class _AbSnapshot {
  const _AbSnapshot({
    this.baselineConversion = 0,
    this.strategyBConversion = 0,
    this.liftPct = 0,
    this.riskDelta = 0,
    this.projection7 = 0,
    this.projection30 = 0,
  });

  final double baselineConversion;
  final double strategyBConversion;
  final double liftPct;
  final double riskDelta;
  final double projection7;
  final double projection30;
}

class _TelemetryInsights {
  const _TelemetryInsights({
    this.lastFeedback,
    this.lastAbRun,
    this.conversionHistory = const [],
  });

  final DateTime? lastFeedback;
  final DateTime? lastAbRun;
  final List<double> conversionHistory;
}

class _PlanEntry {
  const _PlanEntry({
    required this.name,
    required this.startDate,
    required this.confidence,
    required this.notes,
  });

  final String name;
  final DateTime startDate;
  final double confidence;
  final String notes;
}

class _OrchestrationPlan {
  const _OrchestrationPlan({
    required this.entries,
    required this.avgConfidence,
  });

  final List<_PlanEntry> entries;
  final double avgConfidence;
}
