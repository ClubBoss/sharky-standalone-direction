import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/player_explanation_feedback_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/player_explanation_feedback_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/player_explanation_feedback_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = PlayerExplanationFeedbackDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PlayerExplanationFeedbackDashboard {
  final PlayerExplanationFeedbackService _service =
      const PlayerExplanationFeedbackService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing player explanation inputs.');
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

    final score =
        ((result.profileSurface.score * 0.4) +
                (result.sessionAccuracy.score * 0.35) +
                (result.uxResonance.score * 0.25))
            .clamp(0.0, 1.0);
    final pass = score >= _threshold;

    final text = _buildText(
      result.profileSurface.score,
      result.sessionAccuracy.score,
      result.uxResonance.score,
      score,
      pass,
    );
    final json = _buildJson(
      result.profileSurface.score,
      result.sessionAccuracy.score,
      result.uxResonance.score,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        result.profileSurface.score,
        result.sessionAccuracy.score,
        result.uxResonance.score,
        score,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Feedback Index ${(score * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(PlayerExplanationFeedbackResult result) =>
      result.profileSurface.verdict == 'PASS' &&
      result.sessionAccuracy.verdict == 'PASS' &&
      result.uxResonance.verdict == 'PASS';

  bool _timestampsAligned(PlayerExplanationFeedbackResult result) {
    final timestamps = <DateTime>[
      if (result.profileSurface.timestamp != null)
        result.profileSurface.timestamp!,
      if (result.sessionAccuracy.timestamp != null)
        result.sessionAccuracy.timestamp!,
      if (result.uxResonance.timestamp != null) result.uxResonance.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double profile,
    double session,
    double ux,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PLAYER EXPLANATION FEEDBACK SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Profile surface: ${pct(profile)}')
      ..writeln('Session accuracy: ${pct(session)}')
      ..writeln('UX resonance: ${pct(ux)}')
      ..writeln('Feedback Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double profile,
    double session,
    double ux,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'profile_surface_score': profile,
    'session_accuracy': session,
    'ux_resonance': ux,
    'player_explanation_feedback_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double profile,
    double session,
    double ux,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'player_explanation_feedback_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'profile_surface_score': profile,
      'session_accuracy': session,
      'ux_resonance': ux,
      'player_explanation_feedback_index': index,
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
