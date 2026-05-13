/// Passive Tier-B consistency auditor for AI personalization (Phi-10).
class AIPersonalizationTierBConsistencyV1 {
  const AIPersonalizationTierBConsistencyV1({
    required this.tierBAggregate,
    required this.tierBBridge,
    required this.tierAContext,
    required this.personaBundle,
    required this.visualIntegrity,
  });

  final Map<String, Object> tierBAggregate;
  final Map<String, Object> tierBBridge;
  final Map<String, Object> tierAContext;
  final Map<String, Object> personaBundle;
  final Map<String, Object> visualIntegrity;

  Map<String, Object> run() {
    final List<String> missingSections = <String>[];
    if (tierBAggregate.isEmpty) missingSections.add('tier_b_aggregate');
    if (tierBBridge.isEmpty) missingSections.add('tier_b_bridge');
    if (tierAContext.isEmpty) missingSections.add('tier_a_context');
    if (personaBundle.isEmpty) missingSections.add('persona_bundle');
    if (visualIntegrity.isEmpty) missingSections.add('visual_integrity');

    final List<String> emptyKeys = <String>[];
    void _checkEmpty(String prefix, Map<String, Object> map) {
      map.forEach((key, value) {
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          emptyKeys.add('$prefix:$key');
        }
      });
    }

    _checkEmpty('aggregate', tierBAggregate);
    _checkEmpty('bridge', tierBBridge);
    _checkEmpty('tier_a', tierAContext);
    _checkEmpty('persona', personaBundle);
    _checkEmpty('visual', visualIntegrity);

    final List<String> conflicts = <String>[];
    void _typeCheck(
      Map<String, Object> target,
      Map<String, Object> source,
      String label,
    ) {
      source.forEach((key, value) {
        if (target.containsKey(key)) {
          final Object existing = target[key] as Object;
          final bool bothScalar =
              existing is! Map &&
              existing is! Iterable &&
              value is! Map &&
              value is! Iterable;
          if (bothScalar && existing.runtimeType != value.runtimeType) {
            conflicts.add('type_mismatch:$label:$key');
          }
        }
        target[key] = value;
      });
    }

    final Map<String, Object> tierBConsistencyMap = <String, Object>{};
    _typeCheck(tierBConsistencyMap, tierBAggregate, 'aggregate');
    _typeCheck(tierBConsistencyMap, tierBBridge, 'bridge');
    _typeCheck(tierBConsistencyMap, tierAContext, 'tier_a');
    _typeCheck(tierBConsistencyMap, personaBundle, 'persona');
    _typeCheck(tierBConsistencyMap, visualIntegrity, 'visual');

    const List<String> expectedTierAKeys = <String>[
      'v_tokens',
      'v_theme',
      'v_surface',
      'v_activation',
      'v_binding',
    ];
    for (final String key in expectedTierAKeys) {
      if (!tierAContext.containsKey(key)) {
        conflicts.add('missing_tier_a:$key');
      }
    }
    if (personaBundle.isNotEmpty && !personaBundle.containsKey('traits')) {
      conflicts.add('persona_missing_traits');
    }

    final bool consistencyReady =
        missingSections.isEmpty && emptyKeys.isEmpty && conflicts.isEmpty;

    return <String, Object>{
      'missing_sections': missingSections,
      'empty_keys': emptyKeys,
      'conflicts': conflicts,
      'consistency_ready': consistencyReady,
      'tier_b_consistency_map': tierBConsistencyMap,
    };
  }
}
