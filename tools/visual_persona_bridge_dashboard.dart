import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/visual_persona_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/visual_persona_bridge_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_persona_bridge_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = VisualPersonaBridgeDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualPersonaBridgeDashboard {
  final VisualPersonaBridgeService _service =
      const VisualPersonaBridgeService();

  Future<bool> run() async {
    final result = await _service.build();
    if (result == null) {
      stderr.writeln('Visual persona bridge inputs missing.');
      return false;
    }

    final index = result.personaIndex;
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
        'Visual Persona Index ${index.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    VisualPersonaBridgeResult result,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL PERSONA BRIDGE SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Emotion cohesion score: ${pct(result.emotionScore)}')
      ..writeln('Tone harmony score: ${pct(result.toneScore)}')
      ..writeln('Layout balance score: ${pct(result.layoutScore)}')
      ..writeln('Visual Persona Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    VisualPersonaBridgeResult result,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'emotion_cohesion_score': result.emotionScore,
    'tone_harmony_score': result.toneScore,
    'layout_balance_score': result.layoutScore,
    'visual_persona_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    VisualPersonaBridgeResult result,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_persona_bridge_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'emotion_cohesion_score': result.emotionScore,
      'tone_harmony_score': result.toneScore,
      'layout_balance_score': result.layoutScore,
      'visual_persona_index': index,
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
