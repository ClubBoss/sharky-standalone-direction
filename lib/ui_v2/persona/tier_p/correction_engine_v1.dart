class CorrectionEngineV1 {
  const CorrectionEngineV1({
    this.reinforcementSyncSurfaceMap = const <String, Object>{},
    this.reinforcementFeedbackEngineMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  CorrectionEngineV1.fromInputs({
    Map<String, Object?>? reinforcementSyncSurfaceMap,
    Map<String, Object?>? reinforcementFeedbackEngineMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         reinforcementSyncSurfaceMap: _safe(reinforcementSyncSurfaceMap),
         reinforcementFeedbackEngineMap: _safe(reinforcementFeedbackEngineMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> reinforcementSyncSurfaceMap;
  final Map<String, Object> reinforcementFeedbackEngineMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> syncBody =
        reinforcementSyncSurfaceMap['reinforcement_sync_surface_v1']
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

    final String syncTag = (syncBody['sync_tag'] as String?)?.trim() ?? '';
    final double syncStrength = _extractScore(syncBody, 'sync_strength');
    final double feedbackStrength = _extractScore(
      feedbackBody,
      'feedback_strength',
    );
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String correctionTag = 'neutral';
    if (syncTag == 'upshift') {
      correctionTag = 'intensify';
    } else if (syncTag == 'align') {
      correctionTag = 'stabilize';
    } else if (syncTag == 'soften') {
      correctionTag = 'ease_off';
    }

    double correctionValue =
        (syncStrength * 0.6) +
        (feedbackStrength * 0.3) +
        (difficultyScore * 0.1);
    correctionValue = correctionValue.clamp(0.0, 1.0);

    return <String, Object>{
      'correction_engine_v1': <String, Object>{
        'correction_tag': _ascii(correctionTag),
        'correction_value': correctionValue,
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
