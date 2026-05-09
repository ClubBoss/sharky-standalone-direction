import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/planner_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/planner_bridge_summary.txt';
const String _summaryJsonPath = '$_reportsDir/planner_bridge_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlannerBridgeService();
  Map<String, List<PlannerRecommendation>> groups;
  try {
    groups = await service.build();
  } catch (error) {
    stderr.writeln('Planner Bridge failed: $error');
    exitCode = 2;
    return;
  }
  final ordered = groups['all'] ?? [];
  final avgReinforcement = ordered.isEmpty
      ? 0.0
      : ordered.map((p) => p.score).reduce((a, b) => a + b) / ordered.length;

  final text = _buildText(groups, ordered, avgReinforcement);
  final json = _buildJson(groups, ordered, avgReinforcement);

  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(
      ordered.length,
      groups['priority']?.length ?? 0,
      avgReinforcement,
    );
  });
}

String _buildText(
  Map<String, List<PlannerRecommendation>> groups,
  List<PlannerRecommendation> ordered,
  double avgReinforcement,
) {
  final buffer = StringBuffer()
    ..writeln('PLANNER BRIDGE SUMMARY')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Modules: ${ordered.length}')
    ..writeln('Priority modules: ${groups['priority']?.length ?? 0}')
    ..writeln(
      'Average reinforcement: ${(avgReinforcement * 100).toStringAsFixed(2)}%',
    );
  for (final rec in ordered) {
    buffer
      ..writeln('- ${rec.module} [${rec.group}]')
      ..writeln('  score: ${rec.score.toStringAsFixed(3)}')
      ..writeln('  severity: ${rec.severity}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(
  Map<String, List<PlannerRecommendation>> groups,
  List<PlannerRecommendation> ordered,
  double avgReinforcement,
) => {
  'generated_at': DateTime.now().toIso8601String(),
  'module_count': ordered.length,
  'priority_count': groups['priority']?.length ?? 0,
  'avg_reinforcement_score': avgReinforcement,
  'groups': {
    'priority': groups['priority']?.map((m) => m.toJson()).toList() ?? [],
    'mid': groups['mid']?.map((m) => m.toJson()).toList() ?? [],
    'fallback': groups['fallback']?.map((m) => m.toJson()).toList() ?? [],
    'all': ordered.map((m) => m.toJson()).toList(),
  },
};

Future<void> _appendTelemetry(
  int moduleCount,
  int priorityCount,
  double avgReinforcement,
) async {
  final payload = <String, Object?>{
    'event': 'planner_bridge_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'module_count': moduleCount,
    'priority_count': priorityCount,
    'avg_reinforcement_score': avgReinforcement,
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
