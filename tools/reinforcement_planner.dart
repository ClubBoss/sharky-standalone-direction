import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/reinforcement_planner_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/reinforcement_planner_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/reinforcement_planner_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ReinforcementPlannerService();
  List<ReinforcementPlan> plans;
  try {
    plans = await service.plan();
  } catch (error) {
    stderr.writeln('Reinforcement Planner failed: $error');
    exitCode = 2;
    return;
  }
  final avgReinforcement = plans.isEmpty
      ? 0.0
      : plans.map((p) => p.reinforcementScore).reduce((a, b) => a + b) /
            plans.length;

  final text = _buildText(plans, avgReinforcement);
  final json = _buildJson(plans, avgReinforcement);

  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(plans.length, avgReinforcement);
  });
}

String _buildText(List<ReinforcementPlan> plans, double avgReinforcement) {
  final buffer = StringBuffer()
    ..writeln('REINFORCEMENT PLANNER SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Modules: ${plans.length}')
    ..writeln(
      'Average reinforcement score: ${(avgReinforcement * 100).toStringAsFixed(2)}%',
    );
  for (final plan in plans) {
    buffer
      ..writeln('- ${plan.module}')
      ..writeln('  priority: ${plan.priorityScore.toStringAsFixed(3)}')
      ..writeln(
        '  reinforcement: ${plan.reinforcementScore.toStringAsFixed(3)}',
      )
      ..writeln('  severity: ${plan.severityFlag}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(
  List<ReinforcementPlan> plans,
  double avgReinforcement,
) => {
  'generated_at': DateTime.now().toIso8601String(),
  'module_count': plans.length,
  'avg_reinforcement_score': avgReinforcement,
  'plans': plans.map((p) => p.toJson()).toList(),
};

Future<void> _appendTelemetry(int moduleCount, double avgReinforcement) async {
  final payload = <String, Object?>{
    'event': 'reinforcement_planner_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'module_count': moduleCount,
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
