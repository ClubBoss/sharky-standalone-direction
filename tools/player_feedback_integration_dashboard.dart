import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_feedback_integration_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/player_feedback_integration_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/player_feedback_integration_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final dashboard = PlayerFeedbackIntegrationDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PlayerFeedbackIntegrationDashboard {
  final PlayerFeedbackIntegrationService _service =
      const PlayerFeedbackIntegrationService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing player feedback inputs.');
      return false;
    }

    if (!_allPassed(result)) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    if (!_timestampsAligned(result)) {
      stderr.writeln('Inputs span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final index =
        ((result.feedbackScore.score * 0.4) +
                (result.personaScore.score * 0.35) +
                (result.uxScore.score * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      result.feedbackScore.score,
      result.personaScore.score,
      result.uxScore.score,
      index,
      pass,
    );
    final json = _buildJson(
      result.feedbackScore.score,
      result.personaScore.score,
      result.uxScore.score,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        result.feedbackScore.score,
        result.personaScore.score,
        result.uxScore.score,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Feedback Integration Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(PlayerFeedbackIntegrationResult result) =>
      result.feedbackScore.verdict == 'PASS' &&
      result.personaScore.verdict == 'PASS' &&
      result.uxScore.verdict == 'PASS';

  bool _timestampsAligned(PlayerFeedbackIntegrationResult result) {
    final timestamps = <DateTime>[
      if (result.feedbackScore.timestamp != null)
        result.feedbackScore.timestamp!,
      if (result.personaScore.timestamp != null) result.personaScore.timestamp!,
      if (result.uxScore.timestamp != null) result.uxScore.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double feedback,
    double persona,
    double ux,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PLAYER FEEDBACK INTEGRATION SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Explanation feedback: ${pct(feedback)}')
      ..writeln('Persona reaction: ${pct(persona)}')
      ..writeln('UX resonance: ${pct(ux)}')
      ..writeln('Feedback Integration Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double feedback,
    double persona,
    double ux,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'explanation_feedback_score': feedback,
    'persona_reaction_score': persona,
    'ux_resonance_score': ux,
    'feedback_integration_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double feedback,
    double persona,
    double ux,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_feedback_integration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'explanation_feedback_score': feedback,
      'persona_reaction_score': persona,
      'ux_resonance_score': ux,
      'feedback_integration_index': index,
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
