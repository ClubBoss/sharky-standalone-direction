import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ux_stability_check_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ux_stability_result.txt';
const String _summaryJsonPath = '$_reportsDir/ux_stability_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = UXStabilityCheckService();
  UXStabilityResult result;

  try {
    result = await service.run();
  } on UXStabilityCheckException catch (error) {
    stderr.writeln('ux_stability_check: ${error.message}');
    result = error.result;
  } catch (error) {
    stderr.writeln('ux_stability_check: unexpected error: $error');
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
    stdout.writeln('ux_stability_check: reports generated.');
  } catch (error) {
    stderr.writeln('ux_stability_check: report generation failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = result.summary.uxStable ? 0 : 2;
}

String _buildSummary(UXStabilityResult result) {
  final buffer = StringBuffer()
    ..writeln('UX STABILITY CHECK V2')
    ..writeln('=====================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('UX Stable: ${result.summary.uxStable}')
    ..writeln(
      'Issues: ${result.issues.isEmpty ? 'none' : result.issues.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(UXStabilityResult result) async {
  final payload = <String, Object?>{
    'event': 'ux_stability_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'ux_stable': result.summary.uxStable,
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
