import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_aesthetic_feedback_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/adaptive_aesthetic_feedback_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_aesthetic_feedback_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = AdaptiveAestheticFeedbackDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveAestheticFeedbackDashboard {
  final AdaptiveAestheticFeedbackService _service =
      const AdaptiveAestheticFeedbackService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Adaptive aesthetic feedback inputs missing or invalid.');
      return false;
    }

    final pass = result.aestheticIndex >= _threshold;
    final summaryText = _buildTextSummary(result, pass);
    final summaryJson = _buildJsonSummary(result, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Adaptive Aesthetic Feedback Index ${result.aestheticIndex.toStringAsFixed(3)} '
        'below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(AdaptiveAestheticFeedbackResult result, bool pass) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE AESTHETIC FEEDBACK SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Calibration score: ${pct(result.calibrationScore)}')
      ..writeln('Resonance score: ${pct(result.resonanceScore)}')
      ..writeln('Session feedback score: ${pct(result.sessionFeedbackScore)}')
      ..writeln(
        'Adaptive Aesthetic Feedback Index: ${pct(result.aestheticIndex)}',
      )
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AdaptiveAestheticFeedbackResult result,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'calibration_score': result.calibrationScore,
    'resonance_score': result.resonanceScore,
    'session_feedback_score': result.sessionFeedbackScore,
    'adaptive_aesthetic_feedback_index': result.aestheticIndex,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    AdaptiveAestheticFeedbackResult result,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_aesthetic_feedback_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'calibration_score': result.calibrationScore,
      'resonance_score': result.resonanceScore,
      'session_feedback_score': result.sessionFeedbackScore,
      'adaptive_aesthetic_feedback_index': result.aestheticIndex,
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
