class VisualCohesionSummaryV1 {
  const VisualCohesionSummaryV1(
    this.visualCohesionGateMap,
    this.visualFullPassMap,
    this.visualSnapshotMap,
  );

  final Object visualCohesionGateMap;
  final Object visualFullPassMap;
  final Object visualSnapshotMap;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> gate =
        visualCohesionGateMap is Map &&
            (visualCohesionGateMap as Map)['visual_cohesion_gate_v1'] is Map
        ? m((visualCohesionGateMap as Map)['visual_cohesion_gate_v1'] as Map)
        : m(visualCohesionGateMap);
    final Map<String, Object> fullPass = m(visualFullPassMap);
    final Map<String, Object> snapshot = m(visualSnapshotMap);
    final List<String> missing = <String>[
      if (gate.isEmpty) 'visual_cohesion_gate_v1',
      if (fullPass.isEmpty) 'visual_full_pass_v1',
      if (snapshot.isEmpty) 'table_visual_snapshot_v1',
    ];
    final List<String> invalid = <String>[];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'visual_cohesion_summary_v1': <String, Object>{
        'summary': <String, Object>{
          'cohesion_gate': gate,
          'full_pass': fullPass,
          'snapshot': snapshot,
        },
        'summary_ready': ready,
        'missing': missing,
        'invalid': invalid,
      },
      'readiness': ready,
    };
  }
}
