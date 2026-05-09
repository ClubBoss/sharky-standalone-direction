import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_profile_screen_renderer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/player_profile_screen_render_tree.txt';
const String _summaryJsonPath =
    '$_reportsDir/player_profile_screen_render_tree.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PlayerProfileScreenRendererService();
  late final PlayerProfileRenderTreeBundle bundle;

  try {
    bundle = await service.run();
  } on PlayerProfileScreenRendererException catch (error) {
    stderr.writeln('player_profile_screen_renderer: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('player_profile_screen_renderer: unexpected error: $error');
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
    stderr.writeln(
      'player_profile_screen_renderer: report write failed: $error',
    );
    exitCode = 2;
    return;
  }

  stdout.writeln('player_profile_screen_renderer: render tree emitted.');
  exitCode = 0;
}

String _buildSummary(PlayerProfileRenderTreeBundle bundle) {
  final sections = bundle.screen['sections'];
  final count = sections is List ? sections.length : 0;
  final ordering = bundle.screen['ordering'];
  final orderingList = ordering is List ? ordering.join(', ') : '';
  final buffer = StringBuffer()
    ..writeln('PLAYER PROFILE SCREEN RENDER TREE')
    ..writeln('==================================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Sections: $count')
    ..writeln('Ordering: $orderingList');
  return buffer.toString();
}

Future<void> _appendTelemetry(PlayerProfileRenderTreeBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'player_profile_screen_render_tree_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'section_count': (bundle.screen['sections'] as List).length,
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
