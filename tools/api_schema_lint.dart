import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/api_schema_lint_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/api_schema_lint_result.txt';
const String _summaryJsonPath = '$_reportsDir/api_schema_lint_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ApiSchemaLintService();
  ApiSchemaLintResult result;

  try {
    result = await service.run();
  } on ApiSchemaLintException catch (error) {
    stderr.writeln('api_schema_lint: ${error.message}');
    result = error.result;
  } catch (error) {
    stderr.writeln('api_schema_lint: unexpected error: $error');
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
    stdout.writeln('api_schema_lint: reports generated.');
  } catch (error) {
    stderr.writeln('api_schema_lint: report generation failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = result.summary.schemaValid ? 0 : 2;
}

String _buildSummary(ApiSchemaLintResult result) {
  final buffer = StringBuffer()
    ..writeln('API SCHEMA LINT V2')
    ..writeln('===================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('Schema Valid: ${result.summary.schemaValid}')
    ..writeln(
      'Issues: ${result.schemaIssues.isEmpty ? 'none' : result.schemaIssues.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(ApiSchemaLintResult result) async {
  final payload = <String, Object?>{
    'event': 'api_schema_lint_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'schema_valid': result.summary.schemaValid,
    'issue_count': result.schemaIssues.length,
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
