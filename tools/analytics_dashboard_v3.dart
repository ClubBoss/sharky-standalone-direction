import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

Future<void> main(List<String> args) async {
  final unified = await _readJson([
    'tools/_reports/unified_telemetry_summary.json',
    'release/public_beta_v2/unified_telemetry_summary.json',
  ]);
  final economy = await _readJson(['economy_tuning.json']);
  final monetization = await _readJson([
    'tools/_reports/monetization_projection.json',
  ]);
  final regression = await _readJson([
    'tools/_reports/beta_regression_summary.json',
  ]);

  final xpSeries = _resolveSeries(
    unified,
    candidates: ['xp_gain_history', 'xp_history', 'xp_gain', 'xp'],
  );
  final retentionSeries = _resolveSeries(
    unified,
    candidates: ['retention_history', 'retention', 'retention_rate'],
  );
  final monetizationSeries = _resolveSeries(
    monetization,
    candidates: ['stability_history', 'roi_history', 'roi', 'ltv'],
  );

  final xpAvg7 = _rollingAverage(xpSeries, 7);
  final xpAvg14 = _rollingAverage(xpSeries, 14);
  final retentionAvg7 = _rollingAverage(retentionSeries, 7);
  final retentionAvg14 = _rollingAverage(retentionSeries, 14);
  final monetizationAvg7 = _rollingAverage(monetizationSeries, 7);
  final monetizationAvg14 = _rollingAverage(monetizationSeries, 14);

  final summary = <String, Object?>{
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'xp_gain_avg_7': xpAvg7,
    'xp_gain_avg_14': xpAvg14,
    'retention_avg_7': retentionAvg7,
    'retention_avg_14': retentionAvg14,
    'monetization_stability_avg_7': monetizationAvg7,
    'monetization_stability_avg_14': monetizationAvg14,
    'source': {
      'unified_telemetry': unified,
      'economy_tuning': economy,
      'monetization_projection': monetization,
      'beta_regression': regression,
    },
  };

  final outputDir = Directory('release/analytics_dashboard');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  final outputFile = File('${outputDir.path}/analytics_data.json');
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(summary),
  );

  _printSummary(
    xpAvg7: xpAvg7,
    xpAvg14: xpAvg14,
    retentionAvg7: retentionAvg7,
    retentionAvg14: retentionAvg14,
    monetizationAvg7: monetizationAvg7,
    monetizationAvg14: monetizationAvg14,
  );

  unawaited(
    FirebaseLiteTelemetryService.instance.logEvent(
      'analytics_dashboard_generated',
      params: <String, Object?>{
        'xp_avg_7': xpAvg7,
        'xp_avg_14': xpAvg14,
        'retention_avg_7': retentionAvg7,
        'retention_avg_14': retentionAvg14,
        'monetization_avg_7': monetizationAvg7,
        'monetization_avg_14': monetizationAvg14,
      },
    ),
  );
}

Future<Map<String, dynamic>> _readJson(List<String> paths) async {
  for (final path in paths) {
    final file = File(path);
    if (!await file.exists()) {
      continue;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) continue;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore malformed files; continue to next fallback.
    }
  }
  return const {};
}

List<double> _resolveSeries(
  Map<String, dynamic> root, {
  required List<String> candidates,
}) {
  final series = _findSeries(root, candidates);
  if (series.isNotEmpty) {
    return series;
  }
  return const [];
}

List<double> _findSeries(
  dynamic node,
  List<String> candidates, [
  int depth = 0,
]) {
  if (depth > 8) {
    return const [];
  }
  if (node is Map) {
    for (final entry in node.entries) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;
      final match = candidates.any(key.contains);
      if (match) {
        final extracted = _extractNumbers(value);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
      final nested = _findSeries(value, candidates, depth + 1);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
  } else if (node is List) {
    for (final item in node) {
      final result = _findSeries(item, candidates, depth + 1);
      if (result.isNotEmpty) {
        return result;
      }
    }
  }
  return const [];
}

List<double> _extractNumbers(dynamic value) {
  if (value is List) {
    final numbers = <double>[];
    for (final item in value) {
      final numeric = _asDouble(item);
      if (numeric != null) {
        numbers.add(numeric);
      } else if (item is Map) {
        final nested = _extractNumbers(item.values.toList());
        numbers.addAll(nested);
      }
    }
    return numbers;
  } else if (value is Map) {
    return _extractNumbers(value.values.toList());
  } else {
    final numeric = _asDouble(value);
    return numeric != null ? <double>[numeric] : const [];
  }
}

double? _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

double _rollingAverage(List<double> series, int window) {
  if (series.isEmpty) {
    return 0;
  }
  final slice = series.length <= window
      ? series
      : series.sublist(series.length - window);
  final total = slice.fold<double>(0, (sum, value) => sum + value);
  return double.parse((total / slice.length).toStringAsFixed(2));
}

void _printSummary({
  required double xpAvg7,
  required double xpAvg14,
  required double retentionAvg7,
  required double retentionAvg14,
  required double monetizationAvg7,
  required double monetizationAvg14,
}) {
  stdout.writeln('Analytics Dashboard Summary');
  stdout.writeln('===========================');
  stdout.writeln('XP Gain Avg (7d): $xpAvg7');
  stdout.writeln('XP Gain Avg (14d): $xpAvg14');
  stdout.writeln('Retention Avg (7d): $retentionAvg7');
  stdout.writeln('Retention Avg (14d): $retentionAvg14');
  stdout.writeln('Monetization Stability Avg (7d): $monetizationAvg7');
  stdout.writeln('Monetization Stability Avg (14d): $monetizationAvg14');
}
