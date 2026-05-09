import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _emotionPath =
    '$_reportsDir/emotion_feedback_reactor_summary.json';
const String _tonePath = '$_reportsDir/ai_tone_harmonizer_summary.json';
const String _layoutPath =
    '$_reportsDir/adaptive_layout_rebalancer_summary.json';

class VisualPersonaBridgeService {
  const VisualPersonaBridgeService();

  Future<VisualPersonaBridgeResult?> build() async {
    final emotionScore = await _readScore(
      _emotionPath,
      keys: const ['emotional_cohesion_index', 'emotion_feedback_score'],
    );
    final toneScore = await _readScore(
      _tonePath,
      keys: const ['tone_harmony_index', 'tone_harmony_score'],
    );
    final layoutScore = await _readScore(
      _layoutPath,
      keys: const ['layout_balance_score', 'layout_score'],
    );

    if (emotionScore == null || toneScore == null || layoutScore == null) {
      return null;
    }

    return VisualPersonaBridgeResult(
      emotionScore: emotionScore,
      toneScore: toneScore,
      layoutScore: layoutScore,
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

class VisualPersonaBridgeResult {
  VisualPersonaBridgeResult({
    required this.emotionScore,
    required this.toneScore,
    required this.layoutScore,
  });

  final double emotionScore;
  final double toneScore;
  final double layoutScore;

  double get personaIndex {
    final raw =
        (emotionScore * 0.4) + (toneScore * 0.35) + (layoutScore * 0.25);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
