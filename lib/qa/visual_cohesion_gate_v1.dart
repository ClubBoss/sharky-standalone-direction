class VisualCohesionGateV1 {
  const VisualCohesionGateV1(
    this.tokensMap,
    this.polishMap,
    this.depthMap,
    this.highlightsMap,
    this.compositionMap,
    this.renderSpecMap,
  );

  final Object tokensMap;
  final Object polishMap;
  final Object depthMap;
  final Object highlightsMap;
  final Object compositionMap;
  final Object renderSpecMap;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(String name, Object value) => <String, Object>{
      'exists': true,
      'is_map': value is Map,
      'non_empty': value is Map && value.isNotEmpty,
    };

    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{
          'tokens': check('tokens', tokensMap),
          'polish': check('polish', polishMap),
          'depth': check('depth', depthMap),
          'highlights': check('highlights', highlightsMap),
          'composition': check('composition', compositionMap),
          'render_spec': check('render_spec', renderSpecMap),
        };

    final List<String> missing = <String>[];
    final List<String> invalid = <String>[];
    sections.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists) {
        missing.add(key);
      }
      if (exists && (!isMap || !nonEmpty)) {
        invalid.add(key);
      }
    });

    final bool ready = missing.isEmpty && invalid.isEmpty;
    return <String, Object>{
      'visual_cohesion_gate_v1': <String, Object>{
        'sections': sections,
        'missing': missing,
        'invalid': invalid,
        'cohesion_ready': ready,
      },
      'readiness': ready,
    };
  }
}
