import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cohesionPath =
    '$_reportsDir/visual_cohesion_dashboard_v2_summary.txt';
const String _contrastPath = '$_reportsDir/contrast_accessibility_summary.txt';
const String _motionPath = '$_reportsDir/ui_micro_animation_summary.txt';
const String _stressPath = '$_reportsDir/dynamic_visual_stress_summary.txt';
const String _summaryTextPath =
    '$_reportsDir/visual_cohesion_qa_v2_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_cohesion_qa_v2_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warningThreshold = 85.0;
const double _passThreshold = 95.0;

Future<void> main(List<String> args) async {
  final qa = VisualCohesionQaV2();
  final ok = await qa.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualCohesionQaV2 {
  Future<bool> run() async {
    final cohesion = await _extractPercent(
      _cohesionPath,
      'Overall Visual Health Index',
    );
    final contrast = await _extractPercent(_contrastPath, 'Contrast score');
    final motion = await _scoreFromLatency(_motionPath);
    final stress = await _scoreFromStress(_stressPath);

    final vhi =
        (contrast * 0.3) + (cohesion * 0.3) + (motion * 0.2) + (stress * 0.2);
    final verdict = vhi >= _passThreshold
        ? 'PASS'
        : vhi >= _warningThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      cohesion: cohesion,
      contrast: contrast,
      motion: motion,
      stress: stress,
      vhi: vhi,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      cohesion: cohesion,
      contrast: contrast,
      motion: motion,
      stress: stress,
      vhi: vhi,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(vhi, verdict);
    });

    if (vhi < _warningThreshold) {
      stderr.writeln(
        'Visual Cohesion QA v2 VHI ${vhi.toStringAsFixed(2)} below 85%.',
      );
    }

    return vhi >= _warningThreshold;
  }

  Future<double> _extractPercent(String path, String label) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final contents = await file.readAsString();
    final regex = RegExp('$label:?\\s*([0-9.]+)%');
    final match = regex.firstMatch(contents);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  Future<double> _scoreFromLatency(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final contents = await file.readAsString();
    final match = RegExp(r'P95\s*:\s*([0-9.]+)').firstMatch(contents);
    if (match == null) return 0;
    final p95 = double.tryParse(match.group(1) ?? '') ?? 0;
    if (p95 <= 0) return 0;
    const target = 16.0;
    return (target / p95 * 100).clamp(0, 100);
  }

  Future<double> _scoreFromStress(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    final contents = await file.readAsString();
    final match = RegExp(
      r'Frame statistics \(ms\):[\s\S]*?- P95\s*:\s*([0-9.]+)',
    ).firstMatch(contents);
    if (match == null) return 0;
    final p95 = double.tryParse(match.group(1) ?? '') ?? 0;
    const target = 16.0;
    if (p95 <= 0) return 0;
    return (target / p95 * 100).clamp(0, 100);
  }

  String _buildTextSummary({
    required double cohesion,
    required double contrast,
    required double motion,
    required double stress,
    required double vhi,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('VISUAL COHESION QA v2 SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Health Index: ${vhi.toStringAsFixed(2)}%')
      ..writeln(
        'Thresholds: PASS ≥ ${_passThreshold.toStringAsFixed(0)}%, WARN ≥ ${_warningThreshold.toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict')
      ..writeln()
      ..writeln('Inputs:')
      ..writeln('  Contrast score: ${contrast.toStringAsFixed(2)}%')
      ..writeln('  Cohesion index: ${cohesion.toStringAsFixed(2)}%')
      ..writeln('  Motion score: ${motion.toStringAsFixed(2)}%')
      ..writeln('  Stress score: ${stress.toStringAsFixed(2)}%');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double cohesion,
    required double contrast,
    required double motion,
    required double stress,
    required double vhi,
    required String verdict,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'vhi': vhi,
      'verdict': verdict,
      'thresholds': {'pass': _passThreshold, 'warn': _warningThreshold},
      'metrics': {
        'contrast': contrast,
        'cohesion': cohesion,
        'motion': motion,
        'stress': stress,
      },
    };
  }

  Future<void> _appendTelemetry(double vhi, String verdict) async {
    final payload = <String, Object?>{
      'event': 'visual_cohesion_qa_v2_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'vhi': vhi,
      'verdict': verdict,
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
