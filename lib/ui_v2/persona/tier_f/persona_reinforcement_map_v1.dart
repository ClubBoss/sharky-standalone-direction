class PersonaReinforcementMapV1 {
  const PersonaReinforcementMapV1({
    this.personaMicroScoringMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.personaTablePersonaLiftMap = const <String, Object>{},
    this.talentSignalMap = const <String, Object>{},
    this.weaknessSignalMap = const <String, Object>{},
  });

  PersonaReinforcementMapV1.fromInputs({
    Map<String, Object?>? personaMicroScoringMap,
    Map<String, Object?>? personaMicroSegmentsMap,
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? personaTablePersonaLiftMap,
    Map<String, Object?>? talentSignalMap,
    Map<String, Object?>? weaknessSignalMap,
  }) : this(
         personaMicroScoringMap: _safe(personaMicroScoringMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         personaTablePersonaLiftMap: _safe(personaTablePersonaLiftMap),
         talentSignalMap: _safe(talentSignalMap),
         weaknessSignalMap: _safe(weaknessSignalMap),
       );

  final Map<String, Object> personaMicroScoringMap;
  final Map<String, Object> personaMicroSegmentsMap;
  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> personaTablePersonaLiftMap;
  final Map<String, Object> talentSignalMap;
  final Map<String, Object> weaknessSignalMap;

  Map<String, Object> build() {
    final double scoreC = _extractDouble(
      (personaMicroScoringMap['persona_micro_scoring_v1']
          as Map<String, Object?>?)?['score'],
    );
    final double diff = _extractDouble(
      (personaDifficultyBiasMap['persona_difficulty_bias_v1']
          as Map<String, Object?>?)?['difficulty'],
    );
    final double lift = _extractDouble(
      (personaTablePersonaLiftMap['persona_table_persona_lift_v1']
          as Map<String, Object?>?)?['intensity'],
    );
    final double talent = _extractDouble(
      (talentSignalMap['talent_signal_extractor_v1']
          as Map<String, Object?>?)?['talent_score'],
    );
    final double weak = _extractDouble(
      (weaknessSignalMap['persona_weakness_signal_v1']
          as Map<String, Object?>?)?['weakness_score'],
    );
    double reinforcementRaw =
        talent * 0.4 +
        scoreC * 0.2 +
        (1.0 - weak) * 0.2 +
        lift * 0.1 +
        (1.0 - diff) * 0.1;
    reinforcementRaw = reinforcementRaw.clamp(0.0, 1.0);
    final String seg =
        (personaMicroSegmentsMap['persona_micro_segments_v1']
                as Map<String, Object?>?)?['segment']
            as String? ??
        'neutral';
    final String tag = 'reinforce_${seg.toLowerCase()}';
    return <String, Object>{
      'persona_reinforcement_map_v1': <String, Object>{
        'reinforcement_score': reinforcementRaw,
        'reinforcement_tag': _ascii(tag),
        'ready': true,
      },
    };
  }

  static double _extractDouble(Object? raw) {
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
