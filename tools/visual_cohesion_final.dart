import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/visual_cohesion_final_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/visual_cohesion_final.txt';
const String _summaryJsonPath = '$_reportsDir/visual_cohesion_final.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = VisualCohesionFinalService();
  VisualCohesionFinalBundle bundle;

  try {
    bundle = await service.summarize();
  } on VisualCohesionFinalException catch (error) {
    stderr.writeln('visual_cohesion_final: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('visual_cohesion_final: unexpected error: $error');
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
    stdout.writeln(
      'visual_cohesion_final: summary ready (index=${bundle.visualCohesionIndex.toStringAsFixed(3)}).',
    );
  } catch (error) {
    stderr.writeln('visual_cohesion_final: failed to write reports: $error');
    exitCode = 2;
  }
}

String _buildSummary(VisualCohesionFinalBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION FINAL SUMMARY')
    ..writeln('==============================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Token mismatches: ${bundle.tokenMismatches}')
    ..writeln('Spacing inconsistencies: ${bundle.spacingInconsistencies}')
    ..writeln('Layout anomalies: ${bundle.layoutAnomalies}')
    ..writeln(
      'Component diversity score: '
      '${bundle.componentDiversityScore.toStringAsFixed(3)} '
      '(unique components: ${bundle.uniqueComponentCount})',
    )
    ..writeln(
      'Visual cohesion index: ${bundle.visualCohesionIndex.toStringAsFixed(3)}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(VisualCohesionFinalBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_final_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'visual_cohesion_index': bundle.visualCohesionIndex,
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
