import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/high_order_synthesis_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/high_order_synthesis_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/high_order_synthesis_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = HighOrderSynthesisDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class HighOrderSynthesisDashboard {
  final HighOrderSynthesisService _service = const HighOrderSynthesisService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Missing high-order synthesis inputs.');
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

    final contextual = result.conceptualSkill.score;
    final meta = result.metaProgression.score;
    final learning = result.learningTransfer.score;
    final index = ((contextual * 0.4) + (meta * 0.35) + (learning * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(contextual, meta, learning, index, pass);
    final json = _buildJson(contextual, meta, learning, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(contextual, meta, learning, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'High-Order Synthesis Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  bool _allPassed(HighOrderSynthesisResult result) =>
      result.conceptualSkill.verdict == 'PASS' &&
      result.metaProgression.verdict == 'PASS' &&
      result.learningTransfer.verdict == 'PASS';

  bool _timestampsAligned(HighOrderSynthesisResult result) {
    final timestamps = <DateTime>[
      if (result.conceptualSkill.timestamp != null)
        result.conceptualSkill.timestamp!,
      if (result.metaProgression.timestamp != null)
        result.metaProgression.timestamp!,
      if (result.learningTransfer.timestamp != null)
        result.learningTransfer.timestamp!,
    ];
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  String _buildText(
    double contextual,
    double meta,
    double learning,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('HIGH-ORDER SYNTHESIS SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Conceptual skill: ${pct(contextual)}')
      ..writeln('Meta progression: ${pct(meta)}')
      ..writeln('Learning transfer: ${pct(learning)}')
      ..writeln('High-Order Synthesis Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double contextual,
    double meta,
    double learning,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'conceptual_skill_score': contextual,
    'meta_progression_score': meta,
    'learning_transfer_score': learning,
    'high_order_synthesis_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double contextual,
    double meta,
    double learning,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'high_order_synthesis_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'conceptual_skill_score': contextual,
      'meta_progression_score': meta,
      'learning_transfer_score': learning,
      'high_order_synthesis_index': index,
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
