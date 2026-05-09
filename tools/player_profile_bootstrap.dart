import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_bootstrap_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/player_profile_context_bundle.txt';
const String _summaryJsonPath =
    '$_reportsDir/player_profile_context_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlayerProfileBootstrapService();
  PlayerProfileContextBundle bundle;

  try {
    bundle = await service.build();
  } on PlayerProfileBootstrapException catch (error) {
    stderr.writeln('player_profile_bootstrap: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('player_profile_bootstrap: unexpected error: $error');
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
    stdout.writeln('player_profile_bootstrap: context ready.');
  } catch (error) {
    stderr.writeln('player_profile_bootstrap: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(PlayerProfileContextBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE CONTEXT BUNDLE')
    ..writeln('==============================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Persona profile: ${bundle.personaProfile}')
    ..writeln('Hint profile: ${bundle.hintProfile}')
    ..writeln('Training profile: ${bundle.trainingProfile}')
    ..writeln('Summary: ${bundle.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlayerProfileContextBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'player_profile_bootstrap_completed',
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
