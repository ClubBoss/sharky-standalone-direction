import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/conceptual_skill_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/conceptual_skill_summary.txt';
const String _summaryJsonPath = '$_reportsDir/conceptual_skill_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = ConceptualSkillBridgeDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ConceptualSkillBridgeDashboard {
  final ConceptualSkillBridgeService _service =
      const ConceptualSkillBridgeService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing conceptual skill inputs.');
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
    final consolidation = result.skillConsolidation.score;
    final learning = result.learningTransfer.score;
    final index =
        ((contextual * 0.4) + (consolidation * 0.35) + (learning * 0.25)).clamp(
          0.0,
          1.0,
        );
    final pass = index >= _threshold;

    final text = _buildText(contextual, consolidation, learning, index, pass);
    final json = _buildJson(contextual, consolidation, learning, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(contextual, consolidation, learning, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Conceptual Skill Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(ConceptualSkillBridgeResult result) =>
      result.contextualProgression.verdict == 'PASS' &&
      result.skillConsolidation.verdict == 'PASS' &&
      result.learningTransfer.verdict == 'PASS';

  bool _timestampsAligned(ConceptualSkillBridgeResult result) {
    final timestamps = <DateTime>[
      if (result.contextualProgression.timestamp != null)
        result.contextualProgression.timestamp!,
      if (result.skillConsolidation.timestamp != null)
        result.skillConsolidation.timestamp!,
      if (result.learningTransfer.timestamp != null)
        result.learningTransfer.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double contextual,
    double consolidation,
    double learning,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONCEPTUAL SKILL SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Contextual progression: ${pct(contextual)}')
      ..writeln('Skill consolidation: ${pct(consolidation)}')
      ..writeln('Learning transfer: ${pct(learning)}')
      ..writeln('Conceptual Skill Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double contextual,
    double consolidation,
    double learning,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'contextual_progression_score': contextual,
    'skill_consolidation_score': consolidation,
    'learning_transfer_score': learning,
    'conceptual_skill_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double contextual,
    double consolidation,
    double learning,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'conceptual_skill_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'contextual_progression_score': contextual,
      'skill_consolidation_score': consolidation,
      'learning_transfer_score': learning,
      'conceptual_skill_index': index,
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
