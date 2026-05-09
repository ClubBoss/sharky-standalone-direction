import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ai_personalization_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ai_personalization_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ai_personalization_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = AiPersonalizationBridgeDashboard();
  final ok = await dashboard.run();
  if (!ok) exitCode = 2;
}

class AiPersonalizationBridgeDashboard {
  final AiPersonalizationBridgeService _service =
      const AiPersonalizationBridgeService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing AI personalization inputs.');
      return false;
    }

    if (!_allPass(result)) {
      stderr.writeln('One or more AI inputs failed.');
      return false;
    }

    if (!_timestampsAligned(result)) {
      stderr.writeln('Inputs exceed ${_timeWindow.inHours}h.');
      return false;
    }

    final score =
        ((result.xpReaction.score * 0.4) +
                (result.tone.score * 0.35) +
                (result.uxResonance.score * 0.25))
            .clamp(0.0, 1.0);
    final pass = score >= _threshold;

    final text = _buildText(result, score, pass);
    final json = _buildJson(result, score, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(result, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Personalization Index ${(score * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPass(AiPersonalizationBridgeResult result) =>
      result.xpReaction.verdict == 'PASS' &&
      result.tone.verdict == 'PASS' &&
      result.uxResonance.verdict == 'PASS';

  bool _timestampsAligned(AiPersonalizationBridgeResult result) {
    final timestamps = <DateTime>[
      if (result.xpReaction.timestamp != null) result.xpReaction.timestamp!,
      if (result.tone.timestamp != null) result.tone.timestamp!,
      if (result.uxResonance.timestamp != null) result.uxResonance.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    AiPersonalizationBridgeResult result,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('AI PERSONALIZATION SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('XP reaction: ${pct(result.xpReaction.score)}')
      ..writeln('Tone harmony: ${pct(result.tone.score)}')
      ..writeln('UX resonance: ${pct(result.uxResonance.score)}')
      ..writeln('Personalization Index: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    AiPersonalizationBridgeResult result,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'xp_reaction_score': result.xpReaction.score,
    'tone_harmony_score': result.tone.score,
    'ux_resonance_score': result.uxResonance.score,
    'personalization_index': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    AiPersonalizationBridgeResult result,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'ai_personalization_bridge_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'xp_reaction_score': result.xpReaction.score,
      'tone_harmony_score': result.tone.score,
      'ux_resonance_score': result.uxResonance.score,
      'personalization_index': score,
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
