import 'dart:convert';
import 'dart:io';

const List<String> _uxMetricPaths = <String>[
  'release/_exports/ux_metrics.json',
  'release/_reports/ux_metrics.json',
  'ux_metrics.json',
];

const List<String> _autoSummaryPaths = <String>[
  'release/_reports/autonomous_telemetry_summary.txt',
  'release/_exports/autonomous_telemetry_summary.txt',
];

const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/onboarding_flow_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final uxMetrics = await _readUxMetrics();
  final autoSummary = await _readAutonomousSummary();
  final funnel = _buildFunnel(uxMetrics, autoSummary);

  final dropoff = _findDropoff(funnel);
  final overallConversion = _overallConversion(funnel);

  await _withReportsWritable(() async {
    await _writeSummary(
      uxMetrics: uxMetrics,
      autoSummary: autoSummary,
      funnel: funnel,
      dropoffTransition: dropoff,
      overallConversion: overallConversion,
    );
    await _appendTelemetry(
      conversionRate: overallConversion ?? 0.0,
      dropoffStage: dropoff?.label ?? 'data_missing',
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  final conversionLabel = overallConversion == null
      ? 'n/a'
      : overallConversion.toStringAsFixed(3);
  stdout.writeln(
    'onboarding_flow_analyzer: conversion=$conversionLabel '
    'dropoff=${dropoff?.label ?? 'n/a'}.',
  );
}

Future<_UxMetricsSnapshot> _readUxMetrics() async {
  for (final path in _uxMetricPaths) {
    final file = File(path);
    if (!await file.exists()) continue;
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        final timestampRaw = data['timestamp']?.toString();
        final timestamp = timestampRaw == null
            ? null
            : DateTime.tryParse(timestampRaw);
        return _UxMetricsSnapshot(path: path, timestamp: timestamp, data: data);
      }
    } catch (_) {
      // Fall through and keep looking for another source.
    }
  }
  return const _UxMetricsSnapshot(path: null, timestamp: null, data: {});
}

Future<_AutoSummaryData> _readAutonomousSummary() async {
  for (final path in _autoSummaryPaths) {
    final file = File(path);
    if (!await file.exists()) continue;
    try {
      final lines = await file.readAsLines();
      return _AutoSummaryData.fromLines(path, lines);
    } catch (_) {
      return const _AutoSummaryData.empty();
    }
  }
  return const _AutoSummaryData.empty();
}

