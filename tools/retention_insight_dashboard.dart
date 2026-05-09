import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionSummaryPath =
    '$_reportsDir/retention_campaign_summary.json';
const String _marketingSummaryPath =
    '$_reportsDir/marketing_onboarding_summary.json';
const String _telemetrySummaryPath =
    '$_reportsDir/telemetry_health_sweep_summary.json';
const String _summaryTextPath = '$_reportsDir/retention_insight_summary.txt';
const String _summaryJsonPath = '$_reportsDir/retention_insight_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _minScore = 85.0;

Future<void> main(List<String> args) async {
  final dashboard = RetentionInsightDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionInsightDashboard {
  Future<bool> run() async {
    final retention = await _readJsonDouble(
      _retentionSummaryPath,
      'retention_index',
    );
    final retention7 = await _readJsonDouble(
      _retentionSummaryPath,
      'active_last_7d',
    );
    final retention30 = await _readJsonDouble(
      _retentionSummaryPath,
      'active_last_30d',
    );
    final conversion = await _readJsonDouble(
      _marketingSummaryPath,
      'conversion_index',
    );
    final coverage = await _readJsonDouble(
      _telemetrySummaryPath,
      'coverage_ratio',
    );

    final baseRetention = retention > 0
        ? retention
        : retention30 == 0
        ? 0.0
        : (retention7 / retention30) * 100;
    final blended = ((baseRetention + conversion) / 2).clamp(0, 100).toDouble();
    final score = blended * (coverage / 100).clamp(0, 1).toDouble();
    final verdict = score >= _minScore ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      retention: baseRetention,
      conversion: conversion,
      coverage: coverage,
      score: score,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      retention: baseRetention,
      conversion: conversion,
      coverage: coverage,
      score: score,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(score, verdict);
    });

    if (score < _minScore) {
      stderr.writeln(
        'User Retention Score ${score.toStringAsFixed(2)} below 85%.',
      );
    }

    return score >= _minScore;
  }

  Future<double> _readJsonDouble(String path, String field) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    try {
      final dynamic decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final value = decoded[field];
        if (value is num) {
          return value.toDouble();
        }
      }
    } catch (_) {
      return 0;
    }
    return 0;
  }

  String _buildTextSummary({
    required double retention,
    required double conversion,
    required double coverage,
    required double score,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('RETENTION INSIGHT SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention (7d/30d blend): ${retention.toStringAsFixed(2)}%')
      ..writeln('Conversion index: ${conversion.toStringAsFixed(2)}%')
      ..writeln('Telemetry coverage: ${coverage.toStringAsFixed(2)}%')
      ..writeln('User Retention Score: ${score.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minScore.toStringAsFixed(2)}%')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double retention,
    required double conversion,
    required double coverage,
    required double score,
    required String verdict,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'retention': retention,
      'conversion': conversion,
      'telemetry_coverage': coverage,
      'user_retention_score': score,
      'threshold': _minScore,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(double score, String verdict) async {
    final payload = <String, Object?>{
      'event': 'retention_insight_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'user_retention_score': score,
      'threshold': _minScore,
      'verdict': verdict,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
