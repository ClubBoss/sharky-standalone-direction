import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _tonePath = '$_reportsDir/ai_tone_harmonizer_summary.json';
const String _visualCalibrationPath =
    '$_reportsDir/visual_calibration_summary.json';
const String _resonancePath = '$_reportsDir/ux_resonance_summary.json';

class AdaptiveLayoutRebalancerService {
  const AdaptiveLayoutRebalancerService();

  Future<AdaptiveLayoutRebalancerResult?> evaluate() async {
    final toneScore = await _readNormalizedScore(
      _tonePath,
      keys: const ['tone_harmony_index', 'tone_score'],
      percent: true,
    );
    final visualScore = await _readNormalizedScore(
      _visualCalibrationPath,
      keys: const ['visual_calibration_score', 'visual_calibration_index'],
      percent: true,
    );
    final resonanceScore = await _readNormalizedScore(
      _resonancePath,
      keys: const ['average_resonance', 'ux_resonance_score'],
      percent: true,
    );

    if (toneScore == null || visualScore == null || resonanceScore == null) {
      return null;
    }

    return AdaptiveLayoutRebalancerResult(
      toneScore: toneScore,
      visualScore: visualScore,
      resonanceScore: resonanceScore,
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
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
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

class AdaptiveLayoutRebalancerResult {
  AdaptiveLayoutRebalancerResult({
    required this.toneScore,
    required this.visualScore,
    required this.resonanceScore,
  });

  final double toneScore;
  final double visualScore;
  final double resonanceScore;

  double get layoutBalanceScore {
    final raw =
        (toneScore * 0.4) + (visualScore * 0.35) + (resonanceScore * 0.25);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
