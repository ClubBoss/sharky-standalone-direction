import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/visual_design_lift_spec_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/visual_design_lift_spec.txt';
const String _summaryJsonPath = '$_reportsDir/visual_design_lift_spec.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = VisualDesignLiftSpecService();
  VisualDesignLiftSpecBundle bundle;

  try {
    bundle = await service.build();
  } on VisualDesignLiftSpecException catch (error) {
    stderr.writeln('visual_design_lift_spec: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('visual_design_lift_spec: unexpected error: $error');
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
      'visual_design_lift_spec: generated (risk=${bundle.riskSummary['visual_cohesion_index']}).',
    );
  } catch (error) {
    stderr.writeln('visual_design_lift_spec: failed to write reports: $error');
    exitCode = 2;
  }
}

String _buildSummary(VisualDesignLiftSpecBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('VISUAL DESIGN LIFT SPECIFICATION')
    ..writeln('===============================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Color rules: ${bundle.colorRules}')
    ..writeln('Spacing rules: ${bundle.spacingRules}')
    ..writeln('Radii rules: ${bundle.radiiRules}')
    ..writeln('Shadow rules: ${bundle.shadowRules}')
    ..writeln('Layout rules: ${bundle.layoutRules}')
    ..writeln('Component rules: ${bundle.componentRules}')
    ..writeln('Hint integration: ${bundle.hintIntegration}')
    ..writeln('Risk summary: ${bundle.riskSummary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(VisualDesignLiftSpecBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'visual_design_lift_spec_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'visual_cohesion_index': bundle.riskSummary['visual_cohesion_index'],
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
