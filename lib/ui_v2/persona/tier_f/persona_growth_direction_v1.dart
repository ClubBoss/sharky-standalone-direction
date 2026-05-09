class PersonaGrowthDirectionV1 {
  const PersonaGrowthDirectionV1({
    this.personaReinforcementMap = const <String, Object>{},
    this.personaWeaknessSignalMap = const <String, Object>{},
    this.talentSignalMap = const <String, Object>{},
  });

  PersonaGrowthDirectionV1.fromInputs({
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaWeaknessSignalMap,
    Map<String, Object?>? talentSignalMap,
  }) : this(
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaWeaknessSignalMap: _safe(personaWeaknessSignalMap),
         talentSignalMap: _safe(talentSignalMap),
       );

  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaWeaknessSignalMap;
  final Map<String, Object> talentSignalMap;

  Map<String, Object> build() {
    final double reinforcementScore = _extractDouble(
      (personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?)?['reinforcement_score'],
    );
    final double weaknessScore = _extractDouble(
      (personaWeaknessSignalMap['persona_weakness_signal_v1']
          as Map<String, Object?>?)?['weakness_score'],
    );
    final double talentScore = _extractDouble(
      (talentSignalMap['talent_signal_extractor_v1']
          as Map<String, Object?>?)?['talent_score'],
    );
    double directionRaw =
        (reinforcementScore * 0.45) +
        (talentScore * 0.35) +
        ((1.0 - weaknessScore) * 0.20);
    directionRaw = directionRaw.clamp(0.0, 1.0);
    String direction = 'growth_recover';
    if (directionRaw >= 0.75) {
      direction = 'growth_fast';
    } else if (directionRaw >= 0.55) {
      direction = 'growth_normal';
    } else if (directionRaw >= 0.35) {
      direction = 'growth_slow';
    }
    return <String, Object>{
      'persona_growth_direction_v1': <String, Object>{
        'direction': _ascii(direction),
        'score': directionRaw,
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
