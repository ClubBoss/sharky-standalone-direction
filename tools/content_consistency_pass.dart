import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/content_consistency_pass_service.dart';

const String _reportsDir = 'release/_reports';
const String _textPath = '$_reportsDir/content_consistency_result.txt';
const String _jsonPath = '$_reportsDir/content_consistency_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ContentConsistencyPassService();
  ContentConsistencyResult result;

  try {
    result = await service.check();
  } on ContentConsistencyException catch (error) {
    stderr.writeln('content_consistency_pass: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('content_consistency_pass: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(result);
  final summaryJson = {
    'inconsistencies': result.inconsistencies,
    'summary': result.summary,
  };

  try {
    await _withReportsWritable(() async {
      await File(_textPath).writeAsString(summaryText);
      await File(
        _jsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result);
    });
    if (result.inconsistencies.isNotEmpty) {
      stderr.writeln('content_consistency_pass: inconsistencies detected.');
      exitCode = 2;
    } else {
      stdout.writeln('content_consistency_pass: consistent.');
    }
  } catch (error) {
    stderr.writeln('content_consistency_pass: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(ContentConsistencyResult result) {
  final buffer = StringBuffer()
    ..writeln('CONTENT CONSISTENCY RESULT')
    ..writeln('==========================')
    ..writeln('Generated: ${result.summary['timestamp']}')
    ..writeln('Consistent: ${result.summary['consistent']}')
    ..writeln('Inconsistencies: ${result.inconsistencies}');
  return buffer.toString();
}

Future<void> _appendTelemetry(ContentConsistencyResult result) async {
  final payload = <String, Object?>{
    'event': 'content_consistency_completed',
    'timestamp': result.summary['timestamp'],
    'consistent': result.summary['consistent'],
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
