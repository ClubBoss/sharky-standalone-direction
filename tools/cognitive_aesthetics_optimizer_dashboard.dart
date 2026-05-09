import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/cognitive_aesthetics_optimizer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/cognitive_aesthetics_optimizer_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/cognitive_aesthetics_optimizer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = CognitiveAestheticsOptimizerDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class CognitiveAestheticsOptimizerDashboard {
  final CognitiveAestheticsOptimizerService _service =
      const CognitiveAestheticsOptimizerService();

  Future<bool> run() async {
    final result = await _service.optimize();
    if (result == null) {
      stderr.writeln('Cognitive aesthetics inputs missing.');
      return false;
    }

    final index = result.optimizationIndex;
    final pass = index >= _threshold;

    final summaryText = _buildText(result, index, pass);
    final summaryJson = _buildJson(result, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Aesthetic Optimization Index ${index.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildText(
    CognitiveAestheticsOptimization result,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('COGNITIVE AESTHETICS OPTIMIZER SUMMARY')
      ..writeln('======================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Layout balance score: ${pct(result.layoutScore)}')
      ..writeln('Tone harmony score: ${pct(result.toneScore)}')
      ..writeln('Aesthetic feedback score: ${pct(result.aestheticScore)}')
      ..writeln('Aesthetic Optimization Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    CognitiveAestheticsOptimization result,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'layout_balance_score': result.layoutScore,
    'tone_harmony_score': result.toneScore,
    'aesthetic_feedback_score': result.aestheticScore,
    'aesthetic_optimization_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    CognitiveAestheticsOptimization result,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'cognitive_aesthetics_optimizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'layout_balance_score': result.layoutScore,
      'tone_harmony_score': result.toneScore,
      'aesthetic_feedback_score': result.aestheticScore,
      'aesthetic_optimization_index': index,
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
