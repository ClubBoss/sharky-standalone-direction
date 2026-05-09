import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final dashboard = _PostlaunchDashboard();
  final result = await dashboard.build();
  result.printTable();
  await result.writeReport();
  await result.emitTelemetry();
  stdout.writeln(
    'Dashboard written to ${result.reportPath} '
    '(${result.missingSources.isEmpty ? 'all sources present' : 'missing ${result.missingSources.length} source(s)'})',
  );
  if (result.missingSources.isNotEmpty) {
    stdout.writeln('Missing sources:');
    for (final source in result.missingSources) {
      stdout.writeln('  - $source');
    }
  }
}

class _PostlaunchDashboard {
  _PostlaunchDashboard({
    String? marketingPath,
    String? stabilityPath,
    String? uxTelemetryPath,
    String? outputPath,
    String? telemetryPath,
  }) : marketingPath =
           marketingPath ?? 'release/_reports/marketing_analytics_summary.txt',
       stabilityPath =
           stabilityPath ?? 'release/_reports/stability_scaling_audit.txt',
       uxTelemetryPath =
           uxTelemetryPath ?? 'release/_reports/ux_telemetry_tuning.txt',
       outputPath = outputPath ?? 'release/_reports/postlaunch_dashboard.txt',
       telemetryPath = telemetryPath ?? 'release/_reports/telemetry.jsonl';

  final String marketingPath;
  final String stabilityPath;
  final String uxTelemetryPath;
  final String outputPath;
  final String telemetryPath;

  Future<_DashboardResult> build() async {
    final missingSources = <String>[];
    final marketingText = await _readOptional(marketingPath, missingSources);
    final stabilityText = await _readOptional(stabilityPath, missingSources);
    final uxText = await _readOptional(uxTelemetryPath, missingSources);

    final marketing = _MarketingMetrics.fromText(marketingText);
    final stability = _StabilityMetrics.fromText(stabilityText);
    final ux = _UxMetrics.fromText(uxText);

    final metrics = _composeMetrics(
      marketing: marketing,
      stability: stability,
      ux: ux,
    );

    return _DashboardResult(
      metrics: metrics,
      missingSources: missingSources,
      reportPath: outputPath,
      telemetryPath: telemetryPath,
    );
  }

  Future<String?> _readOptional(
    String path,
    List<String> missingSources,
  ) async {
    final file = File(path);
    if (!file.existsSync()) {
      missingSources.add(path);
      return null;
    }
    return file.readAsString();
  }

  List<_Metric> _composeMetrics({
    required _MarketingMetrics marketing,
    required _StabilityMetrics stability,
    required _UxMetrics ux,
  }) {
    final retentionPercent = ux.retentionIndex != null
        ? ux.retentionIndex! * 100
        : marketing.retentionDelta != null
        ? (marketing.retentionDelta! + 1) * 100
        : null;
    final crashFree =
        stability.crashFreePercent ??
        (stability.stabilityScore != null
            ? stability.stabilityScore! * 100
            : null);

    return <_Metric>[
      _Metric(
        name: 'DAU',
        value: marketing.dailyActiveUsers?.toDouble(),
        display: marketing.dailyActiveUsers?.toString() ?? 'n/a',
        status: _statusFor(
          metric: _MetricKind.dau,
          value: marketing.dailyActiveUsers?.toDouble(),
        ),
      ),
      _Metric(
        name: 'Retention %',
        value: retentionPercent,
        display: retentionPercent != null
            ? '${retentionPercent.toStringAsFixed(2)}%'
            : 'n/a',
        status: _statusFor(
          metric: _MetricKind.retention,
          value: retentionPercent,
        ),
      ),
      _Metric(
        name: 'Crash-Free %',
        value: crashFree,
        display: crashFree != null ? '${crashFree.toStringAsFixed(2)}%' : 'n/a',
        status: _statusFor(metric: _MetricKind.crashFree, value: crashFree),
      ),
      _Metric(
        name: 'AI Accuracy %',
        value: ux.aiAccuracyPercent,
        display: ux.aiAccuracyPercent != null
            ? '${ux.aiAccuracyPercent!.toStringAsFixed(2)}%'
            : 'n/a',
        status: _statusFor(
          metric: _MetricKind.aiAccuracy,
          value: ux.aiAccuracyPercent,
        ),
      ),
      _Metric(
        name: 'Conversion %',
        value: marketing.conversionRatePercent,
        display: marketing.conversionRatePercent != null
            ? '${marketing.conversionRatePercent!.toStringAsFixed(2)}%'
            : 'n/a',
        status: _statusFor(
          metric: _MetricKind.conversion,
          value: marketing.conversionRatePercent,
        ),
      ),
    ];
  }
}

