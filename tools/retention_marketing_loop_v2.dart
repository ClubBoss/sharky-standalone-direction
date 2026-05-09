import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/retention_marketing_loop_v2_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/retention_marketing_loop_v2_summary.json';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final loop = RetentionMarketingLoopV2();
  final ok = await loop.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionMarketingLoopV2 {
  Future<bool> run() async {
    final retention = await _readRetentionScore();
    final conversion = await _readConversionScore();
    final reaction = await _readReactionScore();

    if (retention == null || conversion == null || reaction == null) {
      stderr.writeln('Missing retention/marketing/reaction inputs.');
      return false;
    }

    final index = (0.4 * retention) + (0.35 * conversion) + (0.25 * reaction);
    final engaged = index >= _threshold;

    final summaryText = _buildText(
      retention: retention,
      conversion: conversion,
      reaction: reaction,
      index: index,
      verdict: engaged ? 'PASS' : 'FAIL',
    );
    final summaryJson = _buildJson(
      retention: retention,
      conversion: conversion,
      reaction: reaction,
      index: index,
      verdict: engaged ? 'PASS' : 'FAIL',
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(retention, conversion, reaction, index, engaged);
    });

    if (!engaged) {
      stderr.writeln(
        'Engagement Cycle Index ${index.toStringAsFixed(4)} below threshold.',
      );
    }
    return engaged;
  }

  Future<double?> _readRetentionScore() async {
    final file = File('$_reportsDir/retention_insight_summary.json');
    if (!await file.exists()) return null;
    final data = json.decode(await file.readAsString());
    if (data is Map<String, Object?>) {
      final value =
          data['user_retention_score'] ??
          data['retention'] ??
          data['retention_score'];
      return _normalize(value);
    }
    return null;
  }

  Future<double?> _readConversionScore() async {
    final file = File(
      '$_reportsDir/marketing_onboarding_qa_final_summary.json',
    );
    if (!await file.exists()) return null;
    final data = json.decode(await file.readAsString());
    if (data is Map<String, Object?>) {
      final value = data['marketing_onboarding_score'];
      return _normalize(value);
    }
    return null;
  }

  Future<double?> _readReactionScore() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    final lines = await file.readAsLines();
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final payload = json.decode(line) as Map<String, Object?>;
        if (payload['event'] == 'persona_reactions_completed') {
          final celebrate = _asDouble(payload['celebrate_count']) ?? 0.0;
          final encourage = _asDouble(payload['encourage_count']) ?? 0.0;
          final think = _asDouble(payload['thinking_count']) ?? 0.0;
          final total = celebrate + encourage + think;
          if (total == 0) return 0.0;
          final score = (celebrate + (encourage * 0.5)) / total;
          return score.clamp(0, 1);
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  String _buildText({
    required double retention,
    required double conversion,
    required double reaction,
    required double index,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('RETENTION MARKETING LOOP v2 SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention Score: ${(retention * 100).toStringAsFixed(2)}%')
      ..writeln('Conversion Score: ${(conversion * 100).toStringAsFixed(2)}%')
      ..writeln('Reaction Score: ${(reaction * 100).toStringAsFixed(2)}%')
      ..writeln('Engagement Cycle Index: ${(index * 100).toStringAsFixed(2)}%')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson({
    required double retention,
    required double conversion,
    required double reaction,
    required double index,
    required String verdict,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'retention_score': retention,
      'conversion_score': conversion,
      'reaction_score': reaction,
      'engagement_cycle_index': index,
      'threshold': _threshold,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double retention,
    double conversion,
    double reaction,
    double index,
    bool success,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_marketing_v2_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_score': retention,
      'conversion_score': conversion,
      'reaction_score': reaction,
      'engagement_cycle_index': index,
      'verdict': success ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _normalize(Object? value) {
  if (value is num) {
    return (value / 100).clamp(0.0, 1.0).toDouble();
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      return (parsed / 100).clamp(0.0, 1.0).toDouble();
    }
  }
  return null;
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
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
