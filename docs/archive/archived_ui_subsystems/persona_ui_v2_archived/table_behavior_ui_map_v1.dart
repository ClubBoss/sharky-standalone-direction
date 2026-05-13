class TableBehaviorUIMapV1 {
  const TableBehaviorUIMapV1(this.behaviorFinalizerV1Map);

  final Object behaviorFinalizerV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> mapOrEmpty(Object source) =>
        source is Map && (source as Map).isNotEmpty
        ? source as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> finalizer = mapOrEmpty(behaviorFinalizerV1Map);
    final Map<String, Object> finalizerBody =
        finalizer['table_behavior_finalizer_v1'] is Map
        ? mapOrEmpty(finalizer['table_behavior_finalizer_v1'] as Map)
        : finalizer;
    final Map<String, Object> finalBehavior = mapOrEmpty(
      finalizerBody['final_behavior'] ?? <String, Object>{},
    );
    final bool finalReadyFlag = finalizerBody['final_ready'] == true;
    final bool uiReady = finalReadyFlag && finalBehavior.isNotEmpty;
    final List<String> missing = <String>[
      if (finalBehavior.isEmpty) 'table_behavior_finalizer_v1',
      if (!uiReady) 'table_behavior_ui_map_v1',
    ];
    return <String, Object>{
      'table_behavior_ui_map_v1': <String, Object>{
        'ui_behavior': finalBehavior,
        'ui_ready': uiReady,
      },
      'readiness': uiReady,
      'missing': missing,
    };
  }
}
