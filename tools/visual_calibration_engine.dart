import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualStabilityPath =
    '$_reportsDir/visual_telemetry_aggregator_summary.json';
const String _designLiftPath = '$_reportsDir/design_lift_phase1_summary.json';
const String _visualCohesionPath = '$_reportsDir/visual_cohesion_summary.json';
const String _summaryTextPath = '$_reportsDir/visual_calibration_summary.txt';
const String _summaryJsonPath = '$_reportsDir/visual_calibration_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final engine = VisualCalibrationEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualCalibrationEngine {
  Future<bool> run() async {
    final stability = await _extractScore(
      _visualStabilityPath,
      'visual_stability_index',
    );
    final lift = await _extractScore(_designLiftPath, 'design_lift_score');
    final cohesion = await _extractScore(
      _visualCohesionPath,
      'design_cohesion_score',
    );

    if (stability == null || lift == null || cohesion == null) {
      stderr.writeln('Missing calibration inputs.');
      return false;
    }

    final score = ((stability * 0.4) + (lift * 0.35) + (cohesion * 0.25)).clamp(
      0.0,
      1.0,
    );
    final pass = score >= _threshold;

    final summaryText = _buildTextSummary(
      stability,
      lift,
      cohesion,
      score,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      stability,
      lift,
      cohesion,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(stability, lift, cohesion, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Visual Calibration Score ${score.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  Future<double?> _extractScore(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, Object?>) {
        final raw = data[key];
        return _normalize(raw);
      }
    } catch (_) {}
    return null;
  }

  double? _normalize(Object? value) {
    if (value is num) {
      return value.clamp(0.0, 1.0).toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        final normalized = parsed <= 1 ? parsed : parsed / 100;
        return normalized.clamp(0.0, 1.0).toDouble();
      }
    }
    return null;
  }

  String _buildTextSummary(
    double stability,
    double lift,
    double cohesion,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL CALIBRATION SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Stability Index: ${pct(stability)}')
      ..writeln('Design Lift Score: ${pct(lift)}')
      ..writeln('Design Cohesion Score: ${pct(cohesion)}')
      ..writeln('Visual Calibration Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double stability,
    double lift,
    double cohesion,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_stability_index': stability,
    'design_lift_score': lift,
    'design_cohesion_score': cohesion,
    'visual_calibration_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double stability,
    double lift,
    double cohesion,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_calibration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_stability_index': stability,
      'design_lift_score': lift,
      'design_cohesion_score': cohesion,
      'visual_calibration_score': score,
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
