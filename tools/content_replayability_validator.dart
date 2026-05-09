import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/content_replayability_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/content_replayability_result.txt';
const String _summaryJsonPath =
    '$_reportsDir/content_replayability_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ContentReplayabilityService();
  ContentReplayabilityResult result;

  try {
    result = await service.run();
  } on ContentReplayabilityException catch (error) {
    stderr.writeln('content_replayability_validator: ${error.message}');
    result = error.result;
  } catch (error) {
    stderr.writeln('content_replayability_validator: unexpected error: $error');
    exitCode = 1;
    return;
  }

  final summaryText = _buildSummary(result);
  final summaryJson = result.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result);
    });
    stdout.writeln('content_replayability_validator: reports generated.');
  } catch (error) {
    stderr.writeln(
      'content_replayability_validator: report generation failed: $error',
    );
    exitCode = 2;
    return;
  }

  exitCode = result.summary.replayable ? 0 : 2;
}

String _buildSummary(ContentReplayabilityResult result) {
  final buffer = StringBuffer()
    ..writeln('CONTENT REPLAYABILITY VALIDATOR V2')
    ..writeln('===================================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('Replayable: ${result.summary.replayable}')
    ..writeln(
      'Broken modules: ${result.brokenModules.isEmpty ? 'none' : result.brokenModules.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(ContentReplayabilityResult result) async {
  final payload = <String, Object?>{
    'event': 'content_replayability_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'replayable': result.summary.replayable,
    'broken_count': result.brokenModules.length,
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