class _DashboardResult {
  _DashboardResult({
    required this.metrics,
    required this.missingSources,
    required this.reportPath,
    required this.telemetryPath,
  });

  final List<_Metric> metrics;
  final List<String> missingSources;
  final String reportPath;
  final String telemetryPath;

  void printTable() {
    final rows = metrics
        .map(
          (metric) => <String>[
            metric.name,
            metric.display,
            '[${metric.status}]',
          ],
        )
        .toList();
    final widths = <int>[0, 0, 0];
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }
    final border =
        '+-${'-' * widths[0]}-+-${'-' * widths[1]}-+-${'-' * widths[2]}-+';
    stdout.writeln(border);
    stdout.writeln(
      '| ${'Metric'.padRight(widths[0])} | '
      '${'Value'.padRight(widths[1])} | '
      '${'Status'.padRight(widths[2])} |',
    );
    stdout.writeln(border);
    for (final row in rows) {
      stdout.writeln(
        '| ${row[0].padRight(widths[0])} | '
        '${row[1].padRight(widths[1])} | '
        '${row[2].padRight(widths[2])} |',
      );
    }
    stdout.writeln(border);
  }

  Future<void> writeReport() async {
    final buffer = StringBuffer()
      ..writeln('Postlaunch Retention & Telemetry Dashboard')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('');
    for (final metric in metrics) {
      buffer.writeln(
        '${metric.name}: ${metric.display} (status: ${metric.status})',
      );
    }
    if (missingSources.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Missing Sources:');
      for (final source in missingSources) {
        buffer.writeln('  - $source');
      }
    }
    final file = File(reportPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
  }

  Future<void> emitTelemetry() async {
    final metricsMap = <String, Object?>{};
    final statusesMap = <String, String>{};
    for (final metric in metrics) {
      metricsMap[metric.name] = metric.value;
      statusesMap[metric.name] = metric.status;
    }
    final payload = <String, Object?>{
      'event': TelemetryEvents.postlaunchDashboardCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'metrics': metricsMap,
      'statuses': statusesMap,
      'missing_sources': missingSources,
    };
    final log = File(telemetryPath);
    await log.parent.create(recursive: true);
    await log.writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _Metric {
  _Metric({
    required this.name,
    required this.value,
    required this.display,
    required this.status,
  });

  final String name;
  final double? value;
  final String display;
  final String status;
}

enum _MetricKind { dau, retention, crashFree, aiAccuracy, conversion }

String _statusFor({required _MetricKind metric, required double? value}) {
  if (value == null) {
    return 'GREY';
  }
  final config = _thresholds[metric]!;
  if (value >= config.green) {
    return 'GREEN';
  }
  if (value >= config.orange) {
    return 'ORANGE';
  }
  return 'RED';
}

class _Threshold {
  const _Threshold({required this.green, required this.orange});

  final double green;
  final double orange;
}

const Map<_MetricKind, _Threshold> _thresholds = <_MetricKind, _Threshold>{
  _MetricKind.dau: _Threshold(green: 1000, orange: 250),
  _MetricKind.retention: _Threshold(green: 90, orange: 75),
  _MetricKind.crashFree: _Threshold(green: 99.5, orange: 98.0),
  _MetricKind.aiAccuracy: _Threshold(green: 80, orange: 65),
  _MetricKind.conversion: _Threshold(green: 5, orange: 2),
};

class _MarketingMetrics {
  const _MarketingMetrics({
    required this.dailyActiveUsers,
    required this.conversionRatePercent,
    required this.retentionDelta,
  });

  factory _MarketingMetrics.fromText(String? text) {
    if (text == null) {
      return const _MarketingMetrics(
        dailyActiveUsers: null,
        conversionRatePercent: null,
        retentionDelta: null,
      );
    }
    final dau = _firstIntMatch(
      RegExp(r'Daily Active Users:\s*([0-9,]+)', caseSensitive: false),
      text,
    );
    final conversion = _firstDoubleMatch(
      RegExp(r'Conversion Rate:\s*([0-9.+-]+)%?', caseSensitive: false),
      text,
    );
    final retentionDelta = _firstDoubleMatch(
      RegExp(r'Retention Delta:\s*([+|-]?[0-9.]+)', caseSensitive: false),
      text,
    );
    return _MarketingMetrics(
      dailyActiveUsers: dau,
      conversionRatePercent: conversion,
      retentionDelta: retentionDelta,
    );
  }

  final int? dailyActiveUsers;
  final double? conversionRatePercent;
  final double? retentionDelta;
}

class _StabilityMetrics {
  const _StabilityMetrics({
    required this.crashFreePercent,
    required this.stabilityScore,
  });

  factory _StabilityMetrics.fromText(String? text) {
    if (text == null) {
      return const _StabilityMetrics(
        crashFreePercent: null,
        stabilityScore: null,
      );
    }
    final crashFreeRaw = _firstDoubleMatch(
      RegExp(r'Crash[-\s]?Free[:=]\s*([0-9.]+)%?', caseSensitive: false),
      text,
    );
    final stability = _firstDoubleMatch(
      RegExp(r'stability_score\s*=\s*([0-9.]+)', caseSensitive: false),
      text,
    );
    final crashFree = crashFreeRaw == null
        ? null
        : (crashFreeRaw <= 1 ? crashFreeRaw * 100 : crashFreeRaw);
    return _StabilityMetrics(
      crashFreePercent: crashFree,
      stabilityScore: stability,
    );
  }

  final double? crashFreePercent;
  final double? stabilityScore;
}

class _UxMetrics {
  const _UxMetrics({
    required this.retentionIndex,
    required this.aiAccuracyPercent,
  });

  factory _UxMetrics.fromText(String? text) {
    if (text == null) {
      return const _UxMetrics(retentionIndex: null, aiAccuracyPercent: null);
    }
    final retention =
        _firstDoubleMatch(
          RegExp(r'RetentionIndex:\s*([0-9.]+)', caseSensitive: false),
          text,
        ) ??
        _firstDoubleMatch(
          RegExp(r'Value:\s*([0-9.]+)', caseSensitive: false),
          text,
        );
    final aiAccuracy = _firstDoubleMatch(
      RegExp(r'Avg accuracy:\s*([0-9.]+)%?', caseSensitive: false),
      text,
    );
    return _UxMetrics(retentionIndex: retention, aiAccuracyPercent: aiAccuracy);
  }

  final double? retentionIndex;
  final double? aiAccuracyPercent;
}

int? _firstIntMatch(RegExp exp, String text) {
  final match = exp.firstMatch(text);
  if (match == null) return null;
  final raw = match.group(1)?.replaceAll(',', '');
  return int.tryParse(raw ?? '');
}

double? _firstDoubleMatch(RegExp exp, String text) {
  final match = exp.firstMatch(text);
  if (match == null) return null;
  final raw = match.group(1);
  return double.tryParse(raw ?? '');
}
