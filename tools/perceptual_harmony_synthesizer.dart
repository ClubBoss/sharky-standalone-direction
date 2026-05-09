import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cognitivePath =
    '$_reportsDir/cognitive_design_coherence_summary.json';
const String _visualPath = '$_reportsDir/visual_cohesion_final_summary.json';
const String _resonancePath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _summaryTextPath = '$_reportsDir/perceptual_harmony_summary.txt';
const String _summaryJsonPath = '$_reportsDir/perceptual_harmony_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final synthesizer = PerceptualHarmonySynthesizer();
  final ok = await synthesizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PerceptualHarmonySynthesizer {
  Future<bool> run() async {
    final cognitive = await _readJson(_cognitivePath);
    final visual = await _readJson(_visualPath);
    final resonance = await _readJson(_resonancePath);
    if (cognitive == null || visual == null || resonance == null) {
      stderr.writeln(
        'Missing required summaries for perceptual harmony (cognitive/visual/resonance).',
      );
      return false;
    }

    final cognitiveScore =
        (cognitive['cognitive_coherence_score'] as num?)?.toDouble() ?? 0;
    final visualScore =
        (visual['visual_ai_cohesion_index'] as num?)?.toDouble() ??
        (visual['visual_health'] as num?)?.toDouble() ??
        0;
    final resonanceScore =
        (resonance['average_resonance'] as num?)?.toDouble() ?? 0;

    final phi =
        (cognitiveScore * 0.4) + (visualScore * 0.3) + (resonanceScore * 0.3);
    final clampedPhi = phi.clamp(0, 1).toDouble();
    final verdict = clampedPhi >= _passThreshold
        ? 'PASS'
        : clampedPhi >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      cognitiveScore,
      visualScore,
      resonanceScore,
      clampedPhi,
      verdict,
    );
    final summaryJson = _buildJsonSummary(
      cognitiveScore,
      visualScore,
      resonanceScore,
      clampedPhi,
      verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        cognitiveScore,
        visualScore,
        resonanceScore,
        clampedPhi,
        verdict,
      );
    });

    if (clampedPhi < _warnThreshold) {
      stderr.writeln(
        'Perceptual Harmony Index ${clampedPhi.toStringAsFixed(3)} below 0.85.',
      );
    } else if (clampedPhi < _passThreshold) {
      stderr.writeln(
        'Perceptual Harmony Index ${clampedPhi.toStringAsFixed(3)} warning range.',
      );
    }

    return clampedPhi >= _passThreshold;
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
    double cognitive,
    double visual,
    double resonance,
    double phi,
    String verdict,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PERCEPTUAL HARMONY SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Cognitive Coherence: ${pct(cognitive)}')
      ..writeln('Visual Cohesion: ${pct(visual)}')
      ..writeln('UX Resonance: ${pct(resonance)}')
      ..writeln('Perceptual Harmony Index: ${pct(phi)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double cognitive,
    double visual,
    double resonance,
    double phi,
    String verdict,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'cognitive_coherence': cognitive,
      'visual_cohesion': visual,
      'ux_resonance': resonance,
      'perceptual_harmony_index': phi,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double cognitive,
    double visual,
    double resonance,
    double phi,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'perceptual_harmony_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'cognitive_coherence': cognitive,
      'visual_cohesion': visual,
      'ux_resonance': resonance,
      'perceptual_harmony_index': phi,
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
