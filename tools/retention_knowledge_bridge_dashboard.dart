import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/retention_knowledge_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/retention_knowledge_summary.txt';
const String _summaryJsonPath = '$_reportsDir/retention_knowledge_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = RetentionKnowledgeBridgeDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionKnowledgeBridgeDashboard {
  final RetentionKnowledgeBridgeService _service =
      const RetentionKnowledgeBridgeService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing retention knowledge inputs.');
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

    final contextual = result.contextualLearning.score;
    final retention = result.retentionGrowth.score;
    final semantic = result.semanticDepth.score;
    final index = ((contextual * 0.4) + (retention * 0.35) + (semantic * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(contextual, retention, semantic, index, pass);
    final json = _buildJson(contextual, retention, semantic, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(contextual, retention, semantic, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Retention Knowledge Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(RetentionKnowledgeBridgeResult result) =>
      result.contextualLearning.verdict == 'PASS' &&
      result.retentionGrowth.verdict == 'PASS' &&
      result.semanticDepth.verdict == 'PASS';

  bool _timestampsAligned(RetentionKnowledgeBridgeResult result) {
    final timestamps = <DateTime>[
      if (result.contextualLearning.timestamp != null)
        result.contextualLearning.timestamp!,
      if (result.retentionGrowth.timestamp != null)
        result.retentionGrowth.timestamp!,
      if (result.semanticDepth.timestamp != null)
        result.semanticDepth.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double contextual,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('RETENTION KNOWLEDGE SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Contextual learning: ${pct(contextual)}')
      ..writeln('Retention growth: ${pct(retention)}')
      ..writeln('Semantic depth: ${pct(semantic)}')
      ..writeln('Retention Knowledge Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double contextual,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'contextual_learning_score': contextual,
    'retention_growth_score': retention,
    'semantic_depth_index': semantic,
    'retention_knowledge_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double contextual,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_knowledge_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'contextual_learning_score': contextual,
      'retention_growth_score': retention,
      'semantic_depth_index': semantic,
      'retention_knowledge_index': index,
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
