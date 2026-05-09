class PersonaThemeAlignmentV1 {
  const PersonaThemeAlignmentV1(
    this.personaOutputMap,
    this.tableVisualSealV4Map,
    this.tableFinalVisualFusionV4Map,
    this.tableBehaviorTraitsV1Map,
    this.tablePersonaSyncSealV1Map,
  );

  final Object personaOutputMap;
  final Object tableVisualSealV4Map;
  final Object tableFinalVisualFusionV4Map;
  final Object tableBehaviorTraitsV1Map;
  final Object tablePersonaSyncSealV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> check(Object v) => <String, Object>{
      'exists': true,
      'is_map': v is Map,
      'non_empty': v is Map && v.isNotEmpty,
    };
    final Map<String, Map<String, Object>> domains =
        <String, Map<String, Object>>{
          'persona': check(personaOutputMap),
          'visual': check(tableVisualSealV4Map),
          'fusion': check(tableFinalVisualFusionV4Map),
          'behavior': check(tableBehaviorTraitsV1Map),
          'sync': check(tablePersonaSyncSealV1Map),
        };
    final List<String> missing = <String>[];
    domains.forEach((key, value) {
      final bool exists = value['exists'] == true;
      final bool isMap = value['is_map'] == true;
      final bool nonEmpty = value['non_empty'] == true;
      if (!exists || !isMap || !nonEmpty) missing.add(key);
    });
    final List<String> conflicts = <String>[];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'persona_theme_alignment_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'conflicts': conflicts,
        'alignment_ready': ready,
      },
      'readiness': ready,
    };
  }
}
