import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/content_reinforcement_synthesizer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/content_reinforcement_synthesizer_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/content_reinforcement_synthesizer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = ContentReinforcementSynthesizerDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContentReinforcementSynthesizerDashboard {
  final ContentReinforcementSynthesizerService _service =
      const ContentReinforcementSynthesizerService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing content reinforcement inputs.');
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

    final evolution = result.evolution.score;
    final retention = result.retention.score;
    final drill = result.drill.score;
    final index = ((evolution * 0.4) + (retention * 0.35) + (drill * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(evolution, retention, drill, index, pass);
    final json = _buildJson(evolution, retention, drill, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(evolution, retention, drill, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Content Reinforcement Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(ContentReinforcementSynthesizerResult result) =>
      result.evolution.verdict == 'PASS' &&
      result.retention.verdict == 'PASS' &&
      result.drill.verdict == 'PASS';

  bool _timestampsAligned(ContentReinforcementSynthesizerResult result) {
    final timestamps = <DateTime>[
      if (result.evolution.timestamp != null) result.evolution.timestamp!,
      if (result.retention.timestamp != null) result.retention.timestamp!,
      if (result.drill.timestamp != null) result.drill.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double evolution,
    double retention,
    double drill,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONTENT REINFORCEMENT SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Content evolution: ${pct(evolution)}')
      ..writeln('Retention growth: ${pct(retention)}')
      ..writeln('Adaptive drill: ${pct(drill)}')
      ..writeln('Content Reinforcement Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double evolution,
    double retention,
    double drill,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'content_evolution_index': evolution,
    'retention_growth_score': retention,
    'adaptive_drill_index': drill,
    'content_reinforcement_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double evolution,
    double retention,
    double drill,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'content_reinforcement_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'content_evolution_index': evolution,
      'retention_growth_score': retention,
      'adaptive_drill_index': drill,
      'content_reinforcement_index': index,
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
