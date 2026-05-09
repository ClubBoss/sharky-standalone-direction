import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualPath = '$_reportsDir/visual_cohesion_final_summary.json';
const String _aiSummaryPath = '$_reportsDir/ai_personalization_summary.json';
const String _resonancePath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _adaptiveDesignPath =
    '$_reportsDir/adaptive_design_reactor_summary.json';
const String _summaryTextPath =
    '$_reportsDir/visual_ai_integration_bridge_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_ai_integration_bridge_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final bridge = VisualAiIntegrationBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualAiIntegrationBridge {
  Future<bool> run() async {
    final visual = await _readJson(_visualPath);
    final ai = await _readJson(_aiSummaryPath);
    final resonance = await _readJson(_resonancePath);
    if (visual == null || ai == null || resonance == null) {
      stderr.writeln('Missing required summaries for Visual-AI Integration.');
      return false;
    }

    final visualScore =
        (visual['final_health'] as num?)?.toDouble() ??
        (visual['visual_health'] as num?)?.toDouble() ??
        0;
    final aiScore =
        (ai['monetization_insight_score'] as num?)?.toDouble() ??
        (ai['ai_persona_score'] as num?)?.toDouble() ??
        0;
    final resonanceScore =
        (resonance['average_resonance'] as num?)?.toDouble() ?? 0;

    var vaci = (visualScore * 0.4) + (aiScore * 0.3) + (resonanceScore * 0.3);

    final adaptiveDesign = await _readJson(_adaptiveDesignPath);
    if (adaptiveDesign != null) {
      vaci = (vaci * 1.03).clamp(0, 1);
    } else {
      vaci = vaci.clamp(0, 1);
    }

    final verdict = vaci >= _passThreshold
        ? 'PASS'
        : vaci >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      visualScore,
      aiScore,
      resonanceScore,
      vaci,
      verdict,
      adaptiveIncluded: adaptiveDesign != null,
    );
    final summaryJson = _buildJsonSummary(
      visualScore,
      aiScore,
      resonanceScore,
      vaci,
      verdict,
      adaptiveIncluded: adaptiveDesign != null,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        visualScore,
        aiScore,
        resonanceScore,
        vaci,
        verdict,
      );
    });

    if (vaci < _warnThreshold) {
      stderr.writeln(
        'Visual-AI Cohesion Index ${vaci.toStringAsFixed(3)} below 0.85.',
      );
    } else if (vaci < _passThreshold) {
      stderr.writeln(
        'Visual-AI Cohesion Index ${vaci.toStringAsFixed(3)} warning range.',
      );
    }

    return vaci >= _passThreshold;
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
    double ai,
    double resonance,
    double vaci,
    String verdict, {
    required bool adaptiveIncluded,
  }) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL-AI INTEGRATION SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Cohesion Score: ${pct(visual)}')
      ..writeln('AI Personalization Score: ${pct(ai)}')
      ..writeln('Emotional Resonance Score: ${pct(resonance)}')
      ..writeln('Visual-AI Cohesion Index: ${pct(vaci)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict')
      ..writeln(
        'Adaptive design bonus: ${adaptiveIncluded ? 'applied (×1.03 cap)' : 'not applied'}',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double visual,
    double ai,
    double resonance,
    double vaci,
    String verdict, {
    required bool adaptiveIncluded,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'visual_cohesion_score': visual,
      'ai_personalization_score': ai,
      'emotional_resonance_score': resonance,
      'visual_ai_cohesion_index': vaci,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'adaptive_bonus_applied': adaptiveIncluded,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double visual,
    double ai,
    double resonance,
    double vaci,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_ai_integration_bridge_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_cohesion_score': visual,
      'ai_personalization_score': ai,
      'emotional_resonance_score': resonance,
      'visual_ai_cohesion_index': vaci,
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
