import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/persona_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/persona_engine_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/persona_engine_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PersonaEngineService();
  PersonaEngineBundle bundle;

  try {
    bundle = await service.build();
  } on PersonaEngineException catch (error) {
    stderr.writeln('persona_engine: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('persona_engine: unexpected error: $error');
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
    stdout.writeln('persona_engine: bundle saved.');
  } catch (error) {
    stderr.writeln('persona_engine: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(PersonaEngineBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PERSONA ENGINE BUNDLE')
    ..writeln('=====================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Tone profile:')
    ..writeln('  friendly: ${bundle.friendlyTone}')
    ..writeln('  supportive: ${bundle.supportiveTone}')
    ..writeln('  directive: ${bundle.directiveTone}')
    ..writeln('Hint strategy:')
    ..writeln('  visual hints: ${bundle.useVisualHints}')
    ..writeln('  learning hints: ${bundle.useLearningHints}')
    ..writeln('  prefer brief prompts: ${bundle.preferBriefPrompts}')
    ..writeln('Engagement profile:')
    ..writeln('  energy_level: ${bundle.energyLevel}')
    ..writeln('  context_depth: ${bundle.contextDepth}')
    ..writeln('Layout focus: ${bundle.layoutFocus.join(', ')}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PersonaEngineBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'persona_engine_completed',
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
