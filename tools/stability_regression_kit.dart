import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/stability_regression_kit_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/stability_regression_result.txt';
const String _summaryJsonPath = '$_reportsDir/stability_regression_result.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = StabilityRegressionKitService();
  StabilityRegressionResult result;

  try {
    result = await service.run();
  } on StabilityRegressionException catch (error) {
    stderr.writeln('stability_regression_kit: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('stability_regression_kit: unexpected error: $error');
    exitCode = 2;
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
    stdout.writeln('stability_regression_kit: result recorded.');
  } catch (error) {
    stderr.writeln('stability_regression_kit: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(StabilityRegressionResult result) {
  final buffer = StringBuffer()
    ..writeln('STABILITY REGRESSION RESULT')
    ..writeln('===========================')
    ..writeln('Generated: ${result.timestamp.toIso8601String()}')
    ..writeln('Health drop: ${result.healthDrop}')
    ..writeln('Planner invalid: ${result.plannerInvalid}')
    ..writeln('Routing invalid: ${result.routingInvalid}')
    ..writeln('Overlay invalid: ${result.overlayInvalid}')
    ..writeln('Summary: ${result.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(StabilityRegressionResult result) async {
  final payload = <String, Object?>{
    'event': 'stability_regression_completed',
    'timestamp': result.timestamp.toIso8601String(),
    'regression_detected': result.summary['regression_detected'],
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
