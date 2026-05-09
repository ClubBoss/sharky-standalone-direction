import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _personaBridgePath =
    '$_reportsDir/visual_persona_bridge_summary.json';
const String _cognitivePath =
    '$_reportsDir/cognitive_aesthetics_optimizer_summary.json';
const String _visualCalibrationPath =
    '$_reportsDir/visual_calibration_summary.json';

class AestheticCalibrationFinalService {
  const AestheticCalibrationFinalService();

  Future<AestheticCalibrationFinalResult?> evaluate() async {
    final personaScore = await _readNormalizedScore(
      _personaBridgePath,
      keys: const ['visual_persona_index', 'persona_index'],
    );
    final cognitiveScore = await _readNormalizedScore(
      _cognitivePath,
      keys: const ['aesthetic_optimization_index', 'aesthetic_score'],
    );
    final visualScore = await _readNormalizedScore(
      _visualCalibrationPath,
      keys: const ['visual_calibration_score', 'visual_calibration_index'],
    );

    if (personaScore == null || cognitiveScore == null || visualScore == null) {
      return null;
    }
    return AestheticCalibrationFinalResult(
      personaScore: personaScore,
      cognitiveScore: cognitiveScore,
      visualScore: visualScore,
    );
  }

  Future<double?> _readNormalizedScore(
    String path, {
    required List<String> keys,
  }) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;
        final raw = _asDouble(decoded[key]);
        if (raw == null) continue;
        final value = raw > 1 ? raw / 100 : raw;
        return value.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }
}

class AestheticCalibrationFinalResult {
  AestheticCalibrationFinalResult({
    required this.personaScore,
    required this.cognitiveScore,
    required this.visualScore,
  });

  final double personaScore;
  final double cognitiveScore;
  final double visualScore;

  double get finalIndex {
    final raw =
        (personaScore * 0.4) + (cognitiveScore * 0.35) + (visualScore * 0.25);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
