class StabilitySnapshotV1 {
  const StabilitySnapshotV1(this.readinessAuditorMap, this.fullCompositeMap);

  final Object readinessAuditorMap;
  final Object fullCompositeMap;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> auditor =
        readinessAuditorMap is Map &&
            (readinessAuditorMap as Map)['readiness_propagation_auditor_v1']
                is Map
        ? m(
            (readinessAuditorMap as Map)['readiness_propagation_auditor_v1']
                as Map,
          )
        : m(readinessAuditorMap);
    final Map<String, Object> composite = fullCompositeMap is Map
        ? m(fullCompositeMap)
        : <String, Object>{};
    final Iterable<String> readyKeys = composite.keys.where(
      (key) => key.endsWith('_ready') || key.endsWith('_ready_flag'),
    );
    final bool compositeReady =
        readyKeys.isNotEmpty && readyKeys.every((k) => composite[k] == true);
    final List<Object> issues = auditor['issues'] is List
        ? List<Object>.from(auditor['issues'] as List)
        : <Object>[];
    final bool auditorReady = auditor['propagation_ok'] == true;
    final bool ready = compositeReady && auditorReady;
    final List<String> missing = <String>[
      if (auditor.isEmpty) 'readiness_propagation_auditor_v1',
      if (composite.isEmpty) 'full_composite_map',
      if (!ready) 'stability_snapshot_v1',
    ];
    return <String, Object>{
      'stability_snapshot_v1': <String, Object>{
        'auditor': auditor,
        'composite_ready': compositeReady,
        'auditor_ready': auditorReady,
        'issues': issues,
        'summary': composite,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
