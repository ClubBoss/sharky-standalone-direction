import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ai_persona_refinement_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/ai_persona_refinement_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/ai_persona_refinement_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final dashboard = AiPersonaRefinementDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiPersonaRefinementDashboard {
  final AiPersonaRefinementService _service = AiPersonaRefinementService();

  Future<bool> run() async {
    final result = await _service.buildPersonas();
    final toneConsistency = result.toneConsistency;
    final missingPersona = result.personas
        .where((persona) => persona.persona.isEmpty)
        .toList();
    final pass = toneConsistency >= 90.0 && missingPersona.isEmpty;

    final summaryText = _buildTextSummary(result, toneConsistency, pass);
    final summaryJson = _buildJsonSummary(result, toneConsistency, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(toneConsistency, result.personas.length, pass);
    });

    if (!pass) {
      stderr.writeln(
        'AI persona refinement failed: tone consistency '
        '${toneConsistency.toStringAsFixed(2)}%',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    AiPersonaRefinementResult result,
    double toneConsistency,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('AI PERSONA REFINEMENT SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Tone consistency: ${toneConsistency.toStringAsFixed(2)}%')
      ..writeln('Personas detected: ${result.personas.length}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Persona distribution:');
    for (final persona in result.personas) {
      buffer.writeln(
        '  - ${persona.clusterName} (${persona.sampleSize}): ${persona.persona} '
        '| clarity ${persona.clarity.toStringAsFixed(1)}% | ${persona.tone}',
      );
    }
    buffer.writeln();
    buffer.writeln('Tone weights:');
    result.toneWeights.forEach((key, value) {
      buffer.writeln('  - $key: ${value.toStringAsFixed(2)}%');
    });
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AiPersonaRefinementResult result,
    double toneConsistency,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'tone_consistency': toneConsistency,
      'personas': result.personas
          .map(
            (persona) => {
              'cluster': persona.clusterName,
              'persona': persona.persona,
              'sample_size': persona.sampleSize,
              'clarity': persona.clarity,
              'tone': persona.tone,
            },
          )
          .toList(),
      'tone_weights': result.toneWeights,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double toneConsistency,
    int personaCount,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'ai_persona_refinement_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'tone_consistency': toneConsistency,
      'persona_count': personaCount,
      'threshold': 90.0,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod fails
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore if chmod fails
    }
  }
}
