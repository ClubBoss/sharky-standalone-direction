class PersonaMetaRoutingV1 {
  const PersonaMetaRoutingV1({
    this.personaGrowthConsolidatedMap = const <String, Object>{},
    this.personaGrowthDirectionMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
    this.personaWeaknessSignalMap = const <String, Object>{},
  });

  PersonaMetaRoutingV1.fromInputs({
    Map<String, Object?>? personaGrowthConsolidatedMap,
    Map<String, Object?>? personaGrowthDirectionMap,
    Map<String, Object?>? personaReinforcementMap,
    Map<String, Object?>? personaWeaknessSignalMap,
  }) : this(
         personaGrowthConsolidatedMap: _safe(personaGrowthConsolidatedMap),
         personaGrowthDirectionMap: _safe(personaGrowthDirectionMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
         personaWeaknessSignalMap: _safe(personaWeaknessSignalMap),
       );

  final Map<String, Object> personaGrowthConsolidatedMap;
  final Map<String, Object> personaGrowthDirectionMap;
  final Map<String, Object> personaReinforcementMap;
  final Map<String, Object> personaWeaknessSignalMap;

  Map<String, Object> build() {
    final double masterScore = _extractScore(
      personaGrowthConsolidatedMap['persona_growth_consolidated_v1']
          as Map<String, Object?>?,
      'master_score',
    );
    final double weaknessScore = _extractScore(
      personaWeaknessSignalMap['persona_weakness_signal_v1']
          as Map<String, Object?>?,
      'weakness_score',
    );
    final double reinforcementScore = _extractScore(
      personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?,
      'reinforcement_score',
    );
    String route = 'review_mode';
    if (masterScore >= 0.85) {
      route = 'advance_mode';
    } else if (weaknessScore >= 0.6) {
      route = 'stabilize_mode';
    } else if (reinforcementScore >= 0.6) {
      route = 'momentum_mode';
    }
    return <String, Object>{
      'persona_meta_routing_v1': <String, Object>{
        'route': _ascii(route),
        'score': masterScore,
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?>? body, String key) {
    if (body == null) return 0.0;
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
