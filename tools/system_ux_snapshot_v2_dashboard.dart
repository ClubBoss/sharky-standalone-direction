import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/system_ux_snapshot_v2_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/system_ux_snapshot_v2_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/system_ux_snapshot_v2_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = SystemUxSnapshotV2Dashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SystemUxSnapshotV2Dashboard {
  final SystemUxSnapshotV2Service _service = const SystemUxSnapshotV2Service();

  Future<bool> run() async {
    final result = await _service.summarize();
    if (result == null) {
      stderr.writeln('System UX V2 inputs missing.');
      return false;
    }

    final index = result.integrityIndex;
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
        'System UX Integrity Index ${index.toStringAsFixed(3)} below threshold.',
      );
    }

    return pass;
  }

  String _buildText(SystemUxSnapshotV2Result result, double index, bool pass) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SYSTEM UX SNAPSHOT v2 SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('UX Harmony Score: ${pct(result.harmonyScore)}')
      ..writeln('Final Aesthetic Score: ${pct(result.aestheticScore)}')
      ..writeln('Visual Calibration Score: ${pct(result.visualScore)}')
      ..writeln('System UX Integrity Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    SystemUxSnapshotV2Result result,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'ux_harmony_score': result.harmonyScore,
    'final_aesthetic_score': result.aestheticScore,
    'visual_calibration_score': result.visualScore,
    'system_ux_integrity_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    SystemUxSnapshotV2Result result,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'system_ux_snapshot_v2_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'ux_harmony_score': result.harmonyScore,
      'final_aesthetic_score': result.aestheticScore,
      'visual_calibration_score': result.visualScore,
      'system_ux_integrity_index': index,
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
