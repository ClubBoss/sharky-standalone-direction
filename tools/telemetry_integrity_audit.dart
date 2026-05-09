import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/telemetry_integrity_audit_service.dart';

const String _reportsDir = 'release/_reports';
const String _textPath = '$_reportsDir/telemetry_integrity_result.txt';
const String _jsonPath = '$_reportsDir/telemetry_integrity_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = TelemetryIntegrityAuditService();
  late TelemetryIntegrityResult result;

  try {
    result = await service.audit();
  } on TelemetryIntegrityException catch (error) {
    stderr.writeln('telemetry_integrity_audit: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('telemetry_integrity_audit: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(result);
  final summaryJson = {'issues': result.issues, 'summary': result.summary};

  try {
    await _withReportsWritable(() async {
      await File(_textPath).writeAsString(summaryText);
      await File(
        _jsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result);
    });
    if (result.issues.isNotEmpty) {
      stderr.writeln('telemetry_integrity_audit: issues found.');
      exitCode = 2;
    } else {
      stdout.writeln('telemetry_integrity_audit: integrity verified.');
    }
  } catch (error) {
    stderr.writeln('telemetry_integrity_audit: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(TelemetryIntegrityResult result) {
  final buffer = StringBuffer()
    ..writeln('TELEMETRY INTEGRITY RESULT')
    ..writeln('==========================')
    ..writeln('Generated: ${result.summary['timestamp']}')
    ..writeln('Integrity pass: ${result.summary['integrity_pass']}')
    ..writeln('Issues: ${result.issues}');
  return buffer.toString();
}

Future<void> _appendTelemetry(TelemetryIntegrityResult result) async {
  final payload = <String, Object?>{
    'event': 'telemetry_integrity_completed',
    'timestamp': result.summary['timestamp'],
    'integrity_pass': result.summary['integrity_pass'],
    'issue_count': result.issues.length,
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
