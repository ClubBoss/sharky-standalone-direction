import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _resonanceSummaryPath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _personaSummaryPath =
    '$_reportsDir/persona_reactions_summary.json';
const String _cognitiveSummaryPath =
    '$_reportsDir/cognitive_aesthetics_optimizer_summary.json';

class EmotionFeedbackReactorService {
  const EmotionFeedbackReactorService();

  Future<EmotionFeedbackReactorResult?> evaluate() async {
    final resonanceScore = await _readScore(
      _resonanceSummaryPath,
      keys: const ['average_resonance', 'ux_emotion_score'],
      percent: false,
    );
    final personaScore = await _readScore(
      _personaSummaryPath,
      keys: const [
        'persona_alignment',
        'persona_reaction_score',
        'emotion_score',
      ],
      percent: false,
    );
    final aestheticScore = await _readScore(
      _cognitiveSummaryPath,
      keys: const ['aesthetic_optimization_index', 'aesthetic_score'],
      percent: false,
    );

    if (resonanceScore == null ||
        personaScore == null ||
        aestheticScore == null) {
      return null;
    }

    return EmotionFeedbackReactorResult(
      resonanceScore: resonanceScore,
      personaScore: personaScore,
      aestheticScore: aestheticScore,
    );
  }

  Future<double?> _readScore(
    String path, {
    required List<String> keys,
    required bool percent,
  }) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final data = json.decode(await file.readAsString());
      if (data is! Map<String, Object?>) return null;
      for (final key in keys) {
        if (!data.containsKey(key)) continue;
        final value = _asDouble(data[key]);
        if (value == null) continue;
        final normalized = percent ? (value / 100) : value;
        return normalized.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }
}

class EmotionFeedbackReactorResult {
  EmotionFeedbackReactorResult({
    required this.resonanceScore,
    required this.personaScore,
    required this.aestheticScore,
  });

  final double resonanceScore;
  final double personaScore;
  final double aestheticScore;

  double get cohesionIndex {
    final raw =
        (resonanceScore * 0.4) +
        (personaScore * 0.35) +
        (aestheticScore * 0.25);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
