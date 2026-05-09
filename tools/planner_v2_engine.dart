import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/planner_v2_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/planner_v2_plan.txt';
const String _summaryJsonPath = '$_reportsDir/planner_v2_plan.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlannerV2EngineService();
  PlannerV2Plan plan;

  try {
    plan = await service.build();
  } on PlannerV2EngineException catch (error) {
    stderr.writeln('planner_v2_engine: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('planner_v2_engine: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(plan);
  final summaryJson = plan.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(plan);
    });
    stdout.writeln('planner_v2_engine: plan produced.');
  } catch (error) {
    stderr.writeln('planner_v2_engine: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(PlannerV2Plan plan) {
  final buffer = StringBuffer()
    ..writeln('PLANNER V2 PLAN')
    ..writeln('===============')
    ..writeln('Generated: ${plan.timestamp.toIso8601String()}')
    ..writeln('Module scores: ${plan.moduleScores}')
    ..writeln('Difficulty levels: ${plan.difficultyLevels}')
    ..writeln('Routed plan: ${plan.routedPlan}')
    ..writeln('Persona hint modes: ${plan.personaHintModes}')
    ..writeln('Summary: ${plan.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlannerV2Plan plan) async {
  final payload = <String, Object?>{
    'event': 'planner_v2_engine_completed',
    'timestamp': plan.timestamp.toIso8601String(),
    'module_count': plan.summary['module_count'],
    'avg_score': plan.summary['avg_score'],
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
  await _setPermissions(dir.path, true);
  try {
    await action();
  } finally {
    await _setPermissions(dir.path, false);
  }
}

Future<void> _setPermissions(String path, bool writable) async {
  final mode = writable ? 'u+w' : 'u-w';
  try {
    await Process.run('chmod', ['-R', mode, path]);
  } catch (_) {}
}
