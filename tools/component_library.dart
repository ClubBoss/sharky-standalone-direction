import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/component_library_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/component_library_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/component_library_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ComponentLibraryService();
  ComponentLibraryBundle bundle;

  try {
    bundle = await service.build();
  } on ComponentLibraryException catch (error) {
    stderr.writeln('component_library: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('component_library: unexpected error: $error');
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
    stdout.writeln('component_library: bundle generated.');
  } catch (error) {
    stderr.writeln('component_library: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(ComponentLibraryBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('COMPONENT LIBRARY BUNDLE')
    ..writeln('========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Patterns: ${bundle.patterns}')
    ..writeln('Consolidation notes: ${bundle.consolidationNotes}')
    ..writeln('Visual rules: ${bundle.visualRules}');
  return buffer.toString();
}

Future<void> _appendTelemetry(ComponentLibraryBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'component_library_completed',
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
