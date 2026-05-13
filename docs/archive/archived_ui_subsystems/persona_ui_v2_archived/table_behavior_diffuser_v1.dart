class TableBehaviorDiffuserV1 {
  const TableBehaviorDiffuserV1(this.behaviorUIMapV1Map);

  final Object behaviorUIMapV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> mapOrEmpty(Object source) =>
        source is Map && (source as Map).isNotEmpty
        ? source as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> uiMap = mapOrEmpty(behaviorUIMapV1Map);
    final Map<String, Object> uiBody = uiMap['table_behavior_ui_map_v1'] is Map
        ? mapOrEmpty(uiMap['table_behavior_ui_map_v1'] as Map)
        : uiMap;
    final Map<String, Object> uiBehavior = mapOrEmpty(
      uiBody['ui_behavior'] ?? <String, Object>{},
    );
    final bool uiReady = uiBody['ui_ready'] == true && uiBehavior.isNotEmpty;
    final Map<String, Object> diffusedBehavior = <String, Object>{
      'focus': uiBehavior,
      'tempo': uiBehavior,
      'accent': uiBehavior,
    };
    final List<String> missing = <String>[
      if (uiBehavior.isEmpty) 'table_behavior_ui_map_v1',
      if (!uiReady) 'table_behavior_diffuser_v1',
    ];
    return <String, Object>{
      'table_behavior_diffuser_v1': <String, Object>{
        'diffused_behavior': diffusedBehavior,
        'diffused_ready': uiReady,
      },
      'readiness': uiReady,
      'missing': missing,
    };
  }
}
