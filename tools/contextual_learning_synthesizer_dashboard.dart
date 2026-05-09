import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/contextual_learning_synthesizer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/contextual_learning_summary.txt';
const String _summaryJsonPath = '$_reportsDir/contextual_learning_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = ContextualLearningSynthesizerDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContextualLearningSynthesizerDashboard {
  final ContextualLearningSynthesizerService _service =
      const ContextualLearningSynthesizerService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing contextual learning inputs.');
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

    final semantic = result.semanticDepth.score;
    final reinforcement = result.reinforcement.score;
    final uxResonance = result.uxResonance.score;
    final index =
        ((semantic * 0.4) + (reinforcement * 0.35) + (uxResonance * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(semantic, reinforcement, uxResonance, index, pass);
    final json = _buildJson(semantic, reinforcement, uxResonance, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(semantic, reinforcement, uxResonance, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Contextual Learning Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(ContextualLearningSynthesizerResult result) =>
      result.semanticDepth.verdict == 'PASS' &&
      result.reinforcement.verdict == 'PASS' &&
      result.uxResonance.verdict == 'PASS';

  bool _timestampsAligned(ContextualLearningSynthesizerResult result) {
    final timestamps = <DateTime>[
      if (result.semanticDepth.timestamp != null)
        result.semanticDepth.timestamp!,
      if (result.reinforcement.timestamp != null)
        result.reinforcement.timestamp!,
      if (result.uxResonance.timestamp != null) result.uxResonance.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double semantic,
    double reinforcement,
    double uxResonance,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONTEXTUAL LEARNING SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Semantic depth: ${pct(semantic)}')
      ..writeln('Content reinforcement: ${pct(reinforcement)}')
      ..writeln('UX resonance: ${pct(uxResonance)}')
      ..writeln('Contextual Learning Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double semantic,
    double reinforcement,
    double uxResonance,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'semantic_depth_index': semantic,
    'content_reinforcement_score': reinforcement,
    'ux_resonance_score': uxResonance,
    'contextual_learning_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double semantic,
    double reinforcement,
    double uxResonance,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'contextual_learning_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'semantic_depth_index': semantic,
      'content_reinforcement_score': reinforcement,
      'ux_resonance_score': uxResonance,
      'contextual_learning_index': index,
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
