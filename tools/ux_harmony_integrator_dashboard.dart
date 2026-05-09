import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ux_harmony_integrator_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ux_harmony_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ux_harmony_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final dashboard = UxHarmonyIntegratorDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class UxHarmonyIntegratorDashboard {
  final UxHarmonyIntegratorService _service = UxHarmonyIntegratorService();

  Future<bool> run() async {
    final result = await _service.computeHarmony();
    if (result == null) {
      stderr.writeln('Missing inputs for UX harmony integration.');
      return false;
    }

    final harmony = result.harmonyScore;
    final pass = harmony >= _threshold;

    final summaryText = _buildTextSummary(result, harmony, pass);
    final summaryJson = _buildJsonSummary(result, harmony, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, pass);
    });

    if (!pass) {
      stderr.writeln(
        'UX Harmony Score ${harmony.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  String _buildTextSummary(UxHarmonyResult result, double harmony, bool pass) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('UX HARMONY SUMMARY')
      ..writeln('==================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Persona alignment: ${pct(result.personaAlignment)}')
      ..writeln('UX resonance: ${pct(result.resonanceScore)}')
      ..writeln('Cognitive coherence: ${pct(result.coherenceScore)}')
      ..writeln('Harmony score: ${pct(harmony)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    UxHarmonyResult result,
    double harmony,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'persona_alignment': result.personaAlignment,
      'resonance_score': result.resonanceScore,
      'coherence_score': result.coherenceScore,
      'harmony_score': harmony,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(UxHarmonyResult result, bool pass) async {
    final payload = <String, Object?>{
      'event': 'ux_harmony_integrator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'persona_alignment': result.personaAlignment,
      'resonance_score': result.resonanceScore,
      'coherence_score': result.coherenceScore,
      'harmony_score': result.harmonyScore,
      'threshold': _threshold,
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
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
