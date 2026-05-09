import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_screen_assembly_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/player_profile_screen_spec.txt';
const String _summaryJsonPath = '$_reportsDir/player_profile_screen_spec.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlayerProfileScreenAssemblyService();
  PlayerProfileScreenSpec spec;

  try {
    spec = await service.build();
  } on PlayerProfileScreenAssemblyException catch (error) {
    stderr.writeln('player_profile_screen_assembly: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('player_profile_screen_assembly: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(spec);
  final summaryJson = spec.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(spec);
    });
    stdout.writeln('player_profile_screen_assembly: spec ready.');
  } catch (error) {
    stderr.writeln(
      'player_profile_screen_assembly: report write failed: $error',
    );
    exitCode = 2;
  }
}

String _buildSummary(PlayerProfileScreenSpec spec) {
  final sections = spec.sections;
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE SCREEN SPEC')
    ..writeln('==========================')
    ..writeln('Generated: ${spec.timestamp.toIso8601String()}')
    ..writeln('Header: ${sections['header_section']}')
    ..writeln('Hint: ${sections['hint_section']}')
    ..writeln('Training: ${sections['training_section']}')
    ..writeln('Focus: ${sections['focus_section']}')
    ..writeln('Suggestions: ${sections['suggestions_section']}')
    ..writeln('Summary: ${spec.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlayerProfileScreenSpec spec) async {
  final payload = <String, Object?>{
    'event': 'player_profile_screen_assembly_completed',
    'timestamp': spec.timestamp.toIso8601String(),
    'module_count': spec.summary['module_count'],
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
