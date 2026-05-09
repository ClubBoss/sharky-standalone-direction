import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualPath = '$_reportsDir/visual_cohesion_final_summary.json';
const String _adaptivePath =
    '$_reportsDir/adaptive_design_reactor_summary.json';
const String _phiPath = '$_reportsDir/phi_v2_bootstrap_summary.json';
const String _summaryTextPath = '$_reportsDir/design_cohesion_summary.txt';
const String _summaryJsonPath = '$_reportsDir/design_cohesion_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final verifier = DesignCohesionVerifier();
  final ok = await verifier.run();
  if (!ok) {
    exitCode = 2;
  }
}

class DesignCohesionVerifier {
  Future<bool> run() async {
    final visual = await _readJson(_visualPath);
    final adaptive = await _readJson(_adaptivePath);
    final phi = await _readJson(_phiPath);

    if (visual == null || adaptive == null || phi == null) {
      stderr.writeln('Missing required design cohesion inputs.');
      return false;
    }

    final visualScore =
        (visual['visual_ai_cohesion_index'] as num?)?.toDouble() ??
        (visual['final_health'] as num?)?.toDouble() ??
        0;
    final adaptiveScore =
        (adaptive['final_health'] as num?)?.toDouble() ??
        (adaptive['final_visual_health'] as num?)?.toDouble() ??
        0;
    final bootstrapScore = (phi['design_lift_index'] as num?)?.toDouble() ?? 0;

    final cohesion =
        (visualScore * 0.4) + (adaptiveScore * 0.3) + (bootstrapScore * 0.3);
    final clampedCohesion = cohesion.clamp(0, 1).toDouble();

    final verdict = clampedCohesion >= _passThreshold
        ? 'PASS'
        : clampedCohesion >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      visualScore,
      adaptiveScore,
      bootstrapScore,
      clampedCohesion,
      verdict,
    );
    final summaryJson = _buildJsonSummary(
      visualScore,
      adaptiveScore,
      bootstrapScore,
      clampedCohesion,
      verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        visualScore,
        adaptiveScore,
        bootstrapScore,
        clampedCohesion,
        verdict,
      );
    });

    if (clampedCohesion < _warnThreshold) {
      stderr.writeln(
        'Design Cohesion Score ${clampedCohesion.toStringAsFixed(3)} below 0.85.',
      );
    } else if (clampedCohesion < _passThreshold) {
      stderr.writeln(
        'Design Cohesion Score ${clampedCohesion.toStringAsFixed(3)} warning range.',
      );
    }

    return clampedCohesion >= _passThreshold;
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  String _buildTextSummary(
    double visual,
    double adaptive,
    double bootstrap,
    double cohesion,
    String verdict,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('DESIGN COHESION SUMMARY')
      ..writeln('======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Cohesion: ${pct(visual)}')
      ..writeln('Adaptive Design Health: ${pct(adaptive)}')
      ..writeln('Design Lift Index: ${pct(bootstrap)}')
      ..writeln('Design Cohesion Score: ${pct(cohesion)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double visual,
    double adaptive,
    double bootstrap,
    double cohesion,
    String verdict,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'visual_cohesion': visual,
      'adaptive_design_health': adaptive,
      'design_lift_index': bootstrap,
      'design_cohesion_score': cohesion,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double visual,
    double adaptive,
    double bootstrap,
    double cohesion,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'design_cohesion_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_cohesion': visual,
      'adaptive_design_health': adaptive,
      'design_lift_index': bootstrap,
      'design_cohesion_score': cohesion,
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
