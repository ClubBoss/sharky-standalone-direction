import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/explanation_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/explanation_engine_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/explanation_engine_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = ExplanationEngineService();
  ExplanationEngineBundle bundle;

  try {
    bundle = await service.build();
  } on ExplanationEngineException catch (error) {
    stderr.writeln('explanation_engine: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('explanation_engine: unexpected error: $error');
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
    stdout.writeln('explanation_engine: bundle ready.');
  } catch (error) {
    stderr.writeln('explanation_engine: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(ExplanationEngineBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('EXPLANATION ENGINE BUNDLE')
    ..writeln('==========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Persona overview: ${bundle.personaOverview}')
    ..writeln('Hint strategy: ${bundle.hintStrategy}')
    ..writeln('Training overview: ${bundle.trainingOverview}')
    ..writeln('Recommended focus: ${bundle.recommendedFocus}')
    ..writeln('Persona suggestions: ${bundle.personaSuggestions}')
    ..writeln('Summary: ${bundle.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(ExplanationEngineBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'explanation_engine_completed',
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
