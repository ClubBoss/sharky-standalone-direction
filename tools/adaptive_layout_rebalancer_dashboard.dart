import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_layout_rebalancer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/adaptive_layout_rebalancer_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_layout_rebalancer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = AdaptiveLayoutRebalancerDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveLayoutRebalancerDashboard {
  final AdaptiveLayoutRebalancerService _service =
      const AdaptiveLayoutRebalancerService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Adaptive layout rebalancer inputs missing.');
      return false;
    }

    final score = result.layoutBalanceScore;
    final pass = score >= _threshold;

    final summaryText = _buildTextSummary(result, score, pass);
    final summaryJson = _buildJsonSummary(result, score, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Layout Balance Score ${score.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    AdaptiveLayoutRebalancerResult result,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE LAYOUT REBALANCER SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Tone harmony score: ${pct(result.toneScore)}')
      ..writeln('Visual calibration score: ${pct(result.visualScore)}')
      ..writeln('UX resonance score: ${pct(result.resonanceScore)}')
      ..writeln('Layout Balance Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AdaptiveLayoutRebalancerResult result,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'tone_harmony_score': result.toneScore,
    'visual_calibration_score': result.visualScore,
    'ux_resonance_score': result.resonanceScore,
    'layout_balance_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    AdaptiveLayoutRebalancerResult result,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_layout_rebalancer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'tone_harmony_score': result.toneScore,
      'visual_calibration_score': result.visualScore,
      'ux_resonance_score': result.resonanceScore,
      'layout_balance_score': score,
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
