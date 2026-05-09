class BehaviorPersonaReflectionQAV1 {
  const BehaviorPersonaReflectionQAV1(
    this.behaviorSpecMap,
    this.behaviorTraitsMap,
    this.personaBlendMap,
    this.personaSyncSealMap,
    this.fusionPersonaMap,
  );

  final Object behaviorSpecMap;
  final Object behaviorTraitsMap;
  final Object personaBlendMap;
  final Object personaSyncSealMap;
  final Object fusionPersonaMap;

  Map<String, Object> asReadOnlyMap() {
    bool ok(Object source, String key) =>
        source is Map && source.isNotEmpty && source.containsKey(key);
    final bool specOk = ok(behaviorSpecMap, 'table_behavior_spec_v1');
    final bool traitsOk = ok(behaviorTraitsMap, 'table_behavior_traits_v1');
    final bool blendOk = ok(personaBlendMap, 'table_persona_blend_v1');
    final bool syncOk = ok(personaSyncSealMap, 'table_persona_sync_seal_v1');
    final bool fusionOk = ok(fusionPersonaMap, 'table_fusion_persona_v1');
    final List<String> missing = <String>[
      if (!specOk) 'behavior_spec',
      if (!traitsOk) 'behavior_traits',
      if (!blendOk) 'persona_blend',
      if (!syncOk) 'persona_sync',
      if (!fusionOk) 'fusion_persona',
    ];
    final List<String> invalid = <String>[];
    final bool ready = specOk && traitsOk && blendOk && syncOk && fusionOk;
    return <String, Object>{
      'behavior_persona_reflection_qa_v1': <String, Object>{
        'checks': <String, Object>{
          'behavior_spec_ok': specOk,
          'behavior_traits_ok': traitsOk,
          'persona_blend_ok': blendOk,
          'persona_sync_ok': syncOk,
          'fusion_persona_ok': fusionOk,
        },
        'missing': missing,
        'invalid': invalid,
        'reflection_ready': ready,
      },
      'readiness': ready,
    };
  }
}
