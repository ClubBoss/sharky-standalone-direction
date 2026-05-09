import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/component_unification_map_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/component_unification_map.txt';
const String _summaryJsonPath = '$_reportsDir/component_unification_map.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ComponentUnificationMapService();
  ComponentUnificationMapBundle bundle;

  try {
    bundle = await service.build();
  } on ComponentUnificationMapException catch (error) {
    stderr.writeln('component_unification_map: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('component_unification_map: unexpected error: $error');
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
    stdout.writeln('component_unification_map: generated.');
  } catch (error) {
    stderr.writeln('component_unification_map: report build failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(ComponentUnificationMapBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('COMPONENT UNIFICATION MAP')
    ..writeln('=========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Canonical components: ${bundle.canonicalComponents}')
    ..writeln('Consolidation rules: ${bundle.consolidationRules}')
    ..writeln('Visual rules: ${bundle.visualRules}');
  return buffer.toString();
}

Future<void> _appendTelemetry(ComponentUnificationMapBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'component_unification_map_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
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
