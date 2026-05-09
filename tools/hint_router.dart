import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/hint_router_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/hint_routing_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/hint_routing_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = HintRouterService();
  HintRoutingBundle bundle;

  try {
    bundle = await service.build();
  } on HintRouterException catch (error) {
    stderr.writeln('hint_router: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('hint_router: unexpected error: $error');
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
    stdout.writeln('hint_router: bundle saved (tier=${bundle.tier}).');
  } catch (error) {
    stderr.writeln('hint_router: report generation failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(HintRoutingBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('HINT ROUTING BUNDLE')
    ..writeln('====================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Tier: ${bundle.tier}')
    ..writeln('Placement candidates: ${bundle.placementCandidates}')
    ..writeln('Tone rules: ${bundle.toneRules}')
    ..writeln('Layout focus: ${bundle.layoutFocus.join(', ')}');
  return buffer.toString();
}

Future<void> _appendTelemetry(HintRoutingBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'hint_routing_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'tier': bundle.tier,
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
