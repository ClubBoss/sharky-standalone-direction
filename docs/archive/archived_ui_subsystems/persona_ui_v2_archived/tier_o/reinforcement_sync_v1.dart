class ReinforcementSyncV1 {
  const ReinforcementSyncV1({
    this.personaReinforcementMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.contentPacingMap = const <String, Object>{},
  });

  ReinforcementSyncV1.fromInputs({
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? contentPacingMap,
  }) : this(
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         contentPacingMap: _safe(contentPacingMap),
       );

  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> contentPacingMap;

  Map<String, Object> build() {
    final Map<String, Object?> reinforcementBody =
        personaReinforcementMap['persona_reinforcement_map_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> difficultyBody =
        personaDifficultyBiasMap['persona_difficulty_bias_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> pacingBody =
        contentPacingMap['content_pacing_v1'] as Map<String, Object?>? ??
        <String, Object?>{};

    final double reinforcementScore = _extractScore(
      reinforcementBody,
      'reinforcement_score',
    );
    final String reinforcementTag =
        (reinforcementBody['reinforcement_tag'] as String?)?.trim() ?? '';
    final double difficultyScore = _extractScore(difficultyBody, 'difficulty');
    final String difficultyTag =
        (difficultyBody['tag'] as String?)?.trim() ?? '';
    final double paceValue = _extractScore(pacingBody, 'pace_value');

    String syncMode = 'neutral';
    if (reinforcementTag.contains('strong')) {
      syncMode = 'boost';
    } else if (reinforcementTag.contains('weak')) {
      syncMode = 'assist';
    } else if (difficultyTag.contains('hard')) {
      syncMode = 'ease';
    }

    double syncValue =
        (reinforcementScore * 0.5) +
        (paceValue * 0.3) +
        (difficultyScore * 0.2);
    syncValue = syncValue.clamp(0.0, 1.0);

    return <String, Object>{
      'reinforcement_sync_v1': <String, Object>{
        'sync_mode': _ascii(syncMode),
        'sync_value': syncValue,
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
