import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/xp_reaction_synchronizer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/xp_reaction_summary.txt';
const String _summaryJsonPath = '$_reportsDir/xp_reaction_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = XpReactionSynchronizerDashboard();
  final ok = await dashboard.run();
  if (!ok) exitCode = 2;
}

class XpReactionSynchronizerDashboard {
  final XpReactionSynchronizerService _service =
      const XpReactionSynchronizerService();

  Future<bool> run() async {
    final data = await _service.evaluate();
    if (data == null) {
      stderr.writeln('XP reaction inputs missing.');
      return false;
    }

    if (!_allPass(data)) {
      stderr.writeln('One or more XP reaction components failed.');
      return false;
    }

    if (!_timestampsAligned(data)) {
      stderr.writeln('Timestamps exceed ${_timeWindow.inHours}h.');
      return false;
    }

    final index =
        ((data.feedbackDetail.score * 0.4) +
                (data.sessionDetail.score * 0.35) +
                (data.personaDetail.score * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      data.feedbackDetail.score,
      data.sessionDetail.score,
      data.personaDetail.score,
      index,
      pass,
    );
    final json = _buildJson(
      data.feedbackDetail.score,
      data.sessionDetail.score,
      data.personaDetail.score,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        data.feedbackDetail.score,
        data.sessionDetail.score,
        data.personaDetail.score,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'XP Reaction Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPass(XpReactionSynchronizerResult data) =>
      data.feedbackDetail.verdict == 'PASS' &&
      data.sessionDetail.verdict == 'PASS' &&
      data.personaDetail.verdict == 'PASS';

  bool _timestampsAligned(XpReactionSynchronizerResult data) {
    final timestamps = <DateTime>[
      if (data.feedbackDetail.timestamp != null) data.feedbackDetail.timestamp!,
      if (data.sessionDetail.timestamp != null) data.sessionDetail.timestamp!,
      if (data.personaDetail.timestamp != null) data.personaDetail.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double feedback,
    double session,
    double persona,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('XP REACTION SYNCHRONIZER SUMMARY')
      ..writeln('===============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Explanation feedback: ${pct(feedback)}')
      ..writeln('Session accuracy: ${pct(session)}')
      ..writeln('Persona reaction: ${pct(persona)}')
      ..writeln('XP Reaction Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double feedback,
    double session,
    double persona,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'explanation_feedback_score': feedback,
    'session_accuracy': session,
    'persona_reaction_score': persona,
    'xp_reaction_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double feedback,
    double session,
    double persona,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'xp_reaction_synchronizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'explanation_feedback_score': feedback,
      'session_accuracy': session,
      'persona_reaction_score': persona,
      'xp_reaction_index': index,
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
