import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_blueprint_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/player_profile_blueprint.txt';
const String _summaryJsonPath = '$_reportsDir/player_profile_blueprint.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlayerProfileBlueprintService();
  late final PlayerProfileBlueprintBundle bundle;

  try {
    bundle = await service.run();
  } on PlayerProfileBlueprintException catch (error) {
    stderr.writeln('player_profile_blueprint: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('player_profile_blueprint: unexpected error: $error');
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
    stderr.writeln('player_profile_blueprint: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'player_profile_blueprint: blueprint emitted with ${bundle.sections.length} sections.',
  );
  exitCode = 0;
}

String _buildSummary(PlayerProfileBlueprintBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE BLUEPRINT')
    ..writeln('========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Sections: ${bundle.sections.length}')
    ..writeln('Ordering: ${bundle.ordering.join(', ')}')
    ..writeln('Module count: ${bundle.summary['module_count']}')
    ..writeln(
      'Engagement score: ${(bundle.summary['engagement_score'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(PlayerProfileBlueprintBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'player_profile_blueprint_completed',
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
