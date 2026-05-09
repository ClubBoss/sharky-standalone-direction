import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _personaCalibrationPath =
    '$_reportsDir/ai_persona_calibration_summary.json';
const String _resonancePath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _coherencePath =
    '$_reportsDir/cognitive_design_coherence_summary.json';

class UxHarmonyIntegratorService {
  Future<UxHarmonyResult?> computeHarmony() async {
    final persona = await _readJson(_personaCalibrationPath);
    final resonance = await _readJson(_resonancePath);
    final coherence = await _readJson(_coherencePath);
    if (persona == null || resonance == null || coherence == null) {
      return null;
    }

    final personaAlignment =
        (persona['average_alignment'] as num?)?.toDouble() ?? 0;
    final resonanceScore =
        (resonance['average_resonance'] as num?)?.toDouble() ?? 0;
    final coherenceScore =
        (coherence['cognitive_coherence_score'] as num?)?.toDouble() ?? 0;

    final harmony =
        (personaAlignment * 0.4) +
        (resonanceScore * 0.3) +
        (coherenceScore * 0.3);

    return UxHarmonyResult(
      personaAlignment: personaAlignment,
      resonanceScore: resonanceScore,
      coherenceScore: coherenceScore,
      harmonyScore: harmony.clamp(0, 1),
    );
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
}

class UxHarmonyResult {
  const UxHarmonyResult({
    required this.personaAlignment,
    required this.resonanceScore,
    required this.coherenceScore,
    required this.harmonyScore,
  });

  final double personaAlignment;
  final double resonanceScore;
  final double coherenceScore;
  final double harmonyScore;
}
