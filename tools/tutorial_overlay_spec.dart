import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/tutorial_overlay_spec_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/tutorial_overlay_spec.txt';
const String _summaryJsonPath = '$_reportsDir/tutorial_overlay_spec.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = TutorialOverlaySpecService();
  TutorialOverlaySpec spec;

  try {
    spec = await service.build();
  } on TutorialOverlaySpecException catch (error) {
    stderr.writeln('tutorial_overlay_spec: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('tutorial_overlay_spec: unexpected error: $error');
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
    stdout.writeln('tutorial_overlay_spec: bundle generated.');
  } catch (error) {
    stderr.writeln('tutorial_overlay_spec: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(TutorialOverlaySpec spec) {
  final buffer = StringBuffer()
    ..writeln('TUTORIAL OVERLAY SPEC')
    ..writeln('=====================')
    ..writeln('Generated: ${spec.timestamp.toIso8601String()}')
    ..writeln('Overlay flow: ${spec.overlayFlow}')
    ..writeln('Summary: ${spec.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(TutorialOverlaySpec spec) async {
  final payload = <String, Object?>{
    'event': 'tutorial_overlay_spec_completed',
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
