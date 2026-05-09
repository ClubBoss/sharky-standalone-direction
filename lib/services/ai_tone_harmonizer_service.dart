import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _aestheticPath =
    '$_reportsDir/adaptive_aesthetic_feedback_summary.json';
const String _calibrationPath =
    '$_reportsDir/ai_persona_calibration_summary.json';
const String _resonancePath = '$_reportsDir/ux_resonance_summary.json';

class AiToneHarmonizerService {
  const AiToneHarmonizerService();

  Future<AiToneHarmonyResult?> harmonize() async {
    final aesthetic = await _readNormalizedScore(
      _aestheticPath,
      keys: const ['adaptive_aesthetic_feedback_index', 'aesthetic_index'],
      percent: true,
    );
    final calibration = await _readNormalizedScore(
      _calibrationPath,
      keys: const ['persona_alignment', 'tone_alignment_index', 'alignment'],
      percent: true,
    );
    final resonance = await _readNormalizedScore(
      _resonancePath,
      keys: const ['average_resonance', 'ux_resonance_score'],
      percent: true,
    );

    if (aesthetic == null || calibration == null || resonance == null) {
      return null;
    }

    return AiToneHarmonyResult(
      aestheticScore: aesthetic,
      calibrationScore: calibration,
      resonanceScore: resonance,
    );
  }

  Future<double?> _readNormalizedScore(
    String path, {
    required List<String> keys,
    required bool percent,
  }) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, Object?>?;
      if (decoded == null) return null;
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;
        final value = _asDouble(decoded[key]);
        if (value == null) continue;
        final normalized = percent ? (value / 100) : value;
        return normalized.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }
}

class AiToneHarmonyResult {
  AiToneHarmonyResult({
    required this.aestheticScore,
    required this.calibrationScore,
    required this.resonanceScore,
  });

  final double aestheticScore;
  final double calibrationScore;
  final double resonanceScore;

  double get toneHarmonyIndex {
    final raw =
        (aestheticScore * 0.4) +
        (calibrationScore * 0.4) +
        (resonanceScore * 0.2);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
