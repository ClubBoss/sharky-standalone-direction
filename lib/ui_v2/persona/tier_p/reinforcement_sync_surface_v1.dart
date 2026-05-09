class ReinforcementSyncSurfaceV1 {
  const ReinforcementSyncSurfaceV1({
    this.reinforcementFeedbackEngineMap = const <String, Object>{},
    this.contentPacingMap = const <String, Object>{},
    this.loadBalancerMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
  });

  ReinforcementSyncSurfaceV1.fromInputs({
    Map<String, Object?>? reinforcementFeedbackEngineMap,
    Map<String, Object?>? contentPacingMap,
    Map<String, Object?>? loadBalancerMap,
    Map<String, Object?>? personaDifficultyBiasMap,
  }) : this(
         reinforcementFeedbackEngineMap: _safe(reinforcementFeedbackEngineMap),
         contentPacingMap: _safe(contentPacingMap),
         loadBalancerMap: _safe(loadBalancerMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
       );

  final Map<String, Object> reinforcementFeedbackEngineMap;
  final Map<String, Object> contentPacingMap;
  final Map<String, Object> loadBalancerMap;
  final Map<String, Object> personaDifficultyBiasMap;

  Map<String, Object> build() {
    final Map<String, Object?> feedbackBody =
        reinforcementFeedbackEngineMap['reinforcement_feedback_engine_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> pacingBody =
        contentPacingMap['content_pacing_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> loadBody =
        loadBalancerMap['persona_load_balancer_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};

    final String feedbackTag =
        (feedbackBody['feedback_tag'] as String?)?.trim() ?? '';
    final double feedbackStrength = _extractScore(
      feedbackBody,
      'feedback_strength',
    );
    final double pacingValue = _extractScore(pacingBody, 'pace_value');
    final double loadValue = _extractScore(loadBody, 'load_value');
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');

    String syncTag = 'neutral';
    if (feedbackTag == 'push') {
      syncTag = 'upshift';
    } else if (feedbackTag == 'assist') {
      syncTag = 'align';
    } else if (feedbackTag == 'ease') {
      syncTag = 'soften';
    }

    double syncStrength =
        (feedbackStrength * 0.5) +
        (pacingValue * 0.25) +
        (loadValue * 0.15) +
        (difficultyScore * 0.10);
    syncStrength = syncStrength.clamp(0.0, 1.0);

    return <String, Object>{
      'reinforcement_sync_surface_v1': <String, Object>{
        'sync_tag': _ascii(syncTag),
        'sync_strength': syncStrength,
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
