import 'dart:convert';
import 'dart:io';

const String _archivalSummaryPath =
    'release/_reports/archival_verification_summary.txt';
const String _telemetryReliabilityPath =
    'release/_reports/telemetry_reliability_summary.txt';
const String _reportsDir = 'release/_reports';
const String _outputPath = 'release/_reports/long_term_retention_forecast.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final archival = await _readArchivalSummary();
  final reliability = await _readTelemetryReliabilitySummary();

  final archivalForecast = _forecastMetric(
    currentValue: archival.driftPercent,
    daysSince: archival.daysSince,
    threshold: 3.0,
  );
  final telemetryForecast = _forecastMetric(
    currentValue: reliability.missingCount.toDouble(),
    daysSince: reliability.daysSince,
    threshold: 10.0,
  );

  final categories = <_CategoryForecast>[
    _CategoryForecast(
      name: 'Archival Integrity',
      metricLabel: '${archival.driftPercent.toStringAsFixed(2)} % drift',
      risk: _riskBand(archival.driftPercent, 1.0, 3.0),
      nextDueDays: archivalForecast.nextDueDays,
    ),
    _CategoryForecast(
      name: 'Telemetry Reliability',
      metricLabel: '${reliability.missingCount} missing refs',
      risk: _riskBand(reliability.missingCount.toDouble(), 1.0, 10.0),
      nextDueDays: telemetryForecast.nextDueDays,
    ),
  ];

  final avgDrift =
      (archival.driftPercent / 5.0).clamp(0.0, 1.0) +
      (reliability.missingCount / 20.0).clamp(0.0, 1.0);
  final avgDriftScore = avgDrift / 2.0;
  final riskHighCount = categories.where((c) => c.risk == 'HIGH').length;
  final nextDueDays = _minDueDays(categories);

  await _withReportsWritable(() async {
    await _writeSummary(
      archival: archival,
      reliability: reliability,
      categories: categories,
    );
    await _appendTelemetry(
      avgDrift: avgDriftScore,
      riskHigh: riskHighCount,
      nextDueDays: nextDueDays,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'long_term_retention_forecaster: avgDrift=${avgDriftScore.toStringAsFixed(2)} '
    'riskHigh=$riskHighCount nextDue=${nextDueDays ?? -1}',
  );
}

class _ArchivalSnapshot {
  const _ArchivalSnapshot({
    required this.generated,
    required this.driftPercent,
  });

  final DateTime? generated;
  final double driftPercent;

  int get daysSince {
    if (generated == null) return 0;
    return DateTime.now().difference(generated!).inDays.clamp(0, 10000);
  }
}

class _ReliabilitySnapshot {
  const _ReliabilitySnapshot({
    required this.generated,
    required this.missingCount,
  });

  final DateTime? generated;
  final int missingCount;

  int get daysSince {
    if (generated == null) return 0;
    return DateTime.now().difference(generated!).inDays.clamp(0, 10000);
  }
}

Future<_ArchivalSnapshot> _readArchivalSummary() async {
  final file = File(_archivalSummaryPath);
  if (!await file.exists()) {
    return const _ArchivalSnapshot(generated: null, driftPercent: 0);
  }
  DateTime? generated;
  double drift = 0;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
    } else if (trimmed.startsWith('Drift:')) {
      final value = trimmed.split(':').last.trim().replaceAll('%', '');
      drift = double.tryParse(value) ?? 0;
    }
  }
  return _ArchivalSnapshot(generated: generated, driftPercent: drift);
}

Future<_ReliabilitySnapshot> _readTelemetryReliabilitySummary() async {
  final file = File(_telemetryReliabilityPath);
  if (!await file.exists()) {
    return const _ReliabilitySnapshot(generated: null, missingCount: 0);
  }
  DateTime? generated;
  int missing = 0;
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
    } else if (trimmed.startsWith('Missing summary')) {
      final value = RegExp(r'(\d+)').firstMatch(trimmed);
      if (value != null) missing = int.parse(value.group(1)!);
    }
  }
  return _ReliabilitySnapshot(generated: generated, missingCount: missing);
}

class _ForecastMetric {
  const _ForecastMetric({required this.nextDueDays});

  final int? nextDueDays;
}

_ForecastMetric _forecastMetric({
  required double currentValue,
  required int daysSince,
  required double threshold,
}) {
  final safeDays = daysSince <= 0 ? 1 : daysSince;
  final slope = currentValue / safeDays;
  if (currentValue >= threshold) {
    return const _ForecastMetric(nextDueDays: 0);
  }
  if (slope <= 0) {
    return const _ForecastMetric(nextDueDays: null);
  }
  final days = ((threshold - currentValue) / slope).round();
  return _ForecastMetric(nextDueDays: days);
}

String _riskBand(double value, double warnThreshold, double failThreshold) {
  if (value >= failThreshold) return 'HIGH';
  if (value >= warnThreshold) return 'MED';
  return 'LOW';
}

int? _minDueDays(List<_CategoryForecast> categories) {
  final due = categories
      .map((c) => c.nextDueDays)
      .whereType<int>()
      .where((d) => d >= 0)
      .toList();
  if (due.isEmpty) return null;
  due.sort();
  return due.first;
}

class _CategoryForecast {
  const _CategoryForecast({
    required this.name,
    required this.metricLabel,
    required this.risk,
    required this.nextDueDays,
  });

  final String name;
  final String metricLabel;
  final String risk;
  final int? nextDueDays;
}

Future<void> _writeSummary({
  required _ArchivalSnapshot archival,
  required _ReliabilitySnapshot reliability,
  required List<_CategoryForecast> categories,
}) async {
  final buffer = StringBuffer()
    ..writeln('LONG-TERM RETENTION FORECAST')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Inputs:')
    ..writeln(
      '- Archival summary: $_archivalSummaryPath (drift ${archival.driftPercent.toStringAsFixed(2)}%)',
    )
    ..writeln(
      '- Telemetry reliability: $_telemetryReliabilityPath (missing ${reliability.missingCount})',
    )
    ..writeln()
    ..writeln('| Category | Metric | Risk | Next Maintenance (days) |')
    ..writeln('|----------|--------|------|-------------------------|');
  for (final category in categories) {
    final due = category.nextDueDays;
    final dueLabel = due == null
        ? 'n/a'
        : due <= 0
        ? 'due now'
        : due.toString();
    buffer.writeln(
      '| ${category.name} | ${category.metricLabel} | ${category.risk} | $dueLabel |',
    );
  }
  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double avgDrift,
  required int riskHigh,
  required int? nextDueDays,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'long_term_retention_forecast_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'avg_drift': avgDrift,
    'risk_high': riskHigh,
    'next_due_days': nextDueDays,
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
      'long_term_retention_forecaster: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
