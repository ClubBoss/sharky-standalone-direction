import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ai_persona_calibration_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/ai_persona_calibration_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/ai_persona_calibration_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final dashboard = AiPersonaCalibrationDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiPersonaCalibrationDashboard {
  final AiPersonaCalibrationService _service = AiPersonaCalibrationService();

  Future<bool> run() async {
    final result = await _service.calibrate();
    if (result == null) {
      stderr.writeln(
        'Unable to compute AI persona calibration (missing inputs).',
      );
      return false;
    }

    final score = result.averageAlignment;
    final pass = score >= _threshold;

    final summaryText = _buildTextSummary(result, score, pass);
    final summaryJson = _buildJsonSummary(result, score, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'AI Persona Alignment ${score.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    AiPersonaCalibrationResult result,
    double score,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('AI PERSONA CALIBRATION SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Average alignment: ${(score * 100).toStringAsFixed(2)}%')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    for (final alignment in result.alignments.take(20)) {
      buffer.writeln(
        '  - ${alignment.cluster} (${alignment.persona}): '
        '${(alignment.alignment * 100).toStringAsFixed(2)}% '
        '(sample ${alignment.sampleSize})',
      );
    }
    if (result.alignments.length > 20) {
      buffer.writeln(
        '  ... +${result.alignments.length - 20} persona clusters',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    AiPersonaCalibrationResult result,
    double score,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'average_alignment': score,
      'threshold': _threshold,
      'alignments': result.alignments
          .map(
            (alignment) => {
              'cluster': alignment.cluster,
              'persona': alignment.persona,
              'alignment': alignment.alignment,
              'sample_size': alignment.sampleSize,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double score, bool pass) async {
    final payload = <String, Object?>{
      'event': 'ai_persona_calibration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'average_alignment': score,
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
