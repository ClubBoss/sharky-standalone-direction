class PersonaGrowthProfileV1 {
  const PersonaGrowthProfileV1({
    this.personaMicroScoringMap = const <String, Object>{},
    this.personaMicroSegmentsMap = const <String, Object>{},
    this.personaDifficultyBiasMap = const <String, Object>{},
    this.personaTablePersonaLiftMap = const <String, Object>{},
    this.talentSignalMap = const <String, Object>{},
    this.personaWeaknessSignalMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaGrowthDirectionMap = const <String, Object>{},
  });

  PersonaGrowthProfileV1.fromInputs({
    Map<String, Object?>? personaMicroScoringMap,
    Map<String, Object?>? personaMicroSegmentsMap,
    Map<String, Object?>? personaDifficultyBiasMap,
    Map<String, Object?>? personaTablePersonaLiftMap,
    Map<String, Object?>? talentSignalMap,
    Map<String, Object?>? personaWeaknessSignalMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaGrowthDirectionMap,
  }) : this(
         personaMicroScoringMap: _safe(personaMicroScoringMap),
         personaMicroSegmentsMap: _safe(personaMicroSegmentsMap),
         personaDifficultyBiasMap: _safe(personaDifficultyBiasMap),
         personaTablePersonaLiftMap: _safe(personaTablePersonaLiftMap),
         talentSignalMap: _safe(talentSignalMap),
         personaWeaknessSignalMap: _safe(personaWeaknessSignalMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaGrowthDirectionMap: _safe(personaGrowthDirectionMap),
       );

  final Map<String, Object> personaMicroScoringMap;
  final Map<String, Object> personaMicroSegmentsMap;
  final Map<String, Object> personaDifficultyBiasMap;
  final Map<String, Object> personaTablePersonaLiftMap;
  final Map<String, Object> talentSignalMap;
  final Map<String, Object> personaWeaknessSignalMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaGrowthDirectionMap;

  Map<String, Object> build() {
    final double score = _extractDouble(
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
    final double weakness = _extractDouble(
      (personaWeaknessSignalMap['persona_weakness_signal_v1']
          as Map<String, Object?>?)?['weakness_score'],
    );
    final double reinforcement = _extractDouble(
      (personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?)?['reinforcement_score'],
    );
    final double growthDirection = _extractDouble(
      (personaGrowthDirectionMap['persona_growth_direction_v1']
          as Map<String, Object?>?)?['score'],
    );
    final double raw =
        (score * 0.15) +
        (diff * 0.15) +
        (lift * 0.10) +
        (talent * 0.20) +
        ((1.0 - weakness) * 0.10) +
        (reinforcement * 0.15) +
        (growthDirection * 0.15);
    final double profileScore = raw.clamp(0.0, 1.0);
    String profileTag = 'developing_recover';
    if (profileScore >= 0.80) {
      profileTag = 'developing_fast';
    } else if (profileScore >= 0.60) {
      profileTag = 'developing_stable';
    } else if (profileScore >= 0.40) {
      profileTag = 'developing_slow';
    }
    return <String, Object>{
      'persona_growth_profile_v1': <String, Object>{
        'profile_score': profileScore,
        'profile_tag': _ascii(profileTag),
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
