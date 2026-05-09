import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/semantic_depth_analyzer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/semantic_depth_summary.txt';
const String _summaryJsonPath = '$_reportsDir/semantic_depth_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = SemanticDepthAnalyzerDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SemanticDepthAnalyzerDashboard {
  final SemanticDepthAnalyzerService _service =
      const SemanticDepthAnalyzerService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing semantic depth inputs.');
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

    final reinforcement = result.reinforcement.score;
    final adaptiveDrill = result.adaptiveDrill.score;
    final uxHarmony = result.uxHarmony.score;
    final index =
        ((reinforcement * 0.4) + (adaptiveDrill * 0.35) + (uxHarmony * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      reinforcement,
      adaptiveDrill,
      uxHarmony,
      index,
      pass,
    );
    final json = _buildJson(
      reinforcement,
      adaptiveDrill,
      uxHarmony,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        reinforcement,
        adaptiveDrill,
        uxHarmony,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Semantic Depth Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(SemanticDepthAnalyzerResult result) =>
      result.reinforcement.verdict == 'PASS' &&
      result.adaptiveDrill.verdict == 'PASS' &&
      result.uxHarmony.verdict == 'PASS';

  bool _timestampsAligned(SemanticDepthAnalyzerResult result) {
    final timestamps = <DateTime>[
      if (result.reinforcement.timestamp != null)
        result.reinforcement.timestamp!,
      if (result.adaptiveDrill.timestamp != null)
        result.adaptiveDrill.timestamp!,
      if (result.uxHarmony.timestamp != null) result.uxHarmony.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double reinforcement,
    double adaptiveDrill,
    double uxHarmony,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SEMANTIC DEPTH SUMMARY')
      ..writeln('=======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Content reinforcement: ${pct(reinforcement)}')
      ..writeln('Adaptive drill: ${pct(adaptiveDrill)}')
      ..writeln('UX harmony: ${pct(uxHarmony)}')
      ..writeln('Semantic Depth Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double reinforcement,
    double adaptiveDrill,
    double uxHarmony,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'content_reinforcement_score': reinforcement,
    'adaptive_drill_index': adaptiveDrill,
    'ux_harmony_score': uxHarmony,
    'semantic_depth_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double reinforcement,
    double adaptiveDrill,
    double uxHarmony,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'semantic_depth_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'content_reinforcement_score': reinforcement,
      'adaptive_drill_index': adaptiveDrill,
      'ux_harmony_score': uxHarmony,
      'semantic_depth_index': index,
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
