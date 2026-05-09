import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/contextual_progression_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/contextual_progression_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/contextual_progression_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = ContextualProgressionBridgeDashboard();
  final ok = await dashboard.run();
  if (!ok) exitCode = 2;
}

class ContextualProgressionBridgeDashboard {
  final ContextualProgressionBridgeService _service =
      const ContextualProgressionBridgeService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing contextual progression inputs.');
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

    final knowledge = result.knowledgeProgression.score;
    final retention = result.retentionKnowledge.score;
    final contextual = result.contextualLearning.score;
    final index = ((knowledge * 0.4) + (retention * 0.35) + (contextual * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(knowledge, retention, contextual, index, pass);
    final json = _buildJson(knowledge, retention, contextual, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(knowledge, retention, contextual, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Contextual Progression Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(ContextualProgressionBridgeResult result) =>
      result.knowledgeProgression.verdict == 'PASS' &&
      result.retentionKnowledge.verdict == 'PASS' &&
      result.contextualLearning.verdict == 'PASS';

  bool _timestampsAligned(ContextualProgressionBridgeResult result) {
    final timestamps = <DateTime>[
      if (result.knowledgeProgression.timestamp != null)
        result.knowledgeProgression.timestamp!,
      if (result.retentionKnowledge.timestamp != null)
        result.retentionKnowledge.timestamp!,
      if (result.contextualLearning.timestamp != null)
        result.contextualLearning.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double knowledge,
    double retention,
    double contextual,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONTEXTUAL PROGRESSION SUMMARY')
      ..writeln('===============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Knowledge progression: ${pct(knowledge)}')
      ..writeln('Retention knowledge: ${pct(retention)}')
      ..writeln('Contextual learning: ${pct(contextual)}')
      ..writeln('Contextual Progression Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double knowledge,
    double retention,
    double contextual,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'knowledge_progression_score': knowledge,
    'retention_knowledge_score': retention,
    'contextual_learning_score': contextual,
    'contextual_progression_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double knowledge,
    double retention,
    double contextual,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'contextual_progression_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'knowledge_progression_score': knowledge,
      'retention_knowledge_score': retention,
      'contextual_learning_score': contextual,
      'contextual_progression_index': index,
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
