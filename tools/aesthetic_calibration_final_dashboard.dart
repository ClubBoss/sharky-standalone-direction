import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/aesthetic_calibration_final_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/aesthetic_calibration_final_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = AestheticCalibrationFinalDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AestheticCalibrationFinalDashboard {
  final AestheticCalibrationFinalService _service =
      const AestheticCalibrationFinalService();

  Future<bool> run() async {
    final result = await _service.evaluate();
    if (result == null) {
      stderr.writeln('Final aesthetic calibration inputs missing.');
      return false;
    }

    final index = result.finalIndex;
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
        'Final Aesthetic Calibration Index ${index.toStringAsFixed(3)} below '
        '${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildText(
    AestheticCalibrationFinalResult result,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('AESTHETIC CALIBRATION FINAL SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual persona index: ${pct(result.personaScore)}')
      ..writeln('Cognitive aesthetic score: ${pct(result.cognitiveScore)}')
      ..writeln('Visual calibration score: ${pct(result.visualScore)}')
      ..writeln('Final Aesthetic Calibration Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    AestheticCalibrationFinalResult result,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_persona_index': result.personaScore,
    'cognitive_aesthetic_score': result.cognitiveScore,
    'visual_calibration_score': result.visualScore,
    'final_aesthetic_calibration_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    AestheticCalibrationFinalResult result,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'aesthetic_calibration_final_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_persona_index': result.personaScore,
      'cognitive_aesthetic_score': result.cognitiveScore,
      'visual_calibration_score': result.visualScore,
      'final_aesthetic_calibration_index': index,
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
