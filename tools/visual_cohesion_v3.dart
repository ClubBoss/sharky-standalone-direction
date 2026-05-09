import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/visual_cohesion_v3_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/visual_cohesion_v3.txt';
const String _summaryJsonPath = '$_reportsDir/visual_cohesion_v3.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = VisualCohesionV3Service();
  VisualCohesionV3Bundle bundle;

  try {
    bundle = await service.evaluate();
  } on VisualCohesionV3Exception catch (error) {
    stderr.writeln('visual_cohesion_v3: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('visual_cohesion_v3: unexpected error: $error');
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
    stdout.writeln('visual_cohesion_v3: summary complete.');
  } catch (error) {
    stderr.writeln('visual_cohesion_v3: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(VisualCohesionV3Bundle bundle) {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION V3 SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Rule conflicts: ${bundle.ruleConflicts}')
    ..writeln('Component conflicts: ${bundle.componentConflicts}')
    ..writeln('Layout conflicts: ${bundle.layoutConflicts}')
    ..writeln('Missing targets: ${bundle.missingTargets}')
    ..writeln(
      'Visual cohesion v3 index: ${bundle.visualCohesionIndex.toStringAsFixed(3)}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(VisualCohesionV3Bundle bundle) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_v3_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'visual_cohesion_v3_index': bundle.visualCohesionIndex,
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
