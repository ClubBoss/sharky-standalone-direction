import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/file_structure_integrity_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/file_structure_integrity_result.txt';
const String _summaryJsonPath =
    '$_reportsDir/file_structure_integrity_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = FileStructureIntegrityService();
  FileStructureIntegrityResult result;

  try {
    result = await service.run();
  } on FileStructureIntegrityException catch (error) {
    stderr.writeln('file_structure_integrity_validator: ${error.message}');
    result = error.result;
  } catch (error) {
    stderr.writeln(
      'file_structure_integrity_validator: unexpected error: $error',
    );
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
    stdout.writeln('file_structure_integrity_validator: reports generated.');
  } catch (error) {
    stderr.writeln(
      'file_structure_integrity_validator: report generation failed: $error',
    );
    exitCode = 2;
    return;
  }

  exitCode = result.summary.structurePass ? 0 : 2;
}

String _buildSummary(FileStructureIntegrityResult result) {
  final buffer = StringBuffer()
    ..writeln('FILE STRUCTURE INTEGRITY VALIDATOR V2')
    ..writeln('======================================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('Structure Pass: ${result.summary.structurePass}')
    ..writeln(
      'Missing paths: ${result.missingPaths.isEmpty ? 'none' : result.missingPaths.join(', ')}',
    )
    ..writeln(
      'Invalid files: ${result.invalidFiles.isEmpty ? 'none' : result.invalidFiles.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(FileStructureIntegrityResult result) async {
  final payload = <String, Object?>{
    'event': 'file_structure_integrity_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'structure_pass': result.summary.structurePass,
    'missing_count': result.missingPaths.length,
    'invalid_count': result.invalidFiles.length,
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
