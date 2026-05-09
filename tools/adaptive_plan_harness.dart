import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_plan_harness_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/adaptive_plan_harness_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_plan_harness_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = AdaptivePlanHarnessService();
  Map<String, List<AdaptivePlanEntry>> groups;
  try {
    groups = await service.build();
  } catch (error) {
    stderr.writeln('Adaptive Plan Harness failed: $error');
    exitCode = 2;
    return;
  }

  final ordered = <AdaptivePlanEntry>[]
    ..addAll(groups['priority'] ?? [])
    ..addAll(groups['mid'] ?? [])
    ..addAll(groups['fallback'] ?? []);
  final avgScore = ordered.isEmpty
      ? 0.0
      : ordered.map((e) => e.score).reduce((a, b) => a + b) / ordered.length;

  final text = _buildText(groups, ordered, avgScore);
  final json = _buildJson(groups, ordered, avgScore);

  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(
      ordered.length,
      groups['priority']?.length ?? 0,
      avgScore,
    );
  });
}

String _buildText(
  Map<String, List<AdaptivePlanEntry>> groups,
  List<AdaptivePlanEntry> ordered,
  double avgScore,
) {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE PLAN HARNESS SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Modules: ${ordered.length}')
    ..writeln('Priority count: ${groups['priority']?.length ?? 0}')
    ..writeln('Average score: ${(avgScore * 100).toStringAsFixed(2)}%');
  for (final entry in ordered) {
    buffer
      ..writeln('- ${entry.module} [${entry.group}]')
      ..writeln('  score: ${entry.score.toStringAsFixed(3)}')
      ..writeln('  severity: ${entry.severity}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(
  Map<String, List<AdaptivePlanEntry>> groups,
  List<AdaptivePlanEntry> ordered,
  double avgScore,
) => {
  'generated_at': DateTime.now().toIso8601String(),
  'module_count': ordered.length,
  'priority_count': groups['priority']?.length ?? 0,
  'avg_score': avgScore,
  'groups': {
    'priority': groups['priority']?.map((e) => e.toJson()).toList() ?? [],
    'mid': groups['mid']?.map((e) => e.toJson()).toList() ?? [],
    'fallback': groups['fallback']?.map((e) => e.toJson()).toList() ?? [],
    'all': ordered.map((e) => e.toJson()).toList(),
  },
};

Future<void> _appendTelemetry(
  int moduleCount,
  int priorityCount,
  double avgScore,
) async {
  final payload = <String, Object?>{
    'event': 'adaptive_plan_harness_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'module_count': moduleCount,
    'priority_count': priorityCount,
    'avg_score': avgScore,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
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