List<_FunnelStage> _buildFunnel(
  _UxMetricsSnapshot metrics,
  _AutoSummaryData autoSummary,
) {
  final candidates = <Map<String, dynamic>>[metrics.data];
  for (final key in ['funnel', 'onboarding', 'metrics']) {
    final nested = metrics.data[key];
    if (nested is Map<String, dynamic>) {
      candidates.add(nested);
    }
  }

  double? _extract(List<String> keys) {
    for (final map in candidates) {
      for (final key in keys) {
        if (!map.containsKey(key)) continue;
        final value = map[key];
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
    }
    return null;
  }

  final stages = <_FunnelStageDefinition>[
    const _FunnelStageDefinition('Install', [
      'installs',
      'install_count',
      'installs_total',
    ]),
    const _FunnelStageDefinition('First Lesson', [
      'first_lessons',
      'first_lesson',
      'lesson_starts',
      'firstLessonCount',
    ]),
    const _FunnelStageDefinition('First Win', [
      'first_wins',
      'first_win',
      'firstWinCount',
      'first_wins_count',
    ]),
    const _FunnelStageDefinition('Weekly Return', [
      'weekly_returners',
      'weekly_return',
      'week1_returns',
      'weekly_active_users',
    ]),
  ];

  final results = <_FunnelStage>[];
  for (final stage in stages) {
    var value = _extract(stage.keys);
    if (value == null) {
      if (stage.label == 'Install') {
        value = autoSummary.latestDau?.toDouble();
      } else if (stage.label == 'Weekly Return') {
        value = autoSummary.latestWau?.toDouble();
      }
    }
    results.add(_FunnelStage(label: stage.label, count: value));
  }

  double? previousCount;
  for (final stage in results) {
    if (stage.count == null || previousCount == null || previousCount == 0) {
      stage.conversion = stage.count != null && previousCount == null
          ? 1.0
          : null;
    } else {
      stage.conversion = (stage.count! / previousCount).clamp(0.0, 1.0);
    }
    previousCount = stage.count ?? previousCount;
  }

  return results;
}

_DropoffTransition? _findDropoff(List<_FunnelStage> stages) {
  _DropoffTransition? result;
  for (var i = 1; i < stages.length; i++) {
    final current = stages[i];
    final prev = stages[i - 1];
    final conversion = current.conversion;
    if (conversion == null) {
      continue;
    }
    if (result == null || conversion < result.conversion) {
      result = _DropoffTransition(
        label: '${prev.label}→${current.label}',
        conversion: conversion,
      );
    }
  }
  return result;
}

double? _overallConversion(List<_FunnelStage> stages) {
  if (stages.length < 2) return null;
  final first = stages.first.count;
  final last = stages.last.count;
  if (first == null || first == 0 || last == null) return null;
  return (last / first).clamp(0.0, 1.0);
}

Future<void> _writeSummary({
  required _UxMetricsSnapshot uxMetrics,
  required _AutoSummaryData autoSummary,
  required List<_FunnelStage> funnel,
  required _DropoffTransition? dropoffTransition,
  required double? overallConversion,
}) async {
  final buffer = StringBuffer()
    ..writeln('ONBOARDING FLOW SUMMARY')
    ..writeln('=======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('UX metrics source: ${uxMetrics.path ?? 'unavailable'}')
    ..writeln(
      'Autonomous telemetry source: ${autoSummary.path ?? 'unavailable'}',
    )
    ..writeln();

  buffer
    ..writeln('Conversion Funnel')
    ..writeln('-----------------')
    ..writeln('| Stage | Users | Conversion vs prev |')
    ..writeln('|-------|-------|--------------------|');
  for (final stage in funnel) {
    final usersLabel = stage.count == null
        ? 'n/a'
        : stage.count!.toStringAsFixed(stage.count! >= 100 ? 0 : 1);
    final conversionLabel = stage.conversion == null
        ? 'n/a'
        : '${(stage.conversion! * 100).toStringAsFixed(1)}%';
    buffer.writeln('| ${stage.label} | $usersLabel | $conversionLabel |');
  }
  buffer.writeln();

  final dropoffLabel = dropoffTransition == null
      ? 'Insufficient data'
      : '${dropoffTransition.label} (${(dropoffTransition.conversion * 100).toStringAsFixed(1)}%)';
  final conversionLabel = overallConversion == null
      ? 'n/a'
      : '${(overallConversion * 100).toStringAsFixed(1)}%';

  buffer
    ..writeln('Observations')
    ..writeln('------------')
    ..writeln('- First-session drop-off: $dropoffLabel')
    ..writeln('- Overall install→weekly return conversion: $conversionLabel');

  if (autoSummary.retention != null) {
    buffer.writeln(
      '- Next-day retention: ${(autoSummary.retention! * 100).toStringAsFixed(1)}%',
    );
  } else {
    buffer.writeln('- Next-day retention: n/a');
  }
  if (autoSummary.avgSessionSeconds != null) {
    buffer.writeln(
      '- Average session duration: ${autoSummary.avgSessionSeconds!.toStringAsFixed(1)} sec',
    );
  } else {
    buffer.writeln('- Average session duration: n/a');
  }
  if (autoSummary.uxTrendIndex != null) {
    buffer.writeln(
      '- UX trend index: ${autoSummary.uxTrendIndex!.toStringAsFixed(3)}',
    );
  } else {
    buffer.writeln('- UX trend index: n/a');
  }

  buffer
    ..writeln()
    ..writeln('Telemetry Snapshot')
    ..writeln('------------------');
  buffer.writeln('- DAU points captured: ${autoSummary.dauCounts.length}');
  buffer.writeln('- WAU points captured: ${autoSummary.wauCounts.length}');
  if (autoSummary.latestDau != null) {
    buffer.writeln('- Latest DAU: ${autoSummary.latestDau}');
  }
  if (autoSummary.latestWau != null) {
    buffer.writeln('- Latest WAU: ${autoSummary.latestWau}');
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double conversionRate,
  required String dropoffStage,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'onboarding_flow_analyzed',
    'timestamp': DateTime.now().toIso8601String(),
    'conversion_rate': conversionRate,
    'dropoff_stage': dropoffStage,
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
      'onboarding_flow_analyzer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _UxMetricsSnapshot {
  const _UxMetricsSnapshot({
    required this.path,
    required this.timestamp,
    required this.data,
  });

  final String? path;
  final DateTime? timestamp;
  final Map<String, dynamic> data;
}

class _AutoSummaryData {
  const _AutoSummaryData({
    required this.path,
    required this.generated,
    required this.retention,
    required this.avgSessionSeconds,
    required this.uxTrendIndex,
    required this.dauCounts,
    required this.wauCounts,
  });

  const _AutoSummaryData.empty()
    : this(
        path: null,
        generated: null,
        retention: null,
        avgSessionSeconds: null,
        uxTrendIndex: null,
        dauCounts: const {},
        wauCounts: const {},
      );

  factory _AutoSummaryData.fromLines(String path, List<String> lines) {
    DateTime? generated;
    double? retention;
    double? avgSession;
    double? uxTrendIndex;
    final dau = <String, int>{};
    final wau = <String, int>{};

    var currentTable = _AutoTable.none;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.startsWith('Generated:')) {
        final value = trimmed.substring('Generated:'.length).trim();
        generated = DateTime.tryParse(value);
        continue;
      }
      if (trimmed.contains('Daily Active Users')) {
        currentTable = _AutoTable.dau;
        continue;
      }
      if (trimmed.contains('Weekly Active Users')) {
        currentTable = _AutoTable.wau;
        continue;
      }
      if (trimmed.isEmpty) {
        currentTable = _AutoTable.none;
        continue;
      }
      if (trimmed.startsWith('Next-day retention:')) {
        final value = trimmed.split(':').last.trim();
        retention = double.tryParse(value);
        continue;
      }
      if (trimmed.startsWith('Average Session Duration')) {
        if (i + 1 < lines.length) {
          final valueLine = lines[i + 1].trim();
          avgSession = double.tryParse(
            valueLine.replaceAll(RegExp(r'[^0-9\.]'), ''),
          );
        }
        continue;
      }
      if (trimmed.startsWith('UX Trend Index')) {
        if (i + 1 < lines.length) {
          final valueLine = lines[i + 1].trim();
          uxTrendIndex = double.tryParse(valueLine);
        }
        continue;
      }

      final tableMatch = _tableRow.firstMatch(trimmed);
      if (tableMatch != null) {
        final date = tableMatch.group(1)!;
        final count = int.tryParse(tableMatch.group(2)!);
        if (count != null) {
          if (currentTable == _AutoTable.dau) {
            dau[date] = count;
          } else if (currentTable == _AutoTable.wau) {
            wau[date] = count;
          }
        }
      }
    }

    return _AutoSummaryData(
      path: path,
      generated: generated,
      retention: retention,
      avgSessionSeconds: avgSession,
      uxTrendIndex: uxTrendIndex,
      dauCounts: dau,
      wauCounts: wau,
    );
  }

  final String? path;
  final DateTime? generated;
  final double? retention;
  final double? avgSessionSeconds;
  final double? uxTrendIndex;
  final Map<String, int> dauCounts;
  final Map<String, int> wauCounts;

  int? get latestDau => _latestValue(dauCounts);
  int? get latestWau => _latestValue(wauCounts);

  static int? _latestValue(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    final keys = counts.keys.toList()..sort();
    return counts[keys.last];
  }
}

class _FunnelStageDefinition {
  const _FunnelStageDefinition(this.label, this.keys);

  final String label;
  final List<String> keys;
}

class _FunnelStage {
  _FunnelStage({required this.label, required this.count});

  final String label;
  final double? count;
  double? conversion;
}

class _DropoffTransition {
  const _DropoffTransition({required this.label, required this.conversion});

  final String label;
  final double conversion;
}

enum _AutoTable { none, dau, wau }

final RegExp _tableRow = RegExp(
  r'\|\s*(\d{4}-\d{2}-\d{2})\s*\|\s*([0-9]+)\s*\|',
);
