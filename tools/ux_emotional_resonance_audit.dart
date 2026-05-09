import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ux_emotional_resonance_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/ux_emotional_resonance_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _minAverageScore = 85.0;

Future<void> main(List<String> args) async {
  final audit = UxEmotionalResonanceAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class UxEmotionalResonanceAudit {
  final UxEmotionalResonanceService _service = UxEmotionalResonanceService();

  Future<bool> run() async {
    final result = await _service.calculate();
    final pass = result.globalScore >= _minAverageScore;

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
        'Emotional Resonance average ${result.globalScore.toStringAsFixed(2)} '
        'below ${_minAverageScore.toStringAsFixed(0)}.',
      );
    }

    return pass;
  }

  String _buildTextSummary(UxEmotionalResonanceResult result, bool pass) {
    final buffer = StringBuffer()
      ..writeln('UX EMOTIONAL RESONANCE SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Average resonance: ${result.globalScore.toStringAsFixed(2)}')
      ..writeln('Threshold: ${_minAverageScore.toStringAsFixed(2)}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Telemetry ratios:')
      ..writeln(
        '  Positive/Neutral feedback ratio: '
        '${(result.telemetry.positiveNeutralRatio * 100).toStringAsFixed(2)}%',
      )
      ..writeln(
        '  Session consistency: '
        '${(result.telemetry.sessionConsistency * 100).toStringAsFixed(2)}%',
      )
      ..writeln();
    if (result.clusters.isEmpty) {
      buffer.writeln('No persona clusters available.');
    } else {
      buffer.writeln('Cluster resonance scores:');
      for (final cluster in result.clusters) {
        buffer.writeln(
          '  - ${cluster.clusterName} (${cluster.persona}): '
          '${cluster.resonanceScore.toStringAsFixed(2)} (sample ${cluster.sampleSize})',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    UxEmotionalResonanceResult result,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'average_resonance': result.globalScore,
      'threshold': _minAverageScore,
      'telemetry': {
        'positive_neutral_ratio': result.telemetry.positiveNeutralRatio,
        'session_consistency': result.telemetry.sessionConsistency,
        'sample_size': result.telemetry.sampleSize,
      },
      'clusters': result.clusters
          .map(
            (cluster) => {
              'cluster': cluster.clusterName,
              'persona': cluster.persona,
              'sample_size': cluster.sampleSize,
              'score': cluster.resonanceScore,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    UxEmotionalResonanceResult result,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'ux_emotional_resonance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'average_resonance': result.globalScore,
      'threshold': _minAverageScore,
      'sample_size': result.telemetry.sampleSize,
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
