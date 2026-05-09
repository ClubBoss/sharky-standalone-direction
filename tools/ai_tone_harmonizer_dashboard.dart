import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ai_tone_harmonizer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ai_tone_harmonizer_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ai_tone_harmonizer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = AiToneHarmonizerDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiToneHarmonizerDashboard {
  final AiToneHarmonizerService _service = const AiToneHarmonizerService();

  Future<bool> run() async {
    final result = await _service.harmonize();
    if (result == null) {
      stderr.writeln('Tone harmonizer inputs missing.');
      return false;
    }

    final index = result.toneHarmonyIndex;
    final pass = index >= _threshold;

    final summaryText = _buildTextSummary(result, index, pass);
    final summaryJson = _buildJsonSummary(result, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Tone Harmony Index ${index.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    AiToneHarmonyResult result,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('AI TONE HARMONIZER SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Adaptive aesthetic score: ${pct(result.aestheticScore)}')
      ..writeln('Persona calibration score: ${pct(result.calibrationScore)}')
      ..writeln('UX resonance score: ${pct(result.resonanceScore)}')
      ..writeln('Tone Harmony Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AiToneHarmonyResult result,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'adaptive_aesthetic_score': result.aestheticScore,
    'persona_calibration_score': result.calibrationScore,
    'ux_resonance_score': result.resonanceScore,
    'tone_harmony_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    AiToneHarmonyResult result,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'ai_tone_harmonizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'adaptive_aesthetic_score': result.aestheticScore,
      'persona_calibration_score': result.calibrationScore,
      'ux_resonance_score': result.resonanceScore,
      'tone_harmony_index': index,
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
