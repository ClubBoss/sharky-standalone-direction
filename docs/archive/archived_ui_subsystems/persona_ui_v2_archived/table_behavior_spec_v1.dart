/// Passive table behavior spec V1 (Phi-75.3).
class TableBehaviorSpecV1 {
  const TableBehaviorSpecV1(this.tableBehaviorTraitsV1Map);

  final Object tableBehaviorTraitsV1Map;

  Map<String, Object> asReadOnlyMap() {
    final bool hasTraits =
        tableBehaviorTraitsV1Map is Map &&
        (tableBehaviorTraitsV1Map as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasTraits) missing.add('table_behavior_traits_v1');
    final Map<String, Object> traits = hasTraits
        ? (tableBehaviorTraitsV1Map as Map)['table_behavior_traits_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> spec = <String, Object>{
      'intensity_spec': traits['traits'] is Map
          ? (traits['traits'] as Map)['intensity'] ?? <Object>{}
          : <Object>{},
      'clarity_spec': traits['traits'] is Map
          ? (traits['traits'] as Map)['clarity'] ?? <Object>{}
          : <Object>{},
      'stability_spec': traits['traits'] is Map
          ? (traits['traits'] as Map)['stability'] ?? <Object>{}
          : <Object>{},
    };
    final bool specReady = missing.isEmpty;
    return <String, Object>{
      'table_behavior_spec_v1': <String, Object>{
        'spec': spec,
        'spec_ready': specReady,
        'missing': missing,
      },
      'ready': specReady,
    };
  }
}
