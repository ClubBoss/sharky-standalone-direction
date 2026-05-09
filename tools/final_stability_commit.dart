import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/final_stability_commit_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/final_stability_manifest.txt';
const String _summaryJsonPath = '$_reportsDir/final_stability_manifest.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = FinalStabilityCommitService();
  FinalStabilityManifest manifest;

  try {
    manifest = await service.run();
  } on FinalStabilityCommitException catch (error) {
    stderr.writeln('final_stability_commit: ${error.message}');
    return;
  } catch (error) {
    stderr.writeln('final_stability_commit: unexpected error: $error');
    return;
  }

  final summaryText = _buildSummary(manifest);
  final summaryJson = manifest.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(manifest);
    });
    stdout.writeln('final_stability_commit: manifest recorded.');
  } catch (error) {
    stderr.writeln('final_stability_commit: report write failed: $error');
  }

  exitCode = 0;
}

String _buildSummary(FinalStabilityManifest manifest) {
  final buffer = StringBuffer()
    ..writeln('FINAL STABILITY MANIFEST')
    ..writeln('========================')
    ..writeln('Generated: ${manifest.timestamp.toIso8601String()}')
    ..writeln('Safety pass: ${manifest.safetyPass}')
    ..writeln('Stability level: ${manifest.stabilityLevel}')
    ..writeln(
      'Fail domains: ${manifest.failDomains.isEmpty ? 'none' : manifest.failDomains.join(', ')}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(FinalStabilityManifest manifest) async {
  final payload = <String, Object?>{
    'event': 'final_stability_commit_completed',
    'timestamp': manifest.timestamp.toIso8601String(),
    'safety_pass': manifest.safetyPass,
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
