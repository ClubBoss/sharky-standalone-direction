import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/pre_onboarding_intent_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/pre_onboarding_intent.txt';
const String _summaryJsonPath = '$_reportsDir/pre_onboarding_intent.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PreOnboardingIntentService();
  PreOnboardingIntentBundle bundle;

  try {
    bundle = await service.run();
  } on PreOnboardingIntentException catch (error) {
    stderr.writeln('pre_onboarding_intent_map: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('pre_onboarding_intent_map: unexpected error: $error');
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
    stdout.writeln('pre_onboarding_intent_map: intent map emitted.');
  } catch (error) {
    stderr.writeln('pre_onboarding_intent_map: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(PreOnboardingIntentBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PRE-ONBOARDING INTENT MAP')
    ..writeln('=========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Visual intent: ${bundle.visualIntent}')
    ..writeln('Learning intent: ${bundle.learningIntent}')
    ..writeln('Engagement intent: ${bundle.engagementIntent}')
    ..writeln('Routing intent: ${bundle.routingIntent}')
    ..writeln(
      'Onboarding priority: ${bundle.onboardingPriority.toStringAsFixed(2)}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(PreOnboardingIntentBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'pre_onboarding_intent_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'onboarding_priority': bundle.onboardingPriority,
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
