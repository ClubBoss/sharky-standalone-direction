class AdaptiveCorrectionConsolidatorV1 {
  const AdaptiveCorrectionConsolidatorV1({
    this.adaptiveCorrectionEngineMap = const <String, Object>{},
    this.adaptiveCorrectionRefinerMap = const <String, Object>{},
    this.reinforcementFeedbackEngineMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  AdaptiveCorrectionConsolidatorV1.fromInputs({
    Map<String, Object?>? adaptiveCorrectionEngineMap,
    Map<String, Object?>? adaptiveCorrectionRefinerMap,
    Map<String, Object?>? reinforcementFeedbackEngineMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         adaptiveCorrectionEngineMap: _safe(adaptiveCorrectionEngineMap),
         adaptiveCorrectionRefinerMap: _safe(adaptiveCorrectionRefinerMap),
         reinforcementFeedbackEngineMap: _safe(reinforcementFeedbackEngineMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> adaptiveCorrectionEngineMap;
  final Map<String, Object> adaptiveCorrectionRefinerMap;
  final Map<String, Object> reinforcementFeedbackEngineMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> engineBody =
        adaptiveCorrectionEngineMap['adaptive_correction_engine_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> refinerBody =
        adaptiveCorrectionRefinerMap['adaptive_correction_refiner_v1']
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

    final double engineStrength = _extractScore(
      engineBody,
      'adaptive_strength',
    );
    final double refinerStrength = _extractScore(
      refinerBody,
      'refined_strength',
    );
    final double feedbackStrength = _extractScore(
      feedbackBody,
      'feedback_strength',
    );
    final double difficultyStrength = _extractScore(
      difficultyBody,
      'difficulty',
    );

    final double consolidatedStrength =
        (engineStrength * 0.4) +
        (refinerStrength * 0.4) +
        (feedbackStrength * 0.1) +
        (difficultyStrength * 0.1);
    final double clampedStrength = consolidatedStrength.clamp(0.0, 1.0);

    String consolidatedTag = 'adaptive_low';
    if (refinerStrength >= 0.7) {
      consolidatedTag = 'adaptive_strong';
    } else if (refinerStrength >= 0.3) {
      consolidatedTag = 'adaptive_medium';
    }

    return <String, Object>{
      'adaptive_correction_consolidator_v1': <String, Object>{
        'consolidated_tag': _ascii(consolidatedTag),
        'consolidated_strength': clampedStrength,
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
