import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/personalization_kernel_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/personalization_kernel_bundle.txt';
const String _summaryJsonPath =
    '$_reportsDir/personalization_kernel_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PersonalizationKernelService();
  PersonalizationKernelBundle bundle;

  try {
    bundle = await service.build();
  } on PersonalizationKernelException catch (error) {
    stderr.writeln('personalization_kernel: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('personalization_kernel: unexpected error: $error');
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
      'personalization_kernel: saved (risk=${bundle.personalizationRiskScore.toStringAsFixed(3)}).',
    );
  } catch (error) {
    stderr.writeln('personalization_kernel: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(PersonalizationKernelBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PERSONALIZATION KERNEL BUNDLE')
    ..writeln('=============================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Visual adjustments:')
    ..writeln('  increase_contrast: ${bundle.increaseContrast}')
    ..writeln('  reduce_spacing_noise: ${bundle.reduceSpacingNoise}')
    ..writeln('  suggest_token_unification: ${bundle.suggestTokenUnification}')
    ..writeln('Learning adjustments:')
    ..writeln('  priority_boost: ${bundle.priorityModules.join(', ')}')
    ..writeln('  mid_attention: ${bundle.midModules.join(', ')}')
    ..writeln(
      'UI style hints: use_consistent_padding, limit_nested_rows, prefer_standard_radii',
    )
    ..writeln('Explanation priors:')
    ..writeln('  needs_more_context: ${bundle.personalizationRiskScore > 0.5}')
    ..writeln(
      '  prefer_brief_prompts: ${bundle.personalizationRiskScore < 0.25}',
    )
    ..writeln(
      'Persona baseline: sharky_context_sensitivity=${bundle.personalizationRiskScore}',
    )
    ..writeln('Persona hint style: friendly_minimal');
  return buffer.toString();
}

Future<void> _appendTelemetry(PersonalizationKernelBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'personalization_kernel_completed',
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
