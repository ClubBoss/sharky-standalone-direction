import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/system_sanity_validator_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/system_sanity_result.txt';
const String _summaryJsonPath = '$_reportsDir/system_sanity_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = SystemSanityValidatorService();
  late SystemSanityResult result;

  try {
    result = await service.validate();
  } on SystemSanityValidatorException catch (error) {
    stderr.writeln('system_sanity_validator: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('system_sanity_validator: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(result);
  final summaryJson = {
    'invalid_reports': result.invalidReports,
    'summary': result.summary,
  };

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result);
    });
    if (result.invalidReports.isNotEmpty) {
      stderr.writeln('system_sanity_validator: invalid reports detected.');
      exitCode = 2;
    } else {
      stdout.writeln('system_sanity_validator: all reports sane.');
    }
  } catch (error) {
    stderr.writeln('system_sanity_validator: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(SystemSanityResult result) {
  final buffer = StringBuffer()
    ..writeln('SYSTEM SANITY RESULT')
    ..writeln('====================')
    ..writeln('Generated: ${result.summary['timestamp']}')
    ..writeln('Sanity pass: ${result.summary['sanity_pass']}')
    ..writeln('Invalid reports: ${result.invalidReports}');
  return buffer.toString();
}

Future<void> _appendTelemetry(SystemSanityResult result) async {
  final payload = <String, Object?>{
    'event': 'system_sanity_completed',
    'timestamp': result.summary['timestamp'],
    'sanity_pass': result.summary['sanity_pass'],
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
