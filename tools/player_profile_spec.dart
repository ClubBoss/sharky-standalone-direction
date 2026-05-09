import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_spec_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/player_profile_spec.txt';
const String _summaryJsonPath = '$_reportsDir/player_profile_spec.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlayerProfileSpecService();
  late final PlayerProfileBundle bundle;

  try {
    bundle = await service.run();
  } on PlayerProfileSpecException catch (error) {
    stderr.writeln('player_profile_spec: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('player_profile_spec: unexpected error: $error');
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
    stderr.writeln('player_profile_spec: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'player_profile_spec: bundle ready with ${bundle.moduleFocus.length} modules.',
  );
  exitCode = 0;
}

String _buildSummary(PlayerProfileBundle bundle) {
  final hintModes = bundle.hints['modes'];
  final hintCount = hintModes is List ? hintModes.length : 0;
  final engagementScore =
      (bundle.summary['engagement_score'] as double?) ?? 0.0;
  final coverage = (bundle.localization['coverage'] as double?) ?? 0.0;
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE SPEC')
    ..writeln('===================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Persona tone: ${bundle.persona['tone']}')
    ..writeln('Hint modes: $hintCount')
    ..writeln('Modules: ${bundle.moduleFocus.length}')
    ..writeln('Engagement score: ${engagementScore.toStringAsFixed(2)}')
    ..writeln('Localization coverage: ${coverage.toStringAsFixed(2)}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlayerProfileBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'player_profile_spec_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'module_count': bundle.moduleFocus.length,
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
