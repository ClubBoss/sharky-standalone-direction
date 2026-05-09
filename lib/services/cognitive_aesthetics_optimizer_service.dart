import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _layoutPath =
    '$_reportsDir/adaptive_layout_rebalancer_summary.json';
const String _tonePath = '$_reportsDir/ai_tone_harmonizer_summary.json';
const String _aestheticPath =
    '$_reportsDir/adaptive_aesthetic_feedback_summary.json';

class CognitiveAestheticsOptimizerService {
  const CognitiveAestheticsOptimizerService();

  Future<CognitiveAestheticsOptimization?> optimize() async {
    final layoutScore = await _readScore(
      _layoutPath,
      keys: const ['layout_balance_score', 'layout_score'],
    );
    final toneScore = await _readScore(
      _tonePath,
      keys: const ['tone_harmony_index', 'tone_harmony_score'],
    );
    final aestheticScore = await _readScore(
      _aestheticPath,
      keys: const [
        'adaptive_aesthetic_feedback_index',
        'aesthetic_feedback_score',
      ],
    );

    if (layoutScore == null || toneScore == null || aestheticScore == null) {
      return null;
    }

    return CognitiveAestheticsOptimization(
      layoutScore: layoutScore,
      toneScore: toneScore,
      aestheticScore: aestheticScore,
    );
  }

  Future<double?> _readScore(String path, {required List<String> keys}) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;
        final raw = _asDouble(decoded[key]);
        if (raw == null) continue;
        final normalized = raw > 1 ? raw / 100 : raw;
        return normalized.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }
}

class CognitiveAestheticsOptimization {
  CognitiveAestheticsOptimization({
    required this.layoutScore,
    required this.toneScore,
    required this.aestheticScore,
  });

  final double layoutScore;
  final double toneScore;
  final double aestheticScore;

  double get optimizationIndex {
    final raw =
        (layoutScore * 0.4) + (toneScore * 0.35) + (aestheticScore * 0.25);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
