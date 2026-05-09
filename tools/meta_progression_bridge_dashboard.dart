import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/meta_progression_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/meta_progression_summary.txt';
const String _summaryJsonPath = '$_reportsDir/meta_progression_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = MetaProgressionBridgeDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MetaProgressionBridgeDashboard {
  final MetaProgressionBridgeService _service =
      const MetaProgressionBridgeService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing meta progression inputs.');
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

    final contextual = result.contextualProgression.score;
    final knowledge = result.knowledgeProgression.score;
    final uxHarmony = result.uxHarmony.score;
    final index = ((contextual * 0.4) + (knowledge * 0.35) + (uxHarmony * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(contextual, knowledge, uxHarmony, index, pass);
    final json = _buildJson(contextual, knowledge, uxHarmony, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(contextual, knowledge, uxHarmony, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Meta Progression Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(MetaProgressionBridgeResult result) =>
      result.contextualProgression.verdict == 'PASS' &&
      result.knowledgeProgression.verdict == 'PASS' &&
      result.uxHarmony.verdict == 'PASS';

  bool _timestampsAligned(MetaProgressionBridgeResult result) {
    final timestamps = <DateTime>[
      if (result.contextualProgression.timestamp != null)
        result.contextualProgression.timestamp!,
      if (result.knowledgeProgression.timestamp != null)
        result.knowledgeProgression.timestamp!,
      if (result.uxHarmony.timestamp != null) result.uxHarmony.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double contextual,
    double knowledge,
    double uxHarmony,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('META PROGRESSION SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Contextual progression: ${pct(contextual)}')
      ..writeln('Knowledge progression: ${pct(knowledge)}')
      ..writeln('UX harmony: ${pct(uxHarmony)}')
      ..writeln('Meta Progression Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double contextual,
    double knowledge,
    double uxHarmony,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'contextual_progression_score': contextual,
    'knowledge_progression_score': knowledge,
    'ux_harmony_score': uxHarmony,
    'meta_progression_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double contextual,
    double knowledge,
    double uxHarmony,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'meta_progression_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'contextual_progression_score': contextual,
      'knowledge_progression_score': knowledge,
      'ux_harmony_score': uxHarmony,
      'meta_progression_index': index,
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
