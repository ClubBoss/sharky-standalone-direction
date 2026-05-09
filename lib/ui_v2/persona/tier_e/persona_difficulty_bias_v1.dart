class PersonaDifficultyBiasV1 {
  const PersonaDifficultyBiasV1({
    this.personaLearningBookmarkMap = const <String, Object>{},
    this.personaMicroScoreMap = const <String, Object>{},
    this.personaBiasMap = const <String, Object>{},
  });

  PersonaDifficultyBiasV1.fromInputs({
    Map<String, Object?>? personaLearningBookmarkMap,
    Map<String, Object?>? personaMicroScoreMap,
    Map<String, Object?>? personaBiasMap,
  }) : this(
         personaLearningBookmarkMap: _safe(personaLearningBookmarkMap),
         personaMicroScoreMap: _safe(personaMicroScoreMap),
         personaBiasMap: _safe(personaBiasMap),
       );

  final Map<String, Object> personaLearningBookmarkMap;
  final Map<String, Object> personaMicroScoreMap;
  final Map<String, Object> personaBiasMap;

  Map<String, Object> build() {
    final String bookmark =
        (personaLearningBookmarkMap['persona_learning_bookmark_v1']
                as Map<String, Object?>?)?['bookmark']
            as String? ??
        'bookmark_neutral';
    final double score =
        (personaMicroScoreMap['persona_micro_scoring_v1']
                as Map<String, Object?>?)?['score']
            as double? ??
        _toDouble(
          (personaMicroScoreMap['persona_micro_scoring_v1']
              as Map<String, Object?>?)?['score'],
        );
    final String tone =
        (personaBiasMap['persona_bias_map_v1']
                as Map<String, Object?>?)?['bias_tone']
            as String? ??
        'neutral';
    double difficulty =
        (score * 0.6) +
        (tone == 'aggressive' ? 0.2 : 0.0) +
        (bookmark == 'bookmark_m' ? 0.1 : 0.0);
    difficulty = difficulty.clamp(0.0, 1.0);
    final String tag = 'bias_${bookmark}_$tone';
    return <String, Object>{
      'persona_difficulty_bias_v1': <String, Object>{
        'difficulty': difficulty,
        'tag': _ascii(tag),
        'ready': true,
      },
    };
  }

  static double _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      target[entry.key] = entry.value ?? '';
    }
    return target;
  }

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
