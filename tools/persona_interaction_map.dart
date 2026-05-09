import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/persona_interaction_map_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/persona_interaction_map.txt';
const String _summaryJsonPath = '$_reportsDir/persona_interaction_map.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PersonaInteractionMapService();
  PersonaInteractionMapBundle bundle;

  try {
    bundle = await service.build();
  } on PersonaInteractionMapException catch (error) {
    stderr.writeln('persona_interaction_map: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('persona_interaction_map: unexpected error: $error');
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
    stdout.writeln(
      'persona_interaction_map: ready (priority=${bundle.interactionPriority}).',
    );
  } catch (error) {
    stderr.writeln('persona_interaction_map: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(PersonaInteractionMapBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PERSONA INTERACTION MAP')
    ..writeln('=======================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Tone rules:')
    ..writeln('  use_friendly: ${bundle.useFriendly}')
    ..writeln('  use_supportive: ${bundle.useSupportive}')
    ..writeln('  use_directive: ${bundle.useDirective}')
    ..writeln('Hint rules:')
    ..writeln('  visual hints: ${bundle.useVisualHints}')
    ..writeln('  learning hints: ${bundle.useLearningHints}')
    ..writeln('  prefer brief prompts: ${bundle.preferBriefPrompts}')
    ..writeln('Engagement rules:')
    ..writeln('  energy_level: ${bundle.energyLevel}')
    ..writeln('  context_depth: ${bundle.contextDepth}')
    ..writeln('Layout focus: ${bundle.layoutFocus.join(', ')}')
    ..writeln('Interaction priority: ${bundle.interactionPriority}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PersonaInteractionMapBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'persona_interaction_map_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'interaction_priority': bundle.interactionPriority,
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
