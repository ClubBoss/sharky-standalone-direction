class PersonaMetaEnvelopeV1 {
  const PersonaMetaEnvelopeV1({
    this.personaMetaRoutingMap = const <String, Object>{},
    this.personaGrowthConsolidatedMap = const <String, Object>{},
    this.personaGrowthDirectionMap = const <String, Object>{},
    this.personaReinforcementMap = const <String, Object>{},
  });

  PersonaMetaEnvelopeV1.fromInputs({
    Map<String, Object?>? personaMetaRoutingMap,
    Map<String, Object?>? personaGrowthConsolidatedMap,
    Map<String, Object?>? personaGrowthDirectionMap,
    Map<String, Object?>? personaReinforcementMap,
  }) : this(
         personaMetaRoutingMap: _safe(personaMetaRoutingMap),
         personaGrowthConsolidatedMap: _safe(personaGrowthConsolidatedMap),
         personaGrowthDirectionMap: _safe(personaGrowthDirectionMap),
         personaReinforcementMap: _safe(personaReinforcementMap),
       );

  final Map<String, Object> personaMetaRoutingMap;
  final Map<String, Object> personaGrowthConsolidatedMap;
  final Map<String, Object> personaGrowthDirectionMap;
  final Map<String, Object> personaReinforcementMap;

  Map<String, Object> build() {
    final double score = _extractScore(
      personaMetaRoutingMap['persona_meta_routing_v1'] as Map<String, Object?>?,
      'score',
    );
    final double reinforcementScore = _extractScore(
      personaReinforcementMap['persona_reinforcement_map_v1']
          as Map<String, Object?>?,
      'reinforcement_score',
    );
    String mode = 'adaptive_review';
    final String? route =
        (personaMetaRoutingMap['persona_meta_routing_v1']
                as Map<String, Object?>?)?['route']
            as String?;
    if (route == 'advance_mode') {
      mode = 'adaptive_advance';
    } else if (route == 'stabilize_mode') {
      mode = 'adaptive_stabilize';
    } else if (reinforcementScore >= 0.65) {
      mode = 'adaptive_momentum';
    }
    return <String, Object>{
      'persona_meta_envelope_v1': <String, Object>{
        'mode': _ascii(mode),
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
