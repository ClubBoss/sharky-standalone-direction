import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/emotional_hooks_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/emotional_hooks_map.txt';
const String _summaryJsonPath = '$_reportsDir/emotional_hooks_map.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = EmotionalHooksService();
  EmotionalHooksBundle bundle;

  try {
    bundle = await service.run();
  } on EmotionalHooksException catch (error) {
    stderr.writeln('emotional_hooks_map: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('emotional_hooks_map: unexpected error: $error');
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
    stdout.writeln('emotional_hooks_map: bundle saved.');
  } catch (error) {
    stderr.writeln('emotional_hooks_map: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(EmotionalHooksBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('EMOTIONAL HOOKS MAP')
    ..writeln('===================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Confidence hook: ${bundle.confidenceHook}')
    ..writeln('Clarity hook: ${bundle.clarityHook}')
    ..writeln('Engagement hook: ${bundle.engagementHook}')
    ..writeln('Persona alignment hook: ${bundle.personaAlignmentHook}')
    ..writeln(
      'Session mood score: ${bundle.sessionMoodScore.toStringAsFixed(2)}',
    )
    ..writeln('Hook priority: ${bundle.hookPriority.toStringAsFixed(2)}');
  return buffer.toString();
}

Future<void> _appendTelemetry(EmotionalHooksBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'emotional_hooks_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'hook_priority': bundle.hookPriority,
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
