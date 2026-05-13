class PersonaMetaPersonaV1 {
  const PersonaMetaPersonaV1({
    this.personaMetaEnvelopeMap = const <String, Object>{},
    this.personaGrowthConsolidatedMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
  });

  PersonaMetaPersonaV1.fromInputs({
    Map<String, Object?>? personaMetaEnvelopeMap,
    Map<String, Object?>? personaGrowthConsolidatedMap,
    Map<String, Object?>? personaReinforcementMap,
  }) : this(
         personaMetaEnvelopeMap: _safe(personaMetaEnvelopeMap),
         personaGrowthConsolidatedMap: _safe(personaGrowthConsolidatedMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
       );

  final Map<String, Object> personaMetaEnvelopeMap;
  final Map<String, Object> personaGrowthConsolidatedMap;
  final Map<String, Object> personaReinforcementMap;

  Map<String, Object> build() {
    final double score = _extractScore(
      personaMetaEnvelopeMap['persona_meta_envelope_v1']
          as Map<String, Object?>?,
      'score',
    );
    final double reinforcementScore = _extractScore(
      personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?,
      'reinforcement_score',
    );
    final String? mode =
        (personaMetaEnvelopeMap['persona_meta_envelope_v1']
                as Map<String, Object?>?)?['mode']
            as String?;
    String personaTag = 'persona_review';
    if (mode == 'adaptive_advance') {
      personaTag = 'persona_advance';
    } else if (mode == 'adaptive_stabilize') {
      personaTag = 'persona_stabilize';
    } else if (reinforcementScore >= 0.7) {
      personaTag = 'persona_momentum';
    }
    return <String, Object>{
      'persona_meta_persona_v1': <String, Object>{
        'persona_tag': _ascii(personaTag),
        'score': score,
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
