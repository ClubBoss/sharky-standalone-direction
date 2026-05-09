import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/explanation_routing_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/explanation_routing_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/explanation_routing_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ExplanationRoutingService();
  ExplanationRoutingBundle bundle;

  try {
    bundle = await service.build();
  } on ExplanationRoutingException catch (error) {
    stderr.writeln('explanation_routing: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('explanation_routing: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(bundle);
  final summaryJson = bundle.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(bundle);
    });
    stdout.writeln('explanation_routing: bundle generated.');
  } catch (error) {
    stderr.writeln('explanation_routing: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(ExplanationRoutingBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('EXPLANATION ROUTING BUNDLE')
    ..writeln('==========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Routing order: ${bundle.routingOrder}')
    ..writeln('Routing map: ${bundle.routingMap}')
    ..writeln('Triggers: ${bundle.triggers}')
    ..writeln('Summary: ${bundle.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(ExplanationRoutingBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'explanation_routing_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'module_count': bundle.summary['module_count'],
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
