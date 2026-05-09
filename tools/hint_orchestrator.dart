import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/hint_orchestrator_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/hint_orchestration_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/hint_orchestration_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = HintOrchestratorService();
  HintOrchestrationBundle bundle;

  try {
    bundle = await service.build();
  } on HintOrchestratorException catch (error) {
    stderr.writeln('hint_orchestrator: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('hint_orchestrator: unexpected error: $error');
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
    stdout.writeln(
      'hint_orchestrator: bundle emitted (energy=${bundle.hintEnergy}).',
    );
  } catch (error) {
    stderr.writeln('hint_orchestrator: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(HintOrchestrationBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('HINT ORCHESTRATION BUNDLE')
    ..writeln('=========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Hint energy: ${bundle.hintEnergy}')
    ..writeln('Hint depth: ${bundle.hintDepth}')
    ..writeln(
      'Recommended hint types: ${bundle.recommendedHintTypes.join(', ')}',
    )
    ..writeln('Tone rules: ${bundle.toneRules}')
    ..writeln('Layout focus: ${bundle.layoutFocus.join(', ')}');
  return buffer.toString();
}

Future<void> _appendTelemetry(HintOrchestrationBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'hint_orchestration_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'hint_energy': bundle.hintEnergy,
    'hint_depth': bundle.hintDepth,
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
