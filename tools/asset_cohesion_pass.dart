import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/asset_cohesion_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/asset_cohesion_result.txt';
const String _summaryJsonPath = '$_reportsDir/asset_cohesion_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = AssetCohesionService();
  AssetCohesionResult result;

  try {
    result = await service.run();
  } on AssetCohesionException catch (error) {
    stderr.writeln('asset_cohesion_pass: ${error.message}');
    result = error.result;
  } catch (error) {
    stderr.writeln('asset_cohesion_pass: unexpected error: $error');
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
    stdout.writeln('asset_cohesion_pass: reports generated.');
  } catch (error) {
    stderr.writeln('asset_cohesion_pass: report generation failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = result.summary.cohesive ? 0 : 2;
}

String _buildSummary(AssetCohesionResult result) {
  final buffer = StringBuffer()
    ..writeln('ASSET COHESION PASS V2')
    ..writeln('=======================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('Cohesive: ${result.summary.cohesive}')
    ..writeln(
      'Issues: ${result.issues.isEmpty ? 'none' : result.issues.join(', ')}',
    )
    ..writeln(
      'Orphan entries: ${result.orphanEntries.isEmpty ? 'none' : result.orphanEntries.join(', ')}',
    )
    ..writeln(
      'Invalid assets: ${result.invalidAssets.isEmpty ? 'none' : result.invalidAssets.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(AssetCohesionResult result) async {
  final payload = <String, Object?>{
    'event': 'asset_cohesion_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'cohesive': result.summary.cohesive,
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
