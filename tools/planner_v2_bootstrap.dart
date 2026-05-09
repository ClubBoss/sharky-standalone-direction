import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/planner_v2_bootstrap_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/planner_v2_input_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/planner_v2_input_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlannerV2BootstrapService();
  PlannerV2InputBundle bundle;

  try {
    bundle = await service.build();
  } on PlannerV2BootstrapException catch (error) {
    stderr.writeln('planner_v2_bootstrap: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('planner_v2_bootstrap: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(bundle);
  final summaryJson = bundle.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(bundle);
    });
    stdout.writeln('planner_v2_bootstrap: bundle ready.');
  } catch (error) {
    stderr.writeln('planner_v2_bootstrap: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(PlannerV2InputBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PLANNER V2 INPUT BUNDLE')
    ..writeln('=======================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Module data keys: ${bundle.moduleData.keys}')
    ..writeln('Persona tone: ${bundle.personaData['tone_profile']}')
    ..writeln('Hint tier: ${bundle.hintData['tier']}')
    ..writeln(
      'Adaptive modules: ${(bundle.adaptiveData['groups'] as Map?)?.length ?? 0}',
    )
    ..writeln('Summary: ${bundle.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlannerV2InputBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'planner_v2_bootstrap_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'module_count': bundle.summary['module_count'],
    'avg_priority': bundle.summary['avg_priority'],
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
