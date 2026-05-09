import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualAiPath =
    '$_reportsDir/visual_ai_integration_bridge_summary.json';
const String _uxResonancePath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _phiSummaryPath = '$_reportsDir/phi_v2_bootstrap_summary.json';
const String _adaptiveDesignPath =
    '$_reportsDir/adaptive_design_reactor_summary.json';
const String _summaryTextPath =
    '$_reportsDir/cognitive_design_coherence_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/cognitive_design_coherence_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final engine = CognitiveDesignCoherenceEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class CognitiveDesignCoherenceEngine {
  Future<bool> run() async {
    final visualAi = await _readJson(_visualAiPath);
    final resonance = await _readJson(_uxResonancePath);
    final phi = await _readJson(_phiSummaryPath);
    if (visualAi == null || resonance == null || phi == null) {
      stderr.writeln(
        'Missing required summaries (visual AI, UX resonance, or Phi bootstrap).',
      );
      return false;
    }

    final visualScore =
        (visualAi['visual_ai_cohesion_index'] as num?)?.toDouble() ?? 0;
    final resonanceScore =
        (resonance['average_resonance'] as num?)?.toDouble() ?? 0;
    final designLift = (phi['design_lift_index'] as num?)?.toDouble() ?? 0;
    var ccs =
        (visualScore * 0.35) + (resonanceScore * 0.35) + (designLift * 0.30);

    final adaptive = await _readJson(_adaptiveDesignPath);
    if (adaptive != null) {
      ccs = (ccs * 1.02).clamp(0, 1);
    } else {
      ccs = ccs.clamp(0, 1);
    }

    final verdict = ccs >= _passThreshold
        ? 'PASS'
        : ccs >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      visualScore,
      resonanceScore,
      designLift,
      ccs,
      verdict,
      adaptiveApplied: adaptive != null,
    );
    final summaryJson = _buildJsonSummary(
      visualScore,
      resonanceScore,
      designLift,
      ccs,
      verdict,
      adaptiveApplied: adaptive != null,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        visualScore,
        resonanceScore,
        designLift,
        ccs,
        verdict,
      );
    });

    if (ccs < _warnThreshold) {
      stderr.writeln(
        'Cognitive Coherence Score ${ccs.toStringAsFixed(3)} below 0.85.',
      );
    } else if (ccs < _passThreshold) {
      stderr.writeln(
        'Cognitive Coherence Score ${ccs.toStringAsFixed(3)} warning range.',
      );
    }

    return ccs >= _passThreshold;
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
    double resonance,
    double designLift,
    double ccs,
    String verdict, {
    required bool adaptiveApplied,
  }) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('COGNITIVE DESIGN COHERENCE SUMMARY')
      ..writeln('==================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual-AI Cohesion: ${pct(visual)}')
      ..writeln('UX Emotional Resonance: ${pct(resonance)}')
      ..writeln('Design Lift Index: ${pct(designLift)}')
      ..writeln('Cognitive Coherence Score: ${pct(ccs)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict')
      ..writeln(
        'Adaptive Design bonus: ${adaptiveApplied ? 'applied (×1.02 cap)' : 'not applied'}',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double visual,
    double resonance,
    double designLift,
    double ccs,
    String verdict, {
    required bool adaptiveApplied,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'visual_ai_cohesion': visual,
      'ux_resonance': resonance,
      'design_lift_index': designLift,
      'cognitive_coherence_score': ccs,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'adaptive_bonus_applied': adaptiveApplied,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double visual,
    double resonance,
    double designLift,
    double ccs,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'cognitive_design_coherence_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_ai_cohesion': visual,
      'ux_resonance': resonance,
      'design_lift_index': designLift,
      'cognitive_coherence_score': ccs,
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
