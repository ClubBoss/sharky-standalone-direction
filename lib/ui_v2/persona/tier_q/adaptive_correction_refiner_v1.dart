class AdaptiveCorrectionRefinerV1 {
  const AdaptiveCorrectionRefinerV1({
    this.adaptiveCorrectionEngineMap = const <String, Object>{},
    this.reinforcementFeedbackEngineMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  AdaptiveCorrectionRefinerV1.fromInputs({
    Map<String, Object?>? adaptiveCorrectionEngineMap,
    Map<String, Object?>? reinforcementFeedbackEngineMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         adaptiveCorrectionEngineMap: _safe(adaptiveCorrectionEngineMap),
         reinforcementFeedbackEngineMap: _safe(reinforcementFeedbackEngineMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> adaptiveCorrectionEngineMap;
  final Map<String, Object> reinforcementFeedbackEngineMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> adaptiveBody =
        adaptiveCorrectionEngineMap['adaptive_correction_engine_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> feedbackBody =
        reinforcementFeedbackEngineMap['reinforcement_feedback_engine_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final double adaptiveStrength = _extractScore(
      adaptiveBody,
      'adaptive_strength',
    );
    final double feedbackValue = _extractScore(
      feedbackBody,
      'feedback_strength',
    );
    final double difficultyValue = _extractScore(difficultyBody, 'difficulty');

    String refinedTag = 'refine_balance';
    if (difficultyValue > 0.6) {
      refinedTag = 'refine_reduce';
    } else if (difficultyValue < 0.3) {
      refinedTag = 'refine_expand';
    }

    double refinedStrength =
        (adaptiveStrength * 0.6) +
        (feedbackValue * 0.2) +
        (difficultyValue * 0.2);
    refinedStrength = refinedStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'adaptive_correction_refiner_v1': <String, Object>{
        'refined_tag': _ascii(refinedTag),
        'refined_strength': refinedStrength,
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?> body, String key) {
    final Object? raw = body[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      cleaned[entry.key] = entry.value ?? '';
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
