class PersonaWeaknessSignalV1 {
  const PersonaWeaknessSignalV1({
    this.personaMicroScoringMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.personaTablePersonaLiftMap = const <String, Object>{},
    this.talentSignalMap = const <String, Object>{},
  });

  PersonaWeaknessSignalV1.fromInputs({
    Map<String, Object?>? personaMicroScoringMap,
    Map<String, Object?>? personaMicroSegmentsMap,
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? personaTablePersonaLiftMap,
    Map<String, Object?>? talentSignalMap,
  }) : this(
         personaMicroScoringMap: _safe(personaMicroScoringMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         personaTablePersonaLiftMap: _safe(personaTablePersonaLiftMap),
         talentSignalMap: _safe(talentSignalMap),
       );

  final Map<String, Object> personaMicroScoringMap;
  final Map<String, Object> personaMicroSegmentsMap;
  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> personaTablePersonaLiftMap;
  final Map<String, Object> talentSignalMap;

  Map<String, Object> build() {
    final double scoreC =
        _extractScore(
          personaMicroScoringMap['persona_micro_scoring_v1']
              as Map<String, Object?>?,
        ) ??
        0.0;
    final double diff =
        _extractDifficulty(
          personaDifficultyBiasMap['persona_difficulty_bias_v1']
              as Map<String, Object?>?,
        ) ??
        0.0;
    final double lift =
        _extractIntensity(
          personaTablePersonaLiftMap['persona_table_persona_lift_v1']
              as Map<String, Object?>?,
        ) ??
        0.0;
    final double talent =
        _extractTalent(
          talentSignalMap['talent_signal_extractor_v1']
              as Map<String, Object?>?,
        ) ??
        0.0;
    double weaknessRaw =
        (1.0 - talent) * 0.5 +
        (1.0 - scoreC) * 0.2 +
        (diff > 0.5 ? diff * 0.2 : diff * 0.1) +
        (lift < 0.3 ? 0.2 : 0.0);
    weaknessRaw = weaknessRaw.clamp(0.0, 1.0);
    final String segment =
        (personaMicroSegmentsMap['persona_micro_segments_v1']
                as Map<String, Object?>?)?['segment']
            as String? ??
        'neutral';
    final String tag = 'weak_${segment.toLowerCase()}';
    return <String, Object>{
      'persona_weakness_signal_v1': <String, Object>{
        'weakness_score': weaknessRaw,
        'weakness_tag': _ascii(tag),
        'ready': true,
      },
    };
  }

  static double? _extractScore(Map<String, Object?>? body) {
    final Object? raw = body?['score'];
    return _toDouble(raw);
  }

  static double? _extractDifficulty(Map<String, Object?>? body) {
    final Object? raw = body?['difficulty'];
    return _toDouble(raw);
  }

  static double? _extractIntensity(Map<String, Object?>? body) {
    final Object? raw = body?['intensity'];
    return _toDouble(raw);
  }

  static double? _extractTalent(Map<String, Object?>? body) {
    final Object? raw = body?['talent_score'];
    return _toDouble(raw);
  }

  static double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return null;
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
