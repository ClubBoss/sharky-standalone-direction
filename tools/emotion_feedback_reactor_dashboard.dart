import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/emotion_feedback_reactor_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/emotion_feedback_reactor_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/emotion_feedback_reactor_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = EmotionFeedbackReactorDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class EmotionFeedbackReactorDashboard {
  final EmotionFeedbackReactorService _service =
      const EmotionFeedbackReactorService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Emotion feedback reactor inputs missing.');
      return false;
    }

    final index = result.cohesionIndex;
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
        'Emotional Cohesion Index ${index.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    EmotionFeedbackReactorResult result,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('EMOTION FEEDBACK REACTOR SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('UX resonance score: ${pct(result.resonanceScore)}')
      ..writeln('Persona reaction score: ${pct(result.personaScore)}')
      ..writeln('Cognitive aesthetic score: ${pct(result.aestheticScore)}')
      ..writeln('Emotional Cohesion Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    EmotionFeedbackReactorResult result,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'ux_resonance_score': result.resonanceScore,
    'persona_reaction_score': result.personaScore,
    'cognitive_aesthetic_score': result.aestheticScore,
    'emotional_cohesion_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    EmotionFeedbackReactorResult result,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'emotion_feedback_reactor_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'ux_resonance_score': result.resonanceScore,
      'persona_reaction_score': result.personaScore,
      'cognitive_aesthetic_score': result.aestheticScore,
      'emotional_cohesion_index': index,
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
