import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_persona_evolution_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/adaptive_persona_evolution_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_persona_evolution_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final dashboard = AdaptivePersonaEvolutionDashboard();
  final ok = await dashboard.run();
  if (!ok) exitCode = 2;
}

class AdaptivePersonaEvolutionDashboard {
  final AdaptivePersonaEvolutionService _service =
      const AdaptivePersonaEvolutionService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing persona evolution inputs.');
      return false;
    }

    if (!_utterAllPass(result)) {
      stderr.writeln('One or more components failed.');
      return false;
    }

    if (!_timestampsAligned(result)) {
      stderr.writeln('${_timeWindow.inHours}h window violated.');
      return false;
    }

    final score =
        ((result.personalization.score * 0.4) +
                (result.emotion.score * 0.35) +
                (result.feedback.score * 0.25))
            .clamp(0.0, 1.0);
    final pass = score >= _threshold;

    final text = _buildText(
      result.personalization.score,
      result.emotion.score,
      result.feedback.score,
      score,
      pass,
    );
    final json = _buildJson(
      result.personalization.score,
      result.emotion.score,
      result.feedback.score,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(result, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Persona Evolution Index ${(score * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _utterAllPass(AdaptivePersonaEvolutionResult result) =>
      result.personalization.verdict == 'PASS' &&
      result.emotion.verdict == 'PASS' &&
      result.feedback.verdict == 'PASS';

  bool _timestampsAligned(AdaptivePersonaEvolutionResult result) {
    final timestamps = <DateTime>[
      if (result.personalization.timestamp != null)
        result.personalization.timestamp!,
      if (result.emotion.timestamp != null) result.emotion.timestamp!,
      if (result.feedback.timestamp != null) result.feedback.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double personalization,
    double emotion,
    double feedback,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE PERSONA EVOLUTION SUMMARY')
      ..writeln('=================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Personalization score: ${pct(personalization)}')
      ..writeln('Emotion cohesion score: ${pct(emotion)}')
      ..writeln('Feedback integration score: ${pct(feedback)}')
      ..writeln('Persona Evolution Index: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double personalization,
    double emotion,
    double feedback,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'personalization_score': personalization,
    'emotion_cohesion_score': emotion,
    'feedback_integration_score': feedback,
    'persona_evolution_index': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    AdaptivePersonaEvolutionResult result,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_persona_evolution_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'personalization_score': result.personalization.score,
      'emotion_cohesion_score': result.emotion.score,
      'feedback_integration_score': result.feedback.score,
      'persona_evolution_index': score,
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
