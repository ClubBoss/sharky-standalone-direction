import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/universal_qa_snapshot_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/stability_snapshot_v2.txt';
const String _summaryJsonPath = '$_reportsDir/stability_snapshot_v2.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = UniversalQASnapshotService();
  UniversalQASnapshotBundle bundle;

  try {
    bundle = await service.capture();
  } on UniversalQASnapshotException catch (error) {
    stderr.writeln('universal_qa_snapshot: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('universal_qa_snapshot: unexpected error: $error');
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
    stdout.writeln('universal_qa_snapshot: snapshot recorded.');
  } catch (error) {
    stderr.writeln('universal_qa_snapshot: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(UniversalQASnapshotBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('STABILITY SNAPSHOT V2')
    ..writeln('=====================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Summary: ${bundle.summary}')
    ..writeln('Content metrics: ${bundle.contentMetrics}')
    ..writeln('Planner metrics: ${bundle.plannerMetrics}')
    ..writeln('Visual metrics: ${bundle.visualMetrics}')
    ..writeln('Persona metrics: ${bundle.personaMetrics}')
    ..writeln('Hint metrics: ${bundle.hintMetrics}')
    ..writeln('Training path metrics: ${bundle.trainingPathMetrics}');
  return buffer.toString();
}

Future<void> _appendTelemetry(UniversalQASnapshotBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'stability_snapshot_v2_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'health_score': bundle.summary['health_score'],
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
