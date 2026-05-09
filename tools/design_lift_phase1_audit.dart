import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualStabilityPath =
    '$_reportsDir/visual_telemetry_aggregator_summary.json';
const String _visualPolishPath = '$_reportsDir/visual_ux_polish_summary.json';
const String _designCohesionPath = '$_reportsDir/design_cohesion_summary.json';
const String _summaryTextPath = '$_reportsDir/design_lift_phase1_summary.txt';
const String _summaryJsonPath = '$_reportsDir/design_lift_phase1_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final audit = DesignLiftPhase1Audit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class DesignLiftPhase1Audit {
  Future<bool> run() async {
    final visualStability = await _extractScore(
      _visualStabilityPath,
      key: 'visual_stability_index',
    );
    final visualPolish = await _extractScore(
      _visualPolishPath,
      key: 'visual_ux_polish_index',
    );
    final cohesion = await _extractScore(
      _designCohesionPath,
      key: 'design_cohesion_score',
    );

    if (visualStability == null || visualPolish == null || cohesion == null) {
      stderr.writeln('Missing design lift inputs.');
      return false;
    }

    final score = ((visualStability + visualPolish + cohesion) / 3).clamp(
      0.0,
      1.0,
    );
    final pass = score >= _threshold;

    final summaryText = _buildText(
      visualStability,
      visualPolish,
      cohesion,
      score,
      pass,
    );
    final summaryJson = _buildJson(
      visualStability,
      visualPolish,
      cohesion,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        visualStability,
        visualPolish,
        cohesion,
        score,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Design Lift Score ${score.toStringAsFixed(3)} below threshold ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  Future<double?> _extractScore(String path, {required String key}) async {
    final data = await _readJson(path);
    if (data == null) return null;
    final raw = data[key];
    return _normalize(raw);
  }

  Future<Map<String, Object?>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, Object?>) return decoded;
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

  String _buildText(
    double stability,
    double polish,
    double cohesion,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('DESIGN LIFT PHASE 1 SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Stability Index: ${pct(stability)}')
      ..writeln('Visual UX Polish Index: ${pct(polish)}')
      ..writeln('Design Cohesion Score: ${pct(cohesion)}')
      ..writeln('Design Lift Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double stability,
    double polish,
    double cohesion,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_stability_index': stability,
    'visual_ux_polish_index': polish,
    'design_cohesion_score': cohesion,
    'design_lift_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double stability,
    double polish,
    double cohesion,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'design_lift_phase1_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_stability_index': stability,
      'visual_ux_polish_index': polish,
      'design_cohesion_score': cohesion,
      'design_lift_score': score,
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
