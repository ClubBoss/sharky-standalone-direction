class VisualIntegritySealV1 {
  const VisualIntegritySealV1(
    this.cohesionSummaryMap,
    this.cohesionGateMap,
    this.fullPassMap,
    this.visualSnapshotMap,
  );

  final Object cohesionSummaryMap;
  final Object cohesionGateMap;
  final Object fullPassMap;
  final Object visualSnapshotMap;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> summary =
        cohesionSummaryMap is Map &&
            (cohesionSummaryMap as Map)['visual_cohesion_summary_v1'] is Map
        ? m((cohesionSummaryMap as Map)['visual_cohesion_summary_v1'] as Map)
        : m(cohesionSummaryMap);
    final Map<String, Object> gate =
        cohesionGateMap is Map &&
            (cohesionGateMap as Map)['visual_cohesion_gate_v1'] is Map
        ? m((cohesionGateMap as Map)['visual_cohesion_gate_v1'] as Map)
        : m(cohesionGateMap);
    final Map<String, Object> fullPass = m(fullPassMap);
    final Map<String, Object> snapshot = m(visualSnapshotMap);
    final List<String> missing = <String>[
      if (summary.isEmpty) 'visual_cohesion_summary_v1',
      if (gate.isEmpty) 'visual_cohesion_gate_v1',
      if (fullPass.isEmpty) 'visual_full_pass_v1',
      if (snapshot.isEmpty) 'table_visual_snapshot_v1',
    ];
    final List<String> invalid = <String>[];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'visual_integrity_seal_v1': <String, Object>{
        'seal': <String, Object>{
          'summary': summary,
          'gate': gate,
          'full_pass': fullPass,
          'snapshot': snapshot,
        },
        'seal_ready': ready,
        'missing': missing,
        'invalid': invalid,
      },
      'readiness': ready,
    };
  }
}
