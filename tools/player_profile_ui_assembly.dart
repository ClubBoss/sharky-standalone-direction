import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_ui_assembly_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/player_profile_ui_assembly.txt';
const String _summaryJsonPath = '$_reportsDir/player_profile_ui_assembly.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlayerProfileUIAssemblyService();
  late final PlayerProfileUIAssemblyBundle bundle;

  try {
    bundle = await service.run();
  } on PlayerProfileUIAssemblyException catch (error) {
    stderr.writeln('player_profile_ui_assembly: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('player_profile_ui_assembly: unexpected error: $error');
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
  } catch (error) {
    stderr.writeln('player_profile_ui_assembly: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'player_profile_ui_assembly: assembly ready with ${bundle.sections.length} sections.',
  );
  exitCode = 0;
}

String _buildSummary(PlayerProfileUIAssemblyBundle bundle) {
  final ordering = bundle.ordering.join(', ');
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE UI ASSEMBLY')
    ..writeln('==========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Sections: ${bundle.sections.length}')
    ..writeln('Ordering: $ordering');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlayerProfileUIAssemblyBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'player_profile_ui_assembly_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'section_count': bundle.sections.length,
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
