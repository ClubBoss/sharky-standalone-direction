import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/release_safety_check_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/release_safety_result.txt';
const String _summaryJsonPath = '$_reportsDir/release_safety_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ReleaseSafetyCheckService();
  ReleaseSafetyResult result;

  try {
    result = await service.run();
  } on ReleaseSafetyException catch (error) {
    stderr.writeln('release_safety_check: ${error.message}');
    result = error.result;
  } catch (error) {
    stderr.writeln('release_safety_check: unexpected error: $error');
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
    stdout.writeln('release_safety_check: report emitted.');
  } catch (error) {
    stderr.writeln('release_safety_check: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = result.summary.safetyPass ? 0 : 2;
}

String _buildSummary(ReleaseSafetyResult result) {
  final buffer = StringBuffer()
    ..writeln('RELEASE SAFETY CHECK V2')
    ..writeln('========================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('Safety pass: ${result.summary.safetyPass}')
    ..writeln(
      'Failed domains: ${result.failDomains.isEmpty ? 'none' : result.failDomains.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(ReleaseSafetyResult result) async {
  final payload = <String, Object?>{
    'event': 'release_safety_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'safety_pass': result.summary.safetyPass,
    'fail_count': result.failDomains.length,
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
