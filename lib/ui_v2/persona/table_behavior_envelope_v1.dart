class TableBehaviorEnvelopeV1 {
  const TableBehaviorEnvelopeV1(
    this.behaviorSpecV1Map,
    this.behaviorTraitsV1Map,
    this.behaviorModulationV1Map,
    this.behaviorSeedV1Map,
    this.tablePersonalityEnvelopeV1Map,
  );

  final Object behaviorSpecV1Map;
  final Object behaviorTraitsV1Map;
  final Object behaviorModulationV1Map;
  final Object behaviorSeedV1Map;
  final Object tablePersonalityEnvelopeV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> mapOrEmpty(Object source) =>
        source is Map && (source as Map).isNotEmpty
        ? source as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> spec = mapOrEmpty(behaviorSpecV1Map);
    final Map<String, Object> traits = mapOrEmpty(behaviorTraitsV1Map);
    final Map<String, Object> modulation = mapOrEmpty(behaviorModulationV1Map);
    final Map<String, Object> seed = mapOrEmpty(behaviorSeedV1Map);
    final Map<String, Object> persona = mapOrEmpty(
      tablePersonalityEnvelopeV1Map,
    );
    final List<String> missing = <String>[
      if (spec.isEmpty) 'table_behavior_spec_v1',
      if (traits.isEmpty) 'table_behavior_traits_v1',
      if (modulation.isEmpty) 'table_behavior_modulation_v1',
      if (seed.isEmpty) 'table_behavior_seed_v1',
      if (persona.isEmpty) 'table_personality_envelope_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'table_behavior_envelope_v1': <String, Object>{
        'spec': spec,
        'traits': traits,
        'modulation': modulation,
        'seed': seed,
        'persona_envelope': persona,
        'envelope_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
