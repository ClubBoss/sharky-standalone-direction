import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/learning_transfer_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/learning_transfer_summary.txt';
const String _summaryJsonPath = '$_reportsDir/learning_transfer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = LearningTransferEngineDashboard();
  final ok = await dashboard.run();
  if (!ok) exitCode = 2;
}

class LearningTransferEngineDashboard {
  final LearningTransferEngineService _service =
      const LearningTransferEngineService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing learning transfer inputs.');
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

    final adaptive = result.adaptiveContext.score;
    final retention = result.retentionKnowledge.score;
    final semantic = result.semanticDepth.score;
    final index = ((adaptive * 0.4) + (retention * 0.35) + (semantic * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(adaptive, retention, semantic, index, pass);
    final json = _buildJson(adaptive, retention, semantic, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(adaptive, retention, semantic, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Learning Transfer Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(LearningTransferEngineResult result) =>
      result.adaptiveContext.verdict == 'PASS' &&
      result.retentionKnowledge.verdict == 'PASS' &&
      result.semanticDepth.verdict == 'PASS';

  bool _timestampsAligned(LearningTransferEngineResult result) {
    final timestamps = <DateTime>[
      if (result.adaptiveContext.timestamp != null)
        result.adaptiveContext.timestamp!,
      if (result.retentionKnowledge.timestamp != null)
        result.retentionKnowledge.timestamp!,
      if (result.semanticDepth.timestamp != null)
        result.semanticDepth.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double adaptive,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('LEARNING TRANSFER SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Adaptive context: ${pct(adaptive)}')
      ..writeln('Retention knowledge: ${pct(retention)}')
      ..writeln('Semantic depth: ${pct(semantic)}')
      ..writeln('Learning Transfer Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double adaptive,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'adaptive_context_score': adaptive,
    'retention_knowledge_score': retention,
    'semantic_depth_index': semantic,
    'learning_transfer_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double adaptive,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'learning_transfer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'adaptive_context_score': adaptive,
      'retention_knowledge_score': retention,
      'semantic_depth_index': semantic,
      'learning_transfer_index': index,
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
