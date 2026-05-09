import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/personalization_readiness_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/personalization_context_bundle.txt';
const String _summaryJsonPath =
    '$_reportsDir/personalization_context_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PersonalizationReadinessBridgeService();
  PersonalizationContextBundle bundle;

  try {
    bundle = await service.build();
  } on PersonalizationReadinessBridgeException catch (error) {
    stderr.writeln('personalization_readiness_bridge: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln(
      'personalization_readiness_bridge: unexpected error: $error',
    );
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
      'personalization_readiness_bridge: report ready (risk=${bundle.personalizationRiskScore.toStringAsFixed(3)}).',
    );
  } catch (error) {
    stderr.writeln(
      'personalization_readiness_bridge: failed to write reports: $error',
    );
    exitCode = 2;
  }
}

String _buildSummary(PersonalizationContextBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PERSONALIZATION CONTEXT BUNDLE')
    ..writeln('==============================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Visual cohesion index: ${bundle.visualCohesionIndex}')
    ..writeln('Token mismatches: ${bundle.tokenMismatches}')
    ..writeln('Spacing inconsistencies: ${bundle.spacingInconsistencies}')
    ..writeln('Layout anomalies: ${bundle.layoutAnomalies}')
    ..writeln(
      'Component diversity score: ${bundle.componentDiversityScore.toStringAsFixed(3)}',
    )
    ..writeln()
    ..writeln('Priority modules (${bundle.priorityModules.length}):')
    ..writeln(bundle.priorityModules.join(', '))
    ..writeln()
    ..writeln('Mid modules (${bundle.midModules.length}):')
    ..writeln(bundle.midModules.join(', '))
    ..writeln()
    ..writeln('Fallback modules (${bundle.fallbackModules.length}):')
    ..writeln(bundle.fallbackModules.join(', '))
    ..writeln()
    ..writeln('All modules (${bundle.allModules.length}):')
    ..writeln(bundle.allModules.join(', '))
    ..writeln()
    ..writeln(
      'Personalization risk score: ${bundle.personalizationRiskScore.toStringAsFixed(3)}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(PersonalizationContextBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'personalization_readiness_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'personalization_risk_score': bundle.personalizationRiskScore,
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
