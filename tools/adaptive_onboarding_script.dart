import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_onboarding_script_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/adaptive_onboarding_script.txt';
const String _summaryJsonPath = '$_reportsDir/adaptive_onboarding_script.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = AdaptiveOnboardingScriptService();
  AdaptiveOnboardingScriptBundle bundle;

  try {
    bundle = await service.run();
  } on AdaptiveOnboardingScriptException catch (error) {
    stderr.writeln('adaptive_onboarding_script: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('adaptive_onboarding_script: unexpected error: $error');
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
    stdout.writeln('adaptive_onboarding_script: script emitted.');
  } catch (error) {
    stderr.writeln('adaptive_onboarding_script: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(AdaptiveOnboardingScriptBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE ONBOARDING SCRIPT')
    ..writeln('==========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Intro block: ${bundle.introBlock}')
    ..writeln('Motivation block: ${bundle.motivationBlock}')
    ..writeln('First action block: ${bundle.firstActionBlock}')
    ..writeln('Micro guidance block: ${bundle.microGuidanceBlock}')
    ..writeln('Script priority: ${bundle.scriptPriority.toStringAsFixed(2)}');
  return buffer.toString();
}

Future<void> _appendTelemetry(AdaptiveOnboardingScriptBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'adaptive_onboarding_script_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'script_priority': bundle.scriptPriority,
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
