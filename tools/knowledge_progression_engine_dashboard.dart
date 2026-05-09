import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/knowledge_progression_engine_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/knowledge_progression_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/knowledge_progression_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = KnowledgeProgressionEngineDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class KnowledgeProgressionEngineDashboard {
  final KnowledgeProgressionEngineService _service =
      const KnowledgeProgressionEngineService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing knowledge progression inputs.');
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

    final skillConsolidation = result.skillConsolidation.score;
    final retention = result.retentionKnowledge.score;
    final semantic = result.semanticDepth.score;
    final index =
        ((skillConsolidation * 0.4) + (retention * 0.35) + (semantic * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      skillConsolidation,
      retention,
      semantic,
      index,
      pass,
    );
    final json = _buildJson(
      skillConsolidation,
      retention,
      semantic,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        skillConsolidation,
        retention,
        semantic,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Knowledge Progression Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(KnowledgeProgressionEngineResult result) =>
      result.skillConsolidation.verdict == 'PASS' &&
      result.retentionKnowledge.verdict == 'PASS' &&
      result.semanticDepth.verdict == 'PASS';

  bool _timestampsAligned(KnowledgeProgressionEngineResult result) {
    final timestamps = <DateTime>[
      if (result.skillConsolidation.timestamp != null)
        result.skillConsolidation.timestamp!,
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
    double skillConsolidation,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('KNOWLEDGE PROGRESSION SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Skill consolidation: ${pct(skillConsolidation)}')
      ..writeln('Retention knowledge: ${pct(retention)}')
      ..writeln('Semantic depth: ${pct(semantic)}')
      ..writeln('Knowledge Progression Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double skillConsolidation,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'skill_consolidation_score': skillConsolidation,
    'retention_knowledge_score': retention,
    'semantic_depth_index': semantic,
    'knowledge_progression_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double skillConsolidation,
    double retention,
    double semantic,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'knowledge_progression_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'skill_consolidation_score': skillConsolidation,
      'retention_knowledge_score': retention,
      'semantic_depth_index': semantic,
      'knowledge_progression_index': index,
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
