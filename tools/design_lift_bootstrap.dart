import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/design_lift_bootstrap_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/design_lift_blueprint.txt';
const String _summaryJsonPath = '$_reportsDir/design_lift_blueprint.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = DesignLiftBootstrapService();
  DesignLiftBlueprint blueprint;
  try {
    blueprint = await service.bootstrap();
  } catch (error) {
    stderr.writeln('Design Lift Bootstrap failed: $error');
    exitCode = 2;
    return;
  }

  final text = _buildText(blueprint);
  final json = blueprint.toJson();

  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(blueprint.designPriority, blueprint.riskScore);
  });
}

String _buildText(DesignLiftBlueprint blueprint) {
  final buffer = StringBuffer()
    ..writeln('DESIGN LIFT BLUEPRINT')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Design priority: ${blueprint.designPriority}')
    ..writeln('Risk score: ${(blueprint.riskScore * 100).toStringAsFixed(1)}%')
    ..writeln(
      'Failing domains: ${blueprint.domains.entries.where((e) => !e.value).length}',
    )
    ..writeln('Focus areas: ${blueprint.focusAreas.join(', ')}')
    ..writeln('Core directives: ${blueprint.coreDirectives.join(', ')}');
  blueprint.domains.forEach((domain, pass) {
    buffer.writeln('  $domain: ${pass ? 'PASS' : 'FAIL'}');
  });
  return buffer.toString();
}

Future<void> _appendTelemetry(String priority, double riskScore) async {
  final payload = <String, Object?>{
    'event': 'design_lift_bootstrap_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'design_priority': priority,
    'risk_score': riskScore,
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
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
