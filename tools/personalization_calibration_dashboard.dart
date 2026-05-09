import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/personalization_calibration_engine.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/personalization_calibration_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/personalization_calibration_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _thresholdScore = 90.0;

Future<void> main(List<String> args) async {
  final dashboard = PersonalizationCalibrationDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PersonalizationCalibrationDashboard {
  final PersonalizationCalibrationEngine _engine =
      PersonalizationCalibrationEngine();

  Future<bool> run() async {
    final result = await _engine.calibrate();
    final pass = result.adaptationScore >= _thresholdScore;

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
        'Adaptation Score ${result.adaptationScore.toStringAsFixed(2)} below '
        '${_thresholdScore.toStringAsFixed(0)}.',
      );
    }

    return pass;
  }

  String _buildTextSummary(PersonalizationCalibrationResult result, bool pass) {
    final telemetry = result.telemetryMetrics;
    final adjustments = result.adjustments;
    final persona = result.personaSummary;

    final buffer = StringBuffer()
      ..writeln('PERSONALIZATION CALIBRATION SUMMARY')
      ..writeln('==================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Adaptation Score: ${result.adaptationScore.toStringAsFixed(2)}',
      )
      ..writeln('Threshold: ${_thresholdScore.toStringAsFixed(2)}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Telemetry averages (sample ${telemetry.sampleSize}):')
      ..writeln('  Engagement: ${telemetry.engagementAvg.toStringAsFixed(2)}%')
      ..writeln('  Retention: ${telemetry.retentionAvg.toStringAsFixed(2)}%')
      ..writeln('  Accuracy: ${telemetry.accuracyAvg.toStringAsFixed(2)}%')
      ..writeln()
      ..writeln(
        'Persona tone consistency: ${persona.toneConsistency.toStringAsFixed(2)}%',
      )
      ..writeln('Tone weights:')
      ..writeln(
        persona.toneWeights.isEmpty
            ? '  (none)'
            : persona.toneWeights.entries
                  .map(
                    (entry) =>
                        '  - ${entry.key}: ${entry.value.toStringAsFixed(2)}%',
                  )
                  .join('\n'),
      )
      ..writeln()
      ..writeln('Calibration adjustments:')
      ..writeln('  Learning rate: ${adjustments.learningRate}')
      ..writeln('  Hint density: ${adjustments.hintDensity}%')
      ..writeln('  Challenge balance: ${adjustments.challengeBalance}%');

    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    PersonalizationCalibrationResult result,
    bool pass,
  ) {
    final telemetry = result.telemetryMetrics;
    final adjustments = result.adjustments;
    return {
      'generated': DateTime.now().toIso8601String(),
      'adaptation_score': result.adaptationScore,
      'threshold': _thresholdScore,
      'telemetry': {
        'sample_size': telemetry.sampleSize,
        'engagement_avg': telemetry.engagementAvg,
        'retention_avg': telemetry.retentionAvg,
        'accuracy_avg': telemetry.accuracyAvg,
      },
      'persona_tone_consistency': result.personaSummary.toneConsistency,
      'tone_weights': result.personaSummary.toneWeights,
      'adjustments': {
        'learning_rate': adjustments.learningRate,
        'hint_density': adjustments.hintDensity,
        'challenge_balance': adjustments.challengeBalance,
      },
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    PersonalizationCalibrationResult result,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'personalization_calibration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'adaptation_score': result.adaptationScore,
      'threshold': _thresholdScore,
      'learning_rate': result.adjustments.learningRate,
      'hint_density': result.adjustments.hintDensity,
      'challenge_balance': result.adjustments.challengeBalance,
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
  } catch (_) {
    // ignore
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
